//
//  CalendarSyncService.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 25/11/25.
//

import Foundation
import SwiftData
import EventKit
import Combine

// MARK: - Sync Error Types

extension CalendarSyncService {
    enum SyncError: LocalizedError {
        case notAuthorized
        case noEnabledCalendars
        case pushFailed(String)
        case pullFailed(String)
        case conflictResolutionFailed(String)

        var errorDescription: String? {
            switch self {
            case .notAuthorized:
                return "Calendar access is not authorized"
            case .noEnabledCalendars:
                return "No enabled calendars available for sync"
            case .pushFailed(let reason):
                return "Failed to push changes to Apple Calendar: \(reason)"
            case .pullFailed(let reason):
                return "Failed to pull changes from Apple Calendar: \(reason)"
            case .conflictResolutionFailed(let reason):
                return "Conflict resolution failed: \(reason)"
            }
        }
    }

    enum SyncState: Equatable {
        case idle
        case syncing
        case error
    }
}

// MARK: - CalendarSyncService

/// Service for synchronizing events between SwiftData and Apple Calendar
///
/// Orchestrates two-way synchronization between the local SwiftData persistence
/// layer and Apple Calendar (EventKit). Handles pull (remote -> local), push (local -> remote),
/// and full bidirectional sync operations.
///
/// Example usage:
/// ```swift
/// let service = CalendarSyncService(eventKitService: eventKitService, modelContext: context)
/// try await service.performFullSync()
/// service.startObservingChanges {
///     Task { try await service.performFullSync() }
/// }
/// ```
@MainActor
final class CalendarSyncService: ObservableObject {

    private let eventKitService: EventKitService
    private let modelContext: ModelContext
    private var changeObserver: NSObjectProtocol?

    // Constants for sync range
    private let syncStartOffset: TimeInterval = -30 * 24 * 60 * 60 // 30 days ago
    private let syncEndOffset: TimeInterval = 365 * 24 * 60 * 60   // 1 year from now
    private let userDefaultsLastSyncKey = "CalendarSyncLastSyncDate"

    @Published var syncState: SyncState = .idle
    @Published var lastSyncDate: Date?
    @Published var syncError: SyncError?

    // MARK: - Initialization

    init(eventKitService: EventKitService, modelContext: ModelContext) {
        self.eventKitService = eventKitService
        self.modelContext = modelContext

        // Load lastSyncDate from UserDefaults
        if let savedDate = UserDefaults.standard.object(forKey: userDefaultsLastSyncKey) as? Date {
            self.lastSyncDate = savedDate
        }
    }

    // MARK: - Main Sync Methods

    /// Performs a full bidirectional sync between SwiftData and Apple Calendar
    ///
    /// This method orchestrates both pull and push operations:
    /// 1. Pulls new/updated events from Apple Calendar into SwiftData
    /// 2. Pushes pending local changes to Apple Calendar
    ///
    /// - Throws: `SyncError` if sync fails
    func performFullSync() async throws {
        await setSync(state: .syncing, error: nil)

        defer {
            DispatchQueue.main.async {
                self.syncState = .idle
            }
        }

        do {
            // Pull remote changes first
            try await pullRemoteChanges()

            // Push local changes second
            try await pushLocalChanges()

            // Update last sync date
            let now = Date()
            lastSyncDate = now
            UserDefaults.standard.set(now, forKey: userDefaultsLastSyncKey)

            // Update calendar sync dates
            let enabledCalendars = try getEnabledCalendars()
            for calendar in enabledCalendars {
                updateCalendarSyncDate(calendar.calendarIdentifier)
            }

            try modelContext.save()
        } catch {
            await setSync(state: .error, error: mapError(error))
            throw error
        }
    }

    /// Pulls remote changes from Apple Calendar into SwiftData
    ///
    /// Fetches events from all enabled calendars and:
    /// - Creates new SyncableEvent entries for events not in SwiftData
    /// - Updates existing events if remote is newer (last-write-wins)
    /// - Marks local events as deleted if they no longer exist remotely
    ///
    /// - Throws: `SyncError` if the operation fails
    func pullRemoteChanges() async throws {
        do {
            let enabledCalendars = try getEnabledCalendars()
            guard !enabledCalendars.isEmpty else {
                throw SyncError.noEnabledCalendars
            }

            // Calculate sync date range
            let now = Date()
            let startDate = now.addingTimeInterval(syncStartOffset)
            let endDate = now.addingTimeInterval(syncEndOffset)

            // Fetch events from Apple Calendar
            let remoteEvents = eventKitService.fetchEvents(
                from: startDate,
                to: endDate,
                calendars: enabledCalendars
            )

            // Process each remote event
            for ekEvent in remoteEvents {
                if let existing = findExistingEvent(ekEventIdentifier: ekEvent.eventIdentifier) {
                    // Event exists locally - check if remote is newer
                    let remoteModDate = ekEvent.lastModifiedDate ?? ekEvent.startDate ?? Date()
                    let existingModDate = existing.lastModifiedRemote ?? Date.distantPast
                    if remoteModDate > existingModDate {
                        // Remote is newer - update local
                        updateEventFromRemote(existing, ekEvent)
                    }
                    // else: local is newer, preserve local version
                } else {
                    // Event doesn't exist locally - create it
                    let syncableEvent = eventKitService.createSyncableEvent(from: ekEvent)
                    syncableEvent.syncStatus = SyncStatus.synced.rawValue
                    syncableEvent.lastModifiedRemote = ekEvent.lastModifiedDate ?? ekEvent.startDate
                    modelContext.insert(syncableEvent)
                }
            }

            // Find deleted events (exist locally but not in remote)
            let descriptor = FetchDescriptor<SyncableEvent>(
                predicate: #Predicate { $0.ekEventIdentifier != nil && !$0.isDeleted }
            )
            let localEvents = try modelContext.fetch(descriptor)

            let remoteIdentifiers = Set(remoteEvents.map { $0.eventIdentifier })
            for localEvent in localEvents {
                if let ekId = localEvent.ekEventIdentifier, !remoteIdentifiers.contains(ekId) {
                    // Event was deleted remotely
                    localEvent.isDeleted = true
                }
            }

            try modelContext.save()
        } catch let error as SyncError {
            throw error
        } catch {
            throw SyncError.pullFailed(error.localizedDescription)
        }
    }

    /// Pushes pending local changes to Apple Calendar
    ///
    /// Processes pending local changes:
    /// - Creates new events in Apple Calendar for pending events without ekEventIdentifier
    /// - Updates existing events in Apple Calendar
    /// - Deletes events from Apple Calendar that are marked as deleted
    ///
    /// - Throws: `SyncError` if push fails
    func pushLocalChanges() async throws {
        do {
            let enabledCalendars = try getEnabledCalendars()

            // Get enabled calendar for new events (prefer first enabled)
            guard let targetCalendar = enabledCalendars.first else {
                throw SyncError.noEnabledCalendars
            }

            // Query pending events (needs sync)
            let pendingDescriptor = FetchDescriptor<SyncableEvent>(
                predicate: #Predicate { $0.syncStatus == "pending" && !$0.isDeleted }
            )
            let pendingEvents = try modelContext.fetch(pendingDescriptor)

            // Push pending events
            for event in pendingEvents {
                do {
                    if event.ekEventIdentifier == nil {
                        // Create new event in Apple Calendar
                        let ekId = try eventKitService.createEvent(from: event, in: targetCalendar)
                        event.ekEventIdentifier = ekId
                        event.calendarIdentifier = targetCalendar.calendarIdentifier
                    } else {
                        // Update existing event
                        try eventKitService.updateEvent(identifier: event.ekEventIdentifier!, with: event)
                    }
                    event.setSyncStatus(.synced)
                    event.lastModifiedRemote = Date()
                } catch {
                    throw SyncError.pushFailed("Event '\(event.title)': \(error.localizedDescription)")
                }
            }

            // Query deleted events that need cleanup
            let deletedDescriptor = FetchDescriptor<SyncableEvent>(
                predicate: #Predicate { $0.isDeleted && $0.ekEventIdentifier != nil && $0.syncStatus != "deleted" }
            )
            let deletedEvents = try modelContext.fetch(deletedDescriptor)

            // Delete from Apple Calendar
            for event in deletedEvents {
                do {
                    if let ekId = event.ekEventIdentifier {
                        try eventKitService.deleteEvent(identifier: ekId)
                        event.setSyncStatus(.deleted)
                    }
                } catch {
                    throw SyncError.pushFailed("Failed to delete event '\(event.title)': \(error.localizedDescription)")
                }
            }

            try modelContext.save()
        } catch let error as SyncError {
            throw error
        } catch {
            throw SyncError.pushFailed(error.localizedDescription)
        }
    }

    /// Syncs a single event to Apple Calendar
    ///
    /// Creates or updates an event in Apple Calendar immediately.
    /// Useful for immediate sync after local changes.
    ///
    /// - Parameter event: The event to sync
    /// - Throws: `SyncError` if sync fails
    func syncEvent(_ event: SyncableEvent) async throws {
        do {
            let enabledCalendars = try getEnabledCalendars()
            guard let targetCalendar = enabledCalendars.first else {
                throw SyncError.noEnabledCalendars
            }

            if event.ekEventIdentifier == nil {
                // Create new event
                let ekId = try eventKitService.createEvent(from: event, in: targetCalendar)
                event.ekEventIdentifier = ekId
                event.calendarIdentifier = targetCalendar.calendarIdentifier
            } else {
                // Update existing event
                try eventKitService.updateEvent(identifier: event.ekEventIdentifier!, with: event)
            }

            event.setSyncStatus(.synced)
            event.lastModifiedRemote = Date()
            try modelContext.save()
        } catch let error as SyncError {
            throw error
        } catch {
            throw SyncError.pushFailed(error.localizedDescription)
        }
    }

    // MARK: - Change Observation

    /// Starts observing Apple Calendar changes
    ///
    /// Registers a notification observer for calendar store changes.
    /// When changes are detected, the provided handler will be called.
    ///
    /// - Parameter handler: Closure invoked when changes are detected
    func startObservingChanges(handler: @escaping () -> Void) {
        eventKitService.startObservingChanges {
            // Debounce rapid changes with a small delay
            handler()
        }
    }

    /// Stops observing Apple Calendar changes
    func stopObservingChanges() {
        eventKitService.stopObservingChanges()
    }

    // MARK: - Helper Methods

    /// Gets enabled calendars from SwiftData
    ///
    /// - Returns: Array of enabled EKCalendar objects
    /// - Throws: `SyncError` if fetch fails
    func getEnabledCalendars() throws -> [EKCalendar] {
        let descriptor = FetchDescriptor<SyncedCalendar>(
            predicate: #Predicate { $0.isEnabled }
        )
        let syncedCalendars = try modelContext.fetch(descriptor)

        let enabledCalendars = syncedCalendars.compactMap { syncedCal in
            eventKitService.fetchCalendar(identifier: syncedCal.calendarIdentifier)
        }

        return enabledCalendars
    }

    /// Finds an existing event by ekEventIdentifier
    ///
    /// - Parameter ekEventIdentifier: The EventKit event identifier
    /// - Returns: The SyncableEvent if found, nil otherwise
    func findExistingEvent(ekEventIdentifier: String) -> SyncableEvent? {
        let descriptor = FetchDescriptor<SyncableEvent>(
            predicate: #Predicate { $0.ekEventIdentifier == ekEventIdentifier }
        )

        do {
            let events = try modelContext.fetch(descriptor)
            return events.first
        } catch {
            print("Error finding existing event: \(error)")
            return nil
        }
    }

    /// Updates the last sync date for a calendar
    ///
    /// - Parameter calendarIdentifier: The calendar identifier to update
    func updateCalendarSyncDate(_ calendarIdentifier: String) {
        let descriptor = FetchDescriptor<SyncedCalendar>(
            predicate: #Predicate { $0.calendarIdentifier == calendarIdentifier }
        )

        do {
            let calendars = try modelContext.fetch(descriptor)
            if let calendar = calendars.first {
                calendar.updateLastSyncDate()
            }
        } catch {
            print("Error updating calendar sync date: \(error)")
        }
    }

    // MARK: - Private Helpers

    /// Updates a local event with data from a remote EKEvent
    private func updateEventFromRemote(_ local: SyncableEvent, _ remote: EKEvent) {
        local.title = remote.title ?? "Untitled"
        local.startDate = remote.startDate
        local.endDate = remote.endDate
        local.isAllDay = remote.isAllDay
        local.notes = remote.notes
        local.lastModifiedRemote = remote.lastModifiedDate ?? remote.startDate
    }

    /// Sets sync state and error atomically
    private nonisolated func setSync(state: SyncState, error: SyncError?) async {
        await MainActor.run {
            self.syncState = state
            self.syncError = error
        }
    }

    /// Maps generic errors to SyncError
    private func mapError(_ error: Error) -> SyncError {
        if let syncError = error as? SyncError {
            return syncError
        }
        return .pullFailed(error.localizedDescription)
    }
}
