//
//  RecurrencePickerSheetTests.swift
//  lich-plusTests
//
//  Tests for RecurrencePickerSheet with flat-list recurrence selection
//

import XCTest
@testable import lich_plus

final class RecurrencePickerSheetTests: XCTestCase {

    // MARK: - Test: Flat List Shows All Recurrence Types

    func testFlatListShowsAllRecurrenceTypes() {
        let allRecurrences = RecurrenceType.allCases

        // Should show all 7 recurrence types
        XCTAssertEqual(allRecurrences.count, 7)
        XCTAssertTrue(allRecurrences.contains(.none))
        XCTAssertTrue(allRecurrences.contains(.daily))
        XCTAssertTrue(allRecurrences.contains(.weekly))
        XCTAssertTrue(allRecurrences.contains(.monthly))
        XCTAssertTrue(allRecurrences.contains(.yearly))
        XCTAssertTrue(allRecurrences.contains(.lunarMonthly))
        XCTAssertTrue(allRecurrences.contains(.lunarYearly))
    }

    func testFlatListIncludesSolarRecurrenceTypes() {
        let allRecurrences = RecurrenceType.allCases
        let solarTypes: [RecurrenceType] = [.none, .daily, .weekly, .monthly, .yearly]

        for solarType in solarTypes {
            XCTAssertTrue(allRecurrences.contains(solarType), "\(solarType.displayName) should be in flat list")
        }
    }

    func testFlatListIncludesLunarRecurrenceTypes() {
        let allRecurrences = RecurrenceType.allCases
        let lunarTypes: [RecurrenceType] = [.lunarMonthly, .lunarYearly]

        for lunarType in lunarTypes {
            XCTAssertTrue(allRecurrences.contains(lunarType), "\(lunarType.displayName) should be in flat list")
        }
    }

    // MARK: - Test: RecurrenceType Properties

    func testLunarRecurrenceTypesIdentified() {
        XCTAssertTrue(RecurrenceType.lunarMonthly.isLunar)
        XCTAssertTrue(RecurrenceType.lunarYearly.isLunar)
    }

    func testSolarRecurrenceTypesIdentified() {
        XCTAssertFalse(RecurrenceType.none.isLunar)
        XCTAssertFalse(RecurrenceType.daily.isLunar)
        XCTAssertFalse(RecurrenceType.weekly.isLunar)
        XCTAssertFalse(RecurrenceType.monthly.isLunar)
        XCTAssertFalse(RecurrenceType.yearly.isLunar)
    }

    // MARK: - Test: Lunar Recurrence Rule Creation

    func testCreateLunarMonthlyRule() {
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
    }

    func testCreateLunarYearlyRuleWithDateComponents() {
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
    }

}
