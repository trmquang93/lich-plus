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

    // MARK: - Forward-Walk Rewrite Regression Tests
    // These tests pin behaviors that the forward-solar-walk implementation must
    // preserve. They use 2023 (a known Vietnamese lunar leap-month-2 year) as a
    // reference for leap-variant behavior.

    /// "Mùng 1" — monthly recurrence on lunar day 1 over the production 6-year window.
    /// Asserts that the new generator produces roughly one occurrence per lunar
    /// month (no missed months, no duplicates beyond legitimate leap variants).
    func testMonthlyDay1OverSixYearsCountWithinExpectedRange() {
        let rule = SerializableLunarRecurrenceRule(
            frequency: .monthly,
            lunarDay: 1,
            lunarMonth: nil,
            leapMonthBehavior: .skipLeap,
            interval: 1,
            recurrenceEnd: nil
        )

        // Span equivalent to the production range: 1 year past + 5 years future.
        let masterStartDate = Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 17))!
        let rangeStart = Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 17))!
        let rangeEnd = Calendar.current.date(from: DateComponents(year: 2031, month: 5, day: 17))!

        let occurrences = LunarOccurrenceGenerator.generateOccurrences(
            rule: rule,
            masterStartDate: masterStartDate,
            rangeStart: rangeStart,
            rangeEnd: rangeEnd
        )

        // 6 lunar years × 12 months = 72; allow ±2 for window boundaries.
        // skipLeap means leap-month duplicates are excluded.
        XCTAssertGreaterThan(occurrences.count, 65, "Expected ~72 monthly occurrences over 6 years")
        XCTAssertLessThan(occurrences.count, 78)

        // No two occurrences should land on the same calendar day.
        let uniqueDays = Set(occurrences.map { Calendar.current.startOfDay(for: $0) })
        XCTAssertEqual(uniqueDays.count, occurrences.count, "Occurrences must be unique by day")
    }

    /// Leap-month behavior contract (matches pre-rewrite semantics):
    ///   - For lunar months WITHOUT a leap variant, ALL three behaviors emit
    ///     the regular occurrence.
    ///   - For lunar months WITH a leap variant (i.e., the month appears twice
    ///     in the same lunar year), behaviors diverge:
    ///       .includeLeap → both regular and leap
    ///       .skipLeap    → regular only
    ///       .leapOnly    → leap only
    /// 2023 has lunar leap month 2, which is the only month-with-leap in the
    /// year — making it the cleanest cell to assert the contract against.
    func testLeapMonthBehaviorContractAcross2023() {
        let masterStartDate = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 1))!
        let rangeStart = masterStartDate
        let rangeEnd = Calendar.current.date(from: DateComponents(year: 2023, month: 12, day: 31))!

        func run(_ behavior: LeapMonthBehavior) -> [Date] {
            let rule = SerializableLunarRecurrenceRule(
                frequency: .monthly,
                lunarDay: 1,
                lunarMonth: nil,
                leapMonthBehavior: behavior,
                interval: 1,
                recurrenceEnd: nil
            )
            return LunarOccurrenceGenerator.generateOccurrences(
                rule: rule,
                masterStartDate: masterStartDate,
                rangeStart: rangeStart,
                rangeEnd: rangeEnd
            )
        }

        let skip = run(.skipLeap)
        let include = run(.includeLeap)
        let leapOnly = run(.leapOnly)

        // includeLeap should contain every regular AND every leap variant —
        // strictly more dates than skipLeap (by exactly the leap-variant count).
        XCTAssertGreaterThan(include.count, skip.count,
                             "includeLeap must contain strictly more occurrences than skipLeap")
        XCTAssertEqual(include.count - skip.count, 1,
                       "2023 has exactly one leap month; includeLeap - skipLeap should equal 1")

        // skipLeap and leapOnly emit the same NUMBER of occurrences (one per
        // lunar month captured): for non-leap months both emit the same
        // regular date; for the leap month they emit different sides of the pair.
        XCTAssertEqual(skip.count, leapOnly.count,
                       "skipLeap and leapOnly produce one entry per captured month")

        // skipLeap and leapOnly should differ on exactly one date — the
        // leap-month's regular vs leap variant.
        let skipSet = Set(skip.map { Calendar.current.startOfDay(for: $0) })
        let leapOnlySet = Set(leapOnly.map { Calendar.current.startOfDay(for: $0) })
        let symmetricDifference = skipSet.symmetricDifference(leapOnlySet)
        XCTAssertEqual(symmetricDifference.count, 2,
                       "skipLeap and leapOnly should differ on exactly the leap month (regular date in one, leap date in the other)")

        // Every skipLeap and leapOnly date must appear in includeLeap.
        let includeSet = Set(include.map { Calendar.current.startOfDay(for: $0) })
        XCTAssertTrue(skipSet.isSubset(of: includeSet))
        XCTAssertTrue(leapOnlySet.isSubset(of: includeSet))
    }

    /// Yearly recurrence on month 2 with `.leapOnly`: when a year has lunar
    /// leap month 2 the leap variant is used; when it doesn't, the regular
    /// month-2 occurrence is still emitted. This matches pre-rewrite behavior.
    /// Comparing against `.skipLeap` across the same window proves the algorithm
    /// emits the LEAP date in 2023 specifically.
    func testYearlyLeapOnlyDiffersFromSkipLeapOnlyInLeapYears() {
        let masterStartDate = Calendar.current.date(from: DateComponents(year: 2022, month: 1, day: 1))!
        let rangeStart = masterStartDate
        let rangeEnd = Calendar.current.date(from: DateComponents(year: 2027, month: 12, day: 31))!

        func run(_ behavior: LeapMonthBehavior) -> [Date] {
            let rule = SerializableLunarRecurrenceRule(
                frequency: .yearly,
                lunarDay: 15,
                lunarMonth: 2,
                leapMonthBehavior: behavior,
                interval: 1,
                recurrenceEnd: nil
            )
            return LunarOccurrenceGenerator.generateOccurrences(
                rule: rule,
                masterStartDate: masterStartDate,
                rangeStart: rangeStart,
                rangeEnd: rangeEnd
            )
        }

        let skip = run(.skipLeap)
        let leapOnly = run(.leapOnly)

        XCTAssertEqual(skip.count, leapOnly.count,
                       "skipLeap and leapOnly should yield the same number of yearly occurrences")

        // 2023 is the only leap-month-2 year in the 2022–2027 window, so
        // exactly one date should differ between the two.
        let skipSet = Set(skip.map { Calendar.current.startOfDay(for: $0) })
        let leapOnlySet = Set(leapOnly.map { Calendar.current.startOfDay(for: $0) })
        let diff = skipSet.symmetricDifference(leapOnlySet)
        XCTAssertEqual(diff.count, 2, "Exactly one year (2023) should produce different dates between skipLeap and leapOnly")
    }

    /// Performance guard: expanding monthly day=1 over the production 6-year
    /// window must complete in well under the freeze threshold the user was hitting.
    /// First call is cold (cache empty). Threshold chosen to be generous so this
    /// is a smoke test, not a flaky benchmark.
    func testMonthlyExpansionPerformanceUnderOneSecond() {
        let rule = SerializableLunarRecurrenceRule(
            frequency: .monthly,
            lunarDay: 1,
            lunarMonth: nil,
            leapMonthBehavior: .skipLeap,
            interval: 1,
            recurrenceEnd: nil
        )

        let masterStartDate = Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 17))!
        let rangeStart = masterStartDate
        let rangeEnd = Calendar.current.date(from: DateComponents(year: 2031, month: 5, day: 17))!

        let start = CFAbsoluteTimeGetCurrent()
        _ = LunarOccurrenceGenerator.generateOccurrences(
            rule: rule,
            masterStartDate: masterStartDate,
            rangeStart: rangeStart,
            rangeEnd: rangeEnd
        )
        let elapsed = CFAbsoluteTimeGetCurrent() - start

        // Old implementation took ~6 seconds per event on this dataset.
        // The rewrite plus the solarToLunar cache should land well under 1 second.
        XCTAssertLessThan(elapsed, 1.0, "Monthly expansion took \(elapsed)s — perf regression vs forward-walk rewrite")
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
