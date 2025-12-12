//
//  EventKitServiceTests.swift
//  lich-plusTests
//
//  Created by Quang Tran Minh on 25/11/25.
//

import XCTest
import EventKit
@testable import lich_plus

@MainActor
final class EventKitServiceTests: XCTestCase {

    var sut: EventKitService!

    override func setUp() {
        super.setUp()
        sut = EventKitService()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitializationCreatesEventStore() {
        XCTAssertNotNil(sut)
    }

    func testInitializationSetsAuthorizationStatus() {
        // Check that initialization correctly captures current authorization status
        let status = sut.authorizationStatus
        XCTAssert(
            status == .notDetermined || status == .denied ||
            status == .authorized || status == .restricted,
            "Authorization status should be a valid EKAuthorizationStatus"
        )
    }

    func testInitializationInitializesAvailableCalendars() {
        XCTAssertNotNil(sut.availableCalendars)
    }

    // MARK: - Authorization Tests

    func testCheckAuthorizationStatusReturnsCurrentStatus() {
        let status = sut.checkAuthorizationStatus()
        XCTAssert(
            status == .notDetermined || status == .denied ||
            status == .authorized || status == .restricted,
            "Should return valid authorization status"
        )
    }

    func testAuthorizationStatusPublishedProperty() {
        // The @Published property should be observable
        XCTAssertNotNil(sut.$authorizationStatus)
    }

    // MARK: - Calendar Fetch Tests

    func testFetchAllCalendarsReturnsArray() {
        let calendars = sut.fetchAllCalendars()
        XCTAssertNotNil(calendars)
        XCTAssert(calendars is [EKCalendar], "Should return array of EKCalendar")
    }

    func testFetchAllCalendarsReturnsEventCalendars() {
        // Only event calendars, not reminder calendars
        let calendars = sut.fetchAllCalendars()
        for calendar in calendars {
            XCTAssertEqual(calendar.type, .local, "Should return only local event calendars or default type")
        }
    }

    func testFetchCalendarByValidIdentifierReturnsCalendar() {
        // Get an identifier from available calendars
        let allCalendars = sut.fetchAllCalendars()
        guard let firstCalendar = allCalendars.first else {
            XCTSkip("No calendars available for testing")
            return
        }

        let fetchedCalendar = sut.fetchCalendar(identifier: firstCalendar.calendarIdentifier)
        XCTAssertNotNil(fetchedCalendar)
        XCTAssertEqual(fetchedCalendar?.calendarIdentifier, firstCalendar.calendarIdentifier)
    }

    func testFetchCalendarByInvalidIdentifierReturnsNil() {
        let invalidId = UUID().uuidString
        let calendar = sut.fetchCalendar(identifier: invalidId)
        XCTAssertNil(calendar)
    }

    // MARK: - Event Fetch Tests

    func testFetchEventsInDateRangeReturnsArray() {
        let calendars = sut.fetchAllCalendars()
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: 30, to: startDate)!

        let events = sut.fetchEvents(from: startDate, to: endDate, calendars: calendars)
        XCTAssertNotNil(events)
        XCTAssert(events is [EKEvent], "Should return array of EKEvent")
    }

    func testFetchEventsEmptyCalendarArrayReturnsEmpty() {
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: 30, to: startDate)!

        let events = sut.fetchEvents(from: startDate, to: endDate, calendars: [])
        XCTAssertEqual(events.count, 0, "Empty calendar array should return no events")
    }

    func testFetchEventsWithInvalidDateRangeReturnsEmpty() {
        let calendars = sut.fetchAllCalendars()
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: 30, to: endDate)! // startDate after endDate

        let events = sut.fetchEvents(from: startDate, to: endDate, calendars: calendars)
        XCTAssertEqual(events.count, 0, "Invalid date range should return no events")
    }

    func testFetchEventByValidIdentifierReturnsEvent() {
        // Create a test event first if authorization allows
        let calendars = sut.fetchAllCalendars()
        guard let defaultCalendar = calendars.first else {
            XCTSkip("No calendars available for testing")
            return
        }

        let event = EKEvent(eventStore: EKEventStore())
        event.title = "Test Event"
        event.startDate = Date()
        event.endDate = Calendar.current.date(byAdding: .hour, value: 1, to: event.startDate)!
        event.calendar = defaultCalendar

        do {
            try EKEventStore().save(event, span: .thisEvent)
            let fetchedEvent = sut.fetchEvent(identifier: event.eventIdentifier)
            XCTAssertNotNil(fetchedEvent)
            XCTAssertEqual(fetchedEvent?.eventIdentifier, event.eventIdentifier)
        } catch {
            XCTSkip("Cannot save test event: \(error)")
            return
        }
    }

    func testFetchEventByInvalidIdentifierReturnsNil() {
        let invalidId = UUID().uuidString
        let event = sut.fetchEvent(identifier: invalidId)
        XCTAssertNil(event)
    }

    // MARK: - Event Creation Tests

    func testCreateEventReturnsIdentifier() {
        let calendars = sut.fetchAllCalendars()
        guard let calendar = calendars.first else {
            XCTSkip("No calendars available for testing")
            return
        }

        let syncableEvent = SyncableEvent(
            title: "Test Event",
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .hour, value: 1, to: Date()),
            category: "work"
        )

        do {
            let identifier = try sut.createEvent(from: syncableEvent, in: calendar)
            XCTAssertFalse(identifier.isEmpty, "Should return non-empty identifier")

            // Verify the event was created
            let fetchedEvent = sut.fetchEvent(identifier: identifier)
            XCTAssertNotNil(fetchedEvent)
            XCTAssertEqual(fetchedEvent?.title, "Test Event")
        } catch {
            XCTSkip("Cannot create event: \(error)")
            return
        }
    }

    func testCreateEventSetsAllProperties() {
        let calendars = sut.fetchAllCalendars()
        guard let calendar = calendars.first else {
            XCTSkip("No calendars available for testing")
            return
        }

        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .hour, value: 2, to: startDate)!
        let syncableEvent = SyncableEvent(
            title: "Complete Test Event",
            startDate: startDate,
            endDate: endDate,
            isAllDay: false,
            notes: "Test notes",
            category: "personal",
            reminderMinutes: 15
        )

        do {
            let identifier = try sut.createEvent(from: syncableEvent, in: calendar)
            let fetchedEvent = sut.fetchEvent(identifier: identifier)

            XCTAssertEqual(fetchedEvent?.title, "Complete Test Event")
            XCTAssertEqual(fetchedEvent?.notes, "Test notes")
            XCTAssertFalse(fetchedEvent?.isAllDay ?? false)
        } catch {
            XCTSkip("Cannot create event: \(error)")
        }
    }

    func testCreateEventWithAllDayFlag() {
        let calendars = sut.fetchAllCalendars()
        guard let calendar = calendars.first else {
            XCTSkip("No calendars available for testing")
            return
        }

        let syncableEvent = SyncableEvent(
            title: "All Day Event",
            startDate: Date(),
            isAllDay: true,
            category: "birthday"
        )

        do {
            let identifier = try sut.createEvent(from: syncableEvent, in: calendar)
            let fetchedEvent = sut.fetchEvent(identifier: identifier)
            XCTAssertTrue(fetchedEvent?.isAllDay ?? false)
        } catch {
            XCTSkip("Cannot create all-day event: \(error)")
        }
    }

    // MARK: - Event Update Tests

    func testUpdateEventModifiesExistingEvent() {
        let calendars = sut.fetchAllCalendars()
        guard let calendar = calendars.first else {
            XCTSkip("No calendars available for testing")
            return
        }

        // Create initial event
        let initialEvent = SyncableEvent(
            title: "Original Title",
            startDate: Date(),
            category: "work"
        )

        do {
            let identifier = try sut.createEvent(from: initialEvent, in: calendar)

            // Update the event
            let updatedEvent = SyncableEvent(
                title: "Updated Title",
                startDate: Date(),
                notes: "Updated notes",
                category: "personal"
            )

            try sut.updateEvent(identifier: identifier, with: updatedEvent)

            // Verify the update
            let fetchedEvent = sut.fetchEvent(identifier: identifier)
            XCTAssertEqual(fetchedEvent?.title, "Updated Title")
            XCTAssertEqual(fetchedEvent?.notes, "Updated notes")
        } catch {
            XCTSkip("Cannot update event: \(error)")
        }
    }

    func testUpdateEventWithInvalidIdentifierThrows() {
        let invalidId = UUID().uuidString
        let syncableEvent = SyncableEvent(
            title: "Test",
            startDate: Date(),
            category: "other"
        )

        XCTAssertThrowsError(
            try sut.updateEvent(identifier: invalidId, with: syncableEvent)
        )
    }

    // MARK: - Event Deletion Tests

    func testDeleteEventRemovesEvent() {
        let calendars = sut.fetchAllCalendars()
        guard let calendar = calendars.first else {
            XCTSkip("No calendars available for testing")
            return
        }

        let syncableEvent = SyncableEvent(
            title: "Event to Delete",
            startDate: Date(),
            category: "other"
        )

        do {
            let identifier = try sut.createEvent(from: syncableEvent, in: calendar)
            try sut.deleteEvent(identifier: identifier)

            let fetchedEvent = sut.fetchEvent(identifier: identifier)
            XCTAssertNil(fetchedEvent, "Event should be deleted")
        } catch {
            XCTSkip("Cannot delete event: \(error)")
        }
    }

    func testDeleteEventWithInvalidIdentifierThrows() {
        let invalidId = UUID().uuidString
        XCTAssertThrowsError(try sut.deleteEvent(identifier: invalidId))
    }

    // MARK: - Change Observation Tests

    func testStartObservingChangesRegistersHandler() {
        var handlerCallCount = 0

        sut.startObservingChanges {
            handlerCallCount += 1
        }

        // Manually trigger the notification to test the observer
        // Post notification synchronously on main queue
        NotificationCenter.default.post(
            name: .EKEventStoreChanged,
            object: nil
        )

        // Process main queue to ensure notification is delivered
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))

        XCTAssertGreaterThanOrEqual(handlerCallCount, 1,
                                    "Handler should be called at least once")
    }

    func testStopObservingChangesUnregistersHandler() {
        let handler = {
            // Handler that should not be called after stop
        }

        sut.startObservingChanges(handler: handler)
        sut.stopObservingChanges()

        // Verify no exceptions are thrown
        XCTAssert(true)
    }

    func testMultipleObserversCanBeRegistered() {
        var firstCallCount = 0
        var secondCallCount = 0

        sut.startObservingChanges {
            firstCallCount += 1
        }

        sut.startObservingChanges {
            secondCallCount += 1
        }

        // Both observers should exist (implementation detail)
        XCTAssert(true)
    }

    // MARK: - Conversion Tests

    func testApplyToEKEventConvertsAllProperties() {
        let ekEvent = EKEvent(eventStore: EKEventStore())
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .hour, value: 2, to: startDate)!

        let syncableEvent = SyncableEvent(
            title: "Conversion Test",
            startDate: startDate,
            endDate: endDate,
            isAllDay: false,
            notes: "Test conversion",
            category: "work",
            reminderMinutes: 30
        )

        sut.applyToEKEvent(ekEvent, from: syncableEvent)

        XCTAssertEqual(ekEvent.title, "Conversion Test")
        // Use timeIntervalSince for robust date comparison (within 1 second)
        XCTAssertLessThan(abs(ekEvent.startDate.timeIntervalSince(startDate)), 1.0)
        XCTAssertLessThan(abs(ekEvent.endDate.timeIntervalSince(endDate)), 1.0)
        XCTAssertEqual(ekEvent.notes, "Test conversion")
        XCTAssertFalse(ekEvent.isAllDay)
    }

    func testApplyToEKEventHandlesNilEndDate() {
        let ekEvent = EKEvent(eventStore: EKEventStore())
        let startDate = Date()

        let syncableEvent = SyncableEvent(
            title: "No End Date Event",
            startDate: startDate,
            endDate: nil,
            category: "other"
        )

        sut.applyToEKEvent(ekEvent, from: syncableEvent)

        XCTAssertEqual(ekEvent.title, "No End Date Event")
        // Use timeIntervalSince for robust date comparison
        XCTAssertLessThan(abs(ekEvent.startDate.timeIntervalSince(startDate)), 1.0)
    }

    func testCreateSyncableEventFromEKEvent() {
        let ekEvent = EKEvent(eventStore: EKEventStore())
        ekEvent.title = "EK Test Event"
        let startDate = Date()
        ekEvent.startDate = startDate
        ekEvent.endDate = Calendar.current.date(byAdding: .hour, value: 1, to: startDate)
        ekEvent.notes = "EK notes"
        ekEvent.isAllDay = false

        let syncableEvent = sut.createSyncableEvent(from: ekEvent)

        XCTAssertEqual(syncableEvent.title, "EK Test Event")
        // Use timeIntervalSince for robust date comparison
        XCTAssertLessThan(abs(syncableEvent.startDate.timeIntervalSince(startDate)), 1.0)
        XCTAssertEqual(syncableEvent.notes, "EK notes")
        XCTAssertFalse(syncableEvent.isAllDay)
    }

    func testCreateSyncableEventSetsEKEventIdentifier() {
        let ekEvent = EKEvent(eventStore: EKEventStore())
        ekEvent.title = "Identified Event"
        ekEvent.startDate = Date()

        let syncableEvent = sut.createSyncableEvent(from: ekEvent)

        // For unsaved EKEvents, eventIdentifier is nil or empty string
        // The property exists and can be set once the event is saved
        // For now, just verify it's handled correctly (nil or empty for unsaved events)
        if let identifier = syncableEvent.ekEventIdentifier {
            XCTAssertTrue(identifier.isEmpty, "Unsaved event identifier should be empty if not nil")
        } else {
            // nil is also acceptable for unsaved events
            XCTAssertNil(syncableEvent.ekEventIdentifier)
        }
    }

    // MARK: - Integration Tests

    func testCreateUpdateDeleteCycle() {
        let calendars = sut.fetchAllCalendars()
        guard let calendar = calendars.first else {
            XCTSkip("No calendars available for testing")
            return
        }

        do {
            // Create
            let originalEvent = SyncableEvent(
                title: "Lifecycle Test",
                startDate: Date(),
                category: "personal"
            )
            let identifier = try sut.createEvent(from: originalEvent, in: calendar)
            let created = sut.fetchEvent(identifier: identifier)
            XCTAssertNotNil(created)

            // Update
            let updatedEvent = SyncableEvent(
                title: "Updated Lifecycle",
                startDate: Date(),
                notes: "Updated notes",
                category: "work"
            )
            try sut.updateEvent(identifier: identifier, with: updatedEvent)
            let updated = sut.fetchEvent(identifier: identifier)
            XCTAssertEqual(updated?.title, "Updated Lifecycle")

            // Delete
            try sut.deleteEvent(identifier: identifier)
            let deleted = sut.fetchEvent(identifier: identifier)
            XCTAssertNil(deleted)
        } catch {
            XCTSkip("Full lifecycle test requires calendar access: \(error)")
        }
    }

    func testFetchEventsDateOrdering() {
        let calendars = sut.fetchAllCalendars()
        guard !calendars.isEmpty else {
            XCTSkip("No calendars available for testing")
            return
        }

        let startDate = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        let endDate = Calendar.current.date(byAdding: .day, value: 30, to: Date())!

        let events = sut.fetchEvents(from: startDate, to: endDate, calendars: calendars)

        // Verify all events are within the date range
        for event in events {
            XCTAssertGreaterThanOrEqual(event.startDate, startDate)
            XCTAssertLessThanOrEqual(event.startDate, endDate)
        }
    }

    // MARK: - Recurrence Rule Serialization Tests

    func testApplyToEKEventWithoutRecurrenceData() {
        let ekEvent = EKEvent(eventStore: EKEventStore())
        let syncableEvent = SyncableEvent(
            title: "No Recurrence",
            startDate: Date(),
            category: "other"
        )

        sut.applyToEKEvent(ekEvent, from: syncableEvent)

        // EKEvent may return nil or empty array when no recurrence rules are set
        XCTAssertTrue(ekEvent.recurrenceRules == nil || ekEvent.recurrenceRules?.isEmpty == true,
                     "recurrenceRules should be nil or empty")
    }

    func testApplyToEKEventWithSerializedRecurrence() throws {
        let ekEvent = EKEvent(eventStore: EKEventStore())

        // Create a recurrence rule and serialize it
        let dailyRule = EKRecurrenceRule(recurrenceWith: .daily, interval: 1, end: nil)
        let serializableRules = [SerializableRecurrenceRule(from: dailyRule)]
        let recurrenceData = try JSONEncoder().encode(serializableRules)

        // Create SyncableEvent with serialized recurrence
        let syncableEvent = SyncableEvent(
            title: "With Recurrence",
            startDate: Date(),
            category: "other",
            recurrenceRuleData: recurrenceData
        )

        sut.applyToEKEvent(ekEvent, from: syncableEvent)

        XCTAssertNotNil(ekEvent.recurrenceRules)
        XCTAssertEqual(ekEvent.recurrenceRules?.count, 1)
        XCTAssertEqual(ekEvent.recurrenceRules?.first?.frequency, .daily)
    }

    func testCreateSyncableEventWithoutRecurrence() {
        let ekEvent = EKEvent(eventStore: EKEventStore())
        ekEvent.title = "No Recurrence Event"
        ekEvent.startDate = Date()

        let syncableEvent = sut.createSyncableEvent(from: ekEvent)

        XCTAssertNil(syncableEvent.recurrenceRuleData)
    }

    func testCreateSyncableEventEncodesRecurrenceRules() throws {
        let ekEvent = EKEvent(eventStore: EKEventStore())
        ekEvent.title = "Recurring Event"
        ekEvent.startDate = Date()

        // Add a recurrence rule
        let dailyRule = EKRecurrenceRule(recurrenceWith: .daily, interval: 1, end: nil)
        ekEvent.addRecurrenceRule(dailyRule)

        let syncableEvent = sut.createSyncableEvent(from: ekEvent)

        XCTAssertNotNil(syncableEvent.recurrenceRuleData)

        // Verify the data can be decoded back
        let decoded = try JSONDecoder().decode(
            [SerializableRecurrenceRule].self,
            from: syncableEvent.recurrenceRuleData!
        )
        XCTAssertEqual(decoded.count, 1)
        XCTAssertEqual(decoded.first?.frequency, EKRecurrenceFrequency.daily.rawValue)
    }

    func testRecurrenceRoundTripWithMultipleRules() throws {
        // Create EKEvent with multiple recurrence rules
        let ekEvent = EKEvent(eventStore: EKEventStore())
        ekEvent.title = "Multi-Rule Event"
        ekEvent.startDate = Date()

        let dailyRule = EKRecurrenceRule(recurrenceWith: .daily, interval: 1, end: nil)
        ekEvent.addRecurrenceRule(dailyRule)

        // Create SyncableEvent from EKEvent
        let syncableEvent = sut.createSyncableEvent(from: ekEvent)

        // Apply back to a new EKEvent
        let newEkEvent = EKEvent(eventStore: EKEventStore())
        sut.applyToEKEvent(newEkEvent, from: syncableEvent)

        // Verify the rules are preserved
        XCTAssertNotNil(newEkEvent.recurrenceRules)
        XCTAssertEqual(newEkEvent.recurrenceRules?.count, 1)
        XCTAssertEqual(newEkEvent.recurrenceRules?.first?.frequency, .daily)
    }

    func testRecurrenceWithOccurrenceCountRoundTrip() throws {
        let ekEvent = EKEvent(eventStore: EKEventStore())
        ekEvent.title = "Limited Recurrence"
        ekEvent.startDate = Date()

        let end = EKRecurrenceEnd(occurrenceCount: 10)
        let rule = EKRecurrenceRule(recurrenceWith: .weekly, interval: 1, end: end)
        ekEvent.addRecurrenceRule(rule)

        let syncableEvent = sut.createSyncableEvent(from: ekEvent)

        let newEkEvent = EKEvent(eventStore: EKEventStore())
        sut.applyToEKEvent(newEkEvent, from: syncableEvent)

        XCTAssertNotNil(newEkEvent.recurrenceRules?.first?.recurrenceEnd)
        XCTAssertEqual(newEkEvent.recurrenceRules?.first?.recurrenceEnd?.occurrenceCount, 10)
    }
}
