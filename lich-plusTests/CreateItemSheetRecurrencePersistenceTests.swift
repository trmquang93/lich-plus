//
//  CreateItemSheetRecurrencePersistenceTests.swift
//  lich-plusTests
//
//  Tests for recurrence persistence bug fix in CreateItemSheet
//

import XCTest
import SwiftData
@testable import lich_plus

final class CreateItemSheetRecurrencePersistenceTests: XCTestCase {

    // MARK: - Setup

    var modelContainer: ModelContainer!
    var modelContext: ModelContext!

    override func setUp() {
        super.setUp()
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try! ModelContainer(for: SyncableEvent.self, configurations: config)
        modelContext = ModelContext(modelContainer)
    }

    override func tearDown() {
        modelContext = nil
        modelContainer = nil
        super.tearDown()
    }

    // MARK: - Test: Solar Recurrence Persistence

    func testCreateRecurrenceDataForDailyRecurrence() throws {
        // Arrange
        let recurrence = RecurrenceType.daily

        // Act
        let data = createRecurrenceData(selectedRecurrence: recurrence)

        // Assert
        XCTAssertNotNil(data)
        let container = try JSONDecoder().decode(RecurrenceRuleContainer.self, from: data!)

        if case .solar(let rule) = container {
            XCTAssertEqual(rule.frequency, 0)  // daily
            XCTAssertEqual(rule.interval, 1)
        } else {
            XCTFail("Expected solar recurrence")
        }
    }

    func testCreateRecurrenceDataForWeeklyRecurrence() throws {
        // Arrange
        let recurrence = RecurrenceType.weekly

        // Act
        let data = createRecurrenceData(selectedRecurrence: recurrence)

        // Assert
        XCTAssertNotNil(data)
        let container = try JSONDecoder().decode(RecurrenceRuleContainer.self, from: data!)

        if case .solar(let rule) = container {
            XCTAssertEqual(rule.frequency, 1)  // weekly
            XCTAssertEqual(rule.interval, 1)
        } else {
            XCTFail("Expected solar recurrence")
        }
    }

    func testCreateRecurrenceDataForMonthlyRecurrence() throws {
        // Arrange
        let recurrence = RecurrenceType.monthly

        // Act
        let data = createRecurrenceData(selectedRecurrence: recurrence)

        // Assert
        XCTAssertNotNil(data)
        let container = try JSONDecoder().decode(RecurrenceRuleContainer.self, from: data!)

        if case .solar(let rule) = container {
            XCTAssertEqual(rule.frequency, 2)  // monthly
            XCTAssertEqual(rule.interval, 1)
        } else {
            XCTFail("Expected solar recurrence")
        }
    }

    func testCreateRecurrenceDataForYearlyRecurrence() throws {
        // Arrange
        let recurrence = RecurrenceType.yearly

        // Act
        let data = createRecurrenceData(selectedRecurrence: recurrence)

        // Assert
        XCTAssertNotNil(data)
        let container = try JSONDecoder().decode(RecurrenceRuleContainer.self, from: data!)

        if case .solar(let rule) = container {
            XCTAssertEqual(rule.frequency, 3)  // yearly
            XCTAssertEqual(rule.interval, 1)
        } else {
            XCTFail("Expected solar recurrence")
        }
    }

    func testCreateRecurrenceDataForNoneRecurrence() throws {
        // Arrange
        let recurrence = RecurrenceType.none

        // Act
        let data = createRecurrenceData(selectedRecurrence: recurrence)

        // Assert
        XCTAssertNil(data)
    }

    // MARK: - Test: Lunar Recurrence Persistence

    func testCreateRecurrenceDataForLunarMonthly() throws {
        // Arrange
        let lunarRule = SerializableLunarRecurrenceRule(
            frequency: .monthly,
            lunarDay: 15,
            lunarMonth: nil,
            leapMonthBehavior: .includeLeap,
            interval: 1,
            recurrenceEnd: nil
        )

        // Act
        let data = createRecurrenceDataForLunar(lunarRule: lunarRule)

        // Assert
        XCTAssertNotNil(data)
        let container = try JSONDecoder().decode(RecurrenceRuleContainer.self, from: data!)

        if case .lunar(let rule) = container {
            XCTAssertEqual(rule.frequency, .monthly)
            XCTAssertEqual(rule.lunarDay, 15)
            XCTAssertNil(rule.lunarMonth)
            XCTAssertEqual(rule.leapMonthBehavior, .includeLeap)
        } else {
            XCTFail("Expected lunar recurrence")
        }
    }

    func testCreateRecurrenceDataForLunarYearly() throws {
        // Arrange
        let lunarRule = SerializableLunarRecurrenceRule(
            frequency: .yearly,
            lunarDay: 15,
            lunarMonth: 4,
            leapMonthBehavior: .skipLeap,
            interval: 1,
            recurrenceEnd: nil
        )

        // Act
        let data = createRecurrenceDataForLunar(lunarRule: lunarRule)

        // Assert
        XCTAssertNotNil(data)
        let container = try JSONDecoder().decode(RecurrenceRuleContainer.self, from: data!)

        if case .lunar(let rule) = container {
            XCTAssertEqual(rule.frequency, .yearly)
            XCTAssertEqual(rule.lunarDay, 15)
            XCTAssertEqual(rule.lunarMonth, 4)
            XCTAssertEqual(rule.leapMonthBehavior, .skipLeap)
        } else {
            XCTFail("Expected lunar recurrence")
        }
    }

    // MARK: - Test: Save and Load Recurrence

    func testSaveEventWithSolarRecurrence() throws {
        // Arrange
        let event = SyncableEvent(
            title: "Weekly Meeting",
            startDate: Date(),
            endDate: nil,
            isAllDay: false,
            category: "work",
            itemType: "event"
        )

        // Act - save with daily recurrence
        let recurrenceData = createRecurrenceData(selectedRecurrence: .daily)
        event.recurrenceRuleData = recurrenceData

        modelContext.insert(event)
        try modelContext.save()

        // Assert - reload and verify
        let fetched = try modelContext.fetch(FetchDescriptor<SyncableEvent>())
        let savedEvent = fetched.first(where: { $0.id == event.id })

        XCTAssertNotNil(savedEvent?.recurrenceRuleData)
        let container = try JSONDecoder().decode(RecurrenceRuleContainer.self, from: savedEvent!.recurrenceRuleData!)

        if case .solar(let rule) = container {
            XCTAssertEqual(rule.frequency, 0)  // daily
        } else {
            XCTFail("Expected solar recurrence")
        }
    }

    func testSaveTaskWithLunarYearlyRecurrence() throws {
        // Arrange
        let task = SyncableEvent(
            title: "Lunar Birthday",
            startDate: Date(),
            endDate: nil,
            isAllDay: true,
            category: "birthday",
            itemType: "task"
        )

        // Act - save with lunar yearly recurrence
        let lunarRule = SerializableLunarRecurrenceRule(
            frequency: .yearly,
            lunarDay: 15,
            lunarMonth: 7,
            leapMonthBehavior: .skipLeap,
            interval: 1,
            recurrenceEnd: nil
        )
        let recurrenceData = createRecurrenceDataForLunar(lunarRule: lunarRule)
        task.recurrenceRuleData = recurrenceData

        modelContext.insert(task)
        try modelContext.save()

        // Assert - reload and verify
        let fetched = try modelContext.fetch(FetchDescriptor<SyncableEvent>())
        let savedTask = fetched.first(where: { $0.id == task.id })

        XCTAssertNotNil(savedTask?.recurrenceRuleData)
        let container = try JSONDecoder().decode(RecurrenceRuleContainer.self, from: savedTask!.recurrenceRuleData!)

        if case .lunar(let rule) = container {
            XCTAssertEqual(rule.frequency, .yearly)
            XCTAssertEqual(rule.lunarDay, 15)
            XCTAssertEqual(rule.lunarMonth, 7)
        } else {
            XCTFail("Expected lunar recurrence")
        }
    }

    func testLoadEventWithoutRecurrence() throws {
        // Arrange
        let event = SyncableEvent(
            title: "One-time Event",
            startDate: Date(),
            endDate: nil,
            isAllDay: false,
            category: "personal",
            itemType: "event"
        )

        // Act
        modelContext.insert(event)
        try modelContext.save()

        let fetched = try modelContext.fetch(FetchDescriptor<SyncableEvent>())
        let savedEvent = fetched.first(where: { $0.id == event.id })

        // Assert
        XCTAssertNil(savedEvent?.recurrenceRuleData)
    }

    // MARK: - Test: Convert RecurrenceType to Solar Rule

    func testConvertDailyToSolarRule() {
        let rule = createSolarRecurrenceRule(from: .daily)
        XCTAssertEqual(rule.frequency, 0)  // daily
        XCTAssertEqual(rule.interval, 1)
    }

    func testConvertWeeklyToSolarRule() {
        let rule = createSolarRecurrenceRule(from: .weekly)
        XCTAssertEqual(rule.frequency, 1)  // weekly
        XCTAssertEqual(rule.interval, 1)
    }

    func testConvertMonthlyToSolarRule() {
        let rule = createSolarRecurrenceRule(from: .monthly)
        XCTAssertEqual(rule.frequency, 2)  // monthly
        XCTAssertEqual(rule.interval, 1)
    }

    func testConvertYearlyToSolarRule() {
        let rule = createSolarRecurrenceRule(from: .yearly)
        XCTAssertEqual(rule.frequency, 3)  // yearly
        XCTAssertEqual(rule.interval, 1)
    }

    // MARK: - Test: Convert Solar Rule to RecurrenceType

    func testConvertSolarRuleDailyToRecurrenceType() {
        let rule = SerializableRecurrenceRule(frequency: 0, interval: 1)
        let recurrence = convertToRecurrenceType(from: rule)
        XCTAssertEqual(recurrence, .daily)
    }

    func testConvertSolarRuleWeeklyToRecurrenceType() {
        let rule = SerializableRecurrenceRule(frequency: 1, interval: 1)
        let recurrence = convertToRecurrenceType(from: rule)
        XCTAssertEqual(recurrence, .weekly)
    }

    func testConvertSolarRuleMonthlyToRecurrenceType() {
        let rule = SerializableRecurrenceRule(frequency: 2, interval: 1)
        let recurrence = convertToRecurrenceType(from: rule)
        XCTAssertEqual(recurrence, .monthly)
    }

    func testConvertSolarRuleYearlyToRecurrenceType() {
        let rule = SerializableRecurrenceRule(frequency: 3, interval: 1)
        let recurrence = convertToRecurrenceType(from: rule)
        XCTAssertEqual(recurrence, .yearly)
    }

    func testConvertInvalidSolarRuleToNone() {
        let rule = SerializableRecurrenceRule(frequency: 99, interval: 1)
        let recurrence = convertToRecurrenceType(from: rule)
        XCTAssertEqual(recurrence, .none)
    }

    // MARK: - Helper Methods (Mimicking CreateItemSheet behavior)

    private func createRecurrenceData(selectedRecurrence: RecurrenceType) -> Data? {
        if selectedRecurrence != .none && !selectedRecurrence.isLunar {
            let solarRule = createSolarRecurrenceRule(from: selectedRecurrence)
            return try? JSONEncoder().encode(RecurrenceRuleContainer.solar(solarRule))
        }
        return nil
    }

    private func createRecurrenceDataForLunar(lunarRule: SerializableLunarRecurrenceRule) -> Data? {
        return try? JSONEncoder().encode(RecurrenceRuleContainer.lunar(lunarRule))
    }

    private func createSolarRecurrenceRule(from recurrence: RecurrenceType) -> SerializableRecurrenceRule {
        let frequency: Int
        switch recurrence {
        case .daily:
            frequency = 0  // EKRecurrenceFrequency.daily
        case .weekly:
            frequency = 1
        case .monthly:
            frequency = 2
        case .yearly:
            frequency = 3
        default:
            frequency = 0
        }

        return SerializableRecurrenceRule(
            frequency: frequency,
            interval: 1
        )
    }

    private func convertToRecurrenceType(from rule: SerializableRecurrenceRule) -> RecurrenceType {
        switch rule.frequency {
        case 0:
            return .daily
        case 1:
            return .weekly
        case 2:
            return .monthly
        case 3:
            return .yearly
        default:
            return .none
        }
    }
}
