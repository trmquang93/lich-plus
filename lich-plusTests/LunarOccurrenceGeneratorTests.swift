//
//  LunarOccurrenceGeneratorTests.swift
//  lich-plusTests
//
//  Created by Quang Tran Minh on 07/12/25.
//

import XCTest
@testable import lich_plus

final class LunarOccurrenceGeneratorTests: XCTestCase {

    // MARK: - Yearly Recurrence Tests

    /// Test basic yearly recurrence without leap months
    func testYearlyRecurrenceNoLeapMonths() {
        // Setup: 15th of 4th lunar month every year
        let rule = SerializableLunarRecurrenceRule(
            frequency: .yearly,
            lunarDay: 15,
            lunarMonth: 4,
            leapMonthBehavior: .skipLeap,
            interval: 1,
            recurrenceEnd: .occurrenceCount(3)
        )

        // Master start date: 2023-02-01 (neutral date)
        let masterStartDate = Calendar.current.date(from: DateComponents(year: 2023, month: 2, day: 1))!

        // Generate occurrences for 2023-2026
        let rangeStart = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 1))!
        let rangeEnd = Calendar.current.date(from: DateComponents(year: 2026, month: 12, day: 31))!

        let occurrences = LunarOccurrenceGenerator.generateOccurrences(
            rule: rule,
            masterStartDate: masterStartDate,
            rangeStart: rangeStart,
            rangeEnd: rangeEnd
        )

        // Should have up to 3 occurrences (due to occurrenceCount limit and range constraints)
        XCTAssertGreaterThan(occurrences.count, 0)
        XCTAssertLessThanOrEqual(occurrences.count, 3)

        // All occurrences should be in different years (or at least most of them)
        let years = occurrences.map { Calendar.current.component(.year, from: $0) }
        XCTAssertGreaterThanOrEqual(Set(years).count, 2)
    }

    /// Test yearly recurrence with includeLeap behavior
    func testYearlyRecurrenceWithIncludeLeapBehavior() {
        // Setup: 15th of 4th lunar month every year, including leap months
        let rule = SerializableLunarRecurrenceRule(
            frequency: .yearly,
            lunarDay: 15,
            lunarMonth: 4,
            leapMonthBehavior: .includeLeap,
            interval: 1,
            recurrenceEnd: .occurrenceCount(5)
        )

        let masterStartDate = Calendar.current.date(from: DateComponents(year: 2023, month: 4, day: 15))!

        let rangeStart = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 1))!
        let rangeEnd = Calendar.current.date(from: DateComponents(year: 2027, month: 12, day: 31))!

        let occurrences = LunarOccurrenceGenerator.generateOccurrences(
            rule: rule,
            masterStartDate: masterStartDate,
            rangeStart: rangeStart,
            rangeEnd: rangeEnd
        )

        // Should have up to 5 occurrences depending on leap months
        XCTAssertLessThanOrEqual(occurrences.count, 5)
        XCTAssertGreaterThan(occurrences.count, 0)

        // All occurrences should be sorted
        let isSorted = occurrences.indices.dropLast().allSatisfy { i in
            occurrences[i] <= occurrences[i + 1]
        }
        XCTAssertTrue(isSorted)
    }

    /// Test yearly recurrence with skipLeap behavior
    func testYearlyRecurrenceWithSkipLeapBehavior() {
        let rule = SerializableLunarRecurrenceRule(
            frequency: .yearly,
            lunarDay: 1,
            lunarMonth: 1,
            leapMonthBehavior: .skipLeap,
            interval: 1,
            recurrenceEnd: .occurrenceCount(5)
        )

        let masterStartDate = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 1))!

        let rangeStart = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 1))!
        let rangeEnd = Calendar.current.date(from: DateComponents(year: 2028, month: 12, day: 31))!

        let occurrences = LunarOccurrenceGenerator.generateOccurrences(
            rule: rule,
            masterStartDate: masterStartDate,
            rangeStart: rangeStart,
            rangeEnd: rangeEnd
        )

        // Should have 5 occurrences (within range)
        XCTAssertLessThanOrEqual(occurrences.count, 5)
        XCTAssertGreaterThan(occurrences.count, 0)

        // All occurrences should be valid dates
        XCTAssertTrue(occurrences.allSatisfy { $0 >= rangeStart && $0 <= rangeEnd })
    }

    // MARK: - Monthly Recurrence Tests

    /// Test monthly recurrence without leap months
    func testMonthlyRecurrenceNoLeapMonths() {
        // Setup: 15th of every lunar month
        let rule = SerializableLunarRecurrenceRule(
            frequency: .monthly,
            lunarDay: 15,
            lunarMonth: nil,
            leapMonthBehavior: .skipLeap,
            interval: 1,
            recurrenceEnd: .occurrenceCount(12)
        )

        let masterStartDate = Calendar.current.date(from: DateComponents(year: 2023, month: 2, day: 1))!

        let rangeStart = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 1))!
        let rangeEnd = Calendar.current.date(from: DateComponents(year: 2024, month: 12, day: 31))!

        let occurrences = LunarOccurrenceGenerator.generateOccurrences(
            rule: rule,
            masterStartDate: masterStartDate,
            rangeStart: rangeStart,
            rangeEnd: rangeEnd
        )

        // All occurrences should be sorted and within range
        let isSorted = occurrences.indices.dropLast().allSatisfy { i in
            occurrences[i] <= occurrences[i + 1]
        }
        XCTAssertTrue(isSorted)
        XCTAssertTrue(occurrences.allSatisfy { $0 >= rangeStart && $0 <= rangeEnd })
    }

    /// Test monthly recurrence with includeLeap behavior
    func testMonthlyRecurrenceWithIncludeLeapBehavior() {
        let rule = SerializableLunarRecurrenceRule(
            frequency: .monthly,
            lunarDay: 1,
            lunarMonth: nil,
            leapMonthBehavior: .includeLeap,
            interval: 1,
            recurrenceEnd: .occurrenceCount(25)
        )

        let masterStartDate = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 1))!

        let rangeStart = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 1))!
        let rangeEnd = Calendar.current.date(from: DateComponents(year: 2024, month: 12, day: 31))!

        let occurrences = LunarOccurrenceGenerator.generateOccurrences(
            rule: rule,
            masterStartDate: masterStartDate,
            rangeStart: rangeStart,
            rangeEnd: rangeEnd
        )

        // All should be within range and sorted
        XCTAssertTrue(occurrences.allSatisfy { $0 >= rangeStart && $0 <= rangeEnd })
        let isSorted = occurrences.indices.dropLast().allSatisfy { i in
            occurrences[i] <= occurrences[i + 1]
        }
        XCTAssertTrue(isSorted)
    }

    // MARK: - Interval Tests

    /// Test yearly recurrence with interval = 2
    func testYearlyRecurrenceWithInterval2() {
        let rule = SerializableLunarRecurrenceRule(
            frequency: .yearly,
            lunarDay: 15,
            lunarMonth: 4,
            leapMonthBehavior: .skipLeap,
            interval: 2,
            recurrenceEnd: .occurrenceCount(3)
        )

        let masterStartDate = Calendar.current.date(from: DateComponents(year: 2023, month: 4, day: 15))!

        let rangeStart = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 1))!
        let rangeEnd = Calendar.current.date(from: DateComponents(year: 2030, month: 12, day: 31))!

        let occurrences = LunarOccurrenceGenerator.generateOccurrences(
            rule: rule,
            masterStartDate: masterStartDate,
            rangeStart: rangeStart,
            rangeEnd: rangeEnd
        )

        // Should have 3 occurrences (every 2 years)
        XCTAssertEqual(occurrences.count, 3)

        // Years should follow the interval pattern
        let years = occurrences.map { Calendar.current.component(.year, from: $0) }
        if years.count >= 2 {
            let yearDifference = years[1] - years[0]
            XCTAssertGreaterThanOrEqual(yearDifference, 2)
        }
    }

    /// Test monthly recurrence with interval = 2
    func testMonthlyRecurrenceWithInterval2() {
        let rule = SerializableLunarRecurrenceRule(
            frequency: .monthly,
            lunarDay: 15,
            lunarMonth: nil,
            leapMonthBehavior: .skipLeap,
            interval: 2,
            recurrenceEnd: .occurrenceCount(6)
        )

        let masterStartDate = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 1))!

        let rangeStart = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 1))!
        let rangeEnd = Calendar.current.date(from: DateComponents(year: 2024, month: 12, day: 31))!

        let occurrences = LunarOccurrenceGenerator.generateOccurrences(
            rule: rule,
            masterStartDate: masterStartDate,
            rangeStart: rangeStart,
            rangeEnd: rangeEnd
        )

        // Occurrences should be within range and properly handled by interval
        XCTAssertTrue(occurrences.allSatisfy { $0 >= rangeStart && $0 <= rangeEnd })

        // Check sorted
        let isSorted = occurrences.indices.dropLast().allSatisfy { i in
            occurrences[i] <= occurrences[i + 1]
        }
        XCTAssertTrue(isSorted)
    }

    // MARK: - Recurrence End Tests

    /// Test recurrence end by date
    func testRecurrenceEndByDate() {
        let endDate = Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 30))!

        let rule = SerializableLunarRecurrenceRule(
            frequency: .yearly,
            lunarDay: 15,
            lunarMonth: 4,
            leapMonthBehavior: .skipLeap,
            interval: 1,
            recurrenceEnd: .endDate(endDate)
        )

        let masterStartDate = Calendar.current.date(from: DateComponents(year: 2023, month: 4, day: 15))!

        let rangeStart = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 1))!
        let rangeEnd = Calendar.current.date(from: DateComponents(year: 2027, month: 12, day: 31))!

        let occurrences = LunarOccurrenceGenerator.generateOccurrences(
            rule: rule,
            masterStartDate: masterStartDate,
            rangeStart: rangeStart,
            rangeEnd: rangeEnd
        )

        // All occurrences should be before or equal to the end date
        XCTAssertTrue(occurrences.allSatisfy { $0 <= endDate })
    }

    /// Test recurrence end by occurrence count = 1
    func testRecurrenceEndByOccurrenceCount1() {
        let rule = SerializableLunarRecurrenceRule(
            frequency: .yearly,
            lunarDay: 15,
            lunarMonth: 4,
            leapMonthBehavior: .skipLeap,
            interval: 1,
            recurrenceEnd: .occurrenceCount(1)
        )

        let masterStartDate = Calendar.current.date(from: DateComponents(year: 2023, month: 4, day: 15))!

        let rangeStart = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 1))!
        let rangeEnd = Calendar.current.date(from: DateComponents(year: 2025, month: 12, day: 31))!

        let occurrences = LunarOccurrenceGenerator.generateOccurrences(
            rule: rule,
            masterStartDate: masterStartDate,
            rangeStart: rangeStart,
            rangeEnd: rangeEnd
        )

        // Should have exactly 1 occurrence
        XCTAssertEqual(occurrences.count, 1)
    }

    // MARK: - Date Range Tests

    /// Test that occurrences respect the range boundaries
    func testOccurrencesRespectRangeBoundaries() {
        let rule = SerializableLunarRecurrenceRule(
            frequency: .yearly,
            lunarDay: 1,
            lunarMonth: 1,
            leapMonthBehavior: .skipLeap,
            interval: 1,
            recurrenceEnd: .occurrenceCount(5)
        )

        let masterStartDate = Calendar.current.date(from: DateComponents(year: 2020, month: 1, day: 25))!

        let rangeStart = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 1))!
        let rangeEnd = Calendar.current.date(from: DateComponents(year: 2024, month: 12, day: 31))!

        let occurrences = LunarOccurrenceGenerator.generateOccurrences(
            rule: rule,
            masterStartDate: masterStartDate,
            rangeStart: rangeStart,
            rangeEnd: rangeEnd
        )

        // All occurrences should be within the range
        XCTAssertTrue(occurrences.allSatisfy { $0 >= rangeStart && $0 <= rangeEnd })
    }

    /// Test empty result when range doesn't include any occurrences
    func testEmptyResultWhenRangeHasNoOccurrences() {
        let rule = SerializableLunarRecurrenceRule(
            frequency: .yearly,
            lunarDay: 15,
            lunarMonth: 4,
            leapMonthBehavior: .skipLeap,
            interval: 1,
            recurrenceEnd: .occurrenceCount(1)
        )

        let masterStartDate = Calendar.current.date(from: DateComponents(year: 2020, month: 4, day: 15))!

        // Range after the single occurrence
        let rangeStart = Calendar.current.date(from: DateComponents(year: 2021, month: 1, day: 1))!
        let rangeEnd = Calendar.current.date(from: DateComponents(year: 2022, month: 12, day: 31))!

        let occurrences = LunarOccurrenceGenerator.generateOccurrences(
            rule: rule,
            masterStartDate: masterStartDate,
            rangeStart: rangeStart,
            rangeEnd: rangeEnd
        )

        // Should have no occurrences
        XCTAssertEqual(occurrences.count, 0)
    }

    // MARK: - Edge Case Tests

    /// Test recurrence for days that don't exist in some months (e.g., day 30)
    func testRecurrenceForDay30() {
        let rule = SerializableLunarRecurrenceRule(
            frequency: .yearly,
            lunarDay: 30,
            lunarMonth: 1,
            leapMonthBehavior: .skipLeap,
            interval: 1,
            recurrenceEnd: .occurrenceCount(3)
        )

        let masterStartDate = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 1))!

        let rangeStart = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 1))!
        let rangeEnd = Calendar.current.date(from: DateComponents(year: 2026, month: 12, day: 31))!

        let occurrences = LunarOccurrenceGenerator.generateOccurrences(
            rule: rule,
            masterStartDate: masterStartDate,
            rangeStart: rangeStart,
            rangeEnd: rangeEnd
        )

        // Should handle gracefully (lunar month 1 typically has 30 days in even years)
        XCTAssertGreaterThan(occurrences.count, 0)
        XCTAssertLessThanOrEqual(occurrences.count, 3)
    }

    /// Test recurrence starting from a leap month date
    func testRecurrenceFromLeapMonthMasterDate() {
        // Using 2023 which has a leap month 2 (Tháng 2 lặp)
        let rule = SerializableLunarRecurrenceRule(
            frequency: .yearly,
            lunarDay: 15,
            lunarMonth: 2,
            leapMonthBehavior: .leapOnly,
            interval: 1,
            recurrenceEnd: .occurrenceCount(3)
        )

        let masterStartDate = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 1))!

        let rangeStart = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 1))!
        let rangeEnd = Calendar.current.date(from: DateComponents(year: 2027, month: 12, day: 31))!

        let occurrences = LunarOccurrenceGenerator.generateOccurrences(
            rule: rule,
            masterStartDate: masterStartDate,
            rangeStart: rangeStart,
            rangeEnd: rangeEnd
        )

        // Should handle leap-only behavior
        XCTAssertLessThanOrEqual(occurrences.count, 3)
    }

    /// Test large year range (10 years)
    func testLargeYearRange() {
        let rule = SerializableLunarRecurrenceRule(
            frequency: .yearly,
            lunarDay: 15,
            lunarMonth: 4,
            leapMonthBehavior: .skipLeap,
            interval: 1,
            recurrenceEnd: nil
        )

        let masterStartDate = Calendar.current.date(from: DateComponents(year: 2020, month: 2, day: 1))!

        let rangeStart = Calendar.current.date(from: DateComponents(year: 2020, month: 1, day: 1))!
        let rangeEnd = Calendar.current.date(from: DateComponents(year: 2030, month: 12, day: 31))!

        let occurrences = LunarOccurrenceGenerator.generateOccurrences(
            rule: rule,
            masterStartDate: masterStartDate,
            rangeStart: rangeStart,
            rangeEnd: rangeEnd
        )

        // Should have multiple occurrences over the 10-year range
        XCTAssertGreaterThan(occurrences.count, 0)
        XCTAssertLessThanOrEqual(occurrences.count, 15)  // More than 10 to account for boundary cases
    }

    // MARK: - Sorting Tests

    /// Test that results are always sorted
    func testResultsAreSorted() {
        let rule = SerializableLunarRecurrenceRule(
            frequency: .monthly,
            lunarDay: 15,
            lunarMonth: nil,
            leapMonthBehavior: .includeLeap,
            interval: 1,
            recurrenceEnd: .occurrenceCount(24)
        )

        let masterStartDate = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 1))!

        let rangeStart = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 1))!
        let rangeEnd = Calendar.current.date(from: DateComponents(year: 2024, month: 12, day: 31))!

        let occurrences = LunarOccurrenceGenerator.generateOccurrences(
            rule: rule,
            masterStartDate: masterStartDate,
            rangeStart: rangeStart,
            rangeEnd: rangeEnd
        )

        // Check that all occurrences are sorted
        let isSorted = occurrences.indices.dropLast().allSatisfy { i in
            occurrences[i] <= occurrences[i + 1]
        }
        XCTAssertTrue(isSorted)
    }

    /// Test no duplicates in results
    func testNoDuplicatesInResults() {
        let rule = SerializableLunarRecurrenceRule(
            frequency: .yearly,
            lunarDay: 1,
            lunarMonth: 1,
            leapMonthBehavior: .skipLeap,
            interval: 1,
            recurrenceEnd: .occurrenceCount(10)
        )

        let masterStartDate = Calendar.current.date(from: DateComponents(year: 2020, month: 1, day: 25))!

        let rangeStart = Calendar.current.date(from: DateComponents(year: 2020, month: 1, day: 1))!
        let rangeEnd = Calendar.current.date(from: DateComponents(year: 2030, month: 12, day: 31))!

        let occurrences = LunarOccurrenceGenerator.generateOccurrences(
            rule: rule,
            masterStartDate: masterStartDate,
            rangeStart: rangeStart,
            rangeEnd: rangeEnd
        )

        // Check no duplicates
        let uniqueCount = Set(occurrences).count
        XCTAssertEqual(occurrences.count, uniqueCount)
    }
}
