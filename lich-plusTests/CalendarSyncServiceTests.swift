//
//  CalendarSyncServiceTests.swift
//  lich-plusTests
//
//  Created by Quang Tran Minh on 25/11/25.
//

import XCTest
import SwiftData
import EventKit
@testable import lich_plus

@MainActor
final class CalendarSyncServiceTests: XCTestCase {

    var sut: CalendarSyncService!
    var mockEventKitService: MockEventKitService!
    var modelContext: ModelContext!

    override func setUp() async throws {
        try await super.setUp()

        // Create in-memory SwiftData model context
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: SyncableEvent.self, SyncedCalendar.self, configurations: config)
        modelContext = ModelContext(container)

        // Initialize mock EventKitService
        mockEventKitService = MockEventKitService()

        // Initialize SUT
        sut = CalendarSyncService(
            eventKitService: mockEventKitService,
            modelContext: modelContext
        )
    }

    override func tearDown() async throws {
        sut = nil
        mockEventKitService = nil
        modelContext = nil
        try await super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitializationSetsIdleState() {
        XCTAssertEqual(sut.syncState, .idle)
    }

    func testInitializationSetsNoError() {
        XCTAssertNil(sut.syncError)
    }

    func testInitializationSetsLastSyncDateFromUserDefaults() {
        let testDate = Date().addingTimeInterval(-3600) // 1 hour ago
        UserDefaults.standard.set(testDate, forKey: "CalendarSyncLastSyncDate")

        let newService = CalendarSyncService(
            eventKitService: mockEventKitService,
            modelContext: modelContext
        )

        // Allow small time difference due to initialization
        let timeDiff = abs(newService.lastSyncDate?.timeIntervalSince(testDate) ?? 0)
        XCTAssertLessThan(timeDiff, 1.0)

        // Cleanup
        UserDefaults.standard.removeObject(forKey: "CalendarSyncLastSyncDate")
    }

    // MARK: - Pull Sync Tests

    func testPullRemoteChangesCreatesNewEventFromAppleCalendar() async throws {
        // Setup: Create an EKEvent in the mock
        let ekEvent = createMockEKEvent(
            identifier: "ek-123",
            title: "Test Event",
            startDate: Date(),
            endDate: Date().addingTimeInterval(3600)
        )
        mockEventKitService.mockEvents = [ekEvent]

        // Setup: Create enabled calendar in SwiftData
        let calendar = SyncedCalendar(
            calendarIdentifier: "test-calendar",
            title: "Test Calendar"
        )
        modelContext.insert(calendar)
        try modelContext.save()

        // Execute
        try await sut.pullRemoteChanges()

        // Verify: Event was created in SwiftData
        let descriptor = FetchDescriptor<SyncableEvent>()
        let events = try modelContext.fetch(descriptor)

        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events.first?.title, "Test Event")
        XCTAssertEqual(events.first?.ekEventIdentifier, "ek-123")
        XCTAssertEqual(events.first?.sourceEnum, .appleCalendar)
    }

    func testPullRemoteChangesUpdatesExistingEventIfRemoteIsNewer() async throws {
        // Setup: Create initial event in SwiftData
        let initialEvent = SyncableEvent(
            title: "Old Title",
            startDate: Date(),
            lastModifiedLocal: Date().addingTimeInterval(-7200), // 2 hours ago
            lastModifiedRemote: Date().addingTimeInterval(-7200),
            syncStatus: SyncStatus.synced.rawValue,
            source: EventSource.appleCalendar.rawValue
        )
        initialEvent.ekEventIdentifier = "ek-123"
        modelContext.insert(initialEvent)
        try modelContext.save()

        // Setup: Create newer EKEvent
        let ekEvent = createMockEKEvent(
            identifier: "ek-123",
            title: "New Title",
            startDate: Date(),
            endDate: Date().addingTimeInterval(3600)
        )
        mockEventKitService.mockEvents = [ekEvent]

        // Setup: Create enabled calendar
        let calendar = SyncedCalendar(calendarIdentifier: "test-calendar", title: "Test")
        modelContext.insert(calendar)
        try modelContext.save()

        // Execute
        try await sut.pullRemoteChanges()

        // Verify: Event was updated
        let descriptor = FetchDescriptor<SyncableEvent>()
        let events = try modelContext.fetch(descriptor)

        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events.first?.title, "New Title")
    }

    func testPullRemoteChangesPreservesLocalEventIfLocalIsNewer() async throws {
        // Setup: Create local event that is newer
        let localModifiedDate = Date()
        let initialEvent = SyncableEvent(
            title: "Local Title",
            startDate: Date(),
            lastModifiedLocal: localModifiedDate,
            lastModifiedRemote: localModifiedDate.addingTimeInterval(-7200),
            syncStatus: SyncStatus.synced.rawValue,
            source: EventSource.appleCalendar.rawValue
        )
        initialEvent.ekEventIdentifier = "ek-123"
        modelContext.insert(initialEvent)
        try modelContext.save()

        // Setup: Create older EKEvent
        let ekEvent = createMockEKEvent(
            identifier: "ek-123",
            title: "Remote Title",
            startDate: Date(),
            endDate: Date().addingTimeInterval(3600)
        )
        mockEventKitService.mockEvents = [ekEvent]

        // Setup: Create enabled calendar
        let calendar = SyncedCalendar(calendarIdentifier: "test-calendar", title: "Test")
        modelContext.insert(calendar)
        try modelContext.save()

        // Execute
        try await sut.pullRemoteChanges()

        // Verify: Local event was preserved
        let descriptor = FetchDescriptor<SyncableEvent>()
        let events = try modelContext.fetch(descriptor)

        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events.first?.title, "Local Title")
    }

    func testPullRemoteChangesMarksMissingEventsAsDeleted() async throws {
        // Setup: Create event that exists in SwiftData but not in Apple Calendar
        let event = SyncableEvent(
            title: "Deleted Event",
            startDate: Date(),
            syncStatus: SyncStatus.synced.rawValue,
            source: EventSource.appleCalendar.rawValue
        )
        event.ekEventIdentifier = "ek-123"
        modelContext.insert(event)
        try modelContext.save()

        // Setup: Empty mock events
        mockEventKitService.mockEvents = []

        // Setup: Create enabled calendar
        let calendar = SyncedCalendar(calendarIdentifier: "test-calendar", title: "Test")
        modelContext.insert(calendar)
        try modelContext.save()

        // Execute
        try await sut.pullRemoteChanges()

        // Verify: Event marked as deleted
        let descriptor = FetchDescriptor<SyncableEvent>()
        let events = try modelContext.fetch(descriptor)

        XCTAssertEqual(events.count, 1)
        XCTAssertTrue(events.first?.isDeleted ?? false)
    }

    func testPullRemoteChangesIgnoresDisabledCalendars() async throws {
        // Setup: Create disabled calendar
        let calendar = SyncedCalendar(
            calendarIdentifier: "disabled-calendar",
            title: "Disabled",
            isEnabled: false
        )
        modelContext.insert(calendar)
        try modelContext.save()

        // Setup: Create mock event (should be ignored)
        let ekEvent = createMockEKEvent(
            identifier: "ek-123",
            title: "Test Event"
        )
        mockEventKitService.mockEvents = [ekEvent]

        // Execute
        try await sut.pullRemoteChanges()

        // Verify: No events created
        let descriptor = FetchDescriptor<SyncableEvent>()
        let events = try modelContext.fetch(descriptor)

        XCTAssertEqual(events.count, 0)
    }

    // MARK: - Push Sync Tests

    func testPushLocalChangesCreatesNewEventInAppleCalendar() async throws {
        // Setup: Create pending event without ekEventIdentifier
        let event = SyncableEvent(
            title: "New Event",
            startDate: Date(),
            syncStatus: SyncStatus.pending.rawValue,
            source: EventSource.local.rawValue
        )
        modelContext.insert(event)
        try modelContext.save()

        // Setup: Create enabled calendar
        let calendar = SyncedCalendar(calendarIdentifier: "test-calendar", title: "Test")
        modelContext.insert(calendar)
        calendar.isEnabled = true
        try modelContext.save()

        // Setup: Mock EventKit service to return identifier
        mockEventKitService.createdEventIdentifier = "new-ek-123"

        // Execute
        try await sut.pushLocalChanges()

        // Verify: Event was created in EventKit
        XCTAssertTrue(mockEventKitService.createEventCalled)

        // Verify: Event was marked as synced
        let descriptor = FetchDescriptor<SyncableEvent>()
        let events = try modelContext.fetch(descriptor)

        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events.first?.ekEventIdentifier, "new-ek-123")
        XCTAssertEqual(events.first?.syncStatusEnum, .synced)
    }

    func testPushLocalChangesUpdatesExistingEvent() async throws {
        // Setup: Create event with ekEventIdentifier but pending status
        let event = SyncableEvent(
            title: "Updated Event",
            startDate: Date(),
            syncStatus: SyncStatus.pending.rawValue,
            source: EventSource.local.rawValue
        )
        event.ekEventIdentifier = "ek-123"
        modelContext.insert(event)
        try modelContext.save()

        // Setup: Create enabled calendar
        let calendar = SyncedCalendar(calendarIdentifier: "test-calendar", title: "Test")
        modelContext.insert(calendar)
        try modelContext.save()

        // Execute
        try await sut.pushLocalChanges()

        // Verify: Event was updated in EventKit
        XCTAssertTrue(mockEventKitService.updateEventCalled)

        // Verify: Event marked as synced
        let descriptor = FetchDescriptor<SyncableEvent>()
        let events = try modelContext.fetch(descriptor)

        XCTAssertEqual(events.first?.syncStatusEnum, .synced)
    }

    func testPushLocalChangesDeletesMarkedEvents() async throws {
        // Setup: Create event marked for deletion
        let event = SyncableEvent(
            title: "Deleted Event",
            startDate: Date(),
            syncStatus: SyncStatus.pending.rawValue,
            source: EventSource.local.rawValue,
            isDeleted: true
        )
        event.ekEventIdentifier = "ek-123"
        modelContext.insert(event)
        try modelContext.save()

        // Setup: Create enabled calendar
        let calendar = SyncedCalendar(calendarIdentifier: "test-calendar", title: "Test")
        modelContext.insert(calendar)
        try modelContext.save()

        // Execute
        try await sut.pushLocalChanges()

        // Verify: Event was deleted in EventKit
        XCTAssertTrue(mockEventKitService.deleteEventCalled)

        // Verify: Event marked as deleted
        let descriptor = FetchDescriptor<SyncableEvent>()
        let events = try modelContext.fetch(descriptor)

        XCTAssertEqual(events.first?.syncStatusEnum, .deleted)
    }

    func testPushLocalChangesIgnoresSyncedEvents() async throws {
        // Setup: Create already synced event
        let event = SyncableEvent(
            title: "Synced Event",
            startDate: Date(),
            syncStatus: SyncStatus.synced.rawValue,
            source: EventSource.local.rawValue
        )
        event.ekEventIdentifier = "ek-123"
        modelContext.insert(event)
        try modelContext.save()

        // Setup: Create enabled calendar
        let calendar = SyncedCalendar(calendarIdentifier: "test-calendar", title: "Test")
        modelContext.insert(calendar)
        try modelContext.save()

        // Reset mock tracking
        mockEventKitService.updateEventCalled = false
        mockEventKitService.createEventCalled = false

        // Execute
        try await sut.pushLocalChanges()

        // Verify: No create or update was called
        XCTAssertFalse(mockEventKitService.createEventCalled)
        XCTAssertFalse(mockEventKitService.updateEventCalled)
    }

    // MARK: - Full Sync Tests

    func testPerformFullSyncDoesPullAndPush() async throws {
        // Setup: Create pending local event
        let localEvent = SyncableEvent(
            title: "Local Event",
            startDate: Date(),
            syncStatus: SyncStatus.pending.rawValue,
            source: EventSource.local.rawValue
        )
        modelContext.insert(localEvent)

        // Setup: Create enabled calendar
        let calendar = SyncedCalendar(calendarIdentifier: "test-calendar", title: "Test")
        modelContext.insert(calendar)
        try modelContext.save()

        // Setup: Mock remote event
        let ekEvent = createMockEKEvent(
            identifier: "ek-remote",
            title: "Remote Event"
        )
        mockEventKitService.mockEvents = [ekEvent]
        mockEventKitService.createdEventIdentifier = "new-ek-123"

        // Execute
        try await sut.performFullSync()

        // Verify: Both pull and push occurred
        let descriptor = FetchDescriptor<SyncableEvent>()
        let events = try modelContext.fetch(descriptor)

        // Should have both local (now synced) and remote event
        XCTAssertEqual(events.count, 2)
    }

    func testPerformFullSyncUpdatesLastSyncDate() async throws {
        // Setup: Create enabled calendar
        let calendar = SyncedCalendar(calendarIdentifier: "test-calendar", title: "Test")
        modelContext.insert(calendar)
        try modelContext.save()

        let beforeSync = Date()

        // Execute
        try await sut.performFullSync()

        let afterSync = Date()

        // Verify: lastSyncDate is set between before and after
        XCTAssertNotNil(sut.lastSyncDate)
        XCTAssert(sut.lastSyncDate! >= beforeSync && sut.lastSyncDate! <= afterSync)
    }

    func testPerformFullSyncUpdatesSyncState() async throws {
        // Setup: Create enabled calendar
        let calendar = SyncedCalendar(calendarIdentifier: "test-calendar", title: "Test")
        modelContext.insert(calendar)
        try modelContext.save()

        // Initially idle
        XCTAssertEqual(sut.syncState, .idle)

        // Execute (we need to wait to observe state change)
        let syncTask = Task {
            try await sut.performFullSync()
        }

        // Give it a moment to start syncing
        try await Task.sleep(nanoseconds: 10_000_000) // 0.01 seconds

        // Should be syncing (if not too fast)
        let stateWhileSyncing = sut.syncState

        // Wait for completion
        try await syncTask.value

        // Should be back to idle
        XCTAssertEqual(sut.syncState, .idle)
    }

    // MARK: - Single Event Sync Tests

    func testSyncEventCreatesNewEventInAppleCalendar() async throws {
        // Setup: Create event without ekEventIdentifier
        let event = SyncableEvent(
            title: "New Event",
            startDate: Date(),
            syncStatus: SyncStatus.pending.rawValue,
            source: EventSource.local.rawValue
        )
        modelContext.insert(event)
        try modelContext.save()

        // Setup: Create enabled calendar
        let calendar = SyncedCalendar(calendarIdentifier: "test-calendar", title: "Test")
        modelContext.insert(calendar)
        try modelContext.save()

        // Setup: Mock EventKit service
        mockEventKitService.createdEventIdentifier = "new-ek-123"

        // Execute
        try await sut.syncEvent(event)

        // Verify: Event was created
        XCTAssertTrue(mockEventKitService.createEventCalled)

        // Verify: Event has ekEventIdentifier
        XCTAssertEqual(event.ekEventIdentifier, "new-ek-123")
        XCTAssertEqual(event.syncStatusEnum, .synced)
    }

    func testSyncEventUpdatesExistingEvent() async throws {
        // Setup: Create event with ekEventIdentifier
        let event = SyncableEvent(
            title: "Updated Event",
            startDate: Date(),
            syncStatus: SyncStatus.pending.rawValue,
            source: EventSource.local.rawValue
        )
        event.ekEventIdentifier = "ek-123"
        modelContext.insert(event)
        try modelContext.save()

        // Setup: Create enabled calendar
        let calendar = SyncedCalendar(calendarIdentifier: "test-calendar", title: "Test")
        modelContext.insert(calendar)
        try modelContext.save()

        // Execute
        try await sut.syncEvent(event)

        // Verify: Event was updated
        XCTAssertTrue(mockEventKitService.updateEventCalled)
        XCTAssertEqual(event.syncStatusEnum, .synced)
    }

    // MARK: - Helper Method Tests

    func testGetEnabledCalendarsReturnsOnlyEnabledCalendars() throws {
        // Setup: Create mix of enabled and disabled calendars
        let enabledCalendar = SyncedCalendar(
            calendarIdentifier: "enabled",
            title: "Enabled"
        )
        let disabledCalendar = SyncedCalendar(
            calendarIdentifier: "disabled",
            title: "Disabled",
            isEnabled: false
        )

        modelContext.insert(enabledCalendar)
        modelContext.insert(disabledCalendar)
        try modelContext.save()

        // Execute
        let enabled = try sut.getEnabledCalendars()

        // Verify: Only enabled calendars returned
        XCTAssertEqual(enabled.count, 1)
        XCTAssertEqual(enabled.first?.calendarIdentifier, "enabled")
    }

    func testFindExistingEventByEkEventIdentifier() throws {
        // Setup: Create event with identifier
        let event = SyncableEvent(
            title: "Test Event",
            startDate: Date()
        )
        event.ekEventIdentifier = "ek-123"
        modelContext.insert(event)
        try modelContext.save()

        // Execute
        let found = sut.findExistingEvent(ekEventIdentifier: "ek-123")

        // Verify
        XCTAssertNotNil(found)
        XCTAssertEqual(found?.title, "Test Event")
    }

    func testFindExistingEventReturnsNilForUnknownIdentifier() throws {
        // Execute
        let found = sut.findExistingEvent(ekEventIdentifier: "unknown")

        // Verify
        XCTAssertNil(found)
    }

    func testUpdateCalendarSyncDateUpdatesLastSyncDate() throws {
        // Setup: Create calendar
        let calendar = SyncedCalendar(
            calendarIdentifier: "test-cal",
            title: "Test"
        )
        modelContext.insert(calendar)
        try modelContext.save()

        // Setup: Verify initial nil
        XCTAssertNil(calendar.lastSyncDate)

        // Execute
        sut.updateCalendarSyncDate("test-cal")
        try modelContext.save()

        // Verify: Updated
        XCTAssertNotNil(calendar.lastSyncDate)
    }

    // MARK: - Change Observation Tests

    func testStartObservingChangesRegistersObserver() {
        var handlerCalled = false

        // Execute
        sut.startObservingChanges {
            handlerCalled = true
        }

        // Trigger notification manually for testing
        NotificationCenter.default.post(name: NSNotification.Name.EKEventStoreChanged, object: nil)

        // Verify: Handler was called
        XCTAssertTrue(handlerCalled)
    }

    func testStopObservingChangesUnregistersObserver() {
        var handlerCalled = false

        // Setup: Register observer
        sut.startObservingChanges {
            handlerCalled = true
        }

        // Execute: Stop observing
        sut.stopObservingChanges()

        // Trigger notification
        NotificationCenter.default.post(name: NSNotification.Name.EKEventStoreChanged, object: nil)

        // Verify: Handler was not called after stopping
        XCTAssertFalse(handlerCalled)
    }

    // MARK: - Error Handling Tests

    func testPullRemoteChangesThrowsWhenNoEnabledCalendars() async throws {
        // Setup: No enabled calendars

        // Execute and verify error
        await XCTAssertThrowsError(
            try await sut.pullRemoteChanges(),
            "Should throw noEnabledCalendars error"
        ) { error in
            guard let syncError = error as? CalendarSyncService.SyncError else {
                XCTFail("Should be SyncError")
                return
            }
            if case .noEnabledCalendars = syncError {
                // Expected
            } else {
                XCTFail("Should be noEnabledCalendars error")
            }
        }
    }

    // MARK: - Idempotency Tests

    func testPullSyncIsIdempotent() async throws {
        // Setup: Create enabled calendar and mock event
        let calendar = SyncedCalendar(calendarIdentifier: "test-calendar", title: "Test")
        modelContext.insert(calendar)
        try modelContext.save()

        let ekEvent = createMockEKEvent(
            identifier: "ek-123",
            title: "Test Event"
        )
        mockEventKitService.mockEvents = [ekEvent]

        // Execute: First pull
        try await sut.pullRemoteChanges()
        var descriptor = FetchDescriptor<SyncableEvent>()
        var events = try modelContext.fetch(descriptor)
        XCTAssertEqual(events.count, 1)

        // Execute: Second pull with same data
        try await sut.pullRemoteChanges()
        descriptor = FetchDescriptor<SyncableEvent>()
        events = try modelContext.fetch(descriptor)

        // Verify: Still only one event, no duplicates
        XCTAssertEqual(events.count, 1)
    }

    // MARK: - Helper Functions

    private func createMockEKEvent(
        identifier: String,
        title: String,
        startDate: Date = Date(),
        endDate: Date? = nil
    ) -> EKEvent {
        let ekEvent = EKEvent(eventStore: EKEventStore())
        ekEvent.eventIdentifier = identifier
        ekEvent.title = title
        ekEvent.startDate = startDate
        ekEvent.endDate = endDate ?? startDate.addingTimeInterval(3600)
        return ekEvent
    }
}

// MARK: - Mock EventKitService

final class MockEventKitService: EventKitService {
    var mockEvents: [EKEvent] = []
    var createdEventIdentifier: String?
    var createEventCalled = false
    var updateEventCalled = false
    var deleteEventCalled = false

    override func fetchEvents(
        from startDate: Date,
        to endDate: Date,
        calendars: [EKCalendar]
    ) -> [EKEvent] {
        mockEvents
    }

    override func createEvent(from syncable: SyncableEvent, in calendar: EKCalendar) throws -> String {
        createEventCalled = true
        guard let identifier = createdEventIdentifier else {
            throw EventKitServiceError.failedToCreateEvent("No identifier provided")
        }
        return identifier
    }

    override func updateEvent(identifier: String, with syncable: SyncableEvent) throws {
        updateEventCalled = true
    }

    override func deleteEvent(identifier: String) throws {
        deleteEventCalled = true
    }

    override func fetchCalendar(identifier: String) -> EKCalendar? {
        let calendar = EKCalendar(for: .event, eventStore: EKEventStore())
        calendar.calendarIdentifier = identifier
        return calendar
    }
}
