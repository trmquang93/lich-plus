//
//  AIInputSectionTests.swift
//  lich-plusTests
//
//  Created by Quang Tran Minh on 27/11/25.
//

import XCTest
@testable import lich_plus

class AIInputSectionTests: XCTestCase {

    func testParsedTaskModel() {
        let date = Date()
        let parsed = ParsedTask(
            title: "Meeting with John",
            dueDate: date,
            dueTime: Date(timeIntervalSinceNow: 3600),
            category: "Meeting",
            notes: "Discuss project",
            hasReminder: true
        )

        XCTAssertEqual(parsed.title, "Meeting with John")
        XCTAssertEqual(parsed.category, "Meeting")
        XCTAssertTrue(parsed.hasReminder)
        XCTAssertNotNil(parsed.dueTime)
    }

    func testParsedEventModel() {
        let date = Date()
        let parsed = ParsedEvent(
            title: "Conference",
            startDate: date,
            endDate: Date(timeIntervalSinceNow: 7200),
            location: "Convention Center",
            notes: "Annual meeting",
            isAllDay: false
        )

        XCTAssertEqual(parsed.title, "Conference")
        XCTAssertEqual(parsed.location, "Convention Center")
        XCTAssertFalse(parsed.isAllDay)
    }
}
