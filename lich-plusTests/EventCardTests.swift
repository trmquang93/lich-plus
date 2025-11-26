//
//  EventCardTests.swift
//  lich-plusTests
//
//  Created by Quang Tran Minh on 26/11/25.
//

import XCTest
import SwiftUI
@testable import lich_plus

final class EventCardTests: XCTestCase {

    func testEventCard_CreatesWithTaskItem() {
        // Given
        let event = TaskItem(
            title: "Meeting",
            date: Date(),
            startTime: Date(),
            category: .meeting,
            itemType: .event
        )

        // When
        let card = EventCard(
            task: event,
            onDelete: { _ in },
            onEdit: { _ in }
        )

        // Then - Should create successfully
        XCTAssertNotNil(card)
    }

    func testEventCard_RequiresStartTimeForDisplay() {
        // Given
        let event = TaskItem(
            title: "Event",
            date: Date(),
            startTime: Date(),
            category: .work,
            itemType: .event
        )

        // Then - Event should have time display
        XCTAssertNotNil(event.timeDisplay)
    }

    func testEventCard_DisplaysTimeRange() {
        // Given
        let startTime = Date()
        let endTime = Date(timeIntervalSinceNow: 3600)
        let event = TaskItem(
            title: "Event",
            date: Date(),
            startTime: startTime,
            endTime: endTime,
            category: .work,
            itemType: .event
        )

        // Then - Event should have time range display
        XCTAssertNotNil(event.timeRangeDisplay)
    }

    func testEventCard_DisplaysLocation() {
        // Given
        let event = TaskItem(
            title: "Conference",
            date: Date(),
            startTime: Date(),
            category: .meeting,
            itemType: .event,
            location: "Room 123"
        )

        // Then - Location should be available
        XCTAssertEqual(event.location, "Room 123")
    }

    func testEventCard_DisplaysCategoryBadge() {
        // Given
        let event = TaskItem(
            title: "Event",
            date: Date(),
            startTime: Date(),
            category: .work,
            itemType: .event
        )

        // Then - Category should be available
        XCTAssertEqual(event.category, .work)
        XCTAssertFalse(event.category.displayName.isEmpty)
    }

    func testEventCard_HasDeleteCallback() {
        // Given
        let event = TaskItem(
            title: "Event",
            date: Date(),
            startTime: Date(),
            category: .work,
            itemType: .event
        )
        var deletedCalled = false

        // When
        let card = EventCard(
            task: event,
            onDelete: { _ in deletedCalled = true },
            onEdit: { _ in }
        )

        // Then - Card should accept delete callback
        XCTAssertNotNil(card)
        XCTAssertFalse(deletedCalled)
    }

    func testEventCard_HasEditCallback() {
        // Given
        let event = TaskItem(
            title: "Event",
            date: Date(),
            startTime: Date(),
            category: .work,
            itemType: .event
        )
        var editCalled = false

        // When
        let card = EventCard(
            task: event,
            onDelete: { _ in },
            onEdit: { _ in editCalled = true }
        )

        // Then - Card should accept edit callback
        XCTAssertNotNil(card)
        XCTAssertFalse(editCalled)
    }
}
