//
//  ICSCalendarSyncServiceTests.swift
//  lich-plusTests
//

import XCTest
import SwiftData
@testable import lich_plus

@MainActor
final class ICSCalendarSyncServiceTests: XCTestCase {

    var sut: ICSCalendarSyncService!
    var modelContext: ModelContext!
    var container: ModelContainer!

    override func setUp() async throws {
        try await super.setUp()

        // Create in-memory SwiftData model context
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(
            for: SyncableEvent.self, SyncedCalendar.self, ICSSubscription.self, NotificationSettings.self,
            configurations: config
        )
        modelContext = ModelContext(container)

        // Initialize SUT with a mock calendar service that returns empty events
        sut = ICSCalendarSyncService(
            modelContext: modelContext,
            calendarService: MockICSCalendarService()
        )

        // Wait for initial loadSubscriptions to complete
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
    }

    override func tearDown() async throws {
        sut = nil
        modelContext = nil
        container = nil
        try await super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitializationCreatesService() {
        XCTAssertNotNil(sut)
    }

    func testInitializationSetsIdleState() {
        XCTAssertEqual(sut.syncState, .idle)
    }

    func testInitializationHasEmptySubscriptions() {
        XCTAssertTrue(sut.subscriptions.isEmpty)
    }

    // MARK: - Race Condition Fix Test

    /// Tests the fix for the race condition where pullRemoteChanges() was called
    /// before subscriptions were loaded, causing built-in calendars to not sync
    /// on first app launch.
    ///
    /// Scenario:
    /// 1. ICSCalendarSyncService is created (subscriptions array is empty)
    /// 2. A subscription is added directly to the database (simulating BuiltInCalendarManager)
    /// 3. pullRemoteChanges() is called
    /// 4. Before the fix: would exit early because subscriptions array was stale
    /// 5. After the fix: reloads subscriptions and syncs correctly
    func testPullRemoteChangesReloadsSubscriptionsBeforeChecking() async throws {
        // Verify initial state - subscriptions array is empty
        XCTAssertTrue(sut.subscriptions.isEmpty, "Subscriptions should be empty initially")

        // Simulate what BuiltInCalendarManager does: insert subscription directly to database
        // This bypasses the ICSCalendarSyncService, so its subscriptions array remains empty
        let builtInSubscription = ICSSubscription(
            name: "Vietnamese Holidays",
            url: "https://www.officeholidays.com/ics/ics_country.php?tbl_country=Vietnam",
            isEnabled: true,
            colorHex: "#C7251D",
            type: SubscriptionType.builtin.rawValue
        )
        modelContext.insert(builtInSubscription)
        try modelContext.save()

        // Verify the subscription is in the database but not in the service's array
        let descriptor = FetchDescriptor<ICSSubscription>()
        let dbSubscriptions = try modelContext.fetch(descriptor)
        XCTAssertEqual(dbSubscriptions.count, 1, "Database should have 1 subscription")
        XCTAssertTrue(sut.subscriptions.isEmpty, "Service's subscriptions array should still be empty (stale)")

        // Call pullRemoteChanges - this should reload subscriptions before checking if empty
        // Note: We use a mock service that returns empty events, so no actual network call
        try await sut.pullRemoteChanges()

        // After the fix, subscriptions should now be loaded
        XCTAssertEqual(sut.subscriptions.count, 1, "Service should have reloaded subscriptions")
        XCTAssertEqual(sut.subscriptions.first?.name, "Vietnamese Holidays")
        XCTAssertEqual(sut.syncState, .idle, "Sync should complete successfully")
    }

    /// Tests that pullRemoteChanges handles the case when database is truly empty
    func testPullRemoteChangesWithNoSubscriptions() async throws {
        XCTAssertTrue(sut.subscriptions.isEmpty)

        // Should not throw and should complete gracefully
        try await sut.pullRemoteChanges()

        XCTAssertEqual(sut.syncState, .idle)
        XCTAssertNil(sut.syncError)
    }

    /// Tests that subscriptions added via the service's API are immediately available
    func testAddSubscriptionUpdatesArray() async throws {
        XCTAssertTrue(sut.subscriptions.isEmpty)

        try await sut.addSubscription(
            name: "Test Calendar",
            urlString: "https://example.com/calendar.ics"
        )

        XCTAssertEqual(sut.subscriptions.count, 1)
        XCTAssertEqual(sut.subscriptions.first?.name, "Test Calendar")
    }

    // MARK: - Subscription Management Tests

    func testRemoveSubscription() async throws {
        // Add a subscription first
        try await sut.addSubscription(
            name: "Test Calendar",
            urlString: "https://example.com/calendar.ics"
        )
        XCTAssertEqual(sut.subscriptions.count, 1)

        // Remove it
        let subscription = sut.subscriptions.first!
        try await sut.removeSubscription(subscription)

        XCTAssertTrue(sut.subscriptions.isEmpty)
    }

    func testUpdateSubscriptionEnabled() async throws {
        try await sut.addSubscription(
            name: "Test Calendar",
            urlString: "https://example.com/calendar.ics"
        )

        let subscription = sut.subscriptions.first!
        XCTAssertTrue(subscription.isEnabled)

        try await sut.updateSubscription(subscription, isEnabled: false)

        XCTAssertFalse(sut.subscriptions.first!.isEnabled)
    }

    // MARK: - URL Validation Tests

    func testAddSubscriptionRejectsInvalidURL() async {
        do {
            try await sut.addSubscription(
                name: "Bad Calendar",
                urlString: "not-a-url"
            )
            XCTFail("Should throw for invalid URL")
        } catch {
            XCTAssertTrue(error is ICSCalendarSyncError)
        }
    }

    func testAddSubscriptionRejectsNonHTTPURL() async {
        do {
            try await sut.addSubscription(
                name: "FTP Calendar",
                urlString: "ftp://example.com/calendar.ics"
            )
            XCTFail("Should throw for non-HTTP URL")
        } catch {
            XCTAssertTrue(error is ICSCalendarSyncError)
        }
    }
}

// MARK: - Mock ICS Calendar Service

/// Mock service that returns empty events for testing
private class MockICSCalendarService: ICSCalendarService {
    override func fetchEvents(from url: URL) async throws -> [ICSEvent] {
        // Return empty array to simulate successful fetch with no events
        return []
    }
}
