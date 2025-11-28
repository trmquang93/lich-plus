import Foundation
import SwiftData
import Combine

/// Sync state enum for Microsoft Calendar
enum MicrosoftSyncState: String {
    case idle = "idle"
    case syncing = "syncing"
    case error = "error"
}

@MainActor
class MicrosoftCalendarSyncService: ObservableObject {
    @Published var syncState: MicrosoftSyncState = .idle
    @Published var lastSyncDate: Date?
    @Published var syncError: Error?

    private let authService: MicrosoftAuthService
    private let calendarService: MicrosoftCalendarService
    private let modelContext: ModelContext

    // Sync range: 30 days past to 365 days future
    private let syncRangePast: TimeInterval = -30 * 24 * 60 * 60
    private let syncRangeFuture: TimeInterval = 365 * 24 * 60 * 60

    // UserDefaults key for last sync date
    private let lastSyncDateKey = "MicrosoftCalendarLastSyncDate"

    init(authService: MicrosoftAuthService, calendarService: MicrosoftCalendarService, modelContext: ModelContext) {
        self.authService = authService
        self.calendarService = calendarService
        self.modelContext = modelContext

        // Load last sync date from UserDefaults
        self.lastSyncDate = UserDefaults.standard.object(forKey: lastSyncDateKey) as? Date
    }

    // MARK: - Public Methods

    /// Pull all events from enabled Microsoft calendars
    func pullRemoteChanges() async throws {
        guard authService.isSignedIn else {
            throw MicrosoftSyncError.notSignedIn
        }

        syncState = .syncing
        syncError = nil

        do {
            // Get enabled Microsoft calendars
            let enabledCalendars = try getEnabledMicrosoftCalendars()

            if enabledCalendars.isEmpty {
                // No calendars enabled - still a successful sync
                syncState = .idle
                updateLastSyncDate()
                return
            }

            // Calculate sync date range
            let now = Date()
            let startDate = now.addingTimeInterval(syncRangePast)
            let endDate = now.addingTimeInterval(syncRangeFuture)

            // Track all Microsoft event IDs we see in this sync
            var seenEventIds = Set<String>()

            for calendar in enabledCalendars {
                // Fetch events from Microsoft
                let microsoftEvents = try await calendarService.fetchEvents(
                    calendarId: calendar.calendarIdentifier,
                    from: startDate,
                    to: endDate
                )

                for microsoftEvent in microsoftEvents {
                    seenEventIds.insert(microsoftEvent.id)
                    try await processMicrosoftEvent(microsoftEvent, calendarId: calendar.calendarIdentifier)
                }
            }

            // Mark events as deleted if they no longer exist in Microsoft
            try markDeletedEvents(seenEventIds: seenEventIds, enabledCalendars: enabledCalendars)

            // Save changes
            try modelContext.save()

            // Update sync state
            syncState = .idle
            updateLastSyncDate()

        } catch {
            syncState = .error
            syncError = error
            throw error
        }
    }

    /// Fetch and save available Microsoft calendars to SyncedCalendar
    func refreshCalendarList() async throws -> [MicrosoftCalendar] {
        guard authService.isSignedIn else {
            throw MicrosoftSyncError.notSignedIn
        }

        let microsoftCalendars = try await calendarService.fetchCalendarList()

        for microsoftCalendar in microsoftCalendars {
            try saveOrUpdateCalendar(microsoftCalendar)
        }

        try modelContext.save()
        return microsoftCalendars
    }

    /// Get all Microsoft calendars from SyncedCalendar
    func getMicrosoftCalendars() throws -> [SyncedCalendar] {
        let descriptor = FetchDescriptor<SyncedCalendar>(
            predicate: #Predicate { $0.source == "microsoftExchange" }
        )
        return try modelContext.fetch(descriptor)
    }

    /// Get enabled Microsoft calendars
    func getEnabledMicrosoftCalendars() throws -> [SyncedCalendar] {
        let descriptor = FetchDescriptor<SyncedCalendar>(
            predicate: #Predicate { $0.source == "microsoftExchange" && $0.isEnabled == true }
        )
        return try modelContext.fetch(descriptor)
    }

    /// Delete all Microsoft Calendar data (events and calendars)
    func deleteAllMicrosoftData() throws {
        // Delete all Microsoft events
        let eventDescriptor = FetchDescriptor<SyncableEvent>(
            predicate: #Predicate { $0.source == "microsoftExchange" }
        )
        let microsoftEvents = try modelContext.fetch(eventDescriptor)
        for event in microsoftEvents {
            modelContext.delete(event)
        }

        // Delete all Microsoft calendars
        let calendarDescriptor = FetchDescriptor<SyncedCalendar>(
            predicate: #Predicate { $0.source == "microsoftExchange" }
        )
        let microsoftCalendars = try modelContext.fetch(calendarDescriptor)
        for calendar in microsoftCalendars {
            modelContext.delete(calendar)
        }

        try modelContext.save()

        // Clear last sync date
        UserDefaults.standard.removeObject(forKey: lastSyncDateKey)
        lastSyncDate = nil
    }

    // MARK: - Private Methods

    private func processMicrosoftEvent(_ microsoftEvent: MicrosoftEvent, calendarId: String) async throws {
        // Check if event already exists by fetching all events and filtering
        let descriptor = FetchDescriptor<SyncableEvent>(
            predicate: #Predicate { event in
                event.source == "microsoftExchange"
            }
        )
        let microsoftEvents = try modelContext.fetch(descriptor)

        // Find event with matching Microsoft event ID
        let existingEvent = microsoftEvents.first { event in
            event.microsoftEventId == microsoftEvent.id
        }

        if let existingEvent = existingEvent {
            // Update existing event if remote is newer
            if shouldUpdateEvent(existingEvent, with: microsoftEvent) {
                updateExistingEvent(existingEvent, from: microsoftEvent, calendarId: calendarId)
            }
        } else {
            // Create new event
            let newEvent = calendarService.convertToSyncableEvent(microsoftEvent, calendarId: calendarId)
            modelContext.insert(newEvent)
        }
    }

    private func shouldUpdateEvent(_ existing: SyncableEvent, with microsoftEvent: MicrosoftEvent) -> Bool {
        guard let modifiedString = microsoftEvent.lastModifiedDateTime else {
            return false
        }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        if let remoteDate = formatter.date(from: modifiedString) {
            return remoteDate > existing.lastModifiedLocal
        }

        // Try without fractional seconds
        formatter.formatOptions = [.withInternetDateTime]
        if let remoteDate = formatter.date(from: modifiedString) {
            return remoteDate > existing.lastModifiedLocal
        }

        return false
    }

    private func updateExistingEvent(_ event: SyncableEvent, from microsoftEvent: MicrosoftEvent, calendarId: String) {
        event.title = microsoftEvent.subject ?? "Untitled Event"
        event.startDate = microsoftEvent.start?.toDate() ?? Date()
        event.endDate = microsoftEvent.end?.toDate()
        event.isAllDay = microsoftEvent.isAllDay ?? false
        event.notes = microsoftEvent.bodyPreview

        // Build location string
        if let location = microsoftEvent.location {
            if let displayName = location.displayName, !displayName.isEmpty {
                event.location = displayName
            } else if let address = location.address {
                let parts = [address.street, address.city, address.state].compactMap { $0 }
                if !parts.isEmpty {
                    event.location = parts.joined(separator: ", ")
                }
            }
        }

        event.microsoftCalendarId = calendarId
        event.isDeleted = false
        event.syncStatus = SyncStatus.synced.rawValue

        // Update remote modification date
        if let modified = microsoftEvent.lastModifiedDateTime {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            event.lastModifiedRemote = formatter.date(from: modified)
        }
    }

    private func markDeletedEvents(seenEventIds: Set<String>, enabledCalendars: [SyncedCalendar]) throws {
        let calendarIds = enabledCalendars.map { $0.calendarIdentifier }

        // Fetch all Microsoft events from enabled calendars
        let descriptor = FetchDescriptor<SyncableEvent>(
            predicate: #Predicate { event in
                event.source == "microsoftExchange" && event.isDeleted == false
            }
        )
        let existingEvents = try modelContext.fetch(descriptor)

        for event in existingEvents {
            // Only mark as deleted if:
            // 1. The event is from an enabled calendar
            // 2. We didn't see it in the latest sync
            if let microsoftCalendarId = event.microsoftCalendarId,
               calendarIds.contains(microsoftCalendarId),
               let microsoftEventId = event.microsoftEventId,
               !seenEventIds.contains(microsoftEventId) {
                event.isDeleted = true
                event.syncStatus = SyncStatus.deleted.rawValue
            }
        }
    }

    private func saveOrUpdateCalendar(_ microsoftCalendar: MicrosoftCalendar) throws {
        // Check if calendar already exists
        let descriptor = FetchDescriptor<SyncedCalendar>()
        let allCalendars = try modelContext.fetch(descriptor)

        let existingCalendar = allCalendars.first { calendar in
            calendar.calendarIdentifier == microsoftCalendar.id
        }

        // Determine color
        let colorHex = microsoftCalendar.hexColor ?? MicrosoftCalendarColor.hexColor(for: microsoftCalendar.color)

        if let existingCalendar = existingCalendar {
            // Update existing calendar
            existingCalendar.title = microsoftCalendar.name
            existingCalendar.colorHex = colorHex
        } else {
            // Create new calendar (disabled by default, user can enable)
            let newCalendar = SyncedCalendar(
                calendarIdentifier: microsoftCalendar.id,
                title: microsoftCalendar.name,
                colorHex: colorHex,
                isEnabled: false,
                accountName: microsoftCalendar.owner?.address,
                lastSyncDate: nil,
                source: "microsoftExchange"
            )
            modelContext.insert(newCalendar)
        }
    }

    private func updateLastSyncDate() {
        lastSyncDate = Date()
        UserDefaults.standard.set(lastSyncDate, forKey: lastSyncDateKey)
    }
}

// MARK: - Errors

enum MicrosoftSyncError: LocalizedError {
    case notSignedIn
    case noEnabledCalendars
    case syncFailed(String)

    var errorDescription: String? {
        switch self {
        case .notSignedIn:
            return "Please sign in to Microsoft to sync calendars"
        case .noEnabledCalendars:
            return "No Microsoft calendars are enabled for sync"
        case .syncFailed(let message):
            return "Sync failed: \(message)"
        }
    }
}
