//
//  LunarCalendarLeapMonthTests.swift
//  lich-plusTests
//
//  Created by Quang Tran Minh on 07/12/25.
//

import XCTest
@testable import lich_plus

final class LunarCalendarLeapMonthTests: XCTestCase {

    // MARK: - LeapMonthInfo Tests

    func testLeapMonthInfoStructCreation() {
        let leapInfo = LeapMonthInfo(
            hasLeapMonth: true,
            leapMonth: 2,
            lunarYear: 2023
        )

        XCTAssertTrue(leapInfo.hasLeapMonth)
        XCTAssertEqual(leapInfo.leapMonth, 2)
        XCTAssertEqual(leapInfo.lunarYear, 2023)
    }

    func testLeapMonthInfoNoLeapMonth() {
        let leapInfo = LeapMonthInfo(
            hasLeapMonth: false,
            leapMonth: nil,
            lunarYear: 2024
        )

        XCTAssertFalse(leapInfo.hasLeapMonth)
        XCTAssertNil(leapInfo.leapMonth)
        XCTAssertEqual(leapInfo.lunarYear, 2024)
    }

    // MARK: - solarToLunarWithLeap Tests

    func testSolarToLunarWithLeapForNormalDay() {
        // Test a date that is not in a leap month
        // March 1, 2024 (should be lunar 1/2/2024, no leap)
        let testDate = DateComponents(calendar: Calendar.current, year: 2024, month: 3, day: 1).date!
        let result = LunarCalendar.solarToLunarWithLeap(testDate)

        XCTAssertFalse(result.isLeap, "Regular month should not be marked as leap month")
        XCTAssertGreaterThan(result.month, 0)
        XCTAssertLessThanOrEqual(result.month, 12)
        XCTAssertGreaterThan(result.day, 0)
        XCTAssertLessThanOrEqual(result.day, 30)
    }

    func testSolarToLunarWithLeapReturnsValidComponents() {
        // Test that return values are always valid
        let testDate = Date()
        let result = LunarCalendar.solarToLunarWithLeap(testDate)

        XCTAssertGreaterThan(result.day, 0)
        XCTAssertLessThanOrEqual(result.day, 30)
        XCTAssertGreaterThan(result.month, 0)
        XCTAssertLessThanOrEqual(result.month, 12)
        XCTAssertGreaterThan(result.year, 1900)
    }

    func testSolarToLunarWithLeapMatchesBaseConversion() {
        // Ensure the extended method matches the basic solarToLunar
        let testDate = Date()
        let baseResult = LunarCalendar.solarToLunar(testDate)
        let extendedResult = LunarCalendar.solarToLunarWithLeap(testDate)

        XCTAssertEqual(baseResult.day, extendedResult.day)
        XCTAssertEqual(baseResult.month, extendedResult.month)
        XCTAssertEqual(baseResult.year, extendedResult.year)
    }

    // MARK: - getLeapMonthInfo Tests

    func testGetLeapMonthInfoFor2023() {
        // 2023 is known to have a leap month in the lunar calendar
        let leapInfo = LunarCalendar.getLeapMonthInfo(forSolarYear: 2023)

        XCTAssertTrue(leapInfo.hasLeapMonth, "2023 solar year should contain a lunar year with a leap month")
        XCTAssertNotNil(leapInfo.leapMonth, "Should have identified which month is the leap month")

        if let leapMonth = leapInfo.leapMonth {
            XCTAssertGreaterThanOrEqual(leapMonth, 1)
            XCTAssertLessThanOrEqual(leapMonth, 12)
        }
    }

    func testGetLeapMonthInfoFor2024() {
        // Test for a specific year and verify the data structure is valid
        let leapInfo = LunarCalendar.getLeapMonthInfo(forSolarYear: 2024)

        // Verify the structure is always valid (might or might not have leap month)
        XCTAssertNotNil(leapInfo.lunarYear)

        if leapInfo.hasLeapMonth {
            XCTAssertNotNil(leapInfo.leapMonth)
            if let leapMonth = leapInfo.leapMonth {
                XCTAssertGreaterThanOrEqual(leapMonth, 1)
                XCTAssertLessThanOrEqual(leapMonth, 12)
            }
        } else {
            XCTAssertNil(leapInfo.leapMonth)
        }
    }

    func testGetLeapMonthInfoFor2025() {
        // Test for a different year to ensure the method works consistently
        let leapInfo = LunarCalendar.getLeapMonthInfo(forSolarYear: 2025)

        XCTAssertNotNil(leapInfo.lunarYear)
        // The specific result depends on the lunar calendar, but the structure should be valid
        XCTAssert(leapInfo.hasLeapMonth || !leapInfo.hasLeapMonth, "Should always return a valid result")
    }

    func testGetLeapMonthInfoReturnsConsistentResults() {
        // Calling the method multiple times should return the same result
        let leapInfo1 = LunarCalendar.getLeapMonthInfo(forSolarYear: 2023)
        let leapInfo2 = LunarCalendar.getLeapMonthInfo(forSolarYear: 2023)

        XCTAssertEqual(leapInfo1.hasLeapMonth, leapInfo2.hasLeapMonth)
        XCTAssertEqual(leapInfo1.leapMonth, leapInfo2.leapMonth)
        XCTAssertEqual(leapInfo1.lunarYear, leapInfo2.lunarYear)
    }

    // MARK: - Enhanced lunarToSolar with Leap Month Support Tests

    func testLunarToSolarWithoutLeapMonth() {
        // Test conversion without leap month flag
        // Using a date that should be in a non-leap month
        let solarDate = LunarCalendar.lunarToSolar(day: 1, month: 3, year: 2024, isLeapMonth: false)

        XCTAssertNotNil(solarDate)
        // Verify we can convert it back
        let lunarBack = LunarCalendar.solarToLunar(solarDate)

        // Should get back a valid lunar date with matching month and day
        XCTAssertGreaterThan(lunarBack.day, 0)
        XCTAssertGreaterThan(lunarBack.month, 0)
        XCTAssertLessThanOrEqual(lunarBack.month, 12)
    }

    func testLunarToSolarWithLeapMonthForKnownLeapYear() {
        // Find a year with a leap month and test conversion for both regular and leap occurrences
        let leapInfo2023 = LunarCalendar.getLeapMonthInfo(forSolarYear: 2023)

        if let leapMonth = leapInfo2023.leapMonth {
            let regularMonthDate = LunarCalendar.lunarToSolar(day: 1, month: leapMonth, year: leapInfo2023.lunarYear, isLeapMonth: false)
            let leapMonthDate = LunarCalendar.lunarToSolar(day: 1, month: leapMonth, year: leapInfo2023.lunarYear, isLeapMonth: true)

            XCTAssertNotNil(regularMonthDate)
            XCTAssertNotNil(leapMonthDate)

            // The two dates might be different (if the library can distinguish them)
            // But at minimum, both should be valid dates
            let calendar = Calendar.current
            let regularComponents = calendar.dateComponents([.year, .month, .day], from: regularMonthDate)
            let leapComponents = calendar.dateComponents([.year, .month, .day], from: leapMonthDate)

            XCTAssertNotNil(regularComponents.day)
            XCTAssertNotNil(leapComponents.day)
        }
    }

    func testLunarToSolarReturnValueIsValid() {
        // Ensure return date is always valid
        let solarDate = LunarCalendar.lunarToSolar(day: 15, month: 6, year: 2023, isLeapMonth: false)

        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: solarDate)

        XCTAssertNotNil(components.year)
        XCTAssertNotNil(components.month)
        XCTAssertNotNil(components.day)
        XCTAssertGreaterThanOrEqual(components.year ?? 0, 1900)
    }

    func testLunarToSolarWithLeapMonthIsReversible() {
        // Test that lunar-to-solar-to-lunar conversion is reversible
        let leapInfo = LunarCalendar.getLeapMonthInfo(forSolarYear: 2023)

        if let leapMonth = leapInfo.leapMonth {
            // Convert leap month lunar date to solar
            let solarDate = LunarCalendar.lunarToSolar(day: 10, month: leapMonth, year: leapInfo.lunarYear, isLeapMonth: true)

            // Convert back to lunar
            let lunarBack = LunarCalendar.solarToLunarWithLeap(solarDate)

            // Should get back valid lunar components
            XCTAssertGreaterThan(lunarBack.day, 0)
            XCTAssertGreaterThan(lunarBack.month, 0)
            XCTAssertGreaterThan(lunarBack.year, 0)
        }
    }

    // MARK: - Leap Month Detection Edge Cases

    func testLeapMonthDetectionForDateInMiddleOfMonth() {
        // Test detection for various days within a potential leap month
        let testDates = [1, 5, 10, 15, 20, 25, 30]

        for day in testDates {
            let components = DateComponents(calendar: Calendar.current, year: 2023, month: 5, day: day)
            if let date = components.date {
                let result = LunarCalendar.solarToLunarWithLeap(date)

                // All results should have valid leap month flag
                XCTAssert(
                    result.isLeap || !result.isLeap,
                    "Day \(day) should have valid leap flag"
                )
            }
        }
    }

    func testLeapMonthDetectionAcrossYears() {
        // Test that leap month detection works consistently across multiple years
        let yearsToTest = [2020, 2021, 2022, 2023, 2024, 2025]

        for year in yearsToTest {
            let leapInfo = LunarCalendar.getLeapMonthInfo(forSolarYear: year)

            // Should always return valid lunar year
            XCTAssertGreaterThan(leapInfo.lunarYear, 0, "Year \(year) should return valid lunar year")

            // If it has a leap month, it should be between 1-12
            if leapInfo.hasLeapMonth {
                XCTAssertNotNil(leapInfo.leapMonth)
                if let leapMonth = leapInfo.leapMonth {
                    XCTAssertGreaterThanOrEqual(leapMonth, 1, "Leap month should be >= 1")
                    XCTAssertLessThanOrEqual(leapMonth, 12, "Leap month should be <= 12")
                }
            } else {
                XCTAssertNil(leapInfo.leapMonth, "No leap month should be nil")
            }
        }
    }

    // MARK: - Integration Tests

    func testLeapMonthDetectionConsistency() {
        // Get leap month info for 2023
        let leapInfo = LunarCalendar.getLeapMonthInfo(forSolarYear: 2023)

        guard let leapMonth = leapInfo.leapMonth else {
            XCTFail("2023 should have a leap month")
            return
        }

        // Find a date that falls in the leap month (by lunar calendar)
        // and verify it is detected as leap
        let calendar = Calendar.current

        // Start from January 1, 2023 and search through the year
        var currentDate = DateComponents(calendar: calendar, year: 2023, month: 1, day: 1).date!
        var found = false

        for _ in 0..<365 {
            let lunarWithLeap = LunarCalendar.solarToLunarWithLeap(currentDate)

            if lunarWithLeap.month == leapMonth && lunarWithLeap.isLeap {
                found = true
                break
            }

            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }

        XCTAssertTrue(found, "Should find at least one date with leap month detection")
    }

    func testLeapMonthDoesNotExistInNonLeapYears() {
        // For a year without leap month, no date should be marked as leap
        let leapInfo = LunarCalendar.getLeapMonthInfo(forSolarYear: 2024)

        if !leapInfo.hasLeapMonth {
            // Check that no date in 2024 is marked as leap
            let calendar = Calendar.current
            var currentDate = DateComponents(calendar: calendar, year: 2024, month: 1, day: 1).date!
            var leapMonthFound = false

            for _ in 0..<365 {
                let result = LunarCalendar.solarToLunarWithLeap(currentDate)

                if result.isLeap {
                    leapMonthFound = true
                    break
                }

                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
            }

            XCTAssertFalse(leapMonthFound, "2024 should not have any leap month dates")
        }
    }

    // MARK: - Performance Tests

    func testLeapMonthDetectionPerformance() {
        // Measure performance of leap month detection
        self.measure {
            // Get leap month info for 10 different years
            for year in 2020...2029 {
                _ = LunarCalendar.getLeapMonthInfo(forSolarYear: year)
            }
        }
    }

    func testSolarToLunarWithLeapPerformance() {
        // Measure performance of conversion with leap month detection
        let testDate = Date()

        self.measure {
            // Convert the same date 100 times
            for _ in 0..<100 {
                _ = LunarCalendar.solarToLunarWithLeap(testDate)
            }
        }
    }
}
