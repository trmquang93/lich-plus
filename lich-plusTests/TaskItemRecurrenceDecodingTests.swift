//
//  TaskItemRecurrenceDecodingTests.swift
//  lich-plusTests
//
//  Created by Quang Tran Minh on 07/12/25.
//

import XCTest
import SwiftData
import EventKit
@testable import lich_plus

final class TaskItemRecurrenceDecodingTests: XCTestCase {

    var modelContext: ModelContext!

    override func setUp() async throws {
        try await super.setUp()

        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: SyncableEvent.self, configurations: config)
        modelContext = ModelContext(container)
    }

    override func tearDown() async throws {
        modelContext = nil
        try await super.tearDown()
    }

    // MARK: - Lunar Recurrence Decoding Tests

    func testDecodeTaskItem_WithLunarYearlyRecurrence() throws {
        // Given: A SyncableEvent with lunar yearly recurrence data
        let lunarRule = SerializableLunarRecurrenceRule(
            frequency: .yearly,
            lunarDay: 15,
            lunarMonth: 4,
            leapMonthBehavior: .skipLeap,
            interval: 1,
            recurrenceEnd: nil
        )
        let container = RecurrenceRuleContainer.lunar(lunarRule)
        let recurrenceData = try JSONEncoder().encode(container)

        let syncableEvent = SyncableEvent(
            title: "Birthday",
            startDate: Date(),
            category: TaskCategory.birthday.rawValue,
            recurrenceRuleData: recurrenceData,
            itemType: ItemType.event.rawValue,
            priority: Priority.none.rawValue
        )

        // When: Converting to TaskItem
        let taskItem = TaskItem(from: syncableEvent)

        // Then: Recurrence should be decoded to lunarYearly
        XCTAssertEqual(taskItem.recurrence, .lunarYearly)
        XCTAssertTrue(taskItem.recurrence.isLunar)
    }

    func testDecodeTaskItem_WithLunarMonthlyRecurrence() throws {
        // Given: A SyncableEvent with lunar monthly recurrence data
        let lunarRule = SerializableLunarRecurrenceRule(
            frequency: .monthly,
            lunarDay: 1,
            lunarMonth: nil,
            leapMonthBehavior: .includeLeap,
            interval: 1,
            recurrenceEnd: nil
        )
        let container = RecurrenceRuleContainer.lunar(lunarRule)
        let recurrenceData = try JSONEncoder().encode(container)

        let syncableEvent = SyncableEvent(
            title: "Monthly Reminder",
            startDate: Date(),
            category: TaskCategory.personal.rawValue,
            recurrenceRuleData: recurrenceData,
            itemType: ItemType.task.rawValue,
            priority: Priority.none.rawValue
        )

        // When: Converting to TaskItem
        let taskItem = TaskItem(from: syncableEvent)

        // Then: Recurrence should be decoded to lunarMonthly
        XCTAssertEqual(taskItem.recurrence, .lunarMonthly)
        XCTAssertTrue(taskItem.recurrence.isLunar)
    }

    func testDecodeTaskItem_WithNoRecurrence() {
        // Given: A SyncableEvent with no recurrence data
        let syncableEvent = SyncableEvent(
            title: "Simple Task",
            startDate: Date(),
            category: TaskCategory.personal.rawValue,
            recurrenceRuleData: nil,
            itemType: ItemType.task.rawValue,
            priority: Priority.none.rawValue
        )

        // When: Converting to TaskItem
        let taskItem = TaskItem(from: syncableEvent)

        // Then: Recurrence should be .none
        XCTAssertEqual(taskItem.recurrence, .none)
        XCTAssertFalse(taskItem.recurrence.isLunar)
    }

    func testDecodeTaskItem_WithInvalidRecurrenceData() {
        // Given: A SyncableEvent with corrupted recurrence data
        let corruptedData = "invalid json".data(using: .utf8)!

        let syncableEvent = SyncableEvent(
            title: "Task with bad data",
            startDate: Date(),
            category: TaskCategory.personal.rawValue,
            recurrenceRuleData: corruptedData,
            itemType: ItemType.task.rawValue,
            priority: Priority.none.rawValue
        )

        // When: Converting to TaskItem
        let taskItem = TaskItem(from: syncableEvent)

        // Then: Should gracefully handle invalid data and default to .none
        XCTAssertEqual(taskItem.recurrence, .none)
    }

    func testDecodeTaskItem_WithNoneRecurrenceContainer() throws {
        // Given: A SyncableEvent with RecurrenceRuleContainer.none
        let container = RecurrenceRuleContainer.none
        let recurrenceData = try JSONEncoder().encode(container)

        let syncableEvent = SyncableEvent(
            title: "Task with explicit none",
            startDate: Date(),
            category: TaskCategory.personal.rawValue,
            recurrenceRuleData: recurrenceData,
            itemType: ItemType.task.rawValue,
            priority: Priority.none.rawValue
        )

        // When: Converting to TaskItem
        let taskItem = TaskItem(from: syncableEvent)

        // Then: Recurrence should be .none
        XCTAssertEqual(taskItem.recurrence, .none)
    }

    // MARK: - Solar Recurrence Decoding Tests

    func testDecodeTaskItem_WithSolarDailyRecurrence() throws {
        // Given: A SyncableEvent with solar daily recurrence data
        let solarRule = SerializableRecurrenceRule(
            frequency: EKRecurrenceFrequency.daily.rawValue,
            interval: 1,
            daysOfTheWeek: nil,
            daysOfTheMonth: nil,
            monthsOfTheYear: nil,
            weeksOfTheYear: nil,
            daysOfTheYear: nil,
            setPositions: nil,
            recurrenceEnd: nil
        )
        let container = RecurrenceRuleContainer.solar(solarRule)
        let recurrenceData = try JSONEncoder().encode(container)

        let syncableEvent = SyncableEvent(
            title: "Daily Task",
            startDate: Date(),
            category: TaskCategory.personal.rawValue,
            recurrenceRuleData: recurrenceData,
            itemType: ItemType.task.rawValue,
            priority: Priority.none.rawValue
        )

        // When: Converting to TaskItem
        let taskItem = TaskItem(from: syncableEvent)

        // Then: Recurrence should be decoded to solar daily
        XCTAssertEqual(taskItem.recurrence, .daily)
        XCTAssertFalse(taskItem.recurrence.isLunar)
    }

    func testDecodeTaskItem_WithSolarWeeklyRecurrence() throws {
        // Given: A SyncableEvent with solar weekly recurrence data
        let solarRule = SerializableRecurrenceRule(
            frequency: EKRecurrenceFrequency.weekly.rawValue,
            interval: 1,
            daysOfTheWeek: nil,
            daysOfTheMonth: nil,
            monthsOfTheYear: nil,
            weeksOfTheYear: nil,
            daysOfTheYear: nil,
            setPositions: nil,
            recurrenceEnd: nil
        )
        let container = RecurrenceRuleContainer.solar(solarRule)
        let recurrenceData = try JSONEncoder().encode(container)

        let syncableEvent = SyncableEvent(
            title: "Weekly Meeting",
            startDate: Date(),
            category: TaskCategory.meeting.rawValue,
            recurrenceRuleData: recurrenceData,
            itemType: ItemType.event.rawValue,
            priority: Priority.none.rawValue
        )

        // When: Converting to TaskItem
        let taskItem = TaskItem(from: syncableEvent)

        // Then: Recurrence should be decoded to solar weekly
        XCTAssertEqual(taskItem.recurrence, .weekly)
        XCTAssertFalse(taskItem.recurrence.isLunar)
    }

    func testDecodeTaskItem_WithSolarMonthlyRecurrence() throws {
        // Given: A SyncableEvent with solar monthly recurrence data
        let solarRule = SerializableRecurrenceRule(
            frequency: EKRecurrenceFrequency.monthly.rawValue,
            interval: 1,
            daysOfTheWeek: nil,
            daysOfTheMonth: nil,
            monthsOfTheYear: nil,
            weeksOfTheYear: nil,
            daysOfTheYear: nil,
            setPositions: nil,
            recurrenceEnd: nil
        )
        let container = RecurrenceRuleContainer.solar(solarRule)
        let recurrenceData = try JSONEncoder().encode(container)

        let syncableEvent = SyncableEvent(
            title: "Monthly Report",
            startDate: Date(),
            category: TaskCategory.work.rawValue,
            recurrenceRuleData: recurrenceData,
            itemType: ItemType.task.rawValue,
            priority: Priority.high.rawValue
        )

        // When: Converting to TaskItem
        let taskItem = TaskItem(from: syncableEvent)

        // Then: Recurrence should be decoded to solar monthly
        XCTAssertEqual(taskItem.recurrence, .monthly)
        XCTAssertFalse(taskItem.recurrence.isLunar)
    }

    func testDecodeTaskItem_WithSolarYearlyRecurrence() throws {
        // Given: A SyncableEvent with solar yearly recurrence data
        let solarRule = SerializableRecurrenceRule(
            frequency: EKRecurrenceFrequency.yearly.rawValue,
            interval: 1,
            daysOfTheWeek: nil,
            daysOfTheMonth: nil,
            monthsOfTheYear: nil,
            weeksOfTheYear: nil,
            daysOfTheYear: nil,
            setPositions: nil,
            recurrenceEnd: nil
        )
        let container = RecurrenceRuleContainer.solar(solarRule)
        let recurrenceData = try JSONEncoder().encode(container)

        let syncableEvent = SyncableEvent(
            title: "Yearly Anniversary",
            startDate: Date(),
            category: TaskCategory.holiday.rawValue,
            recurrenceRuleData: recurrenceData,
            itemType: ItemType.event.rawValue,
            priority: Priority.none.rawValue
        )

        // When: Converting to TaskItem
        let taskItem = TaskItem(from: syncableEvent)

        // Then: Recurrence should be decoded to solar yearly
        XCTAssertEqual(taskItem.recurrence, .yearly)
        XCTAssertFalse(taskItem.recurrence.isLunar)
    }

    // MARK: - Edge Cases

    func testDecodeTaskItem_WithEmptyRecurrenceData() {
        // Given: A SyncableEvent with empty recurrence data
        let emptyData = Data()

        let syncableEvent = SyncableEvent(
            title: "Task with empty data",
            startDate: Date(),
            category: TaskCategory.personal.rawValue,
            recurrenceRuleData: emptyData,
            itemType: ItemType.task.rawValue,
            priority: Priority.none.rawValue
        )

        // When: Converting to TaskItem
        let taskItem = TaskItem(from: syncableEvent)

        // Then: Should default to .none
        XCTAssertEqual(taskItem.recurrence, .none)
    }

    func testDecodeTaskItem_PreservesOtherProperties() throws {
        // Given: A SyncableEvent with recurrence and other properties
        let lunarRule = SerializableLunarRecurrenceRule(
            frequency: .yearly,
            lunarDay: 15,
            lunarMonth: 4,
            leapMonthBehavior: .skipLeap,
            interval: 1,
            recurrenceEnd: nil
        )
        let container = RecurrenceRuleContainer.lunar(lunarRule)
        let recurrenceData = try JSONEncoder().encode(container)

        let startDate = Date(timeIntervalSince1970: 1000)
        let endDate = Date(timeIntervalSince1970: 2000)

        let syncableEvent = SyncableEvent(
            id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440000")!,
            title: "Birthday",
            startDate: startDate,
            endDate: endDate,
            isAllDay: false,
            notes: "Important birthday",
            isCompleted: false,
            category: TaskCategory.birthday.rawValue,
            reminderMinutes: 60,
            recurrenceRuleData: recurrenceData,
            createdAt: Date(),
            itemType: ItemType.event.rawValue,
            priority: Priority.high.rawValue,
            location: "Home"
        )

        // When: Converting to TaskItem
        let taskItem = TaskItem(from: syncableEvent)

        // Then: All properties should be preserved
        XCTAssertEqual(taskItem.id, syncableEvent.id)
        XCTAssertEqual(taskItem.title, "Birthday")
        XCTAssertEqual(taskItem.date, startDate)
        XCTAssertEqual(taskItem.startTime, startDate)
        XCTAssertEqual(taskItem.endTime, endDate)
        XCTAssertEqual(taskItem.notes, "Important birthday")
        XCTAssertFalse(taskItem.isCompleted)
        XCTAssertEqual(taskItem.category, .birthday)
        XCTAssertEqual(taskItem.reminderMinutes, 60)
        XCTAssertEqual(taskItem.recurrence, .lunarYearly)
        XCTAssertEqual(taskItem.itemType, .event)
        XCTAssertEqual(taskItem.priority, .high)
        XCTAssertEqual(taskItem.location, "Home")
    }

    // MARK: - Recurrence Type Properties

    func testRecurrenceTypeIsLunarProperty() {
        XCTAssertTrue(RecurrenceType.lunarMonthly.isLunar)
        XCTAssertTrue(RecurrenceType.lunarYearly.isLunar)
        XCTAssertFalse(RecurrenceType.none.isLunar)
        XCTAssertFalse(RecurrenceType.daily.isLunar)
        XCTAssertFalse(RecurrenceType.weekly.isLunar)
        XCTAssertFalse(RecurrenceType.monthly.isLunar)
        XCTAssertFalse(RecurrenceType.yearly.isLunar)
    }
}
