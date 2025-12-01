//
//  NLPServiceTests.swift
//  lich-plusTests
//
//  Created by Quang Tran Minh on 27/11/25.
//

import XCTest
@testable import lich_plus

@MainActor
class NLPServiceTests: XCTestCase {

    func testMockNLPServiceParseTaskInput() async throws {
        let service = MockNLPService()
        let currentDate = Date()

        let result = try await service.parseTaskInput(
            "Meeting with John tomorrow at 3pm",
            currentDate: currentDate
        )

        XCTAssertTrue(result.title.contains("Meeting"))
        XCTAssertNotNil(result.dueDate)
    }

    func testMockNLPServiceParseEventInput() async throws {
        let service = MockNLPService()
        let currentDate = Date()

        let result = try await service.parseEventInput(
            "Conference at Convention Center tomorrow at 9am",
            currentDate: currentDate
        )

        XCTAssertTrue(result.title.contains("Conference"))
        XCTAssertNotNil(result.startDate)
    }

    func testMockNLPServiceParseTaskWithNotes() async throws {
        let service = MockNLPService()
        let currentDate = Date()

        let result = try await service.parseTaskInput(
            "Dentist appointment at 2:30 PM on Friday",
            currentDate: currentDate
        )

        XCTAssertTrue(!result.title.isEmpty)
        XCTAssertNotNil(result.dueDate)
    }

    func testMockNLPServiceParseEventWithLocation() async throws {
        let service = MockNLPService()
        let currentDate = Date()

        let result = try await service.parseEventInput(
            "Team meeting at office tomorrow at 10am",
            currentDate: currentDate
        )

        XCTAssertNotNil(result.startDate)
        XCTAssertEqual(result.location, "Mock Location")
    }

    func testMockNLPServiceParseTaskWithReminder() async throws {
        let service = MockNLPService()
        let currentDate = Date()

        let result = try await service.parseTaskInput(
            "Important project deadline this week",
            currentDate: currentDate
        )

        // Mock service provides hasReminder capability
        XCTAssertNotNil(result)
    }

    func testMockNLPServiceErrorHandling() async throws {
        let service = MockNLPService(shouldFail: true, failureError: .parsingFailed("Test error"))

        do {
            _ = try await service.parseTaskInput("Test input", currentDate: Date())
            XCTFail("Should throw error")
        } catch NLPError.parsingFailed {
            // Expected behavior
        }
    }
}
