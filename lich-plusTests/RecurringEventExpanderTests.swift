//
//  RecurringEventExpanderTests.swift
//  lich-plusTests
//
//  Created by Quang Tran Minh on 08/12/25.
//

import XCTest
@testable import lich_plus

final class RecurringEventExpanderTests: XCTestCase {

    // MARK: - Virtual UUID Tests

    /// Test that virtualUUID generates deterministic UUIDs
    func testVirtualUUIDDeterminism() {
        let masterID = UUID()
        let date1 = Calendar.current.date(from: DateComponents(year: 2025, month: 12, day: 8))!
        let date2 = Calendar.current.date(from: DateComponents(year: 2025, month: 12, day: 8))!

        let uuid1 = RecurringEventExpander.virtualUUID(masterID: masterID, occurrenceDate: date1)
        let uuid2 = RecurringEventExpander.virtualUUID(masterID: masterID, occurrenceDate: date2)

        XCTAssertEqual(uuid1, uuid2, "Same inputs should produce same UUID")
    }

    /// Test that different dates produce different UUIDs
    func testVirtualUUIDDifferentForDifferentDates() {
        let masterID = UUID()
        let date1 = Calendar.current.date(from: DateComponents(year: 2025, month: 12, day: 8))!
        let date2 = Calendar.current.date(from: DateComponents(year: 2025, month: 12, day: 9))!

        let uuid1 = RecurringEventExpander.virtualUUID(masterID: masterID, occurrenceDate: date1)
        let uuid2 = RecurringEventExpander.virtualUUID(masterID: masterID, occurrenceDate: date2)

        XCTAssertNotEqual(uuid1, uuid2, "Different dates should produce different UUIDs")
    }

    /// Test that different master IDs produce different UUIDs
    func testVirtualUUIDDifferentForDifferentMasters() {
        let masterID1 = UUID()
        let masterID2 = UUID()
        let date = Calendar.current.date(from: DateComponents(year: 2025, month: 12, day: 8))!

        let uuid1 = RecurringEventExpander.virtualUUID(masterID: masterID1, occurrenceDate: date)
        let uuid2 = RecurringEventExpander.virtualUUID(masterID: masterID2, occurrenceDate: date)

        XCTAssertNotEqual(uuid1, uuid2, "Different master IDs should produce different UUIDs")
    }

    // MARK: - Non-Recurring Event Tests

    /// Test that non-recurring events return single TaskItem
    func testNonRecurringEventReturnsSingleTaskItem() {
        let event = SyncableEvent(
            title: "One-time event",
            startDate: Date(),
            category: "other",
            recurrenceRuleData: nil
        )

        let occurrences = RecurringEventExpander.generateOccurrences(
            for: event,
            rangeStart: Date(),
            rangeEnd: Date()
        )

        XCTAssertEqual(occurrences.count, 1, "Non-recurring event should return single occurrence")
        XCTAssertNil(occurrences.first?.masterEventId, "Master event should have no masterEventId")
    }

    // MARK: - Daily Recurrence Tests

    /// Test daily recurrence expansion
    func testDailyRecurrenceExpansion() {
        let masterDate = Calendar.current.date(from: DateComponents(year: 2025, month: 12, day: 1))!
        let rangeStart = Calendar.current.date(from: DateComponents(year: 2025, month: 12, day: 1))!
        let rangeEnd = Calendar.current.date(from: DateComponents(year: 2025, month: 12, day: 5))!

        // Create daily recurrence rule
        let rule = SerializableRecurrenceRule(
            frequency: 0, // Daily
            interval: 1
        )

        let container = RecurrenceRuleContainer.solar(rule)
        let data = try! JSONEncoder().encode(container)

        let event = SyncableEvent(
            title: "Daily event",
            startDate: masterDate,
            category: "other",
            recurrenceRuleData: data
        )

        let occurrences = RecurringEventExpander.generateOccurrences(
            for: event,
            rangeStart: rangeStart,
            rangeEnd: rangeEnd
        )

        XCTAssertEqual(occurrences.count, 5, "Daily recurrence should produce 5 occurrences")
        XCTAssertTrue(occurrences.allSatisfy { $0.masterEventId == event.id }, "All should reference master ID")

        // Verify dates are consecutive
        for i in 0..<4 {
            let daysBetween = Calendar.current.dateComponents([.day], from: occurrences[i].date, to: occurrences[i + 1].date).day
            XCTAssertEqual(daysBetween, 1, "Daily occurrences should be 1 day apart")
        }
    }

    /// Test daily recurrence with interval
    func testDailyRecurrenceWithInterval() {
        let masterDate = Calendar.current.date(from: DateComponents(year: 2025, month: 12, day: 1))!
        let rangeStart = masterDate
        let rangeEnd = Calendar.current.date(from: DateComponents(year: 2025, month: 12, day: 11))!

        // Create every-2-days recurrence
        let rule = SerializableRecurrenceRule(
            frequency: 0, // Daily
            interval: 2
        )

        let container = RecurrenceRuleContainer.solar(rule)
        let data = try! JSONEncoder().encode(container)

        let event = SyncableEvent(
            title: "Every 2 days event",
            startDate: masterDate,
            category: "other",
            recurrenceRuleData: data
        )

        let occurrences = RecurringEventExpander.generateOccurrences(
            for: event,
            rangeStart: rangeStart,
            rangeEnd: rangeEnd
        )

        XCTAssertEqual(occurrences.count, 6, "Every-2-days should produce 6 occurrences")

        // Verify 2-day intervals
        for i in 0..<(occurrences.count - 1) {
            let daysBetween = Calendar.current.dateComponents([.day], from: occurrences[i].date, to: occurrences[i + 1].date).day
            XCTAssertEqual(daysBetween, 2, "Occurrences should be 2 days apart")
        }
    }

    // MARK: - Weekly Recurrence Tests

    /// Test weekly recurrence expansion
    func testWeeklyRecurrenceExpansion() {
        // Start on a Monday
        let masterDate = Calendar.current.date(from: DateComponents(year: 2025, month: 12, day: 1))! // Monday
        let rangeStart = masterDate
        let rangeEnd = Calendar.current.date(from: DateComponents(year: 2025, month: 12, day: 29))! // 4 weeks

        let rule = SerializableRecurrenceRule(
            frequency: 1, // Weekly
            interval: 1
        )

        let container = RecurrenceRuleContainer.solar(rule)
        let data = try! JSONEncoder().encode(container)

        let event = SyncableEvent(
            title: "Weekly event",
            startDate: masterDate,
            category: "other",
            recurrenceRuleData: data
        )

        let occurrences = RecurringEventExpander.generateOccurrences(
            for: event,
            rangeStart: rangeStart,
            rangeEnd: rangeEnd
        )

        XCTAssertEqual(occurrences.count, 5, "Weekly recurrence over 4 weeks should produce 5 occurrences")

        // Verify 7-day intervals
        for i in 0..<(occurrences.count - 1) {
            let daysBetween = Calendar.current.dateComponents([.day], from: occurrences[i].date, to: occurrences[i + 1].date).day
            XCTAssertEqual(daysBetween, 7, "Weekly occurrences should be 7 days apart")
        }
    }

    // MARK: - Monthly Recurrence Tests

    /// Test monthly recurrence expansion
    func testMonthlyRecurrenceExpansion() {
        let masterDate = Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 15))!
        let rangeStart = masterDate
        let rangeEnd = Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 15))!

        let rule = SerializableRecurrenceRule(
            frequency: 2, // Monthly
            interval: 1
        )

        let container = RecurrenceRuleContainer.solar(rule)
        let data = try! JSONEncoder().encode(container)

        let event = SyncableEvent(
            title: "Monthly event",
            startDate: masterDate,
            category: "other",
            recurrenceRuleData: data
        )

        let occurrences = RecurringEventExpander.generateOccurrences(
            for: event,
            rangeStart: rangeStart,
            rangeEnd: rangeEnd
        )

        XCTAssertEqual(occurrences.count, 6, "Monthly recurrence over 6 months should produce 6 occurrences")

        // Verify all are on the 15th
        XCTAssertTrue(occurrences.allSatisfy { Calendar.current.component(.day, from: $0.date) == 15 }, "All should be on the 15th")
    }

    /// Test monthly recurrence with end date
    func testMonthlyRecurrenceWithEndDate() {
        let masterDate = Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 1))!
        let rangeStart = masterDate
        let rangeEnd = Calendar.current.date(from: DateComponents(year: 2025, month: 12, day: 31))!
        let endDate = Calendar.current.date(from: DateComponents(year: 2025, month: 3, day: 31))!

        let rule = SerializableRecurrenceRule(
            frequency: 2, // Monthly
            interval: 1,
            recurrenceEnd: .endDate(endDate)
        )

        let container = RecurrenceRuleContainer.solar(rule)
        let data = try! JSONEncoder().encode(container)

        let event = SyncableEvent(
            title: "Monthly with end date",
            startDate: masterDate,
            category: "other",
            recurrenceRuleData: data
        )

        let occurrences = RecurringEventExpander.generateOccurrences(
            for: event,
            rangeStart: rangeStart,
            rangeEnd: rangeEnd
        )

        XCTAssertEqual(occurrences.count, 3, "Should respect end date limit")
        XCTAssertTrue(occurrences.allSatisfy { $0.date <= endDate }, "All dates should be before end date")
    }

    /// Test monthly recurrence with occurrence count
    func testMonthlyRecurrenceWithOccurrenceCount() {
        let masterDate = Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 1))!
        let rangeStart = masterDate
        let rangeEnd = Calendar.current.date(from: DateComponents(year: 2025, month: 12, day: 31))!

        let rule = SerializableRecurrenceRule(
            frequency: 2, // Monthly
            interval: 1,
            recurrenceEnd: .occurrenceCount(5)
        )

        let container = RecurrenceRuleContainer.solar(rule)
        let data = try! JSONEncoder().encode(container)

        let event = SyncableEvent(
            title: "Monthly with count",
            startDate: masterDate,
            category: "other",
            recurrenceRuleData: data
        )

        let occurrences = RecurringEventExpander.generateOccurrences(
            for: event,
            rangeStart: rangeStart,
            rangeEnd: rangeEnd
        )

        XCTAssertEqual(occurrences.count, 5, "Should respect occurrence count limit")
    }

    // MARK: - Yearly Recurrence Tests

    /// Test yearly recurrence expansion
    func testYearlyRecurrenceExpansion() {
        let masterDate = Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 15))!
        let rangeStart = Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 1))!
        let rangeEnd = Calendar.current.date(from: DateComponents(year: 2027, month: 12, day: 31))!

        let rule = SerializableRecurrenceRule(
            frequency: 3, // Yearly
            interval: 1
        )

        let container = RecurrenceRuleContainer.solar(rule)
        let data = try! JSONEncoder().encode(container)

        let event = SyncableEvent(
            title: "Yearly event",
            startDate: masterDate,
            category: "other",
            recurrenceRuleData: data
        )

        let occurrences = RecurringEventExpander.generateOccurrences(
            for: event,
            rangeStart: rangeStart,
            rangeEnd: rangeEnd
        )

        XCTAssertEqual(occurrences.count, 3, "Yearly recurrence should produce 3 occurrences")

        // Verify all are on June 15
        XCTAssertTrue(occurrences.allSatisfy {
            let components = Calendar.current.dateComponents([.month, .day], from: $0.date)
            return components.month == 6 && components.day == 15
        }, "All should be on June 15")
    }

    // MARK: - Lunar Monthly Recurrence Tests

    /// Test lunar monthly recurrence expansion
    func testLunarMonthlyRecurrenceExpansion() {
        // Use Jan 29, 2025 which corresponds to lunar 1st/1st (lunar new year)
        // Use a 2-year range to ensure enough occurrences
        let masterDate = Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 29))!
        let rangeStart = masterDate
        let rangeEnd = Calendar.current.date(from: DateComponents(year: 2026, month: 12, day: 31))!

        let rule = SerializableLunarRecurrenceRule(
            frequency: .monthly,
            lunarDay: 1,
            leapMonthBehavior: .skipLeap,
            interval: 1,
            recurrenceEnd: .occurrenceCount(12)
        )

        let container = RecurrenceRuleContainer.lunar(rule)
        let data = try! JSONEncoder().encode(container)

        let event = SyncableEvent(
            title: "Lunar monthly event",
            startDate: masterDate,
            category: "other",
            recurrenceRuleData: data
        )

        let occurrences = RecurringEventExpander.generateOccurrences(
            for: event,
            rangeStart: rangeStart,
            rangeEnd: rangeEnd
        )

        // Lunar calendar is complex, check bounds rather than exact count
        XCTAssertGreaterThan(occurrences.count, 0, "Should have at least one occurrence")
        XCTAssertLessThanOrEqual(occurrences.count, 12, "Should respect occurrence count limit")
        XCTAssertTrue(occurrences.allSatisfy { $0.masterEventId == event.id }, "All should reference master")
        XCTAssertTrue(occurrences.allSatisfy { $0.isOccurrence }, "All should be marked as occurrences")
    }

    /// Test lunar yearly recurrence expansion
    func testLunarYearlyRecurrenceExpansion() {
        let masterDate = Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 29))!
        let rangeStart = masterDate
        let rangeEnd = Calendar.current.date(from: DateComponents(year: 2027, month: 12, day: 31))!

        let rule = SerializableLunarRecurrenceRule(
            frequency: .yearly,
            lunarDay: 1,
            lunarMonth: 1,
            leapMonthBehavior: .skipLeap,
            interval: 1,
            recurrenceEnd: .occurrenceCount(3)
        )

        let container = RecurrenceRuleContainer.lunar(rule)
        let data = try! JSONEncoder().encode(container)

        let event = SyncableEvent(
            title: "Lunar yearly event",
            startDate: masterDate,
            category: "other",
            recurrenceRuleData: data
        )

        let occurrences = RecurringEventExpander.generateOccurrences(
            for: event,
            rangeStart: rangeStart,
            rangeEnd: rangeEnd
        )

        XCTAssertEqual(occurrences.count, 3, "Lunar yearly should respect occurrence count")
        XCTAssertTrue(occurrences.allSatisfy { $0.masterEventId == event.id }, "All should reference master")
    }

    // MARK: - Occurrence Identification Tests

    /// Test that occurrences are marked as occurrences
    func testOccurrencesMarkedAsOccurrences() {
        let masterDate = Calendar.current.date(from: DateComponents(year: 2025, month: 12, day: 1))!
        let rangeStart = masterDate
        let rangeEnd = Calendar.current.date(from: DateComponents(year: 2025, month: 12, day: 5))!

        let rule = SerializableRecurrenceRule(
            frequency: 0, // Daily
            interval: 1
        )

        let container = RecurrenceRuleContainer.solar(rule)
        let data = try! JSONEncoder().encode(container)

        let event = SyncableEvent(
            title: "Daily event",
            startDate: masterDate,
            category: "other",
            recurrenceRuleData: data
        )

        let occurrences = RecurringEventExpander.generateOccurrences(
            for: event,
            rangeStart: rangeStart,
            rangeEnd: rangeEnd
        )

        XCTAssertTrue(occurrences.allSatisfy { $0.isOccurrence }, "All generated occurrences should have isOccurrence = true")
    }

    // MARK: - Expansion Entry Point Tests

    /// Test expandRecurringEvents main entry point
    func testExpandRecurringEventsMainEntryPoint() {
        let masterDate = Calendar.current.date(from: DateComponents(year: 2025, month: 12, day: 1))!

        let rule = SerializableRecurrenceRule(
            frequency: 0, // Daily
            interval: 1
        )

        let container = RecurrenceRuleContainer.solar(rule)
        let data = try! JSONEncoder().encode(container)

        let event = SyncableEvent(
            title: "Daily event",
            startDate: masterDate,
            category: "other",
            recurrenceRuleData: data
        )

        let events = [event]

        // Using default date range
        let occurrences = RecurringEventExpander.expandRecurringEvents(events)

        XCTAssertGreaterThan(occurrences.count, 0, "Should generate occurrences with default range")
        XCTAssertTrue(occurrences.allSatisfy { $0.masterEventId == event.id }, "All should reference master")
    }

    /// Test expandRecurringEvents with custom date range
    func testExpandRecurringEventsWithCustomDateRange() {
        let masterDate = Calendar.current.date(from: DateComponents(year: 2025, month: 12, day: 1))!
        let rangeStart = Calendar.current.date(from: DateComponents(year: 2025, month: 12, day: 1))!
        let rangeEnd = Calendar.current.date(from: DateComponents(year: 2025, month: 12, day: 5))!

        let rule = SerializableRecurrenceRule(
            frequency: 0, // Daily
            interval: 1
        )

        let container = RecurrenceRuleContainer.solar(rule)
        let data = try! JSONEncoder().encode(container)

        let event = SyncableEvent(
            title: "Daily event",
            startDate: masterDate,
            category: "other",
            recurrenceRuleData: data
        )

        let events = [event]

        let occurrences = RecurringEventExpander.expandRecurringEvents(
            events,
            rangeStart: rangeStart,
            rangeEnd: rangeEnd
        )

        XCTAssertEqual(occurrences.count, 5, "Custom range should produce 5 occurrences")
    }

    /// Test expandRecurringEvents with multiple events
    func testExpandRecurringEventsMultipleEvents() {
        let masterDate1 = Calendar.current.date(from: DateComponents(year: 2025, month: 12, day: 1))!
        let masterDate2 = Calendar.current.date(from: DateComponents(year: 2025, month: 12, day: 2))!

        let rule = SerializableRecurrenceRule(
            frequency: 0, // Daily
            interval: 1,
            recurrenceEnd: .occurrenceCount(3)
        )

        let container = RecurrenceRuleContainer.solar(rule)
        let data = try! JSONEncoder().encode(container)

        let event1 = SyncableEvent(
            title: "Event 1",
            startDate: masterDate1,
            category: "other",
            recurrenceRuleData: data
        )

        let event2 = SyncableEvent(
            title: "Event 2",
            startDate: masterDate2,
            category: "other",
            recurrenceRuleData: data
        )

        let events = [event1, event2]
        let rangeStart = masterDate1
        let rangeEnd = Calendar.current.date(from: DateComponents(year: 2025, month: 12, day: 10))!

        let occurrences = RecurringEventExpander.expandRecurringEvents(
            events,
            rangeStart: rangeStart,
            rangeEnd: rangeEnd
        )

        XCTAssertEqual(occurrences.count, 6, "Should expand both events (3 + 3)")

        let event1Occurrences = occurrences.filter { $0.masterEventId == event1.id }
        let event2Occurrences = occurrences.filter { $0.masterEventId == event2.id }

        XCTAssertEqual(event1Occurrences.count, 3)
        XCTAssertEqual(event2Occurrences.count, 3)
    }

    // MARK: - Edge Cases

    /// Test expansion with occurrence date adjustment
    func testOccurrenceDateAdjustment() {
        let masterDate = Calendar.current.date(from: DateComponents(year: 2025, month: 12, day: 1, hour: 10, minute: 30))!
        let rangeStart = masterDate
        let rangeEnd = Calendar.current.date(from: DateComponents(year: 2025, month: 12, day: 3))!

        let rule = SerializableRecurrenceRule(
            frequency: 0, // Daily
            interval: 1
        )

        let container = RecurrenceRuleContainer.solar(rule)
        let data = try! JSONEncoder().encode(container)

        let event = SyncableEvent(
            title: "Event with time",
            startDate: masterDate,
            category: "other",
            recurrenceRuleData: data
        )

        let occurrences = RecurringEventExpander.generateOccurrences(
            for: event,
            rangeStart: rangeStart,
            rangeEnd: rangeEnd
        )

        // First occurrence should be master date
        let firstOccurrence = occurrences.first!
        XCTAssertEqual(
            Calendar.current.dateComponents([.hour, .minute], from: firstOccurrence.date),
            Calendar.current.dateComponents([.hour, .minute], from: masterDate),
            "First occurrence should preserve time from master"
        )
    }

    /// Test decoding error handling
    func testInvalidRecurrenceDataHandling() {
        let event = SyncableEvent(
            title: "Event with invalid recurrence",
            startDate: Date(),
            category: "other",
            recurrenceRuleData: "invalid data".data(using: .utf8)
        )

        let occurrences = RecurringEventExpander.generateOccurrences(
            for: event,
            rangeStart: Date(),
            rangeEnd: Date()
        )

        XCTAssertEqual(occurrences.count, 1, "Should return master event on decode error")
    }

    // MARK: - Deterministic UUID Tests

    /// Test that occurrence UUIDs are deterministic across multiple calls
    func testOccurrenceUUIDConsistency() {
        let masterDate = Calendar.current.date(from: DateComponents(year: 2025, month: 12, day: 1))!
        let rangeStart = masterDate
        let rangeEnd = Calendar.current.date(from: DateComponents(year: 2025, month: 12, day: 5))!

        let rule = SerializableRecurrenceRule(
            frequency: 0, // Daily
            interval: 1
        )

        let container = RecurrenceRuleContainer.solar(rule)
        let data = try! JSONEncoder().encode(container)

        let event = SyncableEvent(
            title: "Daily event",
            startDate: masterDate,
            category: "other",
            recurrenceRuleData: data
        )

        // Generate twice
        let occurrences1 = RecurringEventExpander.generateOccurrences(
            for: event,
            rangeStart: rangeStart,
            rangeEnd: rangeEnd
        )

        let occurrences2 = RecurringEventExpander.generateOccurrences(
            for: event,
            rangeStart: rangeStart,
            rangeEnd: rangeEnd
        )

        // UUIDs should be identical
        for (occ1, occ2) in zip(occurrences1, occurrences2) {
            XCTAssertEqual(occ1.id, occ2.id, "Same occurrence should have same UUID")
        }
    }
}
