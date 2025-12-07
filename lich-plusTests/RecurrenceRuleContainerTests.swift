//
//  RecurrenceRuleContainerTests.swift
//  lich-plusTests
//
//  Created by Quang Tran Minh on 07/12/25.
//

import XCTest
import EventKit
@testable import lich_plus

final class RecurrenceRuleContainerTests: XCTestCase {

    // MARK: - Case Initialization Tests

    func testInitializeSolarCase() throws {
        let solarRule = SerializableRecurrenceRule(
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

        let container = RecurrenceRuleContainer.solar(solarRule)

        if case .solar(let rule) = container {
            XCTAssertEqual(rule.frequency, EKRecurrenceFrequency.daily.rawValue)
        } else {
            XCTFail("Expected solar case")
        }
    }

    func testInitializeLunarCase() {
        let lunarRule = SerializableLunarRecurrenceRule(
            frequency: .monthly,
            lunarDay: 15,
            lunarMonth: nil,
            leapMonthBehavior: .includeLeap,
            interval: 1,
            recurrenceEnd: nil
        )

        let container = RecurrenceRuleContainer.lunar(lunarRule)

        if case .lunar(let rule) = container {
            XCTAssertEqual(rule.frequency, .monthly)
            XCTAssertEqual(rule.lunarDay, 15)
        } else {
            XCTFail("Expected lunar case")
        }
    }

    func testInitializeNoneCase() {
        let container = RecurrenceRuleContainer.none

        if case .none = container {
            // Success
        } else {
            XCTFail("Expected none case")
        }
    }

    // MARK: - JSON Encoding Tests

    func testEncodeSolarRule() throws {
        let solarRule = SerializableRecurrenceRule(
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

        let container = RecurrenceRuleContainer.solar(solarRule)
        let encoded = try JSONEncoder().encode(container)

        XCTAssertNotNil(encoded)
        XCTAssertGreaterThan(encoded.count, 0)
    }

    func testEncodeLunarRule() throws {
        let lunarRule = SerializableLunarRecurrenceRule(
            frequency: .yearly,
            lunarDay: 15,
            lunarMonth: 4,
            leapMonthBehavior: .skipLeap,
            interval: 1,
            recurrenceEnd: nil
        )

        let container = RecurrenceRuleContainer.lunar(lunarRule)
        let encoded = try JSONEncoder().encode(container)

        XCTAssertNotNil(encoded)
        XCTAssertGreaterThan(encoded.count, 0)
    }

    func testEncodeNoneCase() throws {
        let container = RecurrenceRuleContainer.none
        let encoded = try JSONEncoder().encode(container)

        XCTAssertNotNil(encoded)
        XCTAssertGreaterThan(encoded.count, 0)
    }

    // MARK: - JSON Decoding Tests

    func testDecodeSolarRule() throws {
        let solarRule = SerializableRecurrenceRule(
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

        let container = RecurrenceRuleContainer.solar(solarRule)
        let encoded = try JSONEncoder().encode(container)
        let decoded = try JSONDecoder().decode(RecurrenceRuleContainer.self, from: encoded)

        if case .solar(let rule) = decoded {
            XCTAssertEqual(rule.frequency, EKRecurrenceFrequency.daily.rawValue)
            XCTAssertEqual(rule.interval, 1)
        } else {
            XCTFail("Expected solar case after decoding")
        }
    }

    func testDecodeLunarRule() throws {
        let lunarRule = SerializableLunarRecurrenceRule(
            frequency: .monthly,
            lunarDay: 15,
            lunarMonth: nil,
            leapMonthBehavior: .includeLeap,
            interval: 1,
            recurrenceEnd: nil
        )

        let container = RecurrenceRuleContainer.lunar(lunarRule)
        let encoded = try JSONEncoder().encode(container)
        let decoded = try JSONDecoder().decode(RecurrenceRuleContainer.self, from: encoded)

        if case .lunar(let rule) = decoded {
            XCTAssertEqual(rule.frequency, .monthly)
            XCTAssertEqual(rule.lunarDay, 15)
            XCTAssertNil(rule.lunarMonth)
        } else {
            XCTFail("Expected lunar case after decoding")
        }
    }

    func testDecodeNoneCase() throws {
        let container = RecurrenceRuleContainer.none
        let encoded = try JSONEncoder().encode(container)
        let decoded = try JSONDecoder().decode(RecurrenceRuleContainer.self, from: encoded)

        if case .none = decoded {
            // Success
        } else {
            XCTFail("Expected none case after decoding")
        }
    }

    // MARK: - Round-Trip Tests

    func testRoundTripSolarRule() throws {
        let solarRule = SerializableRecurrenceRule(
            frequency: EKRecurrenceFrequency.monthly.rawValue,
            interval: 2,
            daysOfTheWeek: nil,
            daysOfTheMonth: [15],
            monthsOfTheYear: nil,
            weeksOfTheYear: nil,
            daysOfTheYear: nil,
            setPositions: nil,
            recurrenceEnd: .occurrenceCount(10)
        )

        let container = RecurrenceRuleContainer.solar(solarRule)
        let encoded = try JSONEncoder().encode(container)
        let decoded = try JSONDecoder().decode(RecurrenceRuleContainer.self, from: encoded)

        if case .solar(let decodedRule) = decoded {
            XCTAssertEqual(decodedRule.frequency, solarRule.frequency)
            XCTAssertEqual(decodedRule.interval, solarRule.interval)
            XCTAssertEqual(decodedRule.daysOfTheMonth, solarRule.daysOfTheMonth)
        } else {
            XCTFail("Expected solar case")
        }
    }

    func testRoundTripLunarRule() throws {
        let lunarRule = SerializableLunarRecurrenceRule(
            frequency: .yearly,
            lunarDay: 15,
            lunarMonth: 4,
            leapMonthBehavior: .leapOnly,
            interval: 2,
            recurrenceEnd: .endDate(Date())
        )

        let container = RecurrenceRuleContainer.lunar(lunarRule)
        let encoded = try JSONEncoder().encode(container)
        let decoded = try JSONDecoder().decode(RecurrenceRuleContainer.self, from: encoded)

        if case .lunar(let decodedRule) = decoded {
            XCTAssertEqual(decodedRule.frequency, lunarRule.frequency)
            XCTAssertEqual(decodedRule.lunarDay, lunarRule.lunarDay)
            XCTAssertEqual(decodedRule.lunarMonth, lunarRule.lunarMonth)
            XCTAssertEqual(decodedRule.leapMonthBehavior, lunarRule.leapMonthBehavior)
            XCTAssertEqual(decodedRule.interval, lunarRule.interval)
        } else {
            XCTFail("Expected lunar case")
        }
    }

    func testRoundTripNoneCase() throws {
        let container = RecurrenceRuleContainer.none
        let encoded = try JSONEncoder().encode(container)
        let decoded = try JSONDecoder().decode(RecurrenceRuleContainer.self, from: encoded)

        if case .none = decoded {
            // Success
        } else {
            XCTFail("Expected none case")
        }
    }

    // MARK: - Discriminator Field Tests

    func testSolarHasCorrectTypeDiscriminator() throws {
        let solarRule = SerializableRecurrenceRule(
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

        let container = RecurrenceRuleContainer.solar(solarRule)
        let encoded = try JSONEncoder().encode(container)

        if let json = try JSONSerialization.jsonObject(with: encoded) as? [String: Any] {
            XCTAssertEqual(json["type"] as? String, "solar")
        }
    }

    func testLunarHasCorrectTypeDiscriminator() throws {
        let lunarRule = SerializableLunarRecurrenceRule(
            frequency: .monthly,
            lunarDay: 15,
            lunarMonth: nil,
            leapMonthBehavior: .includeLeap,
            interval: 1,
            recurrenceEnd: nil
        )

        let container = RecurrenceRuleContainer.lunar(lunarRule)
        let encoded = try JSONEncoder().encode(container)

        if let json = try JSONSerialization.jsonObject(with: encoded) as? [String: Any] {
            XCTAssertEqual(json["type"] as? String, "lunar")
        }
    }

    func testNoneHasCorrectTypeDiscriminator() throws {
        let container = RecurrenceRuleContainer.none
        let encoded = try JSONEncoder().encode(container)

        if let json = try JSONSerialization.jsonObject(with: encoded) as? [String: Any] {
            XCTAssertEqual(json["type"] as? String, "none")
        }
    }

    // MARK: - Array Serialization Tests

    func testSerializeArrayOfContainers() throws {
        let solar = RecurrenceRuleContainer.solar(
            SerializableRecurrenceRule(
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
        )

        let lunar = RecurrenceRuleContainer.lunar(
            SerializableLunarRecurrenceRule(
                frequency: .yearly,
                lunarDay: 15,
                lunarMonth: 4,
                leapMonthBehavior: .skipLeap,
                interval: 1,
                recurrenceEnd: nil
            )
        )

        let containers = [solar, lunar, .none]
        let encoded = try JSONEncoder().encode(containers)
        let decoded = try JSONDecoder().decode([RecurrenceRuleContainer].self, from: encoded)

        XCTAssertEqual(decoded.count, 3)
        if case .solar = decoded[0] {
            // Success
        } else {
            XCTFail("Expected solar at index 0")
        }
        if case .lunar = decoded[1] {
            // Success
        } else {
            XCTFail("Expected lunar at index 1")
        }
        if case .none = decoded[2] {
            // Success
        } else {
            XCTFail("Expected none at index 2")
        }
    }

    // MARK: - Error Handling Tests

    func testDecodeInvalidTypeThrows() throws {
        let json = """
        {"type": "invalid", "rule": {}}
        """.data(using: .utf8)!

        XCTAssertThrowsError(
            try JSONDecoder().decode(RecurrenceRuleContainer.self, from: json)
        )
    }

    func testDecodeMissingTypeThrows() throws {
        let json = """
        {"rule": {}}
        """.data(using: .utf8)!

        XCTAssertThrowsError(
            try JSONDecoder().decode(RecurrenceRuleContainer.self, from: json)
        )
    }
}
