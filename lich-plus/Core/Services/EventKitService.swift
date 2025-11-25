//
//  EventKitService.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 25/11/25.
//

import Foundation
import EventKit
import Combine

// MARK: - Error Types

enum EventKitServiceError: LocalizedError {
    case authorizationDenied
    case calendarNotFound
    case eventNotFound
    case failedToCreateEvent(String)
    case failedToUpdateEvent(String)
    case failedToDeleteEvent(String)
    case invalidDateRange
    case recurrenceError(String)

    var errorDescription: String? {
        switch self {
        case .authorizationDenied:
            return "Calendar access is denied"
        case .calendarNotFound:
            return "Calendar not found"
        case .eventNotFound:
            return "Event not found"
        case .failedToCreateEvent(let reason):
            return "Failed to create event: \(reason)"
        case .failedToUpdateEvent(let reason):
            return "Failed to update event: \(reason)"
        case .failedToDeleteEvent(let reason):
            return "Failed to delete event: \(reason)"
        case .invalidDateRange:
            return "Invalid date range"
        case .recurrenceError(let reason):
            return "Recurrence error: \(reason)"
        }
    }
}

// MARK: - EventKitService

/// Service for managing synchronization between local events and Apple Calendar
///
/// EventKitService provides a complete abstraction layer for EventKit operations,
/// handling:
/// - Calendar access and permissions
/// - Event CRUD operations
/// - Conversion between SyncableEvent and EKEvent
/// - Change observation and notifications
///
/// The service is designed to run on the main thread and can be used as an
/// observable object for SwiftUI integration.
///
/// Example usage:
/// ```swift
/// let service = EventKitService()
/// let hasAccess = await service.requestFullAccess()
/// let calendars = service.fetchAllCalendars()
/// let identifier = try service.createEvent(from: syncable, in: calendar)
/// ```
@MainActor
final class EventKitService: NSObject, ObservableObject {

    private let eventStore = EKEventStore()
    private var changeObserver: NSObjectProtocol?

    /// Current authorization status for calendar access
    @Published var authorizationStatus: EKAuthorizationStatus

    /// Array of available local and CalDAV calendars
    @Published var availableCalendars: [EKCalendar]

    override init() {
        let initialStatus = Self.getAuthorizationStatus()
        self.authorizationStatus = initialStatus
        self.availableCalendars = []

        super.init()

        // Fetch calendars after initialization is complete
        self.availableCalendars = fetchAllCalendars()
    }


    // MARK: - Authorization

    /// Request full access to calendar (iOS 17+)
    ///
    /// Presents a system dialog requesting full access to the user's calendars
    /// and automatically refreshes available calendars on successful authorization.
    ///
    /// - Returns: `true` if access was granted, `false` otherwise
    func requestFullAccess() async -> Bool {
        do {
            let granted = try await eventStore.requestFullAccessToEvents()
            await MainActor.run {
                self.authorizationStatus = Self.getAuthorizationStatus()
                self.availableCalendars = self.fetchAllCalendars()
            }
            return granted
        } catch {
            print("Error requesting calendar access: \(error)")
            return false
        }
    }

    /// Check current authorization status
    ///
    /// Returns the current status without requesting permissions.
    /// Use this to check if you need to call `requestFullAccess()`.
    ///
    /// - Returns: Current `EKAuthorizationStatus` value
    func checkAuthorizationStatus() -> EKAuthorizationStatus {
        Self.getAuthorizationStatus()
    }

    /// Get current authorization status from EventKit
    private static func getAuthorizationStatus() -> EKAuthorizationStatus {
        EKEventStore.authorizationStatus(for: .event)
    }

    // MARK: - Calendar Operations

    /// Fetch all user's calendars (event type only)
    ///
    /// Returns only local and CalDAV calendars, excluding reminder calendars
    /// and other non-event calendar types.
    ///
    /// - Returns: Array of available `EKCalendar` objects
    func fetchAllCalendars() -> [EKCalendar] {
        let calendars = eventStore.calendars(for: .event)
        return calendars.filter { $0.type == .local || $0.type == .calDAV }
    }

    /// Fetch specific calendar by identifier
    ///
    /// - Parameter identifier: The calendar's unique identifier
    /// - Returns: The `EKCalendar` if found, `nil` otherwise
    func fetchCalendar(identifier: String) -> EKCalendar? {
        eventStore.calendar(withIdentifier: identifier)
    }

    // MARK: - Event Fetch Operations

    /// Fetch events in date range from specific calendars
    ///
    /// Returns all events occurring between the specified start and end dates
    /// from the given calendars, sorted chronologically by start date.
    ///
    /// - Parameters:
    ///   - startDate: The beginning of the date range
    ///   - endDate: The end of the date range (must be >= startDate)
    ///   - calendars: Array of calendars to search in
    /// - Returns: Array of `EKEvent` objects sorted by start date
    func fetchEvents(from startDate: Date, to endDate: Date, calendars: [EKCalendar]) -> [EKEvent] {
        guard startDate <= endDate else {
            return []
        }

        guard !calendars.isEmpty else {
            return []
        }

        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)
        let events = eventStore.events(matching: predicate)

        return events.sorted { $0.startDate < $1.startDate }
    }

    /// Fetch single event by identifier
    ///
    /// - Parameter identifier: The event's unique identifier from EventKit
    /// - Returns: The `EKEvent` if found, `nil` otherwise
    func fetchEvent(identifier: String) -> EKEvent? {
        eventStore.event(withIdentifier: identifier)
    }

    // MARK: - Event Creation

    /// Create event in Apple Calendar
    ///
    /// Creates a new event from a SyncableEvent and saves it to the specified calendar.
    /// The event is immediately saved to Apple Calendar.
    ///
    /// - Parameters:
    ///   - syncable: The `SyncableEvent` to create
    ///   - calendar: The `EKCalendar` to add the event to
    /// - Returns: The newly created event's unique identifier
    /// - Throws: `EventKitServiceError.failedToCreateEvent` if the save fails
    func createEvent(from syncable: SyncableEvent, in calendar: EKCalendar) throws -> String {
        let ekEvent = EKEvent(eventStore: eventStore)
        ekEvent.calendar = calendar

        applyToEKEvent(ekEvent, from: syncable)

        do {
            try eventStore.save(ekEvent, span: .thisEvent)
            return ekEvent.eventIdentifier
        } catch {
            throw EventKitServiceError.failedToCreateEvent(error.localizedDescription)
        }
    }

    // MARK: - Event Update

    /// Update existing event
    ///
    /// Updates an existing event with new values from a SyncableEvent.
    /// Only applies to this event instance (not series).
    ///
    /// - Parameters:
    ///   - identifier: The unique identifier of the event to update
    ///   - syncable: The `SyncableEvent` containing new values
    /// - Throws:
    ///   - `EventKitServiceError.eventNotFound` if no event with the identifier exists
    ///   - `EventKitServiceError.failedToUpdateEvent` if the save fails
    func updateEvent(identifier: String, with syncable: SyncableEvent) throws {
        guard let ekEvent = eventStore.event(withIdentifier: identifier) else {
            throw EventKitServiceError.eventNotFound
        }

        applyToEKEvent(ekEvent, from: syncable)

        do {
            try eventStore.save(ekEvent, span: .thisEvent)
        } catch {
            throw EventKitServiceError.failedToUpdateEvent(error.localizedDescription)
        }
    }

    // MARK: - Event Deletion

    /// Delete event from Apple Calendar
    ///
    /// Permanently removes an event from Apple Calendar.
    /// Only deletes this event instance (not series).
    ///
    /// - Parameter identifier: The unique identifier of the event to delete
    /// - Throws:
    ///   - `EventKitServiceError.eventNotFound` if no event with the identifier exists
    ///   - `EventKitServiceError.failedToDeleteEvent` if the deletion fails
    func deleteEvent(identifier: String) throws {
        guard let ekEvent = eventStore.event(withIdentifier: identifier) else {
            throw EventKitServiceError.eventNotFound
        }

        do {
            try eventStore.remove(ekEvent, span: .thisEvent)
        } catch {
            throw EventKitServiceError.failedToDeleteEvent(error.localizedDescription)
        }
    }

    // MARK: - Change Observation

    /// Start observing calendar changes
    ///
    /// Registers a handler to be called whenever the calendar store changes.
    /// If a handler is already registered, it will be replaced.
    ///
    /// The handler is called on the main thread and is retained for the lifetime
    /// of this service or until `stopObservingChanges()` is called.
    ///
    /// - Parameter handler: Closure to invoke when calendar changes are detected
    func startObservingChanges(handler: @escaping () -> Void) {
        // Stop any existing observation first
        if changeObserver != nil {
            stopObservingChanges()
        }

        changeObserver = NotificationCenter.default.addObserver(
            forName: .EKEventStoreChanged,
            object: eventStore,
            queue: .main
        ) { [weak self] _ in
            handler()
        }
    }

    /// Stop observing calendar changes
    ///
    /// Unregisters the change observer and prevents any further notifications.
    /// Safe to call even if no observer is registered.
    func stopObservingChanges() {
        if let observer = changeObserver {
            NotificationCenter.default.removeObserver(observer)
            changeObserver = nil
        }
    }

    // MARK: - Conversion Methods

    /// Apply SyncableEvent properties to an EKEvent
    ///
    /// Converts properties from a SyncableEvent to an EKEvent, handling
    /// complex types like recurrence rules and reminders.
    ///
    /// - Parameters:
    ///   - ekEvent: The `EKEvent` to update
    ///   - syncable: The `SyncableEvent` source data
    func applyToEKEvent(_ ekEvent: EKEvent, from syncable: SyncableEvent) {
        ekEvent.title = syncable.title
        ekEvent.startDate = syncable.startDate
        ekEvent.endDate = syncable.endDate ?? syncable.startDate
        ekEvent.isAllDay = syncable.isAllDay
        ekEvent.notes = syncable.notes

        // Apply recurrence rules if available
        if let recurrenceData = syncable.recurrenceRuleData {
            do {
                ekEvent.recurrenceRules = try NSKeyedUnarchiver.unarchivedObject(
                    ofClasses: [NSArray.self, EKRecurrenceRule.self],
                    from: recurrenceData
                ) as? [EKRecurrenceRule]
            } catch {
                print("Failed to decode recurrence rules: \(error)")
                ekEvent.recurrenceRules = nil
            }
        } else {
            ekEvent.recurrenceRules = nil
        }

        // Set reminder if specified, otherwise clear alarms
        if let reminderMinutes = syncable.reminderMinutes {
            let alarm = EKAlarm(relativeOffset: TimeInterval(-reminderMinutes * 60))
            ekEvent.alarms = [alarm]
        } else {
            ekEvent.alarms = []
        }
    }

    /// Create a SyncableEvent from an EKEvent
    ///
    /// Converts an EventKit event to a SyncableEvent, handling
    /// complex types and preserving the source identifier.
    ///
    /// - Parameter ekEvent: The `EKEvent` to convert
    /// - Returns: A new `SyncableEvent` with values from the EKEvent
    func createSyncableEvent(from ekEvent: EKEvent) -> SyncableEvent {
        var recurrenceRuleData: Data?

        if let recurrenceRules = ekEvent.recurrenceRules, !recurrenceRules.isEmpty {
            do {
                recurrenceRuleData = try NSKeyedArchiver.archivedData(
                    withRootObject: recurrenceRules,
                    requiringSecureCoding: true
                )
            } catch {
                print("Failed to encode recurrence rules: \(error)")
            }
        }

        // Extract reminder minutes from first alarm if available
        let reminderMinutes = ekEvent.alarms?.first.map { alarm in
            Int(abs(alarm.relativeOffset) / 60)
        }

        // Create the syncable event with Apple Calendar source
        let syncable = SyncableEvent(
            title: ekEvent.title ?? "Untitled",
            startDate: ekEvent.startDate,
            endDate: ekEvent.endDate,
            isAllDay: ekEvent.isAllDay,
            notes: ekEvent.notes,
            category: "other",
            reminderMinutes: reminderMinutes,
            recurrenceRuleData: recurrenceRuleData,
            source: EventSource.appleCalendar.rawValue
        )

        // Set the EventKit identifiers for later syncing
        syncable.ekEventIdentifier = ekEvent.eventIdentifier
        syncable.calendarIdentifier = ekEvent.calendar?.calendarIdentifier

        return syncable
    }
}
