//
//  SerializableLunarRecurrenceRuleTests.swift
//  lich-plusTests
//
//  Created by Quang Tran Minh on 07/12/25.
//

import XCTest
@testable import lich_plus

final class SerializableLunarRecurrenceRuleTests: XCTestCase {

    // MARK: - LunarFrequency Tests

    func testLunarFrequencyMonthlyRawValue() {
        XCTAssertEqual(LunarFrequency.monthly.rawValue, "monthly")
    }

    func testLunarFrequencyYearlyRawValue() {
        XCTAssertEqual(LunarFrequency.yearly.rawValue, "yearly")
    }

    func testLunarFrequencyCodable() throws {
        let monthly = LunarFrequency.monthly
        let encoded = try JSONEncoder().encode(monthly)
        let decoded = try JSONDecoder().decode(LunarFrequency.self, from: encoded)
        XCTAssertEqual(decoded, monthly)
    }

    // MARK: - LeapMonthBehavior Tests

    func testLeapMonthBehaviorIncludeLeapRawValue() {
        XCTAssertEqual(LeapMonthBehavior.includeLeap.rawValue, "includeLeap")
    }

    func testLeapMonthBehaviorSkipLeapRawValue() {
        XCTAssertEqual(LeapMonthBehavior.skipLeap.rawValue, "skipLeap")
    }

    func testLeapMonthBehaviorLeapOnlyRawValue() {
        XCTAssertEqual(LeapMonthBehavior.leapOnly.rawValue, "leapOnly")
    }

    func testLeapMonthBehaviorCodable() throws {
        let skipLeap = LeapMonthBehavior.skipLeap
        let encoded = try JSONEncoder().encode(skipLeap)
        let decoded = try JSONDecoder().decode(LeapMonthBehavior.self, from: encoded)
        XCTAssertEqual(decoded, skipLeap)
    }

    // MARK: - SerializableLunarRecurrenceRule Initialization Tests

    func testInitializeMonthlyLunarRule() {
        let rule = SerializableLunarRecurrenceRule(
            frequency: .monthly,
            lunarDay: 15,
            lunarMonth: nil,
            leapMonthBehavior: .includeLeap,
            interval: 1,
            recurrenceEnd: nil
        )

        XCTAssertEqual(rule.frequency, .monthly)
        XCTAssertEqual(rule.lunarDay, 15)
        XCTAssertNil(rule.lunarMonth)
        XCTAssertEqual(rule.leapMonthBehavior, .includeLeap)
        XCTAssertEqual(rule.interval, 1)
        XCTAssertNil(rule.recurrenceEnd)
    }

    func testInitializeYearlyLunarRule() {
        let rule = SerializableLunarRecurrenceRule(
            frequency: .yearly,
            lunarDay: 15,
            lunarMonth: 4,
            leapMonthBehavior: .skipLeap,
            interval: 1,
            recurrenceEnd: nil
        )

        XCTAssertEqual(rule.frequency, .yearly)
        XCTAssertEqual(rule.lunarDay, 15)
        XCTAssertEqual(rule.lunarMonth, 4)
        XCTAssertEqual(rule.leapMonthBehavior, .skipLeap)
        XCTAssertEqual(rule.interval, 1)
        XCTAssertNil(rule.recurrenceEnd)
    }

    func testInitializeWithCustomInterval() {
        let rule = SerializableLunarRecurrenceRule(
            frequency: .yearly,
            lunarDay: 1,
            lunarMonth: 1,
            leapMonthBehavior: .includeLeap,
            interval: 2,
            recurrenceEnd: nil
        )

        XCTAssertEqual(rule.interval, 2)
    }

    func testInitializeWithRecurrenceEnd() {
        let end = SerializableRecurrenceEnd.occurrenceCount(10)
        let rule = SerializableLunarRecurrenceRule(
            frequency: .yearly,
            lunarDay: 15,
            lunarMonth: 4,
            leapMonthBehavior: .includeLeap,
            interval: 1,
            recurrenceEnd: end
        )

        XCTAssertNotNil(rule.recurrenceEnd)
        if case .occurrenceCount(let count) = rule.recurrenceEnd! {
            XCTAssertEqual(count, 10)
        } else {
            XCTFail("Expected occurrenceCount case")
        }
    }

    // MARK: - Validation Tests

    func testLunarDayValidationRange1To30() {
        for day in 1...30 {
            let rule = SerializableLunarRecurrenceRule(
                frequency: .monthly,
                lunarDay: day,
                lunarMonth: nil,
                leapMonthBehavior: .includeLeap,
                interval: 1,
                recurrenceEnd: nil
            )
            XCTAssertEqual(rule.lunarDay, day)
        }
    }

    func testLunarMonthValidationRange1To12() {
        for month in 1...12 {
            let rule = SerializableLunarRecurrenceRule(
                frequency: .yearly,
                lunarDay: 15,
                lunarMonth: month,
                leapMonthBehavior: .includeLeap,
                interval: 1,
                recurrenceEnd: nil
            )
            XCTAssertEqual(rule.lunarMonth, month)
        }
    }

    func testMonthlyRuleWithNilLunarMonth() {
        // Monthly recurrence should have nil lunarMonth
        let rule = SerializableLunarRecurrenceRule(
            frequency: .monthly,
            lunarDay: 15,
            lunarMonth: nil,
            leapMonthBehavior: .includeLeap,
            interval: 1,
            recurrenceEnd: nil
        )

        XCTAssertNil(rule.lunarMonth)
    }

    func testYearlyRuleWithSpecificMonth() {
        // Yearly recurrence should have specific lunarMonth
        let rule = SerializableLunarRecurrenceRule(
            frequency: .yearly,
            lunarDay: 15,
            lunarMonth: 4,
            leapMonthBehavior: .includeLeap,
            interval: 1,
            recurrenceEnd: nil
        )

        XCTAssertNotNil(rule.lunarMonth)
        XCTAssertEqual(rule.lunarMonth, 4)
    }

    // MARK: - JSON Encoding/Decoding Tests

    func testJSONEncodingMonthlyRule() throws {
        let rule = SerializableLunarRecurrenceRule(
            frequency: .monthly,
            lunarDay: 15,
            lunarMonth: nil,
            leapMonthBehavior: .includeLeap,
            interval: 1,
            recurrenceEnd: nil
        )

        let encoded = try JSONEncoder().encode(rule)
        XCTAssertNotNil(encoded)
        XCTAssertGreaterThan(encoded.count, 0)
    }

    func testJSONDecodingMonthlyRule() throws {
        let rule = SerializableLunarRecurrenceRule(
            frequency: .monthly,
            lunarDay: 15,
            lunarMonth: nil,
            leapMonthBehavior: .skipLeap,
            interval: 1,
            recurrenceEnd: nil
        )

        let encoded = try JSONEncoder().encode(rule)
        let decoded = try JSONDecoder().decode(SerializableLunarRecurrenceRule.self, from: encoded)

        XCTAssertEqual(decoded.frequency, rule.frequency)
        XCTAssertEqual(decoded.lunarDay, rule.lunarDay)
        XCTAssertNil(decoded.lunarMonth)
        XCTAssertEqual(decoded.leapMonthBehavior, rule.leapMonthBehavior)
        XCTAssertEqual(decoded.interval, rule.interval)
    }

    func testJSONRoundTripYearlyRule() throws {
        let rule = SerializableLunarRecurrenceRule(
            frequency: .yearly,
            lunarDay: 15,
            lunarMonth: 4,
            leapMonthBehavior: .leapOnly,
            interval: 2,
            recurrenceEnd: .endDate(Date())
        )

        let encoded = try JSONEncoder().encode(rule)
        let decoded = try JSONDecoder().decode(SerializableLunarRecurrenceRule.self, from: encoded)

        XCTAssertEqual(decoded.frequency, rule.frequency)
        XCTAssertEqual(decoded.lunarDay, rule.lunarDay)
        XCTAssertEqual(decoded.lunarMonth, rule.lunarMonth)
        XCTAssertEqual(decoded.leapMonthBehavior, rule.leapMonthBehavior)
        XCTAssertEqual(decoded.interval, rule.interval)
        XCTAssertNotNil(decoded.recurrenceEnd)
    }

    func testJSONDecodingWithOccurrenceCountEnd() throws {
        let rule = SerializableLunarRecurrenceRule(
            frequency: .yearly,
            lunarDay: 1,
            lunarMonth: 1,
            leapMonthBehavior: .includeLeap,
            interval: 1,
            recurrenceEnd: .occurrenceCount(5)
        )

        let encoded = try JSONEncoder().encode(rule)
        let decoded = try JSONDecoder().decode(SerializableLunarRecurrenceRule.self, from: encoded)

        XCTAssertNotNil(decoded.recurrenceEnd)
        if case .occurrenceCount(let count) = decoded.recurrenceEnd! {
            XCTAssertEqual(count, 5)
        } else {
            XCTFail("Expected occurrenceCount case")
        }
    }

    // MARK: - Array Serialization Tests

    func testSerializeArrayOfLunarRules() throws {
        let monthlyRule = SerializableLunarRecurrenceRule(
            frequency: .monthly,
            lunarDay: 15,
            lunarMonth: nil,
            leapMonthBehavior: .includeLeap,
            interval: 1,
            recurrenceEnd: nil
        )

        let yearlyRule = SerializableLunarRecurrenceRule(
            frequency: .yearly,
            lunarDay: 15,
            lunarMonth: 4,
            leapMonthBehavior: .skipLeap,
            interval: 1,
            recurrenceEnd: nil
        )

        let rules = [monthlyRule, yearlyRule]
        let encoded = try JSONEncoder().encode(rules)
        let decoded = try JSONDecoder().decode([SerializableLunarRecurrenceRule].self, from: encoded)

        XCTAssertEqual(decoded.count, 2)
        XCTAssertEqual(decoded[0].frequency, .monthly)
        XCTAssertEqual(decoded[1].frequency, .yearly)
    }

    // MARK: - Edge Cases

    func testDefaultIntervalValue() {
        let rule = SerializableLunarRecurrenceRule(
            frequency: .monthly,
            lunarDay: 15,
            lunarMonth: nil,
            leapMonthBehavior: .includeLeap
        )

        XCTAssertEqual(rule.interval, 1)
    }

    func testDefaultRecurrenceEndIsNil() {
        let rule = SerializableLunarRecurrenceRule(
            frequency: .yearly,
            lunarDay: 15,
            lunarMonth: 4,
            leapMonthBehavior: .includeLeap
        )

        XCTAssertNil(rule.recurrenceEnd)
    }

    func testAllLeapMonthBehaviors() throws {
        let behaviors: [LeapMonthBehavior] = [.includeLeap, .skipLeap, .leapOnly]

        for behavior in behaviors {
            let rule = SerializableLunarRecurrenceRule(
                frequency: .yearly,
                lunarDay: 15,
                lunarMonth: 4,
                leapMonthBehavior: behavior,
                interval: 1,
                recurrenceEnd: nil
            )

            let encoded = try JSONEncoder().encode(rule)
            let decoded = try JSONDecoder().decode(SerializableLunarRecurrenceRule.self, from: encoded)

            XCTAssertEqual(decoded.leapMonthBehavior, behavior)
        }
    }
}
