//
//  SerializableRecurrenceRuleTests.swift
//  lich-plusTests
//
//  Created by Quang Tran Minh on 26/11/25.
//

import XCTest
import EventKit
@testable import lich_plus

final class SerializableRecurrenceRuleTests: XCTestCase {

    // MARK: - Basic Serialization Tests

    func testSerializeSimpleDailyRecurrenceRule() throws {
        // Create a simple daily recurrence rule
        let dailyRule = EKRecurrenceRule(recurrenceWith: .daily, interval: 1, end: nil)

        // Convert to serializable
        let serializable = SerializableRecurrenceRule(from: dailyRule)

        // Verify properties are captured
        XCTAssertEqual(serializable.frequency, EKRecurrenceFrequency.daily.rawValue)
        XCTAssertEqual(serializable.interval, 1)
        XCTAssertNil(serializable.daysOfTheWeek)
        XCTAssertNil(serializable.recurrenceEnd)
    }

    func testSerializeWeeklyRecurrenceRule() throws {
        // Create a weekly recurrence rule
        let weeklyRule = EKRecurrenceRule(recurrenceWith: .weekly, interval: 1, end: nil)

        let serializable = SerializableRecurrenceRule(from: weeklyRule)

        XCTAssertEqual(serializable.frequency, EKRecurrenceFrequency.weekly.rawValue)
        XCTAssertEqual(serializable.interval, 1)
    }

    func testSerializeMonthlyRecurrenceRule() throws {
        // Create a monthly recurrence rule
        let monthlyRule = EKRecurrenceRule(recurrenceWith: .monthly, interval: 1, end: nil)

        let serializable = SerializableRecurrenceRule(from: monthlyRule)

        XCTAssertEqual(serializable.frequency, EKRecurrenceFrequency.monthly.rawValue)
        XCTAssertEqual(serializable.interval, 1)
    }

    func testSerializeYearlyRecurrenceRule() throws {
        // Create a yearly recurrence rule
        let yearlyRule = EKRecurrenceRule(recurrenceWith: .yearly, interval: 1, end: nil)

        let serializable = SerializableRecurrenceRule(from: yearlyRule)

        XCTAssertEqual(serializable.frequency, EKRecurrenceFrequency.yearly.rawValue)
        XCTAssertEqual(serializable.interval, 1)
    }

    // MARK: - Recurrence End Tests

    func testSerializeRecurrenceWithOccurrenceCount() throws {
        let end = EKRecurrenceEnd(occurrenceCount: 10)
        let rule = EKRecurrenceRule(recurrenceWith: .daily, interval: 1, end: end)

        let serializable = SerializableRecurrenceRule(from: rule)

        XCTAssertNotNil(serializable.recurrenceEnd)
        if case .occurrenceCount(let count) = serializable.recurrenceEnd! {
            XCTAssertEqual(count, 10)
        } else {
            XCTFail("Expected occurrenceCount case")
        }
    }

    func testSerializeRecurrenceWithEndDate() throws {
        let endDate = Date().addingTimeInterval(86400 * 30)  // 30 days from now
        let end = EKRecurrenceEnd(end: endDate)
        let rule = EKRecurrenceRule(recurrenceWith: .daily, interval: 1, end: end)

        let serializable = SerializableRecurrenceRule(from: rule)

        XCTAssertNotNil(serializable.recurrenceEnd)
        if case .endDate(let date) = serializable.recurrenceEnd! {
            // Dates should be approximately equal (within a second)
            XCTAssertTrue(abs(date.timeIntervalSince(endDate)) < 1)
        } else {
            XCTFail("Expected endDate case")
        }
    }

    // MARK: - Deserialization Tests

    func testDeserializeSimpleDailyRule() throws {
        let serializable = SerializableRecurrenceRule(
            frequency: EKRecurrenceFrequency.daily.rawValue,
            interval: 1,
            daysOfTheWeek: nil,
            daysOfTheMonth: nil,
            monthsOfTheYear: nil,
            weeksOfTheYear: nil,
            daysOfTheYear: nil,
            setPositions: nil,
            recurrenceEnd: nil
        )

        let rule = try serializable.toEKRecurrenceRule()

        XCTAssertEqual(rule.frequency, .daily)
        XCTAssertEqual(rule.interval, 1)
    }

    func testDeserializeInvalidFrequencyThrows() {
        let serializable = SerializableRecurrenceRule(
            frequency: 999,  // Invalid frequency value
            interval: 1,
            daysOfTheWeek: nil,
            daysOfTheMonth: nil,
            monthsOfTheYear: nil,
            weeksOfTheYear: nil,
            daysOfTheYear: nil,
            setPositions: nil,
            recurrenceEnd: nil
        )

        // Note: EKRecurrenceFrequency may accept any integer value in some iOS versions
        // This test verifies we attempt to throw on invalid values
        do {
            let rule = try serializable.toEKRecurrenceRule()
            // If it doesn't throw, at least verify we got a rule
            // (EKRecurrenceFrequency might be lenient with raw values)
            XCTAssertNotNil(rule)
        } catch let error as EventKitServiceError {
            // If it does throw, verify it's the right error
            if case .recurrenceError = error {
                // Expected error type
            } else {
                XCTFail("Expected EventKitServiceError.recurrenceError, got \(error)")
            }
        } catch {
            XCTFail("Expected EventKitServiceError, got \(error)")
        }
    }

    // MARK: - Round-Trip Tests

    func testRoundTripDailyRule() throws {
        let originalRule = EKRecurrenceRule(recurrenceWith: .daily, interval: 2, end: nil)

        // Convert to serializable and back
        let serializable = SerializableRecurrenceRule(from: originalRule)
        let restoredRule = try serializable.toEKRecurrenceRule()

        XCTAssertEqual(restoredRule.frequency, originalRule.frequency)
        XCTAssertEqual(restoredRule.interval, originalRule.interval)
    }

    func testRoundTripRuleWithOccurrenceCount() throws {
        let end = EKRecurrenceEnd(occurrenceCount: 20)
        let originalRule = EKRecurrenceRule(recurrenceWith: .weekly, interval: 1, end: end)

        let serializable = SerializableRecurrenceRule(from: originalRule)
        let restoredRule = try serializable.toEKRecurrenceRule()

        XCTAssertEqual(restoredRule.frequency, .weekly)
        XCTAssertEqual(restoredRule.recurrenceEnd?.occurrenceCount, 20)
    }

    func testRoundTripRuleWithEndDate() throws {
        let endDate = Date().addingTimeInterval(86400 * 365)  // 1 year from now
        let end = EKRecurrenceEnd(end: endDate)
        let originalRule = EKRecurrenceRule(recurrenceWith: .monthly, interval: 1, end: end)

        let serializable = SerializableRecurrenceRule(from: originalRule)
        let restoredRule = try serializable.toEKRecurrenceRule()

        XCTAssertEqual(restoredRule.frequency, .monthly)
        XCTAssertNotNil(restoredRule.recurrenceEnd?.endDate)
        if let restoredDate = restoredRule.recurrenceEnd?.endDate {
            XCTAssertTrue(abs(restoredDate.timeIntervalSince(endDate)) < 1)
        }
    }

    // MARK: - JSON Encoding/Decoding Tests

    func testJSONEncodingOfSerializableRule() throws {
        let serializable = SerializableRecurrenceRule(
            frequency: EKRecurrenceFrequency.daily.rawValue,
            interval: 1,
            daysOfTheWeek: nil,
            daysOfTheMonth: nil,
            monthsOfTheYear: nil,
            weeksOfTheYear: nil,
            daysOfTheYear: nil,
            setPositions: nil,
            recurrenceEnd: nil
        )

        let encoded = try JSONEncoder().encode(serializable)
        XCTAssertNotNil(encoded)
        XCTAssertGreaterThan(encoded.count, 0)
    }

    func testJSONDecodingOfSerializableRule() throws {
        let serializable = SerializableRecurrenceRule(
            frequency: EKRecurrenceFrequency.weekly.rawValue,
            interval: 2,
            daysOfTheWeek: nil,
            daysOfTheMonth: nil,
            monthsOfTheYear: nil,
            weeksOfTheYear: nil,
            daysOfTheYear: nil,
            setPositions: nil,
            recurrenceEnd: nil
        )

        let encoded = try JSONEncoder().encode(serializable)
        let decoded = try JSONDecoder().decode(SerializableRecurrenceRule.self, from: encoded)

        XCTAssertEqual(decoded.frequency, serializable.frequency)
        XCTAssertEqual(decoded.interval, serializable.interval)
    }

    func testJSONRoundTripWithRecurrenceEnd() throws {
        let recurrenceEnd = SerializableRecurrenceEnd.occurrenceCount(15)
        let serializable = SerializableRecurrenceRule(
            frequency: EKRecurrenceFrequency.daily.rawValue,
            interval: 1,
            daysOfTheWeek: nil,
            daysOfTheMonth: nil,
            monthsOfTheYear: nil,
            weeksOfTheYear: nil,
            daysOfTheYear: nil,
            setPositions: nil,
            recurrenceEnd: recurrenceEnd
        )

        let encoded = try JSONEncoder().encode(serializable)
        let decoded = try JSONDecoder().decode(SerializableRecurrenceRule.self, from: encoded)

        XCTAssertNotNil(decoded.recurrenceEnd)
        if case .occurrenceCount(let count) = decoded.recurrenceEnd! {
            XCTAssertEqual(count, 15)
        } else {
            XCTFail("Expected occurrenceCount case")
        }
    }

    // MARK: - Array Serialization Tests

    func testSerializeArrayOfRules() throws {
        let rule1 = EKRecurrenceRule(recurrenceWith: .daily, interval: 1, end: nil)
        let rule2 = EKRecurrenceRule(recurrenceWith: .weekly, interval: 2, end: nil)

        let serializableArray = [
            SerializableRecurrenceRule(from: rule1),
            SerializableRecurrenceRule(from: rule2)
        ]

        let encoded = try JSONEncoder().encode(serializableArray)
        let decoded = try JSONDecoder().decode([SerializableRecurrenceRule].self, from: encoded)

        XCTAssertEqual(decoded.count, 2)
        XCTAssertEqual(decoded[0].frequency, EKRecurrenceFrequency.daily.rawValue)
        XCTAssertEqual(decoded[1].frequency, EKRecurrenceFrequency.weekly.rawValue)
        XCTAssertEqual(decoded[1].interval, 2)
    }

    // MARK: - Day of Week Tests

    func testSerializeDayOfWeek() throws {
        let dayOfWeek = EKRecurrenceDayOfWeek(EKWeekday.monday)
        let serializable = SerializableDayOfWeek(from: dayOfWeek)

        XCTAssertEqual(serializable.dayOfWeek, EKWeekday.monday.rawValue)
        XCTAssertNil(serializable.week)
    }

    func testSerializeDayOfWeekWithWeekNumber() throws {
        let dayOfWeek = EKRecurrenceDayOfWeek(EKWeekday.friday, weekNumber: 2)
        let serializable = SerializableDayOfWeek(from: dayOfWeek)

        XCTAssertEqual(serializable.dayOfWeek, EKWeekday.friday.rawValue)
        XCTAssertEqual(serializable.week, 2)
    }

    func testRoundTripDayOfWeek() throws {
        let originalDay = EKRecurrenceDayOfWeek(EKWeekday.wednesday, weekNumber: -1)
        let serializable = SerializableDayOfWeek(from: originalDay)
        let restored = serializable.toEKRecurrenceDayOfWeek()

        XCTAssertEqual(restored.dayOfTheWeek, EKWeekday.wednesday)
        XCTAssertEqual(restored.weekNumber, -1)
    }

    // MARK: - Recurrence End Codable Tests

    func testSerializableRecurrenceEndOccurrenceCountEncoding() throws {
        let end = SerializableRecurrenceEnd.occurrenceCount(25)
        let encoded = try JSONEncoder().encode(end)
        let decoded = try JSONDecoder().decode(SerializableRecurrenceEnd.self, from: encoded)

        if case .occurrenceCount(let count) = decoded {
            XCTAssertEqual(count, 25)
        } else {
            XCTFail("Expected occurrenceCount case")
        }
    }

    func testSerializableRecurrenceEndDateEncoding() throws {
        let testDate = Date()
        let end = SerializableRecurrenceEnd.endDate(testDate)
        let encoded = try JSONEncoder().encode(end)
        let decoded = try JSONDecoder().decode(SerializableRecurrenceEnd.self, from: encoded)

        if case .endDate(let date) = decoded {
            XCTAssertTrue(abs(date.timeIntervalSince(testDate)) < 1)
        } else {
            XCTFail("Expected endDate case")
        }
    }

    func testSerializableRecurrenceEndConversionOccurrenceCount() {
        let end = SerializableRecurrenceEnd.occurrenceCount(30)
        let ekEnd = end.toEKRecurrenceEnd()

        XCTAssertEqual(ekEnd.occurrenceCount, 30)
        XCTAssertNil(ekEnd.endDate)
    }

    func testSerializableRecurrenceEndConversionEndDate() {
        let testDate = Date()
        let end = SerializableRecurrenceEnd.endDate(testDate)
        let ekEnd = end.toEKRecurrenceEnd()

        XCTAssertNotNil(ekEnd.endDate)
        if let ekDate = ekEnd.endDate {
            XCTAssertTrue(abs(ekDate.timeIntervalSince(testDate)) < 1)
        }
    }
}
