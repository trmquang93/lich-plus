//
//  RecurrenceTypeLunarTests.swift
//  lich-plusTests
//
//  Created by Quang Tran Minh on 07/12/25.
//

import XCTest
@testable import lich_plus

final class RecurrenceTypeLunarTests: XCTestCase {

    // MARK: - Lunar Case Initialization Tests

    func testLunarMonthlyRawValue() {
        XCTAssertEqual(RecurrenceType.lunarMonthly.rawValue, "LunarMonthly")
    }

    func testLunarYearlyRawValue() {
        XCTAssertEqual(RecurrenceType.lunarYearly.rawValue, "LunarYearly")
    }

    // MARK: - isLunar Helper Tests

    func testIsLunarForMonthly() {
        let recurrence = RecurrenceType.lunarMonthly
        XCTAssertTrue(recurrence.isLunar)
    }

    func testIsLunarForYearly() {
        let recurrence = RecurrenceType.lunarYearly
        XCTAssertTrue(recurrence.isLunar)
    }

    func testIsLunarForNoneLunarRecurrences() {
        let nonLunarTypes: [RecurrenceType] = [.none, .daily, .weekly, .monthly, .yearly]

        for type in nonLunarTypes {
            XCTAssertFalse(type.isLunar, "\(type) should not be lunar")
        }
    }

    // MARK: - Display Name Tests

    func testLunarMonthlyDisplayName() {
        let recurrence = RecurrenceType.lunarMonthly
        let displayName = recurrence.displayName

        // Should return localized string for "recurrence.lunarMonthly"
        XCTAssertFalse(displayName.isEmpty)
        XCTAssertNotEqual(displayName, "LunarMonthly")  // Should be localized
    }

    func testLunarYearlyDisplayName() {
        let recurrence = RecurrenceType.lunarYearly
        let displayName = recurrence.displayName

        // Should return localized string for "recurrence.lunarYearly"
        XCTAssertFalse(displayName.isEmpty)
        XCTAssertNotEqual(displayName, "LunarYearly")  // Should be localized
    }

    func testAllRecurrenceTypesHaveDisplayNames() {
        let allTypes = RecurrenceType.allCases

        for type in allTypes {
            let displayName = type.displayName
            XCTAssertFalse(displayName.isEmpty, "\(type) should have a display name")
        }
    }

    // MARK: - Identifiable Tests

    func testLunarMonthlyHasUniqueId() {
        let recurrence = RecurrenceType.lunarMonthly
        XCTAssertEqual(recurrence.id, "LunarMonthly")
    }

    func testLunarYearlyHasUniqueId() {
        let recurrence = RecurrenceType.lunarYearly
        XCTAssertEqual(recurrence.id, "LunarYearly")
    }

    func testAllRecurrenceTypesHaveUniqueIds() {
        let allTypes = RecurrenceType.allCases
        let ids = allTypes.map { $0.id }

        // All IDs should be unique
        XCTAssertEqual(ids.count, Set(ids).count)
    }

    // MARK: - CaseIterable Tests

    func testLunarCasesIncludedInAllCases() {
        let allCases = RecurrenceType.allCases

        XCTAssertTrue(allCases.contains(.lunarMonthly))
        XCTAssertTrue(allCases.contains(.lunarYearly))
    }

    func testAllCasesCountIncludesLunarCases() {
        let allCases = RecurrenceType.allCases

        // Should have: none, daily, weekly, monthly, yearly, lunarMonthly, lunarYearly = 7 cases
        XCTAssertGreaterThanOrEqual(allCases.count, 7)
    }

    // MARK: - String Initialization Tests

    func testInitializeFromLunarMonthlyString() {
        let type = RecurrenceType(rawValue: "LunarMonthly")
        XCTAssertEqual(type, .lunarMonthly)
    }

    func testInitializeFromLunarYearlyString() {
        let type = RecurrenceType(rawValue: "LunarYearly")
        XCTAssertEqual(type, .lunarYearly)
    }

    func testInitializeFromInvalidStringReturnsNil() {
        let type = RecurrenceType(rawValue: "InvalidType")
        XCTAssertNil(type)
    }

    // MARK: - Comparison Tests

    func testLunarMonthlyNotEqualToLunarYearly() {
        XCTAssertNotEqual(RecurrenceType.lunarMonthly, RecurrenceType.lunarYearly)
    }

    func testLunarMonthlyNotEqualToSolarMonthly() {
        XCTAssertNotEqual(RecurrenceType.lunarMonthly, RecurrenceType.monthly)
    }

    func testLunarYearlyNotEqualToSolarYearly() {
        XCTAssertNotEqual(RecurrenceType.lunarYearly, RecurrenceType.yearly)
    }

    // MARK: - Enum Usage in Collections Tests

    func testLunarCasesInArray() {
        let recurrences: [RecurrenceType] = [.daily, .lunarMonthly, .yearly, .lunarYearly]

        let lunarOnly = recurrences.filter { $0.isLunar }
        XCTAssertEqual(lunarOnly.count, 2)
        XCTAssertTrue(lunarOnly.contains(.lunarMonthly))
        XCTAssertTrue(lunarOnly.contains(.lunarYearly))
    }

    func testFilterNonLunarCases() {
        let recurrences: [RecurrenceType] = [.daily, .lunarMonthly, .weekly, .lunarYearly, .none]

        let solarOnly = recurrences.filter { !$0.isLunar }
        XCTAssertEqual(solarOnly.count, 3)
        XCTAssertTrue(solarOnly.contains(.daily))
        XCTAssertTrue(solarOnly.contains(.weekly))
        XCTAssertTrue(solarOnly.contains(.none))
    }
}
