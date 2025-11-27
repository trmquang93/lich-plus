import Foundation
import SwiftData
import Combine

/// Sync state enum matching existing CalendarSyncService pattern
enum GoogleSyncState: String {
    case idle = "idle"
    case syncing = "syncing"
    case error = "error"
}

@MainActor
class GoogleCalendarSyncService: ObservableObject {
    @Published var syncState: GoogleSyncState = .idle
    @Published var lastSyncDate: Date?
    @Published var syncError: Error?

    private let authService: GoogleAuthService
    private let calendarService: GoogleCalendarService
    private let modelContext: ModelContext

    // Sync range: 30 days past to 365 days future
    private let syncRangePast: TimeInterval = -30 * 24 * 60 * 60
    private let syncRangeFuture: TimeInterval = 365 * 24 * 60 * 60

    // UserDefaults key for last sync date
    private let lastSyncDateKey = "GoogleCalendarLastSyncDate"

    init(authService: GoogleAuthService, calendarService: GoogleCalendarService, modelContext: ModelContext) {
        self.authService = authService
        self.calendarService = calendarService
        self.modelContext = modelContext

        // Load last sync date from UserDefaults
        self.lastSyncDate = UserDefaults.standard.object(forKey: lastSyncDateKey) as? Date
    }

    // MARK: - Public Methods

    /// Pull all events from enabled Google calendars
    func pullRemoteChanges() async throws {
        guard authService.isSignedIn else {
            throw GoogleSyncError.notSignedIn
        }

        syncState = .syncing
        syncError = nil

        do {
            // Get enabled Google calendars
            let enabledCalendars = try getEnabledGoogleCalendars()

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

            // Track all Google event IDs we see in this sync
            var seenEventIds = Set<String>()

            for calendar in enabledCalendars {
                // Fetch events from Google
                let googleEvents = try await calendarService.fetchEvents(
                    calendarId: calendar.calendarIdentifier,
                    from: startDate,
                    to: endDate
                )

                for googleEvent in googleEvents {
                    seenEventIds.insert(googleEvent.id)
                    try await processGoogleEvent(googleEvent, calendarId: calendar.calendarIdentifier)
                }
            }

            // Mark events as deleted if they no longer exist in Google
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

    /// Fetch and save available Google calendars to SyncedCalendar
    func refreshCalendarList() async throws -> [GoogleCalendar] {
        guard authService.isSignedIn else {
            throw GoogleSyncError.notSignedIn
        }

        let googleCalendars = try await calendarService.fetchCalendarList()

        for googleCalendar in googleCalendars {
            try saveOrUpdateCalendar(googleCalendar)
        }

        try modelContext.save()
        return googleCalendars
    }

    /// Get all Google calendars from SyncedCalendar
    func getGoogleCalendars() throws -> [SyncedCalendar] {
        let descriptor = FetchDescriptor<SyncedCalendar>(
            predicate: #Predicate { $0.source == "googleCalendar" }
        )
        return try modelContext.fetch(descriptor)
    }

    /// Get enabled Google calendars
    func getEnabledGoogleCalendars() throws -> [SyncedCalendar] {
        let descriptor = FetchDescriptor<SyncedCalendar>(
            predicate: #Predicate { $0.source == "googleCalendar" && $0.isEnabled == true }
        )
        return try modelContext.fetch(descriptor)
    }

    /// Delete all Google Calendar data (events and calendars)
    func deleteAllGoogleData() throws {
        // Delete all Google events
        let eventDescriptor = FetchDescriptor<SyncableEvent>(
            predicate: #Predicate { $0.source == "googleCalendar" }
        )
        let googleEvents = try modelContext.fetch(eventDescriptor)
        for event in googleEvents {
            modelContext.delete(event)
        }

        // Delete all Google calendars
        let calendarDescriptor = FetchDescriptor<SyncedCalendar>(
            predicate: #Predicate { $0.source == "googleCalendar" }
        )
        let googleCalendars = try modelContext.fetch(calendarDescriptor)
        for calendar in googleCalendars {
            modelContext.delete(calendar)
        }

        try modelContext.save()

        // Clear last sync date
        UserDefaults.standard.removeObject(forKey: lastSyncDateKey)
        lastSyncDate = nil
    }

    // MARK: - Private Methods

    private func processGoogleEvent(_ googleEvent: GoogleEvent, calendarId: String) async throws {
        // Check if event already exists by fetching all events and filtering
        let descriptor = FetchDescriptor<SyncableEvent>(
            predicate: #Predicate { event in
                event.source == "googleCalendar"
            }
        )
        let googleEvents = try modelContext.fetch(descriptor)

        // Find event with matching Google event ID
        let existingEvent = googleEvents.first { event in
            event.googleEventId == googleEvent.id
        }

        if let existingEvent = existingEvent {
            // Update existing event if remote is newer
            if shouldUpdateEvent(existingEvent, with: googleEvent) {
                updateExistingEvent(existingEvent, from: googleEvent, calendarId: calendarId)
            }
        } else {
            // Create new event
            let newEvent = calendarService.convertToSyncableEvent(googleEvent, calendarId: calendarId)
            modelContext.insert(newEvent)
        }
    }

    private func shouldUpdateEvent(_ existing: SyncableEvent, with googleEvent: GoogleEvent) -> Bool {
        guard let updatedString = googleEvent.updated else {
            return false
        }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let remoteDate = formatter.date(from: updatedString) else {
            // Try without fractional seconds
            formatter.formatOptions = [.withInternetDateTime]
            guard let remoteDate = formatter.date(from: updatedString) else {
                return false
            }
            return remoteDate > existing.lastModifiedLocal
        }

        return remoteDate > existing.lastModifiedLocal
    }

    private func updateExistingEvent(_ event: SyncableEvent, from googleEvent: GoogleEvent, calendarId: String) {
        event.title = googleEvent.summary ?? "Untitled Event"
        event.startDate = googleEvent.start?.toDate() ?? Date()
        event.endDate = googleEvent.end?.toDate()
        event.isAllDay = googleEvent.start?.isAllDay ?? false
        event.notes = googleEvent.description
        event.location = googleEvent.location
        event.googleCalendarId = calendarId
        event.isDeleted = false
        event.syncStatus = SyncStatus.synced.rawValue

        // Update remote modification date
        if let updated = googleEvent.updated {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            event.lastModifiedRemote = formatter.date(from: updated)
        }
    }

    private func markDeletedEvents(seenEventIds: Set<String>, enabledCalendars: [SyncedCalendar]) throws {
        let calendarIds = enabledCalendars.map { $0.calendarIdentifier }

        // Fetch all Google events from enabled calendars
        let descriptor = FetchDescriptor<SyncableEvent>(
            predicate: #Predicate { event in
                event.source == "googleCalendar" && event.isDeleted == false
            }
        )
        let existingEvents = try modelContext.fetch(descriptor)

        for event in existingEvents {
            // Only mark as deleted if:
            // 1. The event is from an enabled calendar
            // 2. We didn't see it in the latest sync
            if let googleCalendarId = event.googleCalendarId,
               calendarIds.contains(googleCalendarId),
               let googleEventId = event.googleEventId,
               !seenEventIds.contains(googleEventId) {
                event.isDeleted = true
                event.syncStatus = SyncStatus.deleted.rawValue
            }
        }
    }

    private func saveOrUpdateCalendar(_ googleCalendar: GoogleCalendar) throws {
        // Check if calendar already exists
        let descriptor = FetchDescriptor<SyncedCalendar>()
        let allCalendars = try modelContext.fetch(descriptor)

        let existingCalendar = allCalendars.first { calendar in
            calendar.calendarIdentifier == googleCalendar.id
        }

        if let existingCalendar = existingCalendar {
            // Update existing calendar
            existingCalendar.title = googleCalendar.summary
            existingCalendar.colorHex = googleCalendar.backgroundColor ?? "#4285F4"
        } else {
            // Create new calendar (disabled by default, user can enable)
            let newCalendar = SyncedCalendar(
                calendarIdentifier: googleCalendar.id,
                title: googleCalendar.summary,
                colorHex: googleCalendar.backgroundColor ?? "#4285F4",
                isEnabled: false,
                accountName: nil,
                lastSyncDate: nil,
                source: "googleCalendar"
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

enum GoogleSyncError: LocalizedError {
    case notSignedIn
    case noEnabledCalendars
    case syncFailed(String)

    var errorDescription: String? {
        switch self {
        case .notSignedIn:
            return "Please sign in to Google to sync calendars"
        case .noEnabledCalendars:
            return "No Google calendars are enabled for sync"
        case .syncFailed(let message):
            return "Sync failed: \(message)"
        }
    }
}
