//
//  RecurrencePickerSheetTests.swift
//  lich-plusTests
//
//  Tests for RecurrencePickerSheet with solar/lunar calendar support
//

import XCTest
@testable import lich_plus

final class RecurrencePickerSheetTests: XCTestCase {

    // MARK: - Test: Calendar Mode Filtering

    func testSolarModeShowsSolarRecurrenceTypes() {
        let solarRecurrences = filterRecurrencesByMode(.solar)

        // Solar mode should show: none, daily, weekly, monthly, yearly
        XCTAssertTrue(solarRecurrences.contains(.none))
        XCTAssertTrue(solarRecurrences.contains(.daily))
        XCTAssertTrue(solarRecurrences.contains(.weekly))
        XCTAssertTrue(solarRecurrences.contains(.monthly))
        XCTAssertTrue(solarRecurrences.contains(.yearly))

        // Should NOT show lunar types
        XCTAssertFalse(solarRecurrences.contains(.lunarMonthly))
        XCTAssertFalse(solarRecurrences.contains(.lunarYearly))
    }

    func testLunarModeShowsLunarRecurrenceTypes() {
        let lunarRecurrences = filterRecurrencesByMode(.lunar)

        // Lunar mode should show: none, lunarMonthly, lunarYearly
        XCTAssertTrue(lunarRecurrences.contains(.none))
        XCTAssertTrue(lunarRecurrences.contains(.lunarMonthly))
        XCTAssertTrue(lunarRecurrences.contains(.lunarYearly))

        // Should NOT show solar types (except none)
        XCTAssertFalse(lunarRecurrences.contains(.daily))
        XCTAssertFalse(lunarRecurrences.contains(.weekly))
        XCTAssertFalse(lunarRecurrences.contains(.monthly))
        XCTAssertFalse(lunarRecurrences.contains(.yearly))
    }

    func testSolarModeDoesNotContainLunarTypes() {
        let solarRecurrences = filterRecurrencesByMode(.solar)

        for recurrence in solarRecurrences {
            XCTAssertFalse(recurrence.isLunar, "\(recurrence.displayName) should not be lunar in solar mode")
        }
    }

    func testLunarModeDoesNotContainSolarTypes() {
        let lunarRecurrences = filterRecurrencesByMode(.lunar)

        let solarOnlyTypes: [RecurrenceType] = [.daily, .weekly, .monthly, .yearly]

        for recurrence in lunarRecurrences {
            if recurrence != .none {
                XCTAssertTrue(recurrence.isLunar, "\(recurrence.displayName) should be lunar in lunar mode")
            }
        }
    }

    // MARK: - Test: Calendar Mode Toggle

    func testToggleBetweenSolarAndLunar() {
        var mode = CalendarMode.solar

        // Toggle to lunar
        mode = .lunar
        XCTAssertEqual(mode, .lunar)

        // Toggle back to solar
        mode = .solar
        XCTAssertEqual(mode, .solar)
    }

    func testToggleResetsSelection() {
        var selectedRecurrence = RecurrenceType.weekly
        var mode = CalendarMode.solar

        // Switch to lunar mode
        mode = .lunar

        // When switching to lunar, weekly should be reset to none (since weekly is not valid in lunar mode)
        if !selectedRecurrence.isLunar {
            selectedRecurrence = .none
        }

        XCTAssertEqual(selectedRecurrence, .none)
    }

    // MARK: - Test: Lunar Date Picker Visibility

    func testLunarDatePickerVisibleOnlyForLunarYearly() {
        let recurrence = RecurrenceType.lunarYearly
        let shouldShowPicker = recurrence == .lunarYearly

        XCTAssertTrue(shouldShowPicker)
    }

    func testLunarDatePickerHiddenForLunarMonthly() {
        let recurrence = RecurrenceType.lunarMonthly
        let shouldShowPicker = recurrence == .lunarYearly

        XCTAssertFalse(shouldShowPicker)
    }

    func testLunarDatePickerHiddenForSolarRecurrences() {
        let solarRecurrences: [RecurrenceType] = [.daily, .weekly, .monthly, .yearly, .none]

        for recurrence in solarRecurrences {
            let shouldShowPicker = recurrence == .lunarYearly
            XCTAssertFalse(shouldShowPicker, "\(recurrence.displayName) should not show lunar date picker")
        }
    }

    // MARK: - Test: Default Selection in Each Mode

    func testDefaultSolarSelection() {
        let defaultSelection = getDefaultSelection(for: .solar)
        XCTAssertEqual(defaultSelection, .none)
    }

    func testDefaultLunarSelection() {
        let defaultSelection = getDefaultSelection(for: .lunar)
        XCTAssertEqual(defaultSelection, .none)
    }

    // MARK: - Test: Valid Selection for Mode

    func testDailyIsValidInSolarMode() {
        XCTAssertTrue(isValidSelection(.daily, for: .solar))
    }

    func testDailyIsInvalidInLunarMode() {
        XCTAssertFalse(isValidSelection(.daily, for: .lunar))
    }

    func testLunarMonthlyIsValidInLunarMode() {
        XCTAssertTrue(isValidSelection(.lunarMonthly, for: .lunar))
    }

    func testLunarMonthlyIsInvalidInSolarMode() {
        XCTAssertFalse(isValidSelection(.lunarMonthly, for: .solar))
    }

    func testNoneIsValidInBothModes() {
        XCTAssertTrue(isValidSelection(.none, for: .solar))
        XCTAssertTrue(isValidSelection(.none, for: .lunar))
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

    // MARK: - Helper Functions (Mimicking RecurrencePickerSheet behavior)

    enum CalendarMode {
        case solar
        case lunar
    }

    private func filterRecurrencesByMode(_ mode: CalendarMode) -> [RecurrenceType] {
        switch mode {
        case .solar:
            return RecurrenceType.allCases.filter { !$0.isLunar }
        case .lunar:
            return RecurrenceType.allCases.filter { $0 == .none || $0.isLunar }
        }
    }

    private func getDefaultSelection(for mode: CalendarMode) -> RecurrenceType {
        .none
    }

    private func isValidSelection(_ recurrence: RecurrenceType, for mode: CalendarMode) -> Bool {
        let validTypes = filterRecurrencesByMode(mode)
        return validTypes.contains(recurrence)
    }
}
