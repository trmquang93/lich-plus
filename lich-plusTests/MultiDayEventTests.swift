//
//  MultiDayEventTests.swift
//  lich-plusTests
//
//  Tests for multi-day all-day event support (Phase 3)
//

import XCTest
import SwiftData
@testable import lich_plus

@MainActor
final class MultiDayEventTests: XCTestCase {

    // MARK: - Setup

    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    var dataManager: CalendarDataManager!

    override func setUp() {
        super.setUp()
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try! ModelContainer(for: SyncableEvent.self, configurations: config)
        modelContext = ModelContext(modelContainer)

        dataManager = CalendarDataManager()
        dataManager.setModelContext(modelContext)
    }

    override func tearDown() {
        modelContext = nil
        modelContainer = nil
        dataManager = nil
        super.tearDown()
    }

    // MARK: - Test: Multi-Day Event Expansion in RecurringEventExpander

    func testMultiDayEventExpansion() {
        // Arrange: Create vacation Dec 20-25, 2025
        let calendar = Calendar.current
        let startDate = calendar.date(from: DateComponents(year: 2025, month: 12, day: 20))!
        let endDate = calendar.date(from: DateComponents(year: 2025, month: 12, day: 25, hour: 23, minute: 59, second: 59))!

        let event = SyncableEvent(
            title: "Vacation",
            startDate: startDate,
            endDate: endDate,
            isAllDay: true,
            category: "Holiday"
        )

        // Act: Expand for Dec 2025
        let rangeStart = calendar.date(from: DateComponents(year: 2025, month: 12, day: 1))!
        let rangeEnd = calendar.date(from: DateComponents(year: 2025, month: 12, day: 31))!

        let occurrences = RecurringEventExpander.generateOccurrences(
            for: event,
            rangeStart: rangeStart,
            rangeEnd: rangeEnd
        )

        // Assert: Should have 6 occurrences (Dec 20, 21, 22, 23, 24, 25)
        XCTAssertEqual(occurrences.count, 6, "Multi-day vacation should have 6 occurrences")

        // Verify each day
        for (index, occurrence) in occurrences.enumerated() {
            let expectedDay = 20 + index
            XCTAssertEqual(calendar.component(.day, from: occurrence.date), expectedDay)
            XCTAssertTrue(occurrence.isAllDay)
            XCTAssertEqual(occurrence.masterEventId, event.id)
        }
    }

    func testMultiDayEventDoesNotAppearOutsideRange() {
        // Arrange: Create vacation Dec 20-25, 2025
        let calendar = Calendar.current
        let startDate = calendar.date(from: DateComponents(year: 2025, month: 12, day: 20))!
        let endDate = calendar.date(from: DateComponents(year: 2025, month: 12, day: 25, hour: 23, minute: 59, second: 59))!

        let event = SyncableEvent(
            title: "Vacation",
            startDate: startDate,
            endDate: endDate,
            isAllDay: true,
            category: "Holiday"
        )

        // Act: Expand for Dec 2025
        let rangeStart = calendar.date(from: DateComponents(year: 2025, month: 12, day: 1))!
        let rangeEnd = calendar.date(from: DateComponents(year: 2025, month: 12, day: 31))!

        let occurrences = RecurringEventExpander.generateOccurrences(
            for: event,
            rangeStart: rangeStart,
            rangeEnd: rangeEnd
        )

        // Assert: Should NOT have Dec 19 or Dec 26
        let dates = occurrences.map { calendar.component(.day, from: $0.date) }
        XCTAssertFalse(dates.contains(19), "Multi-day event should not appear on Dec 19")
        XCTAssertFalse(dates.contains(26), "Multi-day event should not appear on Dec 26")
    }

    func testSingleDayAllDayEventNotExpanded() {
        // Arrange: Single-day all-day event
        let calendar = Calendar.current
        let startDate = calendar.date(from: DateComponents(year: 2025, month: 12, day: 20))!
        let endDate = calendar.date(from: DateComponents(year: 2025, month: 12, day: 20, hour: 23, minute: 59, second: 59))!

        let event = SyncableEvent(
            title: "Birthday",
            startDate: startDate,
            endDate: endDate,
            isAllDay: true,
            category: "Birthday"
        )

        // Act
        let rangeStart = calendar.date(from: DateComponents(year: 2025, month: 12, day: 1))!
        let rangeEnd = calendar.date(from: DateComponents(year: 2025, month: 12, day: 31))!

        let occurrences = RecurringEventExpander.generateOccurrences(
            for: event,
            rangeStart: rangeStart,
            rangeEnd: rangeEnd
        )

        // Assert: Should return exactly 1 item (not expanded)
        XCTAssertEqual(occurrences.count, 1, "Single-day event should return single occurrence")
    }

    func testMultiDayEventPartialRangeOverlap() {
        // Arrange: Vacation Dec 20-25, but only query Dec 23-31
        let calendar = Calendar.current
        let startDate = calendar.date(from: DateComponents(year: 2025, month: 12, day: 20))!
        let endDate = calendar.date(from: DateComponents(year: 2025, month: 12, day: 25, hour: 23, minute: 59, second: 59))!

        let event = SyncableEvent(
            title: "Vacation",
            startDate: startDate,
            endDate: endDate,
            isAllDay: true,
            category: "Holiday"
        )

        // Act: Only query Dec 23-31
        let rangeStart = calendar.date(from: DateComponents(year: 2025, month: 12, day: 23))!
        let rangeEnd = calendar.date(from: DateComponents(year: 2025, month: 12, day: 31))!

        let occurrences = RecurringEventExpander.generateOccurrences(
            for: event,
            rangeStart: rangeStart,
            rangeEnd: rangeEnd
        )

        // Assert: Should have 3 occurrences (Dec 23, 24, 25)
        XCTAssertEqual(occurrences.count, 3, "Partial range should return 3 occurrences")

        let days = occurrences.map { calendar.component(.day, from: $0.date) }
        XCTAssertEqual(days, [23, 24, 25])
    }

    // MARK: - Test: CalendarDataManager.fetchEvents() with Multi-Day Events

    func testCalendarDataManagerFetchesMultiDayEvents() throws {
        // Arrange: Create multi-day vacation Dec 20-25
        let calendar = Calendar.current
        let startDate = calendar.date(from: DateComponents(year: 2025, month: 12, day: 20))!
        let endDate = calendar.date(from: DateComponents(year: 2025, month: 12, day: 25, hour: 23, minute: 59, second: 59))!

        let vacation = SyncableEvent(
            title: "Vacation",
            startDate: startDate,
            endDate: endDate,
            isAllDay: true,
            category: "Holiday"
        )

        modelContext.insert(vacation)
        try modelContext.save()

        // Act: Fetch events for Dec 22 (middle of vacation)
        let queryDate = calendar.date(from: DateComponents(year: 2025, month: 12, day: 22))!
        let events = dataManager.fetchEvents(for: queryDate)

        // Assert: Should include vacation
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events[0].title, "Vacation")
        XCTAssertTrue(events[0].isAllDay)
    }

    func testCalendarDataManagerDoesNotFetchMultiDayOutsideRange() throws {
        // Arrange: Create multi-day vacation Dec 20-25
        let calendar = Calendar.current
        let startDate = calendar.date(from: DateComponents(year: 2025, month: 12, day: 20))!
        let endDate = calendar.date(from: DateComponents(year: 2025, month: 12, day: 25, hour: 23, minute: 59, second: 59))!

        let vacation = SyncableEvent(
            title: "Vacation",
            startDate: startDate,
            endDate: endDate,
            isAllDay: true,
            category: "Holiday"
        )

        modelContext.insert(vacation)
        try modelContext.save()

        // Act: Fetch events for Dec 19 (before vacation)
        let queryDate = calendar.date(from: DateComponents(year: 2025, month: 12, day: 19))!
        let events = dataManager.fetchEvents(for: queryDate)

        // Assert: Should NOT include vacation
        XCTAssertEqual(events.count, 0, "Multi-day event should not appear before start date")
    }

    func testCalendarDataManagerMultiDayEventAppearsBothFirstAndLastDay() throws {
        // Arrange: Create vacation Dec 20-25
        let calendar = Calendar.current
        let startDate = calendar.date(from: DateComponents(year: 2025, month: 12, day: 20))!
        let endDate = calendar.date(from: DateComponents(year: 2025, month: 12, day: 25, hour: 23, minute: 59, second: 59))!

        let vacation = SyncableEvent(
            title: "Vacation",
            startDate: startDate,
            endDate: endDate,
            isAllDay: true,
            category: "Holiday"
        )

        modelContext.insert(vacation)
        try modelContext.save()

        // Act & Assert: Check first day (Dec 20)
        let firstDay = calendar.date(from: DateComponents(year: 2025, month: 12, day: 20))!
        let eventsFirstDay = dataManager.fetchEvents(for: firstDay)
        XCTAssertEqual(eventsFirstDay.count, 1)

        // Act & Assert: Check last day (Dec 25)
        let lastDay = calendar.date(from: DateComponents(year: 2025, month: 12, day: 25))!
        let eventsLastDay = dataManager.fetchEvents(for: lastDay)
        XCTAssertEqual(eventsLastDay.count, 1)
    }

    // MARK: - Test: Event Sorting (All-Day First)

    func testAllDayEventsAppearBeforeTimedEvents() throws {
        // Arrange: Create both all-day and timed events for same day
        let calendar = Calendar.current
        let date = calendar.date(from: DateComponents(year: 2025, month: 12, day: 20))!

        // Create timed event at 2 PM
        let timedEventDate = calendar.date(bySettingHour: 14, minute: 0, second: 0, of: date)!
        let timedEvent = SyncableEvent(
            title: "Team Meeting",
            startDate: timedEventDate,
            endDate: timedEventDate,
            isAllDay: false,
            category: "Work"
        )

        // Create all-day event
        let allDayEvent = SyncableEvent(
            title: "Company Holiday",
            startDate: date,
            endDate: date,
            isAllDay: true,
            category: "Holiday"
        )

        modelContext.insert(timedEvent)
        modelContext.insert(allDayEvent)
        try modelContext.save()

        // Act
        let events = dataManager.fetchEvents(for: date)

        // Assert: All-day should come first
        XCTAssertEqual(events.count, 2)
        XCTAssertTrue(events[0].isAllDay, "First event should be all-day")
        XCTAssertFalse(events[1].isAllDay, "Second event should be timed")
    }

    func testTimedEventsAreSortedByTime() throws {
        // Arrange: Create multiple timed events
        let calendar = Calendar.current
        let date = calendar.date(from: DateComponents(year: 2025, month: 12, day: 20))!

        // Create 2 PM meeting
        let event2PM = SyncableEvent(
            title: "2 PM Meeting",
            startDate: calendar.date(bySettingHour: 14, minute: 0, second: 0, of: date)!,
            endDate: calendar.date(bySettingHour: 14, minute: 0, second: 0, of: date)!,
            isAllDay: false,
            category: "Work"
        )

        // Create 10 AM meeting
        let event10AM = SyncableEvent(
            title: "10 AM Meeting",
            startDate: calendar.date(bySettingHour: 10, minute: 0, second: 0, of: date)!,
            endDate: calendar.date(bySettingHour: 10, minute: 0, second: 0, of: date)!,
            isAllDay: false,
            category: "Work"
        )

        modelContext.insert(event2PM)
        modelContext.insert(event10AM)
        try modelContext.save()

        // Act
        let events = dataManager.fetchEvents(for: date)

        // Assert: Should be sorted by time
        XCTAssertEqual(events.count, 2)
        XCTAssertEqual(events[0].title, "10 AM Meeting")
        XCTAssertEqual(events[1].title, "2 PM Meeting")
    }

    // MARK: - Test: Multi-Day Event with Recurring Events

    func testMultiDayAndTimedEventsCoexist() throws {
        // Arrange: Create both multi-day and timed events for Dec 20
        let calendar = Calendar.current
        let date = calendar.date(from: DateComponents(year: 2025, month: 12, day: 20))!

        // Create timed (non-recurring) event at 10 AM
        let timedEvent = SyncableEvent(
            title: "Morning Meeting",
            startDate: calendar.date(bySettingHour: 10, minute: 0, second: 0, of: date)!,
            endDate: calendar.date(bySettingHour: 11, minute: 0, second: 0, of: date)!,
            isAllDay: false,
            category: "Work"
        )

        // Create multi-day vacation Dec 20-25
        let vacationStart = date
        let vacationEnd = calendar.date(from: DateComponents(year: 2025, month: 12, day: 25, hour: 23, minute: 59, second: 59))!
        let vacation = SyncableEvent(
            title: "Vacation",
            startDate: vacationStart,
            endDate: vacationEnd,
            isAllDay: true,
            category: "Holiday"
        )

        modelContext.insert(timedEvent)
        modelContext.insert(vacation)
        try modelContext.save()

        // Act
        let events = dataManager.fetchEvents(for: date)

        // Assert: Should have both events, all-day first
        XCTAssertEqual(events.count, 2)
        XCTAssertEqual(events[0].title, "Vacation")
        XCTAssertTrue(events[0].isAllDay)
        XCTAssertEqual(events[1].title, "Morning Meeting")
        XCTAssertFalse(events[1].isAllDay)
    }

    // MARK: - Test: Virtual ID Generation for Multi-Day Occurrences

    func testMultiDayEventOccurrencesHaveDeterministicVirtualIDs() {
        // Arrange
        let calendar = Calendar.current
        let startDate = calendar.date(from: DateComponents(year: 2025, month: 12, day: 20))!
        let endDate = calendar.date(from: DateComponents(year: 2025, month: 12, day: 22, hour: 23, minute: 59, second: 59))!

        let event = SyncableEvent(
            title: "Test Event",
            startDate: startDate,
            endDate: endDate,
            isAllDay: true,
            category: "Other"
        )

        // Act
        let rangeStart = calendar.date(from: DateComponents(year: 2025, month: 12, day: 1))!
        let rangeEnd = calendar.date(from: DateComponents(year: 2025, month: 12, day: 31))!

        let occurrences1 = RecurringEventExpander.generateOccurrences(
            for: event,
            rangeStart: rangeStart,
            rangeEnd: rangeEnd
        )

        let occurrences2 = RecurringEventExpander.generateOccurrences(
            for: event,
            rangeStart: rangeStart,
            rangeEnd: rangeEnd
        )

        // Assert: IDs should be deterministic (same expansion = same IDs)
        XCTAssertEqual(occurrences1.count, occurrences2.count)
        for (occ1, occ2) in zip(occurrences1, occurrences2) {
            XCTAssertEqual(occ1.id, occ2.id, "Virtual IDs should be deterministic")
        }
    }
}
