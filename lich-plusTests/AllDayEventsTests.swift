//
//  AllDayEventsTests.swift
//  lich-plusTests
//
//  Tests for all-day events feature (Phase 1 Foundation)
//

import XCTest
import SwiftData
@testable import lich_plus

final class AllDayEventsTests: XCTestCase {

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

    // MARK: - Test: TaskItem.isAllDay Computed Property

    func testTaskItemIsAllDayWhenStartTimeIsNil() {
        // Arrange
        let taskItem = TaskItem(
            title: "All-day meeting",
            date: Date(),
            startTime: nil,  // No start time = all-day
            endTime: nil
        )

        // Act & Assert
        XCTAssertTrue(taskItem.isAllDay, "TaskItem should be all-day when startTime is nil")
    }

    func testTaskItemIsNotAllDayWhenStartTimeExists() {
        // Arrange
        let taskItem = TaskItem(
            title: "Timed meeting",
            date: Date(),
            startTime: Date(),  // Has start time = not all-day
            endTime: nil
        )

        // Act & Assert
        XCTAssertFalse(taskItem.isAllDay, "TaskItem should not be all-day when startTime exists")
    }

    // MARK: - Test: SyncableEvent isAllDay Persistence

    func testCreateNewEventWithIsAllDayTrue() throws {
        // Arrange
        let startDate = Date()
        let event = SyncableEvent(
            title: "All-day event",
            startDate: startDate,
            endDate: startDate,
            isAllDay: true,
            category: "Personal"
        )
        modelContext.insert(event)

        // Act
        try modelContext.save()

        // Assert
        let fetchedEvent = try modelContext.fetch(FetchDescriptor<SyncableEvent>()).first
        XCTAssertNotNil(fetchedEvent)
        XCTAssertTrue(fetchedEvent!.isAllDay, "Event should have isAllDay = true")
    }

    func testCreateNewEventWithIsAllDayFalse() throws {
        // Arrange
        let startDate = Date()
        let event = SyncableEvent(
            title: "Timed event",
            startDate: startDate,
            endDate: startDate,
            isAllDay: false,
            category: "Personal"
        )
        modelContext.insert(event)

        // Act
        try modelContext.save()

        // Assert
        let fetchedEvent = try modelContext.fetch(FetchDescriptor<SyncableEvent>()).first
        XCTAssertNotNil(fetchedEvent)
        XCTAssertFalse(fetchedEvent!.isAllDay, "Event should have isAllDay = false")
    }

    func testUpdateEventIsAllDay() throws {
        // Arrange
        let startDate = Date()
        let event = SyncableEvent(
            title: "Event",
            startDate: startDate,
            endDate: startDate,
            isAllDay: false,
            category: "Personal"
        )
        modelContext.insert(event)
        try modelContext.save()

        // Act - Update isAllDay
        event.isAllDay = true
        try modelContext.save()

        // Assert
        let fetchedEvent = try modelContext.fetch(FetchDescriptor<SyncableEvent>()).first
        XCTAssertTrue(fetchedEvent!.isAllDay, "Event isAllDay should be updated to true")
    }

    // MARK: - Test: TaskItem Conversion with isAllDay

    func testTaskItemFromSyncableEventWithIsAllDayTrue() {
        // Arrange
        let syncableEvent = SyncableEvent(
            title: "All-day event",
            startDate: Date(),
            endDate: Date(),
            isAllDay: true,
            category: "Personal"
        )

        // Act
        let taskItem = TaskItem(from: syncableEvent)

        // Assert
        XCTAssertTrue(taskItem.isAllDay, "TaskItem should be all-day when converted from isAllDay=true event")
        XCTAssertNil(taskItem.startTime, "TaskItem startTime should be nil for all-day events")
    }

    func testTaskItemFromSyncableEventWithIsAllDayFalse() {
        // Arrange
        let startDate = Date()
        let syncableEvent = SyncableEvent(
            title: "Timed event",
            startDate: startDate,
            endDate: Date(),
            isAllDay: false,
            category: "Personal"
        )

        // Act
        let taskItem = TaskItem(from: syncableEvent)

        // Assert
        XCTAssertFalse(taskItem.isAllDay, "TaskItem should not be all-day when converted from isAllDay=false event")
        XCTAssertNotNil(taskItem.startTime, "TaskItem startTime should be set for timed events")
    }

    func testTaskItemToSyncableEventWithIsAllDayTrue() throws {
        // Arrange
        let taskItem = TaskItem(
            title: "All-day meeting",
            date: Date(),
            startTime: nil,  // All-day indicated by nil startTime
            itemType: .event
        )

        // Act
        let syncableEvent = taskItem.toSyncableEvent()

        // Assert
        XCTAssertTrue(syncableEvent.isAllDay, "SyncableEvent should have isAllDay=true when TaskItem startTime is nil")
    }

    func testTaskItemToSyncableEventWithIsAllDayFalse() throws {
        // Arrange
        let startDate = Date()
        let taskItem = TaskItem(
            title: "Timed meeting",
            date: Date(),
            startTime: startDate,
            itemType: .event
        )

        // Act
        let syncableEvent = taskItem.toSyncableEvent()

        // Assert
        XCTAssertFalse(syncableEvent.isAllDay, "SyncableEvent should have isAllDay=false when TaskItem has startTime")
    }

    // MARK: - Test: Date Normalization for All-Day Events

    func testAllDayEventStartDateIsNormalized() throws {
        // Arrange
        let calendar = Calendar.current
        let dateWithTime = calendar.date(bySettingHour: 14, minute: 30, second: 45, of: Date())!

        let syncableEvent = SyncableEvent(
            title: "All-day event",
            startDate: dateWithTime,
            endDate: dateWithTime,
            isAllDay: true,
            category: "Personal"
        )

        // Act - Normalize start date to beginning of day
        syncableEvent.startDate = calendar.startOfDay(for: syncableEvent.startDate)

        // Assert
        let components = calendar.dateComponents([.hour, .minute, .second], from: syncableEvent.startDate)
        XCTAssertEqual(components.hour, 0, "All-day event start time should be 00:00")
        XCTAssertEqual(components.minute, 0, "All-day event start time should be 00:00")
        XCTAssertEqual(components.second, 0, "All-day event start time should be 00:00")
    }

    func testAllDayEventEndDateIsNormalized() throws {
        // Arrange
        let calendar = Calendar.current
        let dateWithTime = calendar.date(bySettingHour: 14, minute: 30, second: 45, of: Date())!

        let syncableEvent = SyncableEvent(
            title: "All-day event",
            startDate: dateWithTime,
            endDate: dateWithTime,
            isAllDay: true,
            category: "Personal"
        )

        // Act - Normalize end date to end of day (23:59:59)
        if let endDate = syncableEvent.endDate {
            syncableEvent.endDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endDate)!
        }

        // Assert
        if let endDate = syncableEvent.endDate {
            let components = calendar.dateComponents([.hour, .minute, .second], from: endDate)
            XCTAssertEqual(components.hour, 23, "All-day event end time should be 23:59:59")
            XCTAssertEqual(components.minute, 59, "All-day event end time should be 23:59:59")
            XCTAssertEqual(components.second, 59, "All-day event end time should be 23:59:59")
        } else {
            XCTFail("endDate should not be nil")
        }
    }

    // MARK: - Test: All-Day Event Occurrence Conversion

    func testOccurrenceFromAllDayMasterEvent() {
        // Arrange
        let masterEvent = SyncableEvent(
            title: "Daily all-day event",
            startDate: Date(),
            endDate: Date(),
            isAllDay: true,
            category: "Personal"
        )

        let occurrenceDate = Calendar.current.date(byAdding: .day, value: 5, to: Date())!
        let virtualID = UUID()

        // Act
        let occurrence = TaskItem.createOccurrence(
            from: masterEvent,
            occurrenceDate: occurrenceDate,
            virtualID: virtualID
        )

        // Assert
        XCTAssertTrue(occurrence.isAllDay, "Occurrence should inherit all-day status from master")
        XCTAssertEqual(occurrence.date, occurrenceDate, "Occurrence date should match provided occurrenceDate")
        XCTAssertNil(occurrence.startTime, "Occurrence startTime should be nil for all-day events")
    }

    // MARK: - Test: TaskItem toSyncableEvent with existing event update

    func testUpdateExistingSyncableEventToAllDay() throws {
        // Arrange
        let originalEvent = SyncableEvent(
            title: "Event",
            startDate: Date(),
            endDate: Date(),
            isAllDay: false,
            category: "Personal"
        )
        modelContext.insert(originalEvent)
        try modelContext.save()

        let taskItem = TaskItem(
            id: originalEvent.id,
            title: "Updated event",
            date: Date(),
            startTime: nil,  // Changing to all-day
            itemType: .event
        )

        // Act
        _ = taskItem.toSyncableEvent(existing: originalEvent)

        // Assert
        XCTAssertTrue(originalEvent.isAllDay, "Existing event should be updated to isAllDay=true")
    }

    func testUpdateExistingSyncableEventToTimed() throws {
        // Arrange
        let startDate = Date()
        let originalEvent = SyncableEvent(
            title: "Event",
            startDate: startDate,
            endDate: startDate,
            isAllDay: true,
            category: "Personal"
        )
        modelContext.insert(originalEvent)
        try modelContext.save()

        let updatedStartDate = Calendar.current.date(byAdding: .hour, value: 2, to: Date())!
        let taskItem = TaskItem(
            id: originalEvent.id,
            title: "Updated event",
            date: Date(),
            startTime: updatedStartDate,  // Changing to timed
            itemType: .event
        )

        // Act
        _ = taskItem.toSyncableEvent(existing: originalEvent)

        // Assert
        XCTAssertFalse(originalEvent.isAllDay, "Existing event should be updated to isAllDay=false")
    }
}
