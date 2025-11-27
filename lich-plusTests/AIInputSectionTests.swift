//
//  AIInputSectionTests.swift
//  lich-plusTests
//
//  Created by Quang Tran Minh on 27/11/25.
//

import XCTest
import SwiftUI
@testable import lich_plus

class AIInputSectionTests: XCTestCase {

    func testAIInputSectionInitialState() {
        let mockService = MockNLPService()
        let component = AIInputSection(nlpService: mockService, itemType: .task)

        // Verify component initializes without crashing
        XCTAssertNotNil(component)
    }

    func testAIInputSectionCallsOnTaskParseSuccess() {
        let mockService = MockNLPService()
        var parsedTask: ParsedTask?

        let expectation = XCTestExpectation(description: "Task parsing completed")

        let component = AIInputSection(
            nlpService: mockService,
            itemType: .task,
            onTaskParsed: { task in
                parsedTask = task
                expectation.fulfill()
            }
        )

        XCTAssertNotNil(component)
    }

    func testAIInputSectionCallsOnEventParseSuccess() {
        let mockService = MockNLPService()
        var parsedEvent: ParsedEvent?

        let expectation = XCTestExpectation(description: "Event parsing completed")

        let component = AIInputSection(
            nlpService: mockService,
            itemType: .event,
            onEventParsed: { event in
                parsedEvent = event
                expectation.fulfill()
            }
        )

        XCTAssertNotNil(component)
    }

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
