//
//  ICSRecurrenceExpanderTests.swift
//  lich-plusTests
//
//  Created by Quang Tran Minh on 08/12/25.
//

import XCTest
@testable import lich_plus

final class ICSRecurrenceExpanderTests: XCTestCase {

    // MARK: - Daily Recurrence Tests

    func testDailyRecurrenceExpansion() {
        let calendar = Calendar.current
        let masterStart = calendar.date(from: DateComponents(year: 2025, month: 1, day: 1, hour: 10, minute: 0))!
        let masterEnd = calendar.date(byAdding: .hour, value: 1, to: masterStart)!

        let rule = SerializableRecurrenceRule(
            frequency: 0,  // Daily
            interval: 1,
            recurrenceEnd: .occurrenceCount(5)
        )

        let occurrences = ICSRecurrenceExpander.expandOccurrences(
            masterStartDate: masterStart,
            masterEndDate: masterEnd,
            rule: rule,
            excludedDates: []
        )

        // Should have 5 occurrences
        XCTAssertEqual(occurrences.count, 5)

        // Check first occurrence
        XCTAssertEqual(occurrences[0].startDate, masterStart)
        XCTAssertEqual(occurrences[0].endDate, masterEnd)

        // Check second occurrence (1 day later)
        let day2Start = calendar.date(byAdding: .day, value: 1, to: masterStart)!
        let day2End = calendar.date(byAdding: .day, value: 1, to: masterEnd)!
        XCTAssertEqual(occurrences[1].startDate, day2Start)
        XCTAssertEqual(occurrences[1].endDate, day2End)

        // Check duration is preserved
        let duration = calendar.dateComponents([.hour], from: masterStart, to: masterEnd).hour ?? 0
        for occurrence in occurrences {
            let occDuration = calendar.dateComponents([.hour], from: occurrence.startDate, to: occurrence.endDate ?? occurrence.startDate).hour ?? 0
            XCTAssertEqual(occDuration, duration)
        }
    }

    func testDailyRecurrenceWithInterval() {
        let calendar = Calendar.current
        let masterStart = calendar.date(from: DateComponents(year: 2025, month: 1, day: 1))!
        let masterEnd = calendar.date(byAdding: .hour, value: 2, to: masterStart)!

        let rule = SerializableRecurrenceRule(
            frequency: 0,  // Daily
            interval: 2,   // Every 2 days
            recurrenceEnd: .occurrenceCount(3)
        )

        let occurrences = ICSRecurrenceExpander.expandOccurrences(
            masterStartDate: masterStart,
            masterEndDate: masterEnd,
            rule: rule,
            excludedDates: []
        )

        XCTAssertEqual(occurrences.count, 3)

        // Check spacing: 0 days, 2 days, 4 days
        let daysBetween0 = calendar.dateComponents([.day], from: occurrences[0].startDate, to: occurrences[1].startDate).day ?? 0
        let daysBetween1 = calendar.dateComponents([.day], from: occurrences[1].startDate, to: occurrences[2].startDate).day ?? 0

        XCTAssertEqual(daysBetween0, 2)
        XCTAssertEqual(daysBetween1, 2)
    }

    // MARK: - Weekly Recurrence Tests

    func testWeeklyRecurrenceExpansion() {
        let calendar = Calendar.current
        let masterStart = calendar.date(from: DateComponents(year: 2025, month: 1, day: 6))!  // Monday
        let masterEnd = calendar.date(byAdding: .hour, value: 1, to: masterStart)!

        let rule = SerializableRecurrenceRule(
            frequency: 1,  // Weekly
            interval: 1,
            recurrenceEnd: .occurrenceCount(4)
        )

        let occurrences = ICSRecurrenceExpander.expandOccurrences(
            masterStartDate: masterStart,
            masterEndDate: masterEnd,
            rule: rule,
            excludedDates: []
        )

        XCTAssertEqual(occurrences.count, 4)

        // Check weekly spacing
        let weeksBetween0 = calendar.dateComponents([.weekOfYear], from: occurrences[0].startDate, to: occurrences[1].startDate).weekOfYear ?? 0
        XCTAssertEqual(weeksBetween0, 1)
    }

    func testWeeklyRecurrenceWithBYDAY() {
        let calendar = Calendar.current
        // Start on Monday (weekday 2)
        let masterStart = calendar.date(from: DateComponents(year: 2025, month: 1, day: 6))!
        let masterEnd = calendar.date(byAdding: .hour, value: 1, to: masterStart)!

        // Monday to Friday (weekdays 2-6)
        let rule = SerializableRecurrenceRule(
            frequency: 1,  // Weekly
            interval: 1,
            daysOfTheWeek: [
                SerializableDayOfWeek(dayOfWeek: 2),  // Monday
                SerializableDayOfWeek(dayOfWeek: 3),  // Tuesday
                SerializableDayOfWeek(dayOfWeek: 4),  // Wednesday
                SerializableDayOfWeek(dayOfWeek: 5),  // Thursday
                SerializableDayOfWeek(dayOfWeek: 6)   // Friday
            ],
            recurrenceEnd: .occurrenceCount(5)
        )

        let occurrences = ICSRecurrenceExpander.expandOccurrences(
            masterStartDate: masterStart,
            masterEndDate: masterEnd,
            rule: rule,
            excludedDates: []
        )

        // Should have 5 occurrences (Mon-Fri of the first week)
        XCTAssertEqual(occurrences.count, 5)

        // All should be within the same week
        let firstDate = occurrences[0].startDate
        let lastDate = occurrences[4].startDate
        let daysBetween = calendar.dateComponents([.day], from: firstDate, to: lastDate).day ?? 0
        XCTAssertEqual(daysBetween, 4)  // Monday to Friday
    }

    // MARK: - Monthly Recurrence Tests

    func testMonthlyRecurrenceExpansion() {
        let calendar = Calendar.current
        let masterStart = calendar.date(from: DateComponents(year: 2025, month: 1, day: 15))!
        let masterEnd = calendar.date(byAdding: .hour, value: 1, to: masterStart)!

        let rule = SerializableRecurrenceRule(
            frequency: 2,  // Monthly
            interval: 1,
            recurrenceEnd: .occurrenceCount(3)
        )

        let occurrences = ICSRecurrenceExpander.expandOccurrences(
            masterStartDate: masterStart,
            masterEndDate: masterEnd,
            rule: rule,
            excludedDates: []
        )

        XCTAssertEqual(occurrences.count, 3)

        // Check dates are on the 15th of each month
        let day0 = calendar.component(.day, from: occurrences[0].startDate)
        let day1 = calendar.component(.day, from: occurrences[1].startDate)
        let day2 = calendar.component(.day, from: occurrences[2].startDate)

        XCTAssertEqual(day0, 15)
        XCTAssertEqual(day1, 15)
        XCTAssertEqual(day2, 15)

        // Check months are sequential
        let month0 = calendar.component(.month, from: occurrences[0].startDate)
        let month1 = calendar.component(.month, from: occurrences[1].startDate)
        let month2 = calendar.component(.month, from: occurrences[2].startDate)

        XCTAssertEqual(month0, 1)
        XCTAssertEqual(month1, 2)
        XCTAssertEqual(month2, 3)
    }

    func testMonthlyRecurrenceWithBYMONTHDAY() {
        let calendar = Calendar.current
        let masterStart = calendar.date(from: DateComponents(year: 2025, month: 1, day: 10))!
        let masterEnd = calendar.date(byAdding: .hour, value: 1, to: masterStart)!

        // Only on the 10th of each month
        let rule = SerializableRecurrenceRule(
            frequency: 2,  // Monthly
            interval: 1,
            daysOfTheMonth: [10],
            recurrenceEnd: .occurrenceCount(4)
        )

        let occurrences = ICSRecurrenceExpander.expandOccurrences(
            masterStartDate: masterStart,
            masterEndDate: masterEnd,
            rule: rule,
            excludedDates: []
        )

        XCTAssertEqual(occurrences.count, 4)

        // All should be on the 10th
        for occurrence in occurrences {
            let day = calendar.component(.day, from: occurrence.startDate)
            XCTAssertEqual(day, 10)
        }
    }

    // MARK: - Yearly Recurrence Tests

    func testYearlyRecurrenceExpansion() {
        let calendar = Calendar.current
        let masterStart = calendar.date(from: DateComponents(year: 2020, month: 3, day: 20))!
        let masterEnd = calendar.date(byAdding: .hour, value: 1, to: masterStart)!

        let rule = SerializableRecurrenceRule(
            frequency: 3,  // Yearly
            interval: 1,
            recurrenceEnd: .occurrenceCount(3)
        )

        let occurrences = ICSRecurrenceExpander.expandOccurrences(
            masterStartDate: masterStart,
            masterEndDate: masterEnd,
            rule: rule,
            excludedDates: []
        )

        XCTAssertEqual(occurrences.count, 3)

        // Check dates are on 3/20
        for occurrence in occurrences {
            let month = calendar.component(.month, from: occurrence.startDate)
            let day = calendar.component(.day, from: occurrence.startDate)
            XCTAssertEqual(month, 3)
            XCTAssertEqual(day, 20)
        }

        // Check years are sequential
        let year0 = calendar.component(.year, from: occurrences[0].startDate)
        let year1 = calendar.component(.year, from: occurrences[1].startDate)
        let year2 = calendar.component(.year, from: occurrences[2].startDate)

        XCTAssertEqual(year0, 2020)
        XCTAssertEqual(year1, 2021)
        XCTAssertEqual(year2, 2022)
    }

    // MARK: - Recurrence End Tests

    func testRecurrenceUNTILDateCutoff() {
        let calendar = Calendar.current
        let masterStart = calendar.date(from: DateComponents(year: 2025, month: 1, day: 1))!
        let masterEnd = calendar.date(byAdding: .hour, value: 1, to: masterStart)!

        let untilDate = calendar.date(from: DateComponents(year: 2025, month: 1, day: 15))!

        let rule = SerializableRecurrenceRule(
            frequency: 0,  // Daily
            interval: 1,
            recurrenceEnd: .endDate(untilDate)
        )

        let occurrences = ICSRecurrenceExpander.expandOccurrences(
            masterStartDate: masterStart,
            masterEndDate: masterEnd,
            rule: rule,
            excludedDates: []
        )

        // Should have occurrences from Jan 1 to Jan 15 (15 days)
        XCTAssertEqual(occurrences.count, 15)

        // Last occurrence should be on or before until date
        let lastDate = occurrences.last!.startDate
        XCTAssertTrue(lastDate <= untilDate)
    }

    func testRecurrenceCOUNTLimit() {
        let calendar = Calendar.current
        let masterStart = calendar.date(from: DateComponents(year: 2025, month: 1, day: 1))!
        let masterEnd = calendar.date(byAdding: .hour, value: 1, to: masterStart)!

        let rule = SerializableRecurrenceRule(
            frequency: 0,  // Daily
            interval: 1,
            recurrenceEnd: .occurrenceCount(10)
        )

        let occurrences = ICSRecurrenceExpander.expandOccurrences(
            masterStartDate: masterStart,
            masterEndDate: masterEnd,
            rule: rule,
            excludedDates: []
        )

        XCTAssertEqual(occurrences.count, 10)
    }

    // MARK: - EXDATE Filtering Tests

    func testExcludesEXDATEDates() {
        let calendar = Calendar.current
        let masterStart = calendar.date(from: DateComponents(year: 2025, month: 1, day: 1))!
        let masterEnd = calendar.date(byAdding: .hour, value: 1, to: masterStart)!

        // Exclude Jan 3, 5, 7
        let exdate3 = calendar.date(from: DateComponents(year: 2025, month: 1, day: 3))!
        let exdate5 = calendar.date(from: DateComponents(year: 2025, month: 1, day: 5))!
        let exdate7 = calendar.date(from: DateComponents(year: 2025, month: 1, day: 7))!
        let excludedDates = [exdate3, exdate5, exdate7]

        let rule = SerializableRecurrenceRule(
            frequency: 0,  // Daily
            interval: 1,
            recurrenceEnd: .occurrenceCount(10)
        )

        let occurrences = ICSRecurrenceExpander.expandOccurrences(
            masterStartDate: masterStart,
            masterEndDate: masterEnd,
            rule: rule,
            excludedDates: excludedDates
        )

        // Should have 7 occurrences (10 days minus 3 excluded)
        XCTAssertEqual(occurrences.count, 7)

        // Verify excluded dates are not in results
        let resultDates = occurrences.map { calendar.dateComponents([.day], from: $0.startDate).day! }
        XCTAssertFalse(resultDates.contains(3))
        XCTAssertFalse(resultDates.contains(5))
        XCTAssertFalse(resultDates.contains(7))
    }

    // MARK: - Duration Preservation Tests

    func testPreservesEventDuration() {
        let calendar = Calendar.current
        let masterStart = calendar.date(from: DateComponents(year: 2025, month: 1, day: 1, hour: 10, minute: 30))!
        let masterEnd = calendar.date(from: DateComponents(year: 2025, month: 1, day: 1, hour: 14, minute: 45))!

        let rule = SerializableRecurrenceRule(
            frequency: 0,  // Daily
            interval: 1,
            recurrenceEnd: .occurrenceCount(5)
        )

        let occurrences = ICSRecurrenceExpander.expandOccurrences(
            masterStartDate: masterStart,
            masterEndDate: masterEnd,
            rule: rule,
            excludedDates: []
        )

        let masterDuration = masterEnd.timeIntervalSince(masterStart)

        for occurrence in occurrences {
            let occurrenceDuration = (occurrence.endDate ?? occurrence.startDate).timeIntervalSince(occurrence.startDate)
            XCTAssertEqual(occurrenceDuration, masterDuration, accuracy: 1)
        }
    }

    // MARK: - Edge Cases Tests

    func testEmptyExcludedDatesList() {
        let calendar = Calendar.current
        let masterStart = calendar.date(from: DateComponents(year: 2025, month: 1, day: 1))!
        let masterEnd = calendar.date(byAdding: .hour, value: 1, to: masterStart)!

        let rule = SerializableRecurrenceRule(
            frequency: 0,  // Daily
            interval: 1,
            recurrenceEnd: .occurrenceCount(5)
        )

        let occurrences = ICSRecurrenceExpander.expandOccurrences(
            masterStartDate: masterStart,
            masterEndDate: masterEnd,
            rule: rule,
            excludedDates: []
        )

        XCTAssertEqual(occurrences.count, 5)
    }

    func testMaxYearsCap() {
        let calendar = Calendar.current
        let masterStart = calendar.date(from: DateComponents(year: 2025, month: 1, day: 1))!
        let masterEnd = calendar.date(byAdding: .hour, value: 1, to: masterStart)!

        let rule = SerializableRecurrenceRule(
            frequency: 0,  // Daily
            interval: 1,
            recurrenceEnd: .endDate(calendar.date(from: DateComponents(year: 2050, month: 1, day: 1))!)
        )

        let occurrences = ICSRecurrenceExpander.expandOccurrences(
            masterStartDate: masterStart,
            masterEndDate: masterEnd,
            rule: rule,
            excludedDates: []
        )

        // Should cap at 5 years of daily events
        let lastYear = calendar.component(.year, from: occurrences.last!.startDate)
        XCTAssertLessThanOrEqual(lastYear, 2030)  // 5 years from 2025
    }

    func testMaxOccurrencesCap() {
        let calendar = Calendar.current
        let masterStart = calendar.date(from: DateComponents(year: 2025, month: 1, day: 1))!
        let masterEnd = calendar.date(byAdding: .hour, value: 1, to: masterStart)!

        let rule = SerializableRecurrenceRule(
            frequency: 0,  // Daily
            interval: 1,
            recurrenceEnd: .occurrenceCount(5000)
        )

        let occurrences = ICSRecurrenceExpander.expandOccurrences(
            masterStartDate: masterStart,
            masterEndDate: masterEnd,
            rule: rule,
            excludedDates: []
        )

        // Should cap at 2000 occurrences
        XCTAssertLessThanOrEqual(occurrences.count, 2000)
    }

    func testMasterStartDateIsFirstOccurrence() {
        let calendar = Calendar.current
        let masterStart = calendar.date(from: DateComponents(year: 2025, month: 1, day: 1))!
        let masterEnd = calendar.date(byAdding: .hour, value: 1, to: masterStart)!

        let rule = SerializableRecurrenceRule(
            frequency: 0,  // Daily
            interval: 1,
            recurrenceEnd: .occurrenceCount(1)
        )

        let occurrences = ICSRecurrenceExpander.expandOccurrences(
            masterStartDate: masterStart,
            masterEndDate: masterEnd,
            rule: rule,
            excludedDates: []
        )

        XCTAssertEqual(occurrences.count, 1)
        XCTAssertEqual(occurrences[0].startDate, masterStart)
        XCTAssertEqual(occurrences[0].endDate, masterEnd)
    }

    func testHandlesNilMasterEndDate() {
        let calendar = Calendar.current
        let masterStart = calendar.date(from: DateComponents(year: 2025, month: 1, day: 1))!

        let rule = SerializableRecurrenceRule(
            frequency: 0,  // Daily
            interval: 1,
            recurrenceEnd: .occurrenceCount(3)
        )

        let occurrences = ICSRecurrenceExpander.expandOccurrences(
            masterStartDate: masterStart,
            masterEndDate: .none,
            rule: rule,
            excludedDates: []
        )

        XCTAssertEqual(occurrences.count, 3)

        // All occurrences should have nil endDate
        for occurrence in occurrences {
            XCTAssertNil(occurrence.endDate)
        }
    }
}
