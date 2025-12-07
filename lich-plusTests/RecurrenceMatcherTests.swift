//
//  RecurrenceMatcherTests.swift
//  lich-plusTests
//
//  Created by Quang Tran Minh on 07/12/25.
//

import XCTest
@testable import lich_plus

final class RecurrenceMatcherTests: XCTestCase {

    // MARK: - Solar Daily Recurrence Tests

    func testDailyRecurrence() {
        // Create a daily recurrence rule
        let rule = SerializableRecurrenceRule(frequency: 0, interval: 1)

        let calendar = Calendar.current
        let masterDate = calendar.date(from: DateComponents(year: 2025, month: 12, day: 1))!

        // Test: Day 1 (master date) should match
        XCTAssertTrue(RecurrenceMatcher.solarRuleMatchesDate(
            rule: rule,
            masterStartDate: masterDate,
            targetDate: masterDate
        ))

        // Test: Day 2 should match
        let day2 = calendar.date(byAdding: .day, value: 1, to: masterDate)!
        XCTAssertTrue(RecurrenceMatcher.solarRuleMatchesDate(
            rule: rule,
            masterStartDate: masterDate,
            targetDate: day2
        ))

        // Test: Day 10 should match
        let day10 = calendar.date(byAdding: .day, value: 9, to: masterDate)!
        XCTAssertTrue(RecurrenceMatcher.solarRuleMatchesDate(
            rule: rule,
            masterStartDate: masterDate,
            targetDate: day10
        ))

        // Test: Date before master should not match
        let dayBefore = calendar.date(byAdding: .day, value: -1, to: masterDate)!
        XCTAssertFalse(RecurrenceMatcher.solarRuleMatchesDate(
            rule: rule,
            masterStartDate: masterDate,
            targetDate: dayBefore
        ))
    }

    func testDailyRecurrenceWithInterval() {
        // Every 2 days
        let rule = SerializableRecurrenceRule(frequency: 0, interval: 2)

        let calendar = Calendar.current
        let masterDate = calendar.date(from: DateComponents(year: 2025, month: 12, day: 1))!

        // Test: Day 1 should match
        XCTAssertTrue(RecurrenceMatcher.solarRuleMatchesDate(
            rule: rule,
            masterStartDate: masterDate,
            targetDate: masterDate
        ))

        // Test: Day 2 should NOT match (interval = 2)
        let day2 = calendar.date(byAdding: .day, value: 1, to: masterDate)!
        XCTAssertFalse(RecurrenceMatcher.solarRuleMatchesDate(
            rule: rule,
            masterStartDate: masterDate,
            targetDate: day2
        ))

        // Test: Day 3 should match (2 days after master)
        let day3 = calendar.date(byAdding: .day, value: 2, to: masterDate)!
        XCTAssertTrue(RecurrenceMatcher.solarRuleMatchesDate(
            rule: rule,
            masterStartDate: masterDate,
            targetDate: day3
        ))

        // Test: Day 5 should match (4 days after master)
        let day5 = calendar.date(byAdding: .day, value: 4, to: masterDate)!
        XCTAssertTrue(RecurrenceMatcher.solarRuleMatchesDate(
            rule: rule,
            masterStartDate: masterDate,
            targetDate: day5
        ))
    }

    // MARK: - Solar Weekly Recurrence Tests

    func testWeeklyRecurrence() {
        // Every week on Monday
        let rule = SerializableRecurrenceRule(frequency: 1, interval: 1)

        let calendar = Calendar.current
        // Dec 1, 2025 is a Monday
        let masterDate = calendar.date(from: DateComponents(year: 2025, month: 12, day: 1))!

        // Test: Same day should match
        XCTAssertTrue(RecurrenceMatcher.solarRuleMatchesDate(
            rule: rule,
            masterStartDate: masterDate,
            targetDate: masterDate
        ))

        // Test: Next Monday (Dec 8) should match
        let nextMonday = calendar.date(byAdding: .day, value: 7, to: masterDate)!
        XCTAssertTrue(RecurrenceMatcher.solarRuleMatchesDate(
            rule: rule,
            masterStartDate: masterDate,
            targetDate: nextMonday
        ))

        // Test: Tuesday (Dec 2) should NOT match
        let tuesday = calendar.date(byAdding: .day, value: 1, to: masterDate)!
        XCTAssertFalse(RecurrenceMatcher.solarRuleMatchesDate(
            rule: rule,
            masterStartDate: masterDate,
            targetDate: tuesday
        ))
    }

    // MARK: - Solar Monthly Recurrence Tests

    func testMonthlyRecurrence() {
        // Every month on the 15th
        let rule = SerializableRecurrenceRule(frequency: 2, interval: 1)

        let calendar = Calendar.current
        let masterDate = calendar.date(from: DateComponents(year: 2025, month: 12, day: 15))!

        // Test: Same day should match
        XCTAssertTrue(RecurrenceMatcher.solarRuleMatchesDate(
            rule: rule,
            masterStartDate: masterDate,
            targetDate: masterDate
        ))

        // Test: Jan 15, 2026 should match
        let nextMonth = calendar.date(from: DateComponents(year: 2026, month: 1, day: 15))!
        XCTAssertTrue(RecurrenceMatcher.solarRuleMatchesDate(
            rule: rule,
            masterStartDate: masterDate,
            targetDate: nextMonth
        ))

        // Test: Dec 16, 2025 should NOT match (wrong day)
        let wrongDay = calendar.date(from: DateComponents(year: 2025, month: 12, day: 16))!
        XCTAssertFalse(RecurrenceMatcher.solarRuleMatchesDate(
            rule: rule,
            masterStartDate: masterDate,
            targetDate: wrongDay
        ))
    }

    // MARK: - Solar Yearly Recurrence Tests

    func testYearlyRecurrence() {
        // Every year on Dec 25
        let rule = SerializableRecurrenceRule(frequency: 3, interval: 1)

        let calendar = Calendar.current
        let masterDate = calendar.date(from: DateComponents(year: 2025, month: 12, day: 25))!

        // Test: Same day should match
        XCTAssertTrue(RecurrenceMatcher.solarRuleMatchesDate(
            rule: rule,
            masterStartDate: masterDate,
            targetDate: masterDate
        ))

        // Test: Dec 25, 2026 should match
        let nextYear = calendar.date(from: DateComponents(year: 2026, month: 12, day: 25))!
        XCTAssertTrue(RecurrenceMatcher.solarRuleMatchesDate(
            rule: rule,
            masterStartDate: masterDate,
            targetDate: nextYear
        ))

        // Test: Dec 25, 2030 should match
        let fiveYearsLater = calendar.date(from: DateComponents(year: 2030, month: 12, day: 25))!
        XCTAssertTrue(RecurrenceMatcher.solarRuleMatchesDate(
            rule: rule,
            masterStartDate: masterDate,
            targetDate: fiveYearsLater
        ))

        // Test: Dec 26, 2026 should NOT match (wrong day)
        let wrongDay = calendar.date(from: DateComponents(year: 2026, month: 12, day: 26))!
        XCTAssertFalse(RecurrenceMatcher.solarRuleMatchesDate(
            rule: rule,
            masterStartDate: masterDate,
            targetDate: wrongDay
        ))
    }

    // MARK: - Lunar Recurrence Tests

    func testLunarYearlyRecurrence() {
        // Lunar yearly recurrence on 1/1 (Tết)
        let rule = SerializableLunarRecurrenceRule(
            frequency: .yearly,
            lunarDay: 1,
            lunarMonth: 1,
            leapMonthBehavior: .skipLeap,
            interval: 1
        )

        // Tết 2025: January 29, 2025 (Lunar 1/1/2025)
        let tet2025 = Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 29))!

        // Test: Tết 2025 should match
        XCTAssertTrue(RecurrenceMatcher.lunarRuleMatchesDate(
            rule: rule,
            masterStartDate: tet2025,
            targetDate: tet2025
        ))

        // Tết 2026: February 17, 2026 (Lunar 1/1/2026)
        let tet2026 = Calendar.current.date(from: DateComponents(year: 2026, month: 2, day: 17))!
        XCTAssertTrue(RecurrenceMatcher.lunarRuleMatchesDate(
            rule: rule,
            masterStartDate: tet2025,
            targetDate: tet2026
        ))

        // Test: Random day should NOT match
        let randomDay = Calendar.current.date(from: DateComponents(year: 2025, month: 3, day: 15))!
        XCTAssertFalse(RecurrenceMatcher.lunarRuleMatchesDate(
            rule: rule,
            masterStartDate: tet2025,
            targetDate: randomDay
        ))
    }

    func testLunarMonthlyRecurrence() {
        // Lunar monthly recurrence on day 1 (new moon)
        let rule = SerializableLunarRecurrenceRule(
            frequency: .monthly,
            lunarDay: 1,
            lunarMonth: nil,
            leapMonthBehavior: .includeLeap,
            interval: 1
        )

        let calendar = Calendar.current
        // Jan 29, 2025 is Lunar 1/1/2025 (Tết)
        let tet2025 = calendar.date(from: DateComponents(year: 2025, month: 1, day: 29))!

        // Test: Tết (Lunar 1/1) should match
        XCTAssertTrue(RecurrenceMatcher.lunarRuleMatchesDate(
            rule: rule,
            masterStartDate: tet2025,
            targetDate: tet2025
        ))

        // Feb 28, 2025 is Lunar 2/1/2025
        let lunar2_1 = calendar.date(from: DateComponents(year: 2025, month: 2, day: 28))!
        XCTAssertTrue(RecurrenceMatcher.lunarRuleMatchesDate(
            rule: rule,
            masterStartDate: tet2025,
            targetDate: lunar2_1
        ))

        // Test: Non-1st lunar day should NOT match
        // Jan 30, 2025 is Lunar 1/2/2025 (day after Tết)
        let dayAfterTet = calendar.date(from: DateComponents(year: 2025, month: 1, day: 30))!
        XCTAssertFalse(RecurrenceMatcher.lunarRuleMatchesDate(
            rule: rule,
            masterStartDate: tet2025,
            targetDate: dayAfterTet
        ))
    }

    // MARK: - Recurrence End Tests

    func testSolarRecurrenceWithEndDate() {
        // Daily recurrence ending on Dec 5, 2025
        let endDate = Calendar.current.date(from: DateComponents(year: 2025, month: 12, day: 5))!
        let rule = SerializableRecurrenceRule(
            frequency: 0,
            interval: 1,
            recurrenceEnd: .endDate(endDate)
        )

        let calendar = Calendar.current
        let masterDate = calendar.date(from: DateComponents(year: 2025, month: 12, day: 1))!

        // Test: Dec 3 should match (before end date)
        let dec3 = calendar.date(from: DateComponents(year: 2025, month: 12, day: 3))!
        XCTAssertTrue(RecurrenceMatcher.solarRuleMatchesDate(
            rule: rule,
            masterStartDate: masterDate,
            targetDate: dec3
        ))

        // Test: Dec 5 should match (on end date)
        XCTAssertTrue(RecurrenceMatcher.solarRuleMatchesDate(
            rule: rule,
            masterStartDate: masterDate,
            targetDate: endDate
        ))

        // Test: Dec 10 should NOT match (after end date)
        let dec10 = calendar.date(from: DateComponents(year: 2025, month: 12, day: 10))!
        XCTAssertFalse(RecurrenceMatcher.solarRuleMatchesDate(
            rule: rule,
            masterStartDate: masterDate,
            targetDate: dec10
        ))
    }
}
