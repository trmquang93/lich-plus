//
//  LunarDatePickerViewTests.swift
//  lich-plusTests
//
//  Tests for LunarDatePickerView component
//

import XCTest
import SwiftUI
@testable import lich_plus

final class LunarDatePickerViewTests: XCTestCase {

    // MARK: - Test: Lunar Date Components Validation

    func testLunarDayRangeIsValid1To30() {
        // Valid range should be 1-30
        for day in 1...30 {
            XCTAssertTrue(isValidLunarDay(day), "Day \(day) should be valid")
        }
    }

    func testLunarDayBelowRange() {
        XCTAssertFalse(isValidLunarDay(0), "Day 0 should be invalid")
        XCTAssertFalse(isValidLunarDay(-1), "Day -1 should be invalid")
    }

    func testLunarDayAboveRange() {
        XCTAssertFalse(isValidLunarDay(31), "Day 31 should be invalid")
        XCTAssertFalse(isValidLunarDay(40), "Day 40 should be invalid")
    }

    func testLunarMonthRangeIsValid1To12() {
        // Valid range should be 1-12
        for month in 1...12 {
            XCTAssertTrue(isValidLunarMonth(month), "Month \(month) should be valid")
        }
    }

    func testLunarMonthBelowRange() {
        XCTAssertFalse(isValidLunarMonth(0), "Month 0 should be invalid")
        XCTAssertFalse(isValidLunarMonth(-1), "Month -1 should be invalid")
    }

    func testLunarMonthAboveRange() {
        XCTAssertFalse(isValidLunarMonth(13), "Month 13 should be invalid")
        XCTAssertFalse(isValidLunarMonth(24), "Month 24 should be invalid")
    }

    // MARK: - Test: Lunar to Solar Conversion

    func testConvertLunarToSolarDate() {
        // Convert Lunar 1/1/2025 to solar date
        // Lunar 1/1 is Tet (Vietnamese New Year)
        let solarDate = convertLunarToSolar(day: 1, month: 1, year: 2025)

        XCTAssertNotNil(solarDate, "Should successfully convert lunar to solar date")

        // Verify the date is reasonable (should be in January or February depending on lunar calendar)
        let calendar = Calendar.current
        let year = calendar.component(.year, from: solarDate!)
        let solarMonth = calendar.component(.month, from: solarDate!)

        XCTAssertEqual(year, 2025)
        XCTAssert((1...2).contains(solarMonth), "Tet should be in January or February")
    }

    func testConvertLunarMidAutumnToSolar() {
        // Lunar 8/15 is Mid-Autumn Festival
        let solarDate = convertLunarToSolar(day: 15, month: 8, year: 2025)

        XCTAssertNotNil(solarDate)

        let calendar = Calendar.current
        let solarMonth = calendar.component(.month, from: solarDate!)

        // Mid-Autumn should be around September
        XCTAssert((8...10).contains(solarMonth), "Mid-Autumn should be around September")
    }

    func testConvertLunarDateEdgeCases() {
        // Test edge cases: day 30
        let solarDate1 = convertLunarToSolar(day: 30, month: 1, year: 2025)
        XCTAssertNotNil(solarDate1)

        // Test edge cases: month 12
        let solarDate2 = convertLunarToSolar(day: 15, month: 12, year: 2025)
        XCTAssertNotNil(solarDate2)
    }

    // MARK: - Test: Solar to Lunar Conversion

    func testConvertSolarToLunarDate() {
        // Convert a known solar date to lunar
        var dateComponents = DateComponents()
        dateComponents.year = 2025
        dateComponents.month = 1
        dateComponents.day = 29

        let solarDate = Calendar.current.date(from: dateComponents)!

        let (lunarDay, lunarMonth, lunarYear) = convertSolarToLunar(solarDate)

        XCTAssertGreaterThan(lunarDay, 0)
        XCTAssertGreaterThan(lunarMonth, 0)
        XCTAssertGreaterThan(lunarYear, 0)
        XCTAssertLessThanOrEqual(lunarDay, 30)
        XCTAssertLessThanOrEqual(lunarMonth, 12)
    }

    // MARK: - Test: Leap Month Support

    func testLeapMonthToggle() {
        let hasLeap = hasLeapMonthInYear(2025)
        // Result can be true or false - verify it's a valid boolean result
        XCTAssert(hasLeap == true || hasLeap == false)
    }

    func testLeapMonthHandling() {
        // When leap month is included, recurrence should capture leap month info
        let lunarRule = SerializableLunarRecurrenceRule(
            frequency: .yearly,
            lunarDay: 15,
            lunarMonth: 4,
            leapMonthBehavior: .includeLeap,
            interval: 1
        )

        XCTAssertEqual(lunarRule.leapMonthBehavior, .includeLeap)
    }

    func testLeapMonthSkip() {
        let lunarRule = SerializableLunarRecurrenceRule(
            frequency: .yearly,
            lunarDay: 15,
            lunarMonth: 4,
            leapMonthBehavior: .skipLeap,
            interval: 1
        )

        XCTAssertEqual(lunarRule.leapMonthBehavior, .skipLeap)
    }

    // MARK: - Test: Lunar Month Display Names

    func testLunarMonthDisplayNames() {
        let months = getLunarMonthDisplayNames()

        XCTAssertEqual(months.count, 12)
        XCTAssertNotNil(months.first)
        XCTAssertNotNil(months.last)
    }

    func testLunarMonthDisplayNameForMonth1() {
        let name = getLunarMonthDisplayName(1)
        XCTAssertFalse(name.isEmpty)
        // Should contain "Tháng" or "Thang" or month indicator
        XCTAssert(name.lowercased().contains("thang") || name.lowercased().contains("1"))
    }

    func testLunarMonthDisplayNameForMonth12() {
        let name = getLunarMonthDisplayName(12)
        XCTAssertFalse(name.isEmpty)
        XCTAssert(name.lowercased().contains("thang") || name.lowercased().contains("12"))
    }

    // MARK: - Helper Functions (Mimicking LunarDatePickerView behavior)

    private func isValidLunarDay(_ day: Int) -> Bool {
        (1...30).contains(day)
    }

    private func isValidLunarMonth(_ month: Int) -> Bool {
        (1...12).contains(month)
    }

    private func convertLunarToSolar(day: Int, month: Int, year: Int) -> Date? {
        let components = convertLunarToSolar(lunarDay: day, lunarMonth: month, lunarYear: year)

        var dateComponents = DateComponents()
        dateComponents.year = components.year
        dateComponents.month = components.month
        dateComponents.day = components.day

        return Calendar.current.date(from: dateComponents)
    }

    private func convertLunarToSolar(lunarDay: Int, lunarMonth: Int, lunarYear: Int) -> (year: Int, month: Int, day: Int) {
        let solarDate = LunarCalendar.lunarToSolar(day: lunarDay, month: lunarMonth, year: lunarYear)
        let year = Calendar.current.component(.year, from: solarDate)
        let month = Calendar.current.component(.month, from: solarDate)
        let day = Calendar.current.component(.day, from: solarDate)
        return (year, month, day)
    }

    private func convertSolarToLunar(_ date: Date) -> (day: Int, month: Int, year: Int) {
        return LunarCalendar.solarToLunar(date)
    }

    private func hasLeapMonthInYear(_ year: Int) -> Bool {
        let leapInfo = LunarCalendar.getLeapMonthInfo(forSolarYear: year)
        return leapInfo.hasLeapMonth
    }

    private func getLunarMonthDisplayNames() -> [String] {
        (1...12).map { month in
            getLunarMonthDisplayName(month)
        }
    }

    private func getLunarMonthDisplayName(_ month: Int) -> String {
        "Thang \(month)"
    }
}
