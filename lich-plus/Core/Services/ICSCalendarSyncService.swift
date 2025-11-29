//
//  ICSCalendarSyncService.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 30/11/25.
//

import Foundation
import SwiftData
import Combine

enum ICSCalendarSyncState: String {
    case idle = "idle"
    case syncing = "syncing"
    case error = "error"
}

enum ICSCalendarSyncError: LocalizedError {
    case invalidSubscription
    case syncFailed(String)
    case persistenceFailed(String)
    case invalidURL(String)

    var errorDescription: String? {
        switch self {
        case .invalidSubscription:
            return "Invalid subscription configuration"
        case .syncFailed(let message):
            return "Sync failed: \(message)"
        case .persistenceFailed(let message):
            return "Failed to save events: \(message)"
        case .invalidURL(let urlString):
            return "Invalid calendar URL: \(urlString)"
        }
    }
}

@MainActor
class ICSCalendarSyncService: ObservableObject {
    @Published var syncState: ICSCalendarSyncState = .idle
    @Published var lastSyncDate: Date?
    @Published var syncError: Error?
    @Published var subscriptions: [ICSSubscription] = []

    private let calendarService: ICSCalendarService
    private let modelContext: ModelContext

    private let lastSyncDateKey = "ICSCalendarLastSyncDate"

    init(
        modelContext: ModelContext,
        calendarService: ICSCalendarService? = nil
    ) {
        self.calendarService = calendarService ?? ICSCalendarService()
        self.modelContext = modelContext

        // Load last sync date from UserDefaults
        self.lastSyncDate = UserDefaults.standard.object(forKey: lastSyncDateKey) as? Date

        // Load subscriptions
        Task {
            await self.loadSubscriptions()
        }
    }

    // MARK: - Public Methods

    /// Add a new ICS calendar subscription
    func addSubscription(name: String, urlString: String) async throws {
        guard URL(string: urlString) != nil else {
            throw ICSCalendarSyncError.invalidURL(urlString)
        }

        guard urlString.lowercased().starts(with: "http://") || urlString.lowercased().starts(with: "https://") else {
            throw ICSCalendarSyncError.invalidURL(urlString)
        }

        let subscription = ICSSubscription(
            name: name,
            url: urlString
        )

        modelContext.insert(subscription)
        try modelContext.save()

        await loadSubscriptions()
    }

    /// Remove an ICS calendar subscription
    func removeSubscription(_ subscription: ICSSubscription) async throws {
        modelContext.delete(subscription)
        try modelContext.save()
        await loadSubscriptions()
    }

    /// Update subscription enable/disable status
    func updateSubscription(_ subscription: ICSSubscription, isEnabled: Bool) async throws {
        subscription.isEnabled = isEnabled
        try modelContext.save()
        await loadSubscriptions()
    }

    /// Pull remote changes from all enabled subscriptions
    func pullRemoteChanges() async throws {
        guard !subscriptions.isEmpty else {
            syncState = .idle
            updateLastSyncDate()
            return
        }

        syncState = .syncing
        syncError = nil

        do {
            let enabledSubscriptions = subscriptions.filter { $0.isEnabled }

            for subscription in enabledSubscriptions {
                try await syncSubscription(subscription)
            }

            syncState = .idle
            updateLastSyncDate()

        } catch {
            syncState = .error
            syncError = error
            throw error
        }
    }

    /// Get all subscriptions
    func getSubscriptions() throws -> [ICSSubscription] {
        return subscriptions
    }

    // MARK: - Private Methods

    private func syncSubscription(_ subscription: ICSSubscription) async throws {
        guard let url = URL(string: subscription.url) else {
            throw ICSCalendarSyncError.invalidURL(subscription.url)
        }

        // Fetch events from ICS
        let icsEvents = try await calendarService.fetchEvents(from: url)

        // Track ICS event UIDs for this subscription
        var seenEventUids = Set<String>()

        for icsEvent in icsEvents {
            seenEventUids.insert(icsEvent.uid)

            // Check if event already exists
            let existingEvent = findExistingEvent(icsEventUid: icsEvent.uid, subscriptionId: subscription.id.uuidString)

            let syncableEvent = calendarService.convertToSyncableEvent(
                icsEvent,
                subscriptionId: subscription.id.uuidString,
                subscriptionName: subscription.name,
                colorHex: subscription.colorHex
            )

            if let existing = existingEvent {
                // Update existing event
                updateExistingEvent(existing, with: syncableEvent)
            } else {
                // Insert new event
                modelContext.insert(syncableEvent)
            }
        }

        // Mark events as deleted if they no longer exist in the ICS
        try markDeletedICSEvents(subscriptionId: subscription.id.uuidString, seenUids: seenEventUids)

        // Save changes
        try modelContext.save()

        // Update subscription sync date
        subscription.updateLastSyncDate()
        try modelContext.save()
    }

    private func findExistingEvent(icsEventUid: String, subscriptionId: String) -> SyncableEvent? {
        let predicate = #Predicate<SyncableEvent> { event in
            event.icsEventUid == icsEventUid && event.icsSubscriptionId == subscriptionId
        }

        let descriptor = FetchDescriptor(predicate: predicate)
        return try? modelContext.fetch(descriptor).first
    }

    private func updateExistingEvent(_ existing: SyncableEvent, with new: SyncableEvent) {
        existing.title = new.title
        existing.startDate = new.startDate
        existing.endDate = new.endDate
        existing.isAllDay = new.isAllDay
        existing.notes = new.notes
        existing.location = new.location
        existing.lastModifiedRemote = new.lastModifiedRemote
        existing.lastModifiedLocal = Date()
    }

    private func markDeletedICSEvents(subscriptionId: String, seenUids: Set<String>) throws {
        let predicate = #Predicate<SyncableEvent> { event in
            event.icsSubscriptionId == subscriptionId && !event.isDeleted
        }

        let descriptor = FetchDescriptor(predicate: predicate)
        let allEvents = try modelContext.fetch(descriptor)

        for event in allEvents {
            if let uid = event.icsEventUid, !seenUids.contains(uid) {
                event.isDeleted = true
                event.lastModifiedLocal = Date()
            }
        }
    }

    private func loadSubscriptions() async {
        let descriptor = FetchDescriptor<ICSSubscription>(sortBy: [SortDescriptor(\.createdAt, order: .forward)])
        subscriptions = (try? modelContext.fetch(descriptor)) ?? []
    }

    private func updateLastSyncDate() {
        lastSyncDate = Date()
        UserDefaults.standard.set(lastSyncDate, forKey: lastSyncDateKey)
    }
}
