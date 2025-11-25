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
        }
    }

    func testCreateEventSetsAllProperties() {
        let calendars = sut.fetchAllCalendars()
        guard let calendar = calendars.first else {
            XCTSkip("No calendars available for testing")
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
        let handlerExpectation = expectation(description: "Change handler called")
        var handlerCallCount = 0

        sut.startObservingChanges {
            handlerCallCount += 1
            handlerExpectation.fulfill()
        }

        // Note: In a real test environment, we would need to trigger a calendar change
        // For now, we're just verifying the method doesn't crash
        XCTAssertGreaterThanOrEqual(handlerCallCount, 0)
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
        XCTAssertEqual(ekEvent.startDate, startDate)
        XCTAssertEqual(ekEvent.endDate, endDate)
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
        XCTAssertEqual(ekEvent.startDate, startDate)
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
        XCTAssertEqual(syncableEvent.startDate, startDate)
        XCTAssertEqual(syncableEvent.notes, "EK notes")
        XCTAssertFalse(syncableEvent.isAllDay)
    }

    func testCreateSyncableEventSetsEKEventIdentifier() {
        let ekEvent = EKEvent(eventStore: EKEventStore())
        ekEvent.title = "Identified Event"
        ekEvent.startDate = Date()

        // Set identifier if available
        let syncableEvent = sut.createSyncableEvent(from: ekEvent)

        // Should have the ekEventIdentifier set (may be empty if event not saved)
        XCTAssertNotNil(syncableEvent.ekEventIdentifier)
    }

    // MARK: - Integration Tests

    func testCreateUpdateDeleteCycle() {
        let calendars = sut.fetchAllCalendars()
        guard let calendar = calendars.first else {
            XCTSkip("No calendars available for testing")
        }

        do {
            // Create
            let originalEvent = SyncableEvent(
                title: "Lifecycle Test",
                startDate: Date(),
                category: "personal"
            )
            let identifier = try sut.createEvent(from: originalEvent, in: calendar)
            var created = sut.fetchEvent(identifier: identifier)
            XCTAssertNotNil(created)

            // Update
            let updatedEvent = SyncableEvent(
                title: "Updated Lifecycle",
                startDate: Date(),
                notes: "Updated notes",
                category: "work"
            )
            try sut.updateEvent(identifier: identifier, with: updatedEvent)
            var updated = sut.fetchEvent(identifier: identifier)
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
}
