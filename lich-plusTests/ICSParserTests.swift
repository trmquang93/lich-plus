//
//  ICSParserTests.swift
//  lich-plusTests
//
//  Created by Quang Tran Minh on 30/11/25.
//

import XCTest
@testable import lich_plus

final class ICSParserTests: XCTestCase {
    var sut: ICSParser!

    override func setUp() {
        super.setUp()
        sut = ICSParser()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Basic Parsing Tests

    func testParseValidICS() throws {
        let icsContent = """
        BEGIN:VCALENDAR
        VERSION:2.0
        PRODID:-//Test//Test//EN
        BEGIN:VEVENT
        UID:test-event-1
        DTSTART:20231225T100000Z
        DTEND:20231225T110000Z
        SUMMARY:Test Event
        END:VEVENT
        END:VCALENDAR
        """

        let events = try sut.parse(icsContent)

        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events[0].uid, "test-event-1")
        XCTAssertEqual(events[0].summary, "Test Event")
        XCTAssertFalse(events[0].isAllDay)
    }

    func testParseMultipleEvents() throws {
        let icsContent = """
        BEGIN:VCALENDAR
        VERSION:2.0
        BEGIN:VEVENT
        UID:event-1
        DTSTART:20231225T100000Z
        SUMMARY:Event 1
        END:VEVENT
        BEGIN:VEVENT
        UID:event-2
        DTSTART:20231226T140000Z
        SUMMARY:Event 2
        END:VEVENT
        END:VCALENDAR
        """

        let events = try sut.parse(icsContent)

        XCTAssertEqual(events.count, 2)
        XCTAssertEqual(events[0].uid, "event-1")
        XCTAssertEqual(events[1].uid, "event-2")
    }

    // MARK: - Date Format Tests

    func testParseAllDayEvent() throws {
        let icsContent = """
        BEGIN:VCALENDAR
        BEGIN:VEVENT
        UID:all-day-event
        DTSTART;VALUE=DATE:20231225
        SUMMARY:All Day Event
        END:VEVENT
        END:VCALENDAR
        """

        let events = try sut.parse(icsContent)

        XCTAssertEqual(events.count, 1)
        XCTAssertTrue(events[0].isAllDay)
        XCTAssertEqual(events[0].summary, "All Day Event")
    }

    func testParseAllDayEventWithoutValueParameter() throws {
        let icsContent = """
        BEGIN:VCALENDAR
        BEGIN:VEVENT
        UID:all-day-event-2
        DTSTART:20231225
        SUMMARY:All Day Event 2
        END:VEVENT
        END:VCALENDAR
        """

        let events = try sut.parse(icsContent)

        XCTAssertEqual(events.count, 1)
        XCTAssertTrue(events[0].isAllDay)
    }

    // MARK: - Optional Fields Tests

    func testParseEventWithDescription() throws {
        let icsContent = """
        BEGIN:VCALENDAR
        BEGIN:VEVENT
        UID:event-with-desc
        DTSTART:20231225T100000Z
        SUMMARY:Event with Description
        DESCRIPTION:This is a test description
        END:VEVENT
        END:VCALENDAR
        """

        let events = try sut.parse(icsContent)

        XCTAssertEqual(events[0].description, "This is a test description")
    }

    func testParseEventWithLocation() throws {
        let icsContent = """
        BEGIN:VCALENDAR
        BEGIN:VEVENT
        UID:event-with-location
        DTSTART:20231225T100000Z
        SUMMARY:Event with Location
        LOCATION:New York, NY
        END:VEVENT
        END:VCALENDAR
        """

        let events = try sut.parse(icsContent)

        XCTAssertEqual(events[0].location, "New York, NY")
    }

    func testParseEventWithRecurrence() throws {
        let icsContent = """
        BEGIN:VCALENDAR
        BEGIN:VEVENT
        UID:event-with-rrule
        DTSTART:20231225T100000Z
        SUMMARY:Recurring Event
        RRULE:FREQ=WEEKLY;BYDAY=MO,WE,FR
        END:VEVENT
        END:VCALENDAR
        """

        let events = try sut.parse(icsContent)

        XCTAssertEqual(events[0].recurrenceRule, "FREQ=WEEKLY;BYDAY=MO,WE,FR")
    }

    func testParseEventWithEndDate() throws {
        let icsContent = """
        BEGIN:VCALENDAR
        BEGIN:VEVENT
        UID:event-with-end
        DTSTART:20231225T100000Z
        DTEND:20231225T110000Z
        SUMMARY:Event with End Time
        END:VEVENT
        END:VCALENDAR
        """

        let events = try sut.parse(icsContent)

        XCTAssertNotNil(events[0].endDate)
    }

    // MARK: - Error Handling Tests

    func testParseInvalidFormat() throws {
        let invalidICS = "INVALID CONTENT"

        XCTAssertThrowsError(try sut.parse(invalidICS)) { error in
            XCTAssertEqual(error as? ICSParserError, ICSParserError.invalidFormat)
        }
    }

    func testParseEmptyContent() throws {
        let emptyICS = ""

        XCTAssertThrowsError(try sut.parse(emptyICS)) { error in
            XCTAssertEqual(error as? ICSParserError, ICSParserError.emptyContent)
        }
    }

    func testParseEventWithoutUID() throws {
        let icsContent = """
        BEGIN:VCALENDAR
        BEGIN:VEVENT
        DTSTART:20231225T100000Z
        SUMMARY:Event Without UID
        END:VEVENT
        END:VCALENDAR
        """

        XCTAssertThrowsError(try sut.parse(icsContent)) { error in
            XCTAssertEqual(error as? ICSParserError, ICSParserError.missingUID)
        }
    }

    func testParseEventWithoutSummary() throws {
        let icsContent = """
        BEGIN:VCALENDAR
        BEGIN:VEVENT
        UID:event-no-summary
        DTSTART:20231225T100000Z
        END:VEVENT
        END:VCALENDAR
        """

        XCTAssertThrowsError(try sut.parse(icsContent)) { error in
            XCTAssertEqual(error as? ICSParserError, ICSParserError.missingSummary)
        }
    }

    func testParseEventWithoutStartDate() throws {
        let icsContent = """
        BEGIN:VCALENDAR
        BEGIN:VEVENT
        UID:event-no-start
        SUMMARY:Event Without Start Date
        END:VEVENT
        END:VCALENDAR
        """

        XCTAssertThrowsError(try sut.parse(icsContent)) { error in
            XCTAssertEqual(error as? ICSParserError, ICSParserError.invalidDateFormat)
        }
    }

    // MARK: - Whitespace Handling Tests

    func testParseWithExtraWhitespace() throws {
        let icsContent = """
        BEGIN:VCALENDAR
        VERSION:2.0

        BEGIN:VEVENT

        UID:event-whitespace
        DTSTART:20231225T100000Z
        SUMMARY:Event with Whitespace

        END:VEVENT

        END:VCALENDAR
        """

        let events = try sut.parse(icsContent)

        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events[0].uid, "event-whitespace")
    }

    // MARK: - Edge Cases

    func testParseEventWithSpecialCharactersInSummary() throws {
        let icsContent = """
        BEGIN:VCALENDAR
        BEGIN:VEVENT
        UID:event-special-chars
        DTSTART:20231225T100000Z
        SUMMARY:Event with Special Chars & Symbols!
        END:VEVENT
        END:VCALENDAR
        """

        let events = try sut.parse(icsContent)

        XCTAssertEqual(events[0].summary, "Event with Special Chars & Symbols!")
    }

    func testParseEventWithLongDescription() throws {
        let longDesc = "This is a very long description that spans multiple concepts. It contains important information about the event including date, time, location, and special instructions for attendees."
        let icsContent = """
        BEGIN:VCALENDAR
        BEGIN:VEVENT
        UID:event-long-desc
        DTSTART:20231225T100000Z
        SUMMARY:Event with Long Description
        DESCRIPTION:\(longDesc)
        END:VEVENT
        END:VCALENDAR
        """

        let events = try sut.parse(icsContent)

        XCTAssertEqual(events[0].description, longDesc)
    }

    func testParseSkipsInvalidEventAndContinues() throws {
        let icsContent = """
        BEGIN:VCALENDAR
        BEGIN:VEVENT
        UID:valid-event-1
        DTSTART:20231225T100000Z
        SUMMARY:Valid Event 1
        END:VEVENT
        BEGIN:VEVENT
        DTSTART:20231226T100000Z
        SUMMARY:Invalid Event (no UID)
        END:VEVENT
        BEGIN:VEVENT
        UID:valid-event-2
        DTSTART:20231227T100000Z
        SUMMARY:Valid Event 2
        END:VEVENT
        END:VCALENDAR
        """

        let events = try sut.parse(icsContent)

        // Should skip invalid event and return the two valid ones
        XCTAssertEqual(events.count, 2)
        XCTAssertEqual(events[0].uid, "valid-event-1")
        XCTAssertEqual(events[1].uid, "valid-event-2")
    }
}
