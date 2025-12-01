//
//  AddEditTaskSheetTests.swift
//  lich-plusTests
//
//  Created by Quang Tran Minh on 26/11/25.
//

import XCTest
import SwiftData
@testable import lich_plus

final class AddEditTaskSheetTests: XCTestCase {

    // MARK: - Helper

    private func createInMemoryContext() throws -> ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: SyncableEvent.self, configurations: config)
        return ModelContext(container)
    }

    // MARK: - Priority Tests

    func testPriority_HasDefaultValue() {
        let priority = Priority.none
        XCTAssertEqual(priority, .none)
        XCTAssertEqual(priority.rawValue, "none")
    }

    func testPriority_HasAllCases() {
        let allCases = Priority.allCases
        XCTAssertEqual(allCases.count, 4)
        XCTAssertTrue(allCases.contains(.none))
        XCTAssertTrue(allCases.contains(.low))
        XCTAssertTrue(allCases.contains(.medium))
        XCTAssertTrue(allCases.contains(.high))
    }

    func testPriority_HasCorrectColors() {
        XCTAssertEqual(Priority.none.color, AppColors.textSecondary)
        XCTAssertEqual(Priority.low.color, AppColors.eventBlue)
        XCTAssertEqual(Priority.medium.color, AppColors.eventYellow)
        XCTAssertEqual(Priority.high.color, AppColors.primary)
    }

    // MARK: - ItemType Tests

    func testItemType_HasTaskAndEvent() {
        let allCases = ItemType.allCases
        XCTAssertEqual(allCases.count, 2)
        XCTAssertTrue(allCases.contains(.task))
        XCTAssertTrue(allCases.contains(.event))
    }

    func testItemType_HasCorrectRawValues() {
        XCTAssertEqual(ItemType.task.rawValue, "task")
        XCTAssertEqual(ItemType.event.rawValue, "event")
    }

    // MARK: - SyncableEvent Conversion Tests

    func testSyncableEvent_StoresItemType() {
        let event = SyncableEvent(
            title: "Test Event",
            startDate: Date(),
            itemType: "task",
            priority: "high"
        )

        XCTAssertEqual(event.itemType, "task")
        XCTAssertEqual(event.itemTypeEnum, .task)
    }

    func testSyncableEvent_StoresPriority() {
        let event = SyncableEvent(
            title: "Test Event",
            startDate: Date(),
            itemType: "task",
            priority: "high"
        )

        XCTAssertEqual(event.priority, "high")
        XCTAssertEqual(event.priorityEnum, .high)
    }

    func testSyncableEvent_StoresLocation() {
        let event = SyncableEvent(
            title: "Meeting",
            startDate: Date(),
            itemType: "event",
            location: "Conference Room A"
        )

        XCTAssertEqual(event.location, "Conference Room A")
    }

    func testSyncableEvent_HandlesNilLocation() {
        let event = SyncableEvent(
            title: "Task",
            startDate: Date(),
            itemType: "task",
            location: nil
        )

        XCTAssertNil(event.location)
    }

    func testSyncableEvent_DefaultItemTypeIsTask() {
        let event = SyncableEvent(
            title: "Default Event",
            startDate: Date()
        )

        XCTAssertEqual(event.itemType, "task")
        XCTAssertEqual(event.itemTypeEnum, .task)
    }

    func testSyncableEvent_DefaultPriorityIsNone() {
        let event = SyncableEvent(
            title: "Default Event",
            startDate: Date()
        )

        XCTAssertEqual(event.priority, "none")
        XCTAssertEqual(event.priorityEnum, .none)
    }

    // MARK: - Item Type and Priority Enum Tests

    func testItemTypeEnum_ConversionFromString() {
        XCTAssertEqual(ItemType(rawValue: "task"), .task)
        XCTAssertEqual(ItemType(rawValue: "event"), .event)
    }

    func testPriorityEnum_ConversionFromString() {
        XCTAssertEqual(Priority(rawValue: "none"), Priority.none)
        XCTAssertEqual(Priority(rawValue: "low"), Priority.low)
        XCTAssertEqual(Priority(rawValue: "medium"), Priority.medium)
        XCTAssertEqual(Priority(rawValue: "high"), Priority.high)
    }

    // MARK: - Syncable Event Property Modification Tests

    func testSyncableEvent_CanUpdateItemType() throws {
        let event = SyncableEvent(
            title: "Event",
            startDate: Date(),
            itemType: "task"
        )

        event.itemType = "event"

        XCTAssertEqual(event.itemType, "event")
        XCTAssertEqual(event.itemTypeEnum, .event)
    }

    func testSyncableEvent_CanUpdatePriority() throws {
        let event = SyncableEvent(
            title: "Event",
            startDate: Date(),
            priority: "none"
        )

        event.priority = "high"

        XCTAssertEqual(event.priority, "high")
        XCTAssertEqual(event.priorityEnum, .high)
    }

    func testSyncableEvent_CanUpdateLocation() throws {
        let event = SyncableEvent(
            title: "Event",
            startDate: Date(),
            location: nil
        )

        event.location = "Room 101"

        XCTAssertEqual(event.location, "Room 101")
    }

    // MARK: - Persistence Tests

    @MainActor
    func testSyncableEvent_PersistsTaskTypeToDatabase() throws {
        let modelContext = try createInMemoryContext()

        let event = SyncableEvent(
            title: "Database Task",
            startDate: Date(),
            itemType: "task",
            priority: "high"
        )

        modelContext.insert(event)
        try modelContext.save()

        XCTAssertEqual(event.itemType, "task")
        XCTAssertEqual(event.priority, "high")
    }

    @MainActor
    func testSyncableEvent_PersistsEventTypeToDatabase() throws {
        let modelContext = try createInMemoryContext()

        let event = SyncableEvent(
            title: "Database Event",
            startDate: Date(),
            itemType: "event",
            priority: "medium",
            location: "Database Room"
        )

        modelContext.insert(event)
        try modelContext.save()

        XCTAssertEqual(event.itemType, "event")
        XCTAssertEqual(event.priority, "medium")
        XCTAssertEqual(event.location, "Database Room")
    }

    @MainActor
    func testSyncableEvent_UpdatesPersistentProperties() throws {
        let modelContext = try createInMemoryContext()

        let event = SyncableEvent(
            title: "Original",
            startDate: Date(),
            itemType: "task",
            priority: "low"
        )

        modelContext.insert(event)
        try modelContext.save()

        // Update
        event.itemType = "event"
        event.priority = "high"
        event.location = "Updated Location"

        try modelContext.save()

        XCTAssertEqual(event.itemType, "event")
        XCTAssertEqual(event.priority, "high")
        XCTAssertEqual(event.location, "Updated Location")
    }
}
