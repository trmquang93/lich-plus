//
//  CalendarDataManagerLunarExpansionTests.swift
//  lich-plusTests
//
//  Created by Quang Tran Minh on 07/12/25.
//

import XCTest
import SwiftData
@testable import lich_plus

@MainActor
final class CalendarDataManagerLunarExpansionTests: XCTestCase {

    var modelContext: ModelContext!
    var manager: CalendarDataManager!
    var testDate: Date!

    override func setUp() async throws {
        try await super.setUp()

        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: SyncableEvent.self, configurations: config)
        modelContext = ModelContext(container)

        await MainActor.run {
            manager = CalendarDataManager()
            manager.setModelContext(modelContext)
        }

        testDate = Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 15))!
    }

    override func tearDown() async throws {
        modelContext = nil
        manager = nil
        testDate = nil
        try await super.tearDown()
    }

    // MARK: - No Recurrence Tests

    @MainActor
    func testFetchEvents_WithNonRecurringEvent() throws {
        let syncableEvent = SyncableEvent(
            title: "Regular Event",
            startDate: testDate,
            category: TaskCategory.personal.rawValue,
            recurrenceRuleData: nil,
            itemType: ItemType.event.rawValue,
            priority: Priority.none.rawValue
        )
        modelContext.insert(syncableEvent)
        try modelContext.save()

        let events = manager.fetchEvents(for: testDate)

        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events[0].title, "Regular Event")
    }

    @MainActor
    func testFetchEvents_WithNonRecurringEvent_DifferentDate() throws {
        let eventDate = Calendar.current.date(byAdding: .day, value: 1, to: testDate)!
        let syncableEvent = SyncableEvent(
            title: "Tomorrow's Event",
            startDate: eventDate,
            category: TaskCategory.personal.rawValue,
            recurrenceRuleData: nil,
            itemType: ItemType.event.rawValue,
            priority: Priority.none.rawValue
        )
        modelContext.insert(syncableEvent)
        try modelContext.save()

        let events = manager.fetchEvents(for: testDate)

        XCTAssertEqual(events.count, 0)
    }

    // MARK: - Lunar Yearly Recurrence Tests

    @MainActor
    func testFetchEvents_WithLunarYearlyRecurrence() throws {
        // Chinese New Year (lunar 1/1)
        let lunarRule = SerializableLunarRecurrenceRule(
            frequency: .yearly,
            lunarDay: 1,
            lunarMonth: 1,
            leapMonthBehavior: .skipLeap,
            interval: 1,
            recurrenceEnd: .endDate(Calendar.current.date(from: DateComponents(year: 2027, month: 12, day: 31))!)
        )
        let container = RecurrenceRuleContainer.lunar(lunarRule)
        let recurrenceData = try JSONEncoder().encode(container)

        // Use the actual occurrence date (Jan 29, 2025 = lunar 1/1) as the master date
        // This ensures the lunar year is correctly identified
        let masterDate = Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 29))!

        let syncableEvent = SyncableEvent(
            title: "Chinese New Year",
            startDate: masterDate,
            category: TaskCategory.holiday.rawValue,
            recurrenceRuleData: recurrenceData,
            itemType: ItemType.event.rawValue,
            priority: Priority.none.rawValue
        )
        modelContext.insert(syncableEvent)
        try modelContext.save()

        // Chinese New Year 2025 is January 29, 2025
        let occurrenceDate = Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 29))!
        let events = manager.fetchEvents(for: occurrenceDate)

        XCTAssertGreaterThan(events.count, 0)
        XCTAssertTrue(events.contains { $0.title == "Chinese New Year" })
    }

    @MainActor
    func testFetchEvents_WithLunarYearlyRecurrence_NextYear() throws {
        // Chinese New Year (lunar 1/1)
        let lunarRule = SerializableLunarRecurrenceRule(
            frequency: .yearly,
            lunarDay: 1,
            lunarMonth: 1,
            leapMonthBehavior: .skipLeap,
            interval: 1,
            recurrenceEnd: .endDate(Calendar.current.date(from: DateComponents(year: 2027, month: 12, day: 31))!)
        )
        let container = RecurrenceRuleContainer.lunar(lunarRule)
        let recurrenceData = try JSONEncoder().encode(container)

        // Use Jan 29, 2025 as master date (lunar 1/1 in 2025)
        let masterDate = Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 29))!

        let syncableEvent = SyncableEvent(
            title: "Chinese New Year",
            startDate: masterDate,
            category: TaskCategory.holiday.rawValue,
            recurrenceRuleData: recurrenceData,
            itemType: ItemType.event.rawValue,
            priority: Priority.none.rawValue
        )
        modelContext.insert(syncableEvent)
        try modelContext.save()

        // Chinese New Year 2026 is February 17, 2026
        let futureOccurrence = Calendar.current.date(from: DateComponents(year: 2026, month: 2, day: 17))!
        let events = manager.fetchEvents(for: futureOccurrence)

        XCTAssertGreaterThan(events.count, 0)
        XCTAssertTrue(events.contains { $0.title == "Chinese New Year" })
    }

    // MARK: - Lunar Monthly Recurrence Tests

    @MainActor
    func testFetchEvents_WithLunarMonthlyRecurrence() throws {
        // Every 1st day of each lunar month
        let lunarRule = SerializableLunarRecurrenceRule(
            frequency: .monthly,
            lunarDay: 1,
            lunarMonth: nil,
            leapMonthBehavior: .includeLeap,
            interval: 1,
            recurrenceEnd: .endDate(Calendar.current.date(from: DateComponents(year: 2026, month: 12, day: 31))!)
        )
        let container = RecurrenceRuleContainer.lunar(lunarRule)
        let recurrenceData = try JSONEncoder().encode(container)

        let masterDate = Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 29))!

        let syncableEvent = SyncableEvent(
            title: "Monthly Check-in",
            startDate: masterDate,
            category: TaskCategory.personal.rawValue,
            recurrenceRuleData: recurrenceData,
            itemType: ItemType.task.rawValue,
            priority: Priority.none.rawValue
        )
        modelContext.insert(syncableEvent)
        try modelContext.save()

        // January 29, 2025 is lunar 1/1
        let firstOccurrence = Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 29))!
        let firstEvents = manager.fetchEvents(for: firstOccurrence)

        XCTAssertGreaterThan(firstEvents.count, 0)
        XCTAssertTrue(firstEvents.contains { $0.title == "Monthly Check-in" })

        // February 28, 2025 is lunar 2/1
        let secondOccurrence = Calendar.current.date(from: DateComponents(year: 2025, month: 2, day: 28))!
        let secondEvents = manager.fetchEvents(for: secondOccurrence)

        XCTAssertGreaterThan(secondEvents.count, 0)
        XCTAssertTrue(secondEvents.contains { $0.title == "Monthly Check-in" })
    }

    // MARK: - Multiple Events Tests

    @MainActor
    func testFetchEvents_WithMultipleRecurringEvents() throws {
        // Yearly: Chinese New Year (lunar 1/1)
        let lunarYearlyRule = SerializableLunarRecurrenceRule(
            frequency: .yearly,
            lunarDay: 1,
            lunarMonth: 1,
            leapMonthBehavior: .skipLeap,
            interval: 1,
            recurrenceEnd: .endDate(Calendar.current.date(from: DateComponents(year: 2027, month: 12, day: 31))!)
        )
        let yearlyContainer = RecurrenceRuleContainer.lunar(lunarYearlyRule)
        let yearlyRecurrenceData = try JSONEncoder().encode(yearlyContainer)

        // Monthly: Every 1st of lunar month
        let lunarMonthlyRule = SerializableLunarRecurrenceRule(
            frequency: .monthly,
            lunarDay: 1,
            lunarMonth: nil,
            leapMonthBehavior: .includeLeap,
            interval: 1,
            recurrenceEnd: .endDate(Calendar.current.date(from: DateComponents(year: 2027, month: 12, day: 31))!)
        )
        let monthlyContainer = RecurrenceRuleContainer.lunar(lunarMonthlyRule)
        let monthlyRecurrenceData = try JSONEncoder().encode(monthlyContainer)

        let masterDate = Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 29))!

        let yearlyEvent = SyncableEvent(
            title: "Chinese New Year",
            startDate: masterDate,
            category: TaskCategory.holiday.rawValue,
            recurrenceRuleData: yearlyRecurrenceData,
            itemType: ItemType.event.rawValue,
            priority: Priority.none.rawValue
        )

        let monthlyEvent = SyncableEvent(
            title: "Monthly Check-in",
            startDate: masterDate,
            category: TaskCategory.personal.rawValue,
            recurrenceRuleData: monthlyRecurrenceData,
            itemType: ItemType.task.rawValue,
            priority: Priority.none.rawValue
        )

        modelContext.insert(yearlyEvent)
        modelContext.insert(monthlyEvent)
        try modelContext.save()

        // January 29, 2025 is lunar 1/1 (matches both yearly and monthly)
        let occurrenceDate = Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 29))!
        let events = manager.fetchEvents(for: occurrenceDate)

        XCTAssertGreaterThanOrEqual(events.count, 2)
        XCTAssertTrue(events.contains { $0.title == "Chinese New Year" })
        XCTAssertTrue(events.contains { $0.title == "Monthly Check-in" })
    }

    @MainActor
    func testFetchEvents_WithMixedRecurringAndNonRecurring() throws {
        // Chinese New Year (lunar 1/1)
        let lunarRule = SerializableLunarRecurrenceRule(
            frequency: .yearly,
            lunarDay: 1,
            lunarMonth: 1,
            leapMonthBehavior: .skipLeap,
            interval: 1,
            recurrenceEnd: .endDate(Calendar.current.date(from: DateComponents(year: 2027, month: 12, day: 31))!)
        )
        let container = RecurrenceRuleContainer.lunar(lunarRule)
        let recurrenceData = try JSONEncoder().encode(container)

        let masterDate = Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 29))!
        // January 29, 2025 is lunar 1/1
        let targetDate = Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 29))!

        let recurringEvent = SyncableEvent(
            title: "Chinese New Year",
            startDate: masterDate,
            category: TaskCategory.holiday.rawValue,
            recurrenceRuleData: recurrenceData,
            itemType: ItemType.event.rawValue,
            priority: Priority.none.rawValue
        )

        let nonRecurringEvent = SyncableEvent(
            title: "One-time Event",
            startDate: targetDate,
            category: TaskCategory.personal.rawValue,
            recurrenceRuleData: nil,
            itemType: ItemType.event.rawValue,
            priority: Priority.none.rawValue
        )

        modelContext.insert(recurringEvent)
        modelContext.insert(nonRecurringEvent)
        try modelContext.save()

        let events = manager.fetchEvents(for: targetDate)

        XCTAssertGreaterThanOrEqual(events.count, 2)
        XCTAssertTrue(events.contains { $0.title == "Chinese New Year" })
        XCTAssertTrue(events.contains { $0.title == "One-time Event" })
    }

    // MARK: - Deleted Event Tests

    @MainActor
    func testFetchEvents_IgnoresDeletedRecurringEvents() throws {
        // Chinese New Year (lunar 1/1)
        let lunarRule = SerializableLunarRecurrenceRule(
            frequency: .yearly,
            lunarDay: 1,
            lunarMonth: 1,
            leapMonthBehavior: .skipLeap,
            interval: 1,
            recurrenceEnd: .endDate(Calendar.current.date(from: DateComponents(year: 2027, month: 12, day: 31))!)
        )
        let container = RecurrenceRuleContainer.lunar(lunarRule)
        let recurrenceData = try JSONEncoder().encode(container)

        let masterDate = Calendar.current.date(from: DateComponents(year: 2025, month: 2, day: 10))!

        let syncableEvent = SyncableEvent(
            title: "Deleted Event",
            startDate: masterDate,
            category: TaskCategory.personal.rawValue,
            recurrenceRuleData: recurrenceData,
            isDeleted: true,
            itemType: ItemType.event.rawValue,
            priority: Priority.none.rawValue
        )
        modelContext.insert(syncableEvent)
        try modelContext.save()

        // February 10, 2025 is lunar 1/1
        let targetDate = Calendar.current.date(from: DateComponents(year: 2025, month: 2, day: 10))!
        let events = manager.fetchEvents(for: targetDate)

        XCTAssertEqual(events.count, 0)
        XCTAssertFalse(events.contains { $0.title == "Deleted Event" })
    }

    // MARK: - Empty Database Tests

    @MainActor
    func testFetchEvents_EmptyDatabase() {
        let events = manager.fetchEvents(for: testDate)

        XCTAssertEqual(events.count, 0)
    }

    // MARK: - Event Properties Tests

    @MainActor
    func testFetchEvents_PreservesEventProperties() throws {
        // Chinese New Year (lunar 1/1)
        let lunarRule = SerializableLunarRecurrenceRule(
            frequency: .yearly,
            lunarDay: 1,
            lunarMonth: 1,
            leapMonthBehavior: .skipLeap,
            interval: 1,
            recurrenceEnd: nil
        )
        let container = RecurrenceRuleContainer.lunar(lunarRule)
        let recurrenceData = try JSONEncoder().encode(container)

        let masterDate = Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 29))!

        let syncableEvent = SyncableEvent(
            title: "Test Event",
            startDate: masterDate,
            notes: "Important event",
            category: TaskCategory.work.rawValue,
            recurrenceRuleData: recurrenceData,
            itemType: ItemType.event.rawValue,
            priority: Priority.high.rawValue
        )
        modelContext.insert(syncableEvent)
        try modelContext.save()

        // January 29, 2025 is lunar 1/1
        let targetDate = Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 29))!
        let events = manager.fetchEvents(for: targetDate)

        XCTAssertGreaterThan(events.count, 0)
        let event = events.first(where: { $0.title == "Test Event" })
        XCTAssertNotNil(event)
        XCTAssertEqual(event?.description, "Important event")
    }

    // MARK: - No Occurrences in Range Tests

    @MainActor
    func testFetchEvents_NoOccurrencesInRange() throws {
        // Chinese New Year (lunar 1/1)
        let lunarRule = SerializableLunarRecurrenceRule(
            frequency: .yearly,
            lunarDay: 1,
            lunarMonth: 1,
            leapMonthBehavior: .skipLeap,
            interval: 1,
            recurrenceEnd: .endDate(Calendar.current.date(from: DateComponents(year: 2025, month: 12, day: 31))!)
        )
        let container = RecurrenceRuleContainer.lunar(lunarRule)
        let recurrenceData = try JSONEncoder().encode(container)

        let masterDate = Calendar.current.date(from: DateComponents(year: 2025, month: 2, day: 10))!

        let syncableEvent = SyncableEvent(
            title: "Chinese New Year",
            startDate: masterDate,
            category: TaskCategory.holiday.rawValue,
            recurrenceRuleData: recurrenceData,
            itemType: ItemType.event.rawValue,
            priority: Priority.none.rawValue
        )
        modelContext.insert(syncableEvent)
        try modelContext.save()

        // June 15, 2025 is NOT a lunar 1/1 date, so no occurrence should be found
        let nonMatchingDate = Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 15))!
        let events = manager.fetchEvents(for: nonMatchingDate)

        XCTAssertEqual(events.count, 0)
    }
}
