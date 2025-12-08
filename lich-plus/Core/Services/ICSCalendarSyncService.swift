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

        // Delete all existing events for this subscription (full replace strategy)
        try deleteAllEventsForSubscription(subscriptionId: subscription.id.uuidString)

        // Expand each ICS event (handles both recurring and non-recurring)
        for icsEvent in icsEvents {
            // Determine default category based on subscription type
            let defaultCategory = subscription.isBuiltIn ? "holiday" : "other"

            // Expand recurring event (or get single event if not recurring)
            let syncableEvents = calendarService.expandRecurringEvent(
                icsEvent,
                subscriptionId: subscription.id.uuidString,
                subscriptionName: subscription.name,
                colorHex: subscription.colorHex,
                defaultCategory: defaultCategory
            )

            // Insert all occurrences
            for event in syncableEvents {
                modelContext.insert(event)
            }
        }

        // Save changes
        try modelContext.save()

        // Update subscription sync date
        subscription.updateLastSyncDate()
        try modelContext.save()
    }

    /// Delete all events for a subscription
    ///
    /// Used by the full replace sync strategy to remove all existing events
    /// before inserting fresh data from the ICS feed.
    ///
    /// - Parameter subscriptionId: The subscription ID
    private func deleteAllEventsForSubscription(subscriptionId: String) throws {
        let predicate = #Predicate<SyncableEvent> { event in
            event.icsSubscriptionId == subscriptionId
        }

        let descriptor = FetchDescriptor(predicate: predicate)
        let eventsToDelete = try modelContext.fetch(descriptor)

        for event in eventsToDelete {
            modelContext.delete(event)
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
