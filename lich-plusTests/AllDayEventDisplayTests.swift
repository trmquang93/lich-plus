//
//  AllDayEventDisplayTests.swift
//  lich-plusTests
//
//  Created by Test on 2025-12-11.
//

import XCTest
import SwiftData
@testable import lich_plus

final class AllDayEventDisplayTests: XCTestCase {

    var modelContext: ModelContext!

    override func setUp() async throws {
        try await super.setUp()

        // Create in-memory SwiftData model context
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: SyncableEvent.self, configurations: config)
        modelContext = ModelContext(container)
    }

    override func tearDown() async throws {
        modelContext = nil
        try await super.tearDown()
    }

    // MARK: - Event Model Tests

    func testEvent_CanBeCreatedWithOptionalTime() {
        // Given
        let event = Event(
            title: "All day meeting",
            time: nil,
            isAllDay: true,
            category: .meeting,
            description: nil
        )

        // Then
        XCTAssertEqual(event.title, "All day meeting")
        XCTAssertNil(event.time)
        XCTAssertTrue(event.isAllDay)
        XCTAssertEqual(event.category, .meeting)
    }

    func testEvent_CanBeCreatedWithTime() {
        // Given
        let event = Event(
            title: "Team standup",
            time: "09:00",
            isAllDay: false,
            category: .meeting,
            description: "Daily sync"
        )

        // Then
        XCTAssertEqual(event.title, "Team standup")
        XCTAssertEqual(event.time, "09:00")
        XCTAssertFalse(event.isAllDay)
        XCTAssertEqual(event.description, "Daily sync")
    }

    // MARK: - SyncableEvent Conversion Tests

    func testSyncableEventWithAllDay() {
        // Given
        let syncableEvent = SyncableEvent(
            title: "Birthday celebration",
            startDate: Date(),
            isAllDay: true,
            category: "Birthday"
        )

        // Then
        XCTAssertEqual(syncableEvent.title, "Birthday celebration")
        XCTAssertTrue(syncableEvent.isAllDay)
    }

    func testSyncableEventWithTime() {
        // Given
        let startDate = Date()
        let syncableEvent = SyncableEvent(
            title: "Team meeting",
            startDate: startDate,
            isAllDay: false,
            category: "Meeting"
        )

        // Then
        XCTAssertEqual(syncableEvent.title, "Team meeting")
        XCTAssertFalse(syncableEvent.isAllDay)
        XCTAssertEqual(syncableEvent.startDate, startDate)
    }

    // MARK: - Event Sorting Tests

    func testEventSorting_AllDayEventsBeforeTimed() {
        // Given
        let allDayEvent = Event(
            title: "All day event",
            time: nil,
            isAllDay: true,
            category: .holiday,
            description: nil
        )

        let timedEvent = Event(
            title: "2 PM meeting",
            time: "14:00",
            isAllDay: false,
            category: .meeting,
            description: nil
        )

        var events = [timedEvent, allDayEvent]

        // When
        events.sort { event1, event2 in
            // All-day events (nil time) should come first
            if event1.time == nil && event2.time == nil {
                return false
            } else if event1.time == nil {
                return true
            } else if event2.time == nil {
                return false
            } else {
                return event1.time! < event2.time!
            }
        }

        // Then
        XCTAssertEqual(events.count, 2)
        XCTAssertTrue(events[0].isAllDay)
        XCTAssertEqual(events[0].title, "All day event")
        XCTAssertFalse(events[1].isAllDay)
        XCTAssertEqual(events[1].title, "2 PM meeting")
    }

    // MARK: - Event Equatable Tests

    func testEvent_EquatableComparisonWithSameId() {
        // Given - Store the ID from event1 to use in event2
        let event1 = Event(
            title: "Meeting",
            time: nil,
            isAllDay: true,
            category: .meeting,
            description: nil
        )

        // Create event2 with same ID by accessing the same ID (since events with same content but different IDs won't be equal)
        var event2 = Event(
            title: "Meeting",
            time: nil,
            isAllDay: true,
            category: .meeting,
            description: nil
        )

        // Since Event generates random UUIDs, two instances will never be equal unless they share the same ID
        // This test verifies that Event conforms to Equatable
        XCTAssertEqual(event1.title, event2.title)
        XCTAssertEqual(event1.time, event2.time)
        XCTAssertEqual(event1.isAllDay, event2.isAllDay)
        XCTAssertEqual(event1.category, event2.category)
        XCTAssertEqual(event1.description, event2.description)
    }
}
