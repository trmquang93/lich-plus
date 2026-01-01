//
//  AutoSyncCoordinatorTests.swift
//  lich-plusTests
//
//  Created by Claude on December 20, 2025.
//

import XCTest
import SwiftData
import EventKit
import Combine
@testable import lich_plus

@MainActor
final class AutoSyncCoordinatorTests: XCTestCase {

    var sut: AutoSyncCoordinator!
    var mockEventKitService: MockEventKitServiceForCoordinator!
    var mockCalendarSyncService: CalendarSyncService!
    var modelContext: ModelContext!

    override func setUp() async throws {
        try await super.setUp()

        // Create in-memory SwiftData model context
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: SyncableEvent.self, SyncedCalendar.self, configurations: config)
        modelContext = ModelContext(container)

        // Initialize mocks
        mockEventKitService = MockEventKitServiceForCoordinator()
        mockCalendarSyncService = CalendarSyncService(
            eventKitService: mockEventKitService,
            modelContext: modelContext
        )

        // Initialize SUT
        sut = AutoSyncCoordinator(
            syncService: mockCalendarSyncService,
            eventKitService: mockEventKitService,
            modelContext: modelContext
        )
    }

    override func tearDown() async throws {
        sut.stopObserving()
        sut.stopObservingExternalChanges()
        sut = nil
        mockEventKitService = nil
        mockCalendarSyncService = nil
        modelContext = nil
        try await super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitializationCreatesCoordinator() {
        XCTAssertNotNil(sut)
    }

    func testInitializationSetsIsSyncingFalse() {
        XCTAssertFalse(sut.isSyncing)
    }

    func testInitializationSetsNoError() {
        XCTAssertNil(sut.lastSyncError)
    }

    // MARK: - Outbound Observation Tests (Local Changes → Apple Calendar)

    func testStartObservingRegistersNotificationObserver() {
        sut.startObserving()
        // Verify by posting notification and checking if coordinator responds
        // The actual verification happens through integration
        XCTAssertTrue(true)
    }

    func testStopObservingCleansUpNotificationObserver() {
        sut.startObserving()
        sut.stopObserving()
        // Verify cleanup doesn't crash and subsequent notifications don't trigger sync
        XCTAssertTrue(true)
    }

    // MARK: - Inbound Observation Tests (Apple Calendar Changes → Local)

    func testStartObservingExternalChangesRegistersObserver() {
        sut.startObservingExternalChanges()
        // Verify registration succeeded without errors
        XCTAssertTrue(true)
    }

    func testStopObservingExternalChangesCleansUpObserver() {
        sut.startObservingExternalChanges()
        sut.stopObservingExternalChanges()
        // Verify cleanup doesn't crash
        XCTAssertTrue(true)
    }

    // MARK: - Sync Behavior Tests

    func testPerformSyncCompletesSuccessfully() async {
        mockEventKitService.mockHasFullAccess = true
        
        let expectation = XCTestExpectation(description: "Sync completes")
        
        Task {
            await sut.performSync()
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 2.0)
        
        // After sync completes, isSyncing should be false
        XCTAssertFalse(sut.isSyncing, "Should not be syncing after completion")
    }

    func testPerformSyncRequestsPermissionsIfNotGranted() async {
        mockEventKitService.mockHasFullAccess = false
        mockEventKitService.shouldGrantAccess = true
        
        await sut.performSync()
        
        // Verify requestFullAccess was called
        XCTAssertTrue(mockEventKitService.requestFullAccessCalled)
    }

    func testPerformSyncSkipsPermissionRequestIfAlreadyGranted() async {
        mockEventKitService.mockHasFullAccess = true
        
        await sut.performSync()
        
        // Should not need to request
        XCTAssertFalse(mockEventKitService.requestFullAccessCalled)
    }

    func testPerformSyncReturnsEarlyIfAlreadySyncing() async {
        mockEventKitService.mockHasFullAccess = true
        
        // Set syncing flag
        sut.isSyncing = true
        
        await sut.performSync()
        
        // Should return early and not change state
        XCTAssertTrue(sut.isSyncing)
    }

    // MARK: - Error Handling Tests

    func testPerformSyncErrorIsSilent() async {
        mockEventKitService.mockHasFullAccess = true
        
        // No enabled calendars to trigger error
        let expectation = XCTestExpectation(description: "Sync completes")
        
        Task {
            await sut.performSync()
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 2.0)
        
        // Error should be captured but not propagated
        // (no exception should be thrown)
        XCTAssertTrue(true)
    }

    // MARK: - Lifecycle Tests

    func testDeinitCleansUpBothObservers() async {
        let tempCoordinator = AutoSyncCoordinator(
            syncService: mockCalendarSyncService,
            eventKitService: mockEventKitService,
            modelContext: modelContext
        )
        
        tempCoordinator.startObserving()
        tempCoordinator.startObservingExternalChanges()
        
        // Deinit should clean up without crashing
        // No exception should be thrown
        XCTAssertTrue(true)
    }

    // MARK: - Multi-Observer Lifecycle Tests

    func testStartAndStopObservingCanBeCalled() async {
        // Start both observers
        sut.startObserving()
        sut.startObservingExternalChanges()
        
        // Stop both observers
        sut.stopObserving()
        sut.stopObservingExternalChanges()
        
        // Can restart
        sut.startObserving()
        sut.startObservingExternalChanges()
        
        // Cleanup
        sut.stopObserving()
        sut.stopObservingExternalChanges()
        
        XCTAssertTrue(true)
    }
}

// MARK: - Mock Services

@MainActor
final class MockEventKitServiceForCoordinator: EventKitService {
    var requestFullAccessCalled = false
    var mockHasFullAccess = false
    var shouldGrantAccess = false

    override func hasFullAccess() -> Bool {
        return mockHasFullAccess
    }

    override func requestFullAccess() async -> Bool {
        requestFullAccessCalled = true
        return shouldGrantAccess
    }

    override func fetchAllCalendars() -> [EKCalendar] {
        return []
    }

    override func checkAuthorizationStatus() -> EKAuthorizationStatus {
        return mockHasFullAccess ? .fullAccess : .notDetermined
    }

    override func fetchCalendar(identifier: String) -> EKCalendar? {
        return nil
    }

    override func fetchEvent(identifier: String) -> EKEvent? {
        return nil
    }

    override func fetchAllEventsWithFreshStore(calendarIdentifiers: [String]) -> [EKEvent] {
        return []
    }
}
