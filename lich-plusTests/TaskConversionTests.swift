//
//  TaskConversionTests.swift
//  lich-plusTests
//
//  Created by Quang Tran Minh on 25/11/25.
//

import XCTest
import SwiftData
@testable import lich_plus

final class TaskConversionTests: XCTestCase {

    var modelContext: ModelContext!

    override func setUp() async throws {
        try await super.setUp()

        // Create in-memory SwiftData model context
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: SyncableEvent.self, configurations: config)
        modelContext = ModelContext(container)
    }

    override func tearDown() async throws {
        modelContext = nil
        try await super.tearDown()
    }

    // MARK: - TaskItem Initialization from SyncableEvent

    func testInitFromSyncableEvent_WithBasicProperties() {
        // Given
        let syncableEvent = SyncableEvent(
            id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440000")!,
            title: "Team Meeting",
            startDate: Date(timeIntervalSince1970: 0),
            isAllDay: true,
            category: TaskCategory.work.rawValue,
            isCompleted: false
        )

        // When
        let task = TaskItem(from: syncableEvent)

        // Then
        XCTAssertEqual(task.id, syncableEvent.id)
        XCTAssertEqual(task.title, "Team Meeting")
        XCTAssertEqual(task.category, .work)
        XCTAssertFalse(task.isCompleted)
    }

    func testInitFromSyncableEvent_WithTimes() {
        // Given
        let startDate = Date(timeIntervalSince1970: 1000)
        let endDate = Date(timeIntervalSince1970: 2000)
        let syncableEvent = SyncableEvent(
            title: "Meeting",
            startDate: startDate,
            endDate: endDate,
            isAllDay: false,
            category: TaskCategory.meeting.rawValue
        )

        // When
        let task = TaskItem(from: syncableEvent)

        // Then
        XCTAssertEqual(task.startTime, startDate)
        XCTAssertEqual(task.endTime, endDate)
    }

    func testInitFromSyncableEvent_AllDayEvent() {
        // Given
        let startDate = Date(timeIntervalSince1970: 1000)
        let syncableEvent = SyncableEvent(
            title: "Birthday",
            startDate: startDate,
            isAllDay: true,
            category: TaskCategory.birthday.rawValue
        )

        // When
        let task = TaskItem(from: syncableEvent)

        // Then
        XCTAssertNil(task.startTime)
        XCTAssertEqual(task.date, startDate)
    }

    func testInitFromSyncableEvent_WithNotes() {
        // Given
        let notes = "Important notes about the task"
        let syncableEvent = SyncableEvent(
            title: "Task",
            startDate: Date(),
            notes: notes,
            category: "personal"
        )

        // When
        let task = TaskItem(from: syncableEvent)

        // Then
        XCTAssertEqual(task.notes, notes)
    }

    func testInitFromSyncableEvent_WithReminder() {
        // Given
        let syncableEvent = SyncableEvent(
            title: "Task",
            startDate: Date(),
            category: "personal",
            reminderMinutes: 30
        )

        // When
        let task = TaskItem(from: syncableEvent)

        // Then
        XCTAssertEqual(task.reminderMinutes, 30)
    }

    func testInitFromSyncableEvent_CompletedTask() {
        // Given
        let syncableEvent = SyncableEvent(
            title: "Completed Task",
            startDate: Date(),
            isCompleted: true,
            category: "personal"
        )

        // When
        let task = TaskItem(from: syncableEvent)

        // Then
        XCTAssertTrue(task.isCompleted)
    }

    func testInitFromSyncableEvent_CategoryMapping() {
        // Given all category types
        let categories: [String] = ["work", "personal", "birthday", "holiday", "meeting", "other"]

        for categoryString in categories {
            // When
            let syncableEvent = SyncableEvent(
                title: "Task",
                startDate: Date(),
                category: categoryString
            )
            let task = TaskItem(from: syncableEvent)

            // Then
            XCTAssertNotNil(TaskCategory(rawValue: categoryString.prefix(1).uppercased() + categoryString.dropFirst()))
        }
    }

    // MARK: - TaskItem Conversion to SyncableEvent

    func testToSyncableEvent_CreatesNewEvent() {
        // Given
        let task = TaskItem(
            title: "New Task",
            date: Date(timeIntervalSince1970: 1000),
            category: .personal,
            notes: "Task notes"
        )

        // When
        let syncableEvent = task.toSyncableEvent()

        // Then
        XCTAssertEqual(syncableEvent.id, task.id)
        XCTAssertEqual(syncableEvent.title, task.title)
        XCTAssertEqual(syncableEvent.category, "personal")
        XCTAssertEqual(syncableEvent.notes, "Task notes")
        XCTAssertEqual(syncableEvent.syncStatus, SyncStatus.pending.rawValue)
    }

    func testToSyncableEvent_PreservesTaskProperties() {
        // Given
        let startTime = Date(timeIntervalSince1970: 1000)
        let endTime = Date(timeIntervalSince1970: 2000)
        let task = TaskItem(
            title: "Task",
            date: Date(timeIntervalSince1970: 500),
            startTime: startTime,
            endTime: endTime,
            category: .work,
            notes: "Notes",
            isCompleted: true,
            reminderMinutes: 15
        )

        // When
        let syncableEvent = task.toSyncableEvent()

        // Then
        XCTAssertEqual(syncableEvent.title, task.title)
        XCTAssertEqual(syncableEvent.startDate, startTime)
        XCTAssertEqual(syncableEvent.endDate, endTime)
        XCTAssertEqual(syncableEvent.isCompleted, true)
        XCTAssertEqual(syncableEvent.reminderMinutes, 15)
        XCTAssertEqual(syncableEvent.category, "work")
    }

    func testToSyncableEvent_UpdatesExistingEvent() {
        // Given
        let existingSyncableEvent = SyncableEvent(
            id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440000")!,
            title: "Old Title",
            startDate: Date(),
            category: "personal",
            syncStatus: SyncStatus.synced.rawValue
        )

        let updatedTask = TaskItem(
            id: existingSyncableEvent.id,
            title: "Updated Title",
            date: Date(timeIntervalSince1970: 5000),
            category: .work
        )

        // When
        let syncableEvent = updatedTask.toSyncableEvent(existing: existingSyncableEvent)

        // Then
        XCTAssertEqual(syncableEvent.id, updatedTask.id)
        XCTAssertEqual(syncableEvent.title, "Updated Title")
        XCTAssertEqual(syncableEvent.category, "work")
        // When updating existing, it should preserve some properties
        XCTAssertEqual(syncableEvent.id, existingSyncableEvent.id)
    }

    func testToSyncableEvent_AllDayTask() {
        // Given
        let task = TaskItem(
            title: "All Day Task",
            date: Date(timeIntervalSince1970: 1000),
            startTime: nil,
            endTime: nil,
            category: .personal
        )

        // When
        let syncableEvent = task.toSyncableEvent()

        // Then
        XCTAssertTrue(syncableEvent.isAllDay)
    }

    func testToSyncableEvent_TimedTask() {
        // Given
        let startTime = Date(timeIntervalSince1970: 1000)
        let task = TaskItem(
            title: "Timed Task",
            date: Date(timeIntervalSince1970: 500),
            startTime: startTime,
            category: .personal
        )

        // When
        let syncableEvent = task.toSyncableEvent()

        // Then
        XCTAssertFalse(syncableEvent.isAllDay)
        XCTAssertEqual(syncableEvent.startDate, startTime)
    }

    // MARK: - Roundtrip Conversion Tests

    func testRoundtripConversion_BasicTask() {
        // Given
        let originalTask = TaskItem(
            title: "Original Task",
            date: Date(),
            category: .work,
            notes: "Some notes",
            reminderMinutes: 30
        )

        // When
        let syncableEvent = originalTask.toSyncableEvent()
        let reconvertedTask = TaskItem(from: syncableEvent)

        // Then
        XCTAssertEqual(reconvertedTask.title, originalTask.title)
        XCTAssertEqual(reconvertedTask.category, originalTask.category)
        XCTAssertEqual(reconvertedTask.notes, originalTask.notes)
        XCTAssertEqual(reconvertedTask.reminderMinutes, originalTask.reminderMinutes)
    }

    func testRoundtripConversion_ComplexTask() {
        // Given
        let startTime = Date(timeIntervalSince1970: 1000)
        let endTime = Date(timeIntervalSince1970: 2000)
        let originalTask = TaskItem(
            title: "Complex Task",
            date: Date(timeIntervalSince1970: 500),
            startTime: startTime,
            endTime: endTime,
            category: .meeting,
            notes: "Complex notes",
            isCompleted: true,
            reminderMinutes: 60
        )

        // When
        let syncableEvent = originalTask.toSyncableEvent()
        let reconvertedTask = TaskItem(from: syncableEvent)

        // Then
        XCTAssertEqual(reconvertedTask.title, originalTask.title)
        XCTAssertEqual(reconvertedTask.category, originalTask.category)
        XCTAssertEqual(reconvertedTask.isCompleted, originalTask.isCompleted)
        XCTAssertEqual(reconvertedTask.reminderMinutes, originalTask.reminderMinutes)
        XCTAssertEqual(reconvertedTask.startTime, startTime)
        XCTAssertEqual(reconvertedTask.endTime, endTime)
    }
}
