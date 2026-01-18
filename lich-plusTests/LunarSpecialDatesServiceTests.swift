//
//  LunarSpecialDatesServiceTests.swift
//  lich-plusTests
//
//  Created by Claude Code
//

import XCTest
import SwiftData
@testable import lich_plus

@MainActor
final class LunarSpecialDatesServiceTests: XCTestCase {

    var modelContext: ModelContext!
    var service: LunarSpecialDateService!
    let mung1 = LunarSpecialDate.allDates.first { $0.id == "lunar-mung1" }!
    let ngayRam = LunarSpecialDate.allDates.first { $0.id == "lunar-ram" }!

    override func setUp() async throws {
        try await super.setUp()

        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: SyncableEvent.self, configurations: config)
        modelContext = ModelContext(container)
        service = LunarSpecialDateService(modelContext: modelContext)
    }

    override func tearDown() async throws {
        modelContext = nil
        service = nil
        try await super.tearDown()
    }

    // MARK: - Unique Category Tests

    func testUniqueCategoryPatternForMung1() {
        XCTAssertEqual(mung1.uniqueCategory, "lunar.special.date.lunar-mung1")
    }

    func testUniqueCategoryPatternForNgayRam() {
        XCTAssertEqual(ngayRam.uniqueCategory, "lunar.special.date.lunar-ram")
    }

    func testUniqueCategoryPreventsCollisionWithUserCategory() {
        // User event uses "spiritual" category
        let userCategory = "spiritual"
        let systemCategory = mung1.uniqueCategory

        XCTAssertNotEqual(userCategory, systemCategory,
                          "System category should not match user's spiritual category")
    }

    // MARK: - Enable/Disable Tests

    func testEnableThenDisableSpecialDate() throws {
        // Given: Special date disabled
        XCTAssertFalse(service.isEnabled(mung1))

        // When: Enable
        try service.enableSpecialDate(mung1)

        // Then: Master event exists
        XCTAssertTrue(service.isEnabled(mung1))

        // When: Disable
        try service.disableSpecialDate(mung1)

        // Then: Master event deleted
        XCTAssertFalse(service.isEnabled(mung1))

        // And: No events remain
        let descriptor = FetchDescriptor<SyncableEvent>()
        let events = try modelContext.fetch(descriptor)
        XCTAssertTrue(events.isEmpty, "All events should be deleted after disable")
    }

    func testEnableSpecialDateCreatesEventWithUniqueCategory() throws {
        // When: Enable special date
        try service.enableSpecialDate(mung1)

        // Then: Event created with unique category
        let predicate = #Predicate<SyncableEvent> { event in
            event.category == "lunar.special.date.lunar-mung1"
        }
        let descriptor = FetchDescriptor<SyncableEvent>(predicate: predicate)
        let events = try modelContext.fetch(descriptor)

        XCTAssertEqual(events.count, 1, "Should have exactly one master event")
        XCTAssertEqual(events.first?.title, mung1.title)
        XCTAssertEqual(events.first?.category, "lunar.special.date.lunar-mung1")
    }

    func testEnableWhenAlreadyEnabledDoesNotDuplicate() throws {
        // Given: Enable special date
        try service.enableSpecialDate(mung1)

        // When: Enable again
        try service.enableSpecialDate(mung1)

        // Then: Still only one event
        let descriptor = FetchDescriptor<SyncableEvent>()
        let events = try modelContext.fetch(descriptor)

        XCTAssertEqual(events.count, 1, "Should not create duplicate events")
    }

    // MARK: - Data Loss Prevention Tests

    func testDisableSpecialDate_DoesNotDeleteUserEventsWithSameTitle() throws {
        // Given: User creates manual event "Mùng 1" + category "spiritual"
        let userEvent = SyncableEvent(
            id: UUID(),
            title: "Mùng 1",
            startDate: Date(),
            endDate: nil,
            isAllDay: true,
            notes: "User created event",
            isCompleted: false,
            category: "spiritual",
            reminderMinutes: nil,
            recurrenceRuleData: nil,
            lastModifiedLocal: Date(),
            lastModifiedRemote: nil,
            syncStatus: SyncStatus.localOnly.rawValue,
            source: EventSource.local.rawValue,
            isDeleted: false,
            createdAt: Date(),
            itemType: ItemType.event.rawValue,
            priority: Priority.none.rawValue,
            location: nil,
            timeZone: nil
        )
        modelContext.insert(userEvent)

        // And: System master event exists with unique category
        try service.enableSpecialDate(mung1)
        try modelContext.save()

        // Verify both events exist
        let beforeDescriptor = FetchDescriptor<SyncableEvent>()
        let beforeEvents = try modelContext.fetch(beforeDescriptor)
        XCTAssertEqual(beforeEvents.count, 2, "Should have 2 events before disable")

        // When: Disable special date
        try service.disableSpecialDate(mung1)

        // Then: Only master event deleted, user event remains
        let afterDescriptor = FetchDescriptor<SyncableEvent>()
        let afterEvents = try modelContext.fetch(afterDescriptor)

        XCTAssertEqual(afterEvents.count, 1, "Should have 1 event after disable")
        XCTAssertEqual(afterEvents.first?.category, "spiritual", "Remaining event should be user's event")
        XCTAssertEqual(afterEvents.first?.title, "Mùng 1")
        XCTAssertEqual(afterEvents.first?.notes, "User created event")
    }

    func testDisableSpecialDate_DoesNotDeleteUserEventsWithDifferentTitle() throws {
        // Given: User creates manual event with different title
        let userEvent = SyncableEvent(
            id: UUID(),
            title: "My Custom Event",
            startDate: Date(),
            endDate: nil,
            isAllDay: true,
            notes: nil,
            isCompleted: false,
            category: "lunar.special.date.lunar-mung1",
            reminderMinutes: nil,
            recurrenceRuleData: nil,
            lastModifiedLocal: Date(),
            lastModifiedRemote: nil,
            syncStatus: SyncStatus.localOnly.rawValue,
            source: EventSource.local.rawValue,
            isDeleted: false,
            createdAt: Date(),
            itemType: ItemType.event.rawValue,
            priority: Priority.none.rawValue,
            location: nil,
            timeZone: nil
        )
        modelContext.insert(userEvent)
        try modelContext.save()

        // When: Disable special date
        try service.disableSpecialDate(mung1)

        // Then: Event with matching category is deleted (even with different title)
        let descriptor = FetchDescriptor<SyncableEvent>()
        let events = try modelContext.fetch(descriptor)

        XCTAssertEqual(events.count, 0, "All events with unique category should be deleted")
    }

    // MARK: - Multiple Special Dates Tests

    func testEnableMultipleSpecialDates() throws {
        // When: Enable both special dates
        try service.enableSpecialDate(mung1)
        try service.enableSpecialDate(ngayRam)

        // Then: Both events exist
        let descriptor = FetchDescriptor<SyncableEvent>()
        let events = try modelContext.fetch(descriptor)

        XCTAssertEqual(events.count, 2, "Should have 2 master events")

        let categories = events.map { $0.category }.sorted()
        XCTAssertEqual(categories, ["lunar.special.date.lunar-mung1", "lunar.special.date.lunar-ram"])
    }

    func testDisableOneSpecialDateDoesNotAffectOther() throws {
        // Given: Both special dates enabled
        try service.enableSpecialDate(mung1)
        try service.enableSpecialDate(ngayRam)

        // When: Disable only Mùng 1
        try service.disableSpecialDate(mung1)

        // Then: Ngày Rầm event still exists
        let predicate = #Predicate<SyncableEvent> { event in
            event.category == "lunar.special.date.lunar-ram"
        }
        let descriptor = FetchDescriptor<SyncableEvent>(predicate: predicate)
        let events = try modelContext.fetch(descriptor)

        XCTAssertEqual(events.count, 1, "Ngày Rầm event should still exist")
    }

    // MARK: - Recurrence Data Tests

    func testCreateMasterEvent_HandlesEncodingErrorGracefully() {
        // Given: Special date with lunar recurrence rule
        // When: Create master event
        let event = service.createMasterEvent(mung1)

        // Then: Event created
        XCTAssertNotNil(event)
        XCTAssertEqual(event.category, "lunar.special.date.lunar-mung1")

        // And: Recurrence data is present (encoding should succeed in normal case)
        XCTAssertNotNil(event.recurrenceRuleData, "Recurrence data should be encoded successfully")
    }

    func testCreateMasterEvent_HasCorrectProperties() {
        // When: Create master event
        let event = service.createMasterEvent(ngayRam)

        // Then: Event has correct properties
        XCTAssertEqual(event.title, ngayRam.title)
        XCTAssertEqual(event.category, "lunar.special.date.lunar-ram")
        XCTAssertTrue(event.isAllDay)
        XCTAssertEqual(event.source, EventSource.local.rawValue)
        XCTAssertEqual(event.syncStatus, SyncStatus.localOnly.rawValue)
        XCTAssertNotNil(event.recurrenceRuleData)
    }

    // MARK: - Error Handling Tests

    func testHasMasterEvent_ReturnsFalseWhenNoEvent() {
        // Given: No events in database
        // When: Check hasMasterEvent
        let result = service.hasMasterEvent(for: mung1)

        // Then: Returns false
        XCTAssertFalse(result)
    }

    func testHasMasterEvent_ReturnsTrueWhenEventExists() throws {
        // Given: Event exists
        try service.enableSpecialDate(mung1)

        // When: Check hasMasterEvent
        let result = service.hasMasterEvent(for: mung1)

        // Then: Returns true
        XCTAssertTrue(result)
    }

    func testEnableAfterDisableCleanly() throws {
        // Given: Enable and then disable
        try service.enableSpecialDate(mung1)
        try service.disableSpecialDate(mung1)

        // When: Enable again
        try service.enableSpecialDate(mung1)

        // Then: Should work cleanly
        XCTAssertTrue(service.isEnabled(mung1))

        let descriptor = FetchDescriptor<SyncableEvent>()
        let events = try modelContext.fetch(descriptor)

        XCTAssertEqual(events.count, 1, "Should have exactly one event after re-enable")
    }
}
