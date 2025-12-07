//
//  EventCardTests.swift
//  lich-plusTests
//
//  Created by Quang Tran Minh on 26/11/25.
//

import XCTest
@testable import lich_plus

final class EventCardTests: XCTestCase {

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
}
