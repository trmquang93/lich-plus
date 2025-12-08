//
//  ICSRRuleParserTests.swift
//  lich-plusTests
//
//  Created by Quang Tran Minh on 08/12/25.
//

import XCTest
@testable import lich_plus

final class ICSRRuleParserTests: XCTestCase {

    // MARK: - Basic Frequency Tests

    func testParseDailyRecurrence() throws {
        let rruleString = "FREQ=DAILY"
        let result = try ICSRRuleParser.parse(rruleString)

        XCTAssertEqual(result.frequency, 0) // DAILY
        XCTAssertEqual(result.interval, 1)
        XCTAssertNil(result.daysOfTheWeek)
        XCTAssertNil(result.recurrenceEnd)
    }

    func testParseWeeklyRecurrence() throws {
        let rruleString = "FREQ=WEEKLY"
        let result = try ICSRRuleParser.parse(rruleString)

        XCTAssertEqual(result.frequency, 1) // WEEKLY
        XCTAssertEqual(result.interval, 1)
    }

    func testParseMonthlyRecurrence() throws {
        let rruleString = "FREQ=MONTHLY"
        let result = try ICSRRuleParser.parse(rruleString)

        XCTAssertEqual(result.frequency, 2) // MONTHLY
        XCTAssertEqual(result.interval, 1)
    }

    func testParseYearlyRecurrence() throws {
        let rruleString = "FREQ=YEARLY"
        let result = try ICSRRuleParser.parse(rruleString)

        XCTAssertEqual(result.frequency, 3) // YEARLY
        XCTAssertEqual(result.interval, 1)
    }

    // MARK: - Interval Tests

    func testParseIntervalOne() throws {
        let rruleString = "FREQ=DAILY;INTERVAL=1"
        let result = try ICSRRuleParser.parse(rruleString)

        XCTAssertEqual(result.interval, 1)
    }

    func testParseIntervalMultiple() throws {
        let rruleString = "FREQ=DAILY;INTERVAL=5"
        let result = try ICSRRuleParser.parse(rruleString)

        XCTAssertEqual(result.interval, 5)
    }

    func testParseIntervalDefault() throws {
        let rruleString = "FREQ=DAILY"
        let result = try ICSRRuleParser.parse(rruleString)

        XCTAssertEqual(result.interval, 1) // Default
    }

    // MARK: - BYDAY Tests (Simple Format)

    func testParseByDaySingleDay() throws {
        let rruleString = "FREQ=WEEKLY;BYDAY=MO"
        let result = try ICSRRuleParser.parse(rruleString)

        XCTAssertNotNil(result.daysOfTheWeek)
        XCTAssertEqual(result.daysOfTheWeek?.count, 1)
        XCTAssertEqual(result.daysOfTheWeek?[0].dayOfWeek, 2) // Monday
        XCTAssertNil(result.daysOfTheWeek?[0].week)
    }

    func testParseByDayMultipleDays() throws {
        let rruleString = "FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR"
        let result = try ICSRRuleParser.parse(rruleString)

        XCTAssertNotNil(result.daysOfTheWeek)
        XCTAssertEqual(result.daysOfTheWeek?.count, 5)

        let expectedDays = [2, 3, 4, 5, 6] // MO, TU, WE, TH, FR
        for (index, expectedDay) in expectedDays.enumerated() {
            XCTAssertEqual(result.daysOfTheWeek?[index].dayOfWeek, expectedDay)
            XCTAssertNil(result.daysOfTheWeek?[index].week)
        }
    }

    func testParseByDaySunday() throws {
        let rruleString = "FREQ=WEEKLY;BYDAY=SU"
        let result = try ICSRRuleParser.parse(rruleString)

        XCTAssertEqual(result.daysOfTheWeek?[0].dayOfWeek, 1) // Sunday
    }

    func testParseByDayAllDays() throws {
        let rruleString = "FREQ=WEEKLY;BYDAY=SU,MO,TU,WE,TH,FR,SA"
        let result = try ICSRRuleParser.parse(rruleString)

        XCTAssertEqual(result.daysOfTheWeek?.count, 7)
        let expectedDays = [1, 2, 3, 4, 5, 6, 7]
        for (index, expectedDay) in expectedDays.enumerated() {
            XCTAssertEqual(result.daysOfTheWeek?[index].dayOfWeek, expectedDay)
        }
    }

    // MARK: - BYDAY Tests (Week Number Format)

    func testParseByDayWithWeekNumber() throws {
        let rruleString = "FREQ=MONTHLY;BYDAY=2TU"
        let result = try ICSRRuleParser.parse(rruleString)

        XCTAssertNotNil(result.daysOfTheWeek)
        XCTAssertEqual(result.daysOfTheWeek?.count, 1)
        XCTAssertEqual(result.daysOfTheWeek?[0].dayOfWeek, 3) // Tuesday
        XCTAssertEqual(result.daysOfTheWeek?[0].week, 2)
    }

    func testParseByDayWithNegativeWeekNumber() throws {
        let rruleString = "FREQ=MONTHLY;BYDAY=-1FR"
        let result = try ICSRRuleParser.parse(rruleString)

        XCTAssertEqual(result.daysOfTheWeek?[0].dayOfWeek, 6) // Friday
        XCTAssertEqual(result.daysOfTheWeek?[0].week, -1)
    }

    func testParseByDayWithWeekNumberNegativeFive() throws {
        let rruleString = "FREQ=MONTHLY;BYDAY=-5SU"
        let result = try ICSRRuleParser.parse(rruleString)

        XCTAssertEqual(result.daysOfTheWeek?[0].dayOfWeek, 1) // Sunday
        XCTAssertEqual(result.daysOfTheWeek?[0].week, -5)
    }

    func testParseByDayWithPositiveWeekNumber() throws {
        let rruleString = "FREQ=MONTHLY;BYDAY=1MO,3WE,5FR"
        let result = try ICSRRuleParser.parse(rruleString)

        XCTAssertEqual(result.daysOfTheWeek?.count, 3)

        // First Monday
        XCTAssertEqual(result.daysOfTheWeek?[0].dayOfWeek, 2)
        XCTAssertEqual(result.daysOfTheWeek?[0].week, 1)

        // Third Wednesday
        XCTAssertEqual(result.daysOfTheWeek?[1].dayOfWeek, 4)
        XCTAssertEqual(result.daysOfTheWeek?[1].week, 3)

        // Fifth Friday
        XCTAssertEqual(result.daysOfTheWeek?[2].dayOfWeek, 6)
        XCTAssertEqual(result.daysOfTheWeek?[2].week, 5)
    }

    // MARK: - BYMONTHDAY Tests

    func testParseByMonthDaySingleDay() throws {
        let rruleString = "FREQ=MONTHLY;BYMONTHDAY=15"
        let result = try ICSRRuleParser.parse(rruleString)

        XCTAssertNotNil(result.daysOfTheMonth)
        XCTAssertEqual(result.daysOfTheMonth?.count, 1)
        XCTAssertEqual(result.daysOfTheMonth?[0], 15)
    }

    func testParseByMonthDayMultipleDays() throws {
        let rruleString = "FREQ=MONTHLY;BYMONTHDAY=1,15,30"
        let result = try ICSRRuleParser.parse(rruleString)

        XCTAssertEqual(result.daysOfTheMonth?.count, 3)
        XCTAssertEqual(result.daysOfTheMonth, [1, 15, 30])
    }

    func testParseByMonthDayNegative() throws {
        let rruleString = "FREQ=MONTHLY;BYMONTHDAY=-1"
        let result = try ICSRRuleParser.parse(rruleString)

        XCTAssertEqual(result.daysOfTheMonth?.count, 1)
        XCTAssertEqual(result.daysOfTheMonth?[0], -1)
    }

    func testParseByMonthDayMixedPositiveNegative() throws {
        let rruleString = "FREQ=MONTHLY;BYMONTHDAY=1,15,-1"
        let result = try ICSRRuleParser.parse(rruleString)

        XCTAssertEqual(result.daysOfTheMonth?.count, 3)
        XCTAssertEqual(result.daysOfTheMonth, [1, 15, -1])
    }

    // MARK: - BYMONTH Tests

    func testParseByMonthSingleMonth() throws {
        let rruleString = "FREQ=YEARLY;BYMONTH=1"
        let result = try ICSRRuleParser.parse(rruleString)

        XCTAssertNotNil(result.monthsOfTheYear)
        XCTAssertEqual(result.monthsOfTheYear?.count, 1)
        XCTAssertEqual(result.monthsOfTheYear?[0], 1)
    }

    func testParseByMonthMultipleMonths() throws {
        let rruleString = "FREQ=YEARLY;BYMONTH=1,6,12"
        let result = try ICSRRuleParser.parse(rruleString)

        XCTAssertEqual(result.monthsOfTheYear?.count, 3)
        XCTAssertEqual(result.monthsOfTheYear, [1, 6, 12])
    }

    func testParseByMonthAll() throws {
        let rruleString = "FREQ=YEARLY;BYMONTH=1,2,3,4,5,6,7,8,9,10,11,12"
        let result = try ICSRRuleParser.parse(rruleString)

        XCTAssertEqual(result.monthsOfTheYear?.count, 12)
    }

    // MARK: - COUNT Tests

    func testParseCountSmall() throws {
        let rruleString = "FREQ=DAILY;COUNT=5"
        let result = try ICSRRuleParser.parse(rruleString)

        XCTAssertNotNil(result.recurrenceEnd)
        if case .occurrenceCount(let count) = result.recurrenceEnd! {
            XCTAssertEqual(count, 5)
        } else {
            XCTFail("Expected occurrenceCount, got endDate")
        }
    }

    func testParseCountLarge() throws {
        let rruleString = "FREQ=MONTHLY;COUNT=120"
        let result = try ICSRRuleParser.parse(rruleString)

        if case .occurrenceCount(let count) = result.recurrenceEnd! {
            XCTAssertEqual(count, 120)
        } else {
            XCTFail("Expected occurrenceCount")
        }
    }

    // MARK: - UNTIL Tests (UTC Format)

    func testParseUntilUTC() throws {
        let rruleString = "FREQ=DAILY;UNTIL=20251231T235959Z"
        let result = try ICSRRuleParser.parse(rruleString)

        XCTAssertNotNil(result.recurrenceEnd)
        if case .endDate(let date) = result.recurrenceEnd! {
            // Use UTC timezone when extracting components for UTC dates
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = TimeZone(abbreviation: "UTC")!
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)

            XCTAssertEqual(components.year, 2025)
            XCTAssertEqual(components.month, 12)
            XCTAssertEqual(components.day, 31)
        } else {
            XCTFail("Expected endDate, got occurrenceCount")
        }
    }

    func testParseUntilLocalDateTime() throws {
        let rruleString = "FREQ=DAILY;UNTIL=20251231T235959"
        let result = try ICSRRuleParser.parse(rruleString)

        XCTAssertNotNil(result.recurrenceEnd)
        if case .endDate(let date) = result.recurrenceEnd! {
            let calendar = Calendar(identifier: .gregorian)
            let components = calendar.dateComponents([.year, .month, .day], from: date)

            XCTAssertEqual(components.year, 2025)
            XCTAssertEqual(components.month, 12)
            XCTAssertEqual(components.day, 31)
        } else {
            XCTFail("Expected endDate")
        }
    }

    func testParseUntilDateOnly() throws {
        let rruleString = "FREQ=DAILY;UNTIL=20251231"
        let result = try ICSRRuleParser.parse(rruleString)

        XCTAssertNotNil(result.recurrenceEnd)
        if case .endDate(let date) = result.recurrenceEnd! {
            let calendar = Calendar(identifier: .gregorian)
            let components = calendar.dateComponents([.year, .month, .day], from: date)

            XCTAssertEqual(components.year, 2025)
            XCTAssertEqual(components.month, 12)
            XCTAssertEqual(components.day, 31)
        } else {
            XCTFail("Expected endDate")
        }
    }

    // MARK: - Complex Scenarios

    func testParseWeeklyWithMultipleDaysAndUntil() throws {
        let rruleString = "FREQ=WEEKLY;BYDAY=MO,WE,FR;UNTIL=20251231T235959Z"
        let result = try ICSRRuleParser.parse(rruleString)

        XCTAssertEqual(result.frequency, 1) // WEEKLY
        XCTAssertEqual(result.daysOfTheWeek?.count, 3)
        XCTAssertNotNil(result.recurrenceEnd)
    }

    func testParseMonthlyWithByMonthDay() throws {
        let rruleString = "FREQ=MONTHLY;BYMONTHDAY=1,15;INTERVAL=1"
        let result = try ICSRRuleParser.parse(rruleString)

        XCTAssertEqual(result.frequency, 2) // MONTHLY
        XCTAssertEqual(result.daysOfTheMonth, [1, 15])
        XCTAssertEqual(result.interval, 1)
    }

    func testParseYearlyWithByMonthAndByMonthDay() throws {
        let rruleString = "FREQ=YEARLY;BYMONTH=1;BYMONTHDAY=1"
        let result = try ICSRRuleParser.parse(rruleString)

        XCTAssertEqual(result.frequency, 3) // YEARLY
        XCTAssertEqual(result.monthsOfTheYear, [1])
        XCTAssertEqual(result.daysOfTheMonth, [1])
    }

    func testParseMonthlySecondTuesdayWithCount() throws {
        let rruleString = "FREQ=MONTHLY;BYDAY=2TU;COUNT=12"
        let result = try ICSRRuleParser.parse(rruleString)

        XCTAssertEqual(result.frequency, 2) // MONTHLY
        XCTAssertEqual(result.daysOfTheWeek?.count, 1)
        XCTAssertEqual(result.daysOfTheWeek?[0].dayOfWeek, 3) // Tuesday
        XCTAssertEqual(result.daysOfTheWeek?[0].week, 2)
        if case .occurrenceCount(let count) = result.recurrenceEnd! {
            XCTAssertEqual(count, 12)
        }
    }

    func testParseComplexWeeklyPattern() throws {
        let rruleString = "FREQ=WEEKLY;INTERVAL=2;BYDAY=MO,WE,FR;UNTIL=20260630T235959Z"
        let result = try ICSRRuleParser.parse(rruleString)

        XCTAssertEqual(result.frequency, 1)
        XCTAssertEqual(result.interval, 2)
        XCTAssertEqual(result.daysOfTheWeek?.count, 3)
        XCTAssertNotNil(result.recurrenceEnd)
    }

    // MARK: - Case Insensitivity Tests

    func testParseLowercaseFreq() throws {
        let rruleString = "freq=daily"
        let result = try ICSRRuleParser.parse(rruleString)

        XCTAssertEqual(result.frequency, 0)
    }

    func testParseMixedCaseParameters() throws {
        let rruleString = "Freq=Daily;Interval=2"
        let result = try ICSRRuleParser.parse(rruleString)

        XCTAssertEqual(result.frequency, 0)
        XCTAssertEqual(result.interval, 2)
    }

    // MARK: - Whitespace Handling

    func testParseWithWhitespace() throws {
        let rruleString = "FREQ=DAILY; INTERVAL=1"
        let result = try ICSRRuleParser.parse(rruleString)

        XCTAssertEqual(result.frequency, 0)
        XCTAssertEqual(result.interval, 1)
    }

    func testParseWithLeadingTrailingWhitespace() throws {
        let rruleString = "  FREQ=DAILY;INTERVAL=1  "
        let result = try ICSRRuleParser.parse(rruleString)

        XCTAssertEqual(result.frequency, 0)
    }

    // MARK: - Error Cases

    func testParseMissingFreq() throws {
        let rruleString = "INTERVAL=1"

        XCTAssertThrowsError(try ICSRRuleParser.parse(rruleString)) { error in
            guard let parserError = error as? ICSRRuleParserError else {
                XCTFail("Expected ICSRRuleParserError")
                return
            }
            if case .missingFrequency = parserError {
                // Expected
            } else {
                XCTFail("Expected missingFrequency error")
            }
        }
    }

    func testParseInvalidFreq() throws {
        let rruleString = "FREQ=INVALID"

        XCTAssertThrowsError(try ICSRRuleParser.parse(rruleString)) { error in
            guard let parserError = error as? ICSRRuleParserError else {
                XCTFail("Expected ICSRRuleParserError")
                return
            }
            if case .invalidFrequency = parserError {
                // Expected
            } else {
                XCTFail("Expected invalidFrequency error")
            }
        }
    }

    func testParseInvalidInterval() throws {
        let rruleString = "FREQ=DAILY;INTERVAL=abc"

        XCTAssertThrowsError(try ICSRRuleParser.parse(rruleString)) { error in
            guard let parserError = error as? ICSRRuleParserError else {
                XCTFail("Expected ICSRRuleParserError")
                return
            }
            if case .invalidInterval = parserError {
                // Expected
            } else {
                XCTFail("Expected invalidInterval error")
            }
        }
    }

    func testParseInvalidCount() throws {
        let rruleString = "FREQ=DAILY;COUNT=abc"

        XCTAssertThrowsError(try ICSRRuleParser.parse(rruleString)) { error in
            guard let parserError = error as? ICSRRuleParserError else {
                XCTFail("Expected ICSRRuleParserError")
                return
            }
            if case .invalidCount = parserError {
                // Expected
            } else {
                XCTFail("Expected invalidCount error")
            }
        }
    }

    func testParseInvalidUntil() throws {
        let rruleString = "FREQ=DAILY;UNTIL=invalid-date"

        XCTAssertThrowsError(try ICSRRuleParser.parse(rruleString)) { error in
            guard let parserError = error as? ICSRRuleParserError else {
                XCTFail("Expected ICSRRuleParserError")
                return
            }
            if case .invalidUntil = parserError {
                // Expected
            } else {
                XCTFail("Expected invalidUntil error")
            }
        }
    }

    func testParseInvalidByDay() throws {
        let rruleString = "FREQ=WEEKLY;BYDAY=XX"

        XCTAssertThrowsError(try ICSRRuleParser.parse(rruleString)) { error in
            guard let parserError = error as? ICSRRuleParserError else {
                XCTFail("Expected ICSRRuleParserError")
                return
            }
            if case .invalidByDay = parserError {
                // Expected
            } else {
                XCTFail("Expected invalidByDay error")
            }
        }
    }

    func testParseEmptyString() throws {
        let rruleString = ""

        XCTAssertThrowsError(try ICSRRuleParser.parse(rruleString)) { error in
            guard let parserError = error as? ICSRRuleParserError else {
                XCTFail("Expected ICSRRuleParserError")
                return
            }
            if case .missingFrequency = parserError {
                // Expected
            } else {
                XCTFail("Expected missingFrequency error")
            }
        }
    }

    // MARK: - Real-World Examples

    func testParseOutlookDailyRecurrence() throws {
        // Outlook export format: daily recurrence for 2 years
        let rruleString = "FREQ=DAILY;INTERVAL=1;COUNT=730"
        let result = try ICSRRuleParser.parse(rruleString)

        XCTAssertEqual(result.frequency, 0)
        XCTAssertEqual(result.interval, 1)
        if case .occurrenceCount(let count) = result.recurrenceEnd! {
            XCTAssertEqual(count, 730)
        }
    }

    func testParseGoogleWorkWeekRecurrence() throws {
        // Google Calendar: weekday recurrence (Mon-Fri)
        let rruleString = "FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR"
        let result = try ICSRRuleParser.parse(rruleString)

        XCTAssertEqual(result.frequency, 1)
        XCTAssertEqual(result.daysOfTheWeek?.count, 5)
    }

    func testParseAppleCalendarMonthlyRecurrence() throws {
        // Apple Calendar: every last day of month
        let rruleString = "FREQ=MONTHLY;BYMONTHDAY=-1"
        let result = try ICSRRuleParser.parse(rruleString)

        XCTAssertEqual(result.frequency, 2)
        XCTAssertEqual(result.daysOfTheMonth, [-1])
    }

    func testParseAnnualBirthdayRecurrence() throws {
        // Annual birthday: January 15th
        let rruleString = "FREQ=YEARLY;BYMONTH=1;BYMONTHDAY=15"
        let result = try ICSRRuleParser.parse(rruleString)

        XCTAssertEqual(result.frequency, 3)
        XCTAssertEqual(result.monthsOfTheYear, [1])
        XCTAssertEqual(result.daysOfTheMonth, [15])
    }

    func testParseMonthlyStaffMeetingRecurrence() throws {
        // First Monday of every month, up to 24 months
        let rruleString = "FREQ=MONTHLY;BYDAY=1MO;COUNT=24"
        let result = try ICSRRuleParser.parse(rruleString)

        XCTAssertEqual(result.frequency, 2)
        XCTAssertEqual(result.daysOfTheWeek?.count, 1)
        XCTAssertEqual(result.daysOfTheWeek?[0].dayOfWeek, 2) // Monday
        XCTAssertEqual(result.daysOfTheWeek?[0].week, 1)
    }

    // MARK: - EXDATE Parsing Tests

    func testParseExdateSingleUTCDatetime() throws {
        let exdateStrings = ["20231226T100000Z"]
        let dates = try ICSRRuleParser.parseExDates(exdateStrings)

        XCTAssertEqual(dates.count, 1)
        // Use UTC calendar to extract components from UTC-parsed date
        var utcCalendar = Calendar(identifier: .gregorian)
        utcCalendar.timeZone = TimeZone(abbreviation: "UTC")!
        let components = utcCalendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: dates[0])
        XCTAssertEqual(components.year, 2023)
        XCTAssertEqual(components.month, 12)
        XCTAssertEqual(components.day, 26)
        XCTAssertEqual(components.hour, 10)
        XCTAssertEqual(components.minute, 0)
    }

    func testParseExdateSingleLocalDatetime() throws {
        let exdateStrings = ["20231226T100000"]
        let dates = try ICSRRuleParser.parseExDates(exdateStrings)

        XCTAssertEqual(dates.count, 1)
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: dates[0])
        XCTAssertEqual(components.year, 2023)
        XCTAssertEqual(components.month, 12)
        XCTAssertEqual(components.day, 26)
        XCTAssertEqual(components.hour, 10)
        XCTAssertEqual(components.minute, 0)
    }

    func testParseExdateSingleDateOnly() throws {
        let exdateStrings = ["20231226"]
        let dates = try ICSRRuleParser.parseExDates(exdateStrings)

        XCTAssertEqual(dates.count, 1)
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: dates[0])
        XCTAssertEqual(components.year, 2023)
        XCTAssertEqual(components.month, 12)
        XCTAssertEqual(components.day, 26)
    }

    func testParseExdateDateWithTrailingT() throws {
        // Test the format "YYYYMMDDT" (date with trailing T but no time)
        // This format is produced by some calendars like Outlook
        let exdateStrings = ["20251009T"]
        let dates = try ICSRRuleParser.parseExDates(exdateStrings)

        XCTAssertEqual(dates.count, 1)
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: dates[0])
        XCTAssertEqual(components.year, 2025)
        XCTAssertEqual(components.month, 10)
        XCTAssertEqual(components.day, 9)
    }

    func testParseExdateMultipleDatesWithTrailingT() throws {
        // Multiple dates with trailing T format
        let exdateStrings = ["20251007T", "20251009T", "20251031T"]
        let dates = try ICSRRuleParser.parseExDates(exdateStrings)

        XCTAssertEqual(dates.count, 3)
        let calendar = Calendar.current

        let comp1 = calendar.dateComponents([.year, .month, .day], from: dates[0])
        XCTAssertEqual(comp1.month, 10)
        XCTAssertEqual(comp1.day, 7)

        let comp2 = calendar.dateComponents([.year, .month, .day], from: dates[1])
        XCTAssertEqual(comp2.month, 10)
        XCTAssertEqual(comp2.day, 9)

        let comp3 = calendar.dateComponents([.year, .month, .day], from: dates[2])
        XCTAssertEqual(comp3.month, 10)
        XCTAssertEqual(comp3.day, 31)
    }

    func testParseExdateMultipleSeparateLines() throws {
        let exdateStrings = ["20231226T100000Z", "20231227T100000Z", "20231228T100000Z"]
        let dates = try ICSRRuleParser.parseExDates(exdateStrings)

        XCTAssertEqual(dates.count, 3)
        let calendar = Calendar.current

        // Verify first date
        let comp1 = calendar.dateComponents([.month, .day], from: dates[0])
        XCTAssertEqual(comp1.day, 26)

        // Verify second date
        let comp2 = calendar.dateComponents([.month, .day], from: dates[1])
        XCTAssertEqual(comp2.day, 27)

        // Verify third date
        let comp3 = calendar.dateComponents([.month, .day], from: dates[2])
        XCTAssertEqual(comp3.day, 28)
    }

    func testParseExdateCommaSeparatedDates() throws {
        // Single EXDATE line with comma-separated dates
        let exdateStrings = ["20231226T100000Z,20231227T100000Z,20231228T100000Z"]
        let dates = try ICSRRuleParser.parseExDates(exdateStrings)

        XCTAssertEqual(dates.count, 3)
        let calendar = Calendar.current

        // Verify first date
        let comp1 = calendar.dateComponents([.month, .day], from: dates[0])
        XCTAssertEqual(comp1.day, 26)

        // Verify second date
        let comp2 = calendar.dateComponents([.month, .day], from: dates[1])
        XCTAssertEqual(comp2.day, 27)

        // Verify third date
        let comp3 = calendar.dateComponents([.month, .day], from: dates[2])
        XCTAssertEqual(comp3.day, 28)
    }

    func testParseExdateMixedFormats() throws {
        let exdateStrings = [
            "20231226T100000Z,20231227",
            "20231228T100000"
        ]
        let dates = try ICSRRuleParser.parseExDates(exdateStrings)

        XCTAssertEqual(dates.count, 3)

        // Use UTC calendar for UTC-parsed dates
        var utcCalendar = Calendar(identifier: .gregorian)
        utcCalendar.timeZone = TimeZone(abbreviation: "UTC")!
        let calendar = Calendar.current

        // Verify first date (UTC datetime)
        let comp1 = utcCalendar.dateComponents([.month, .day, .hour], from: dates[0])
        XCTAssertEqual(comp1.day, 26)
        XCTAssertEqual(comp1.hour, 10)

        // Verify second date (date only)
        let comp2 = calendar.dateComponents([.month, .day], from: dates[1])
        XCTAssertEqual(comp2.day, 27)

        // Verify third date (local datetime)
        let comp3 = calendar.dateComponents([.month, .day, .hour], from: dates[2])
        XCTAssertEqual(comp3.day, 28)
        XCTAssertEqual(comp3.hour, 10)
    }

    func testParseExdateEmptyArray() throws {
        let exdateStrings: [String] = []
        let dates = try ICSRRuleParser.parseExDates(exdateStrings)

        XCTAssertTrue(dates.isEmpty)
    }

    func testParseExdateWithWhitespace() throws {
        let exdateStrings = [" 20231226T100000Z , 20231227T100000Z "]
        let dates = try ICSRRuleParser.parseExDates(exdateStrings)

        XCTAssertEqual(dates.count, 2)
        let calendar = Calendar.current
        let comp1 = calendar.dateComponents([.month, .day], from: dates[0])
        XCTAssertEqual(comp1.day, 26)
    }

    func testParseExdateInvalidFormat() throws {
        let exdateStrings = ["invalid-date-format"]

        XCTAssertThrowsError(try ICSRRuleParser.parseExDates(exdateStrings))
    }
}
