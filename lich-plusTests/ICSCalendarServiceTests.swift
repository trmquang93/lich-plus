//
//  ICSCalendarServiceTests.swift
//  lich-plusTests
//

import XCTest
@testable import lich_plus

@MainActor
final class ICSCalendarServiceTests: XCTestCase {
    var sut: ICSCalendarService!

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testICSCalendarServiceInitialization() {
        sut = ICSCalendarService()
        XCTAssertNotNil(sut)
    }

    // MARK: - Convert to SyncableEvent Tests

    func testConvertToSyncableEvent() {
        sut = ICSCalendarService()
        let icsEvent = ICSEvent(
            uid: "test-uid-123",
            summary: "Test Event",
            description: "Test Description",
            startDate: Date(),
            endDate: nil,
            isAllDay: false,
            location: "Test Location",
            recurrenceRule: nil
        )

        let syncableEvent = sut.convertToSyncableEvent(
            icsEvent,
            subscriptionId: "subscription-1",
            subscriptionName: "Test Calendar",
            colorHex: "#C7251D"
        )

        XCTAssertEqual(syncableEvent.icsEventUid, "test-uid-123")
        XCTAssertEqual(syncableEvent.icsSubscriptionId, "subscription-1")
        XCTAssertEqual(syncableEvent.title, "Test Event")
        XCTAssertEqual(syncableEvent.notes, "Test Description")
        XCTAssertEqual(syncableEvent.location, "Test Location")
        XCTAssertEqual(syncableEvent.source, EventSource.icsSubscription.rawValue)
        XCTAssertEqual(syncableEvent.itemType, "event")
        XCTAssertEqual(syncableEvent.syncStatus, SyncStatus.synced.rawValue)
    }

    func testConvertAllDayEvent() {
        sut = ICSCalendarService()
        let icsEvent = ICSEvent(
            uid: "all-day-uid",
            summary: "All Day Event",
            description: nil,
            startDate: Date(),
            endDate: nil,
            isAllDay: true,
            location: nil,
            recurrenceRule: nil
        )

        let syncableEvent = sut.convertToSyncableEvent(
            icsEvent,
            subscriptionId: "sub-1",
            subscriptionName: "Calendar",
            colorHex: "#FF0000"
        )

        XCTAssertTrue(syncableEvent.isAllDay)
    }

    func testConvertEventWithEndDate() {
        sut = ICSCalendarService()
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(3600)

        let icsEvent = ICSEvent(
            uid: "event-with-end",
            summary: "Event with End",
            description: nil,
            startDate: startDate,
            endDate: endDate,
            isAllDay: false,
            location: nil,
            recurrenceRule: nil
        )

        let syncableEvent = sut.convertToSyncableEvent(
            icsEvent,
            subscriptionId: "sub-1",
            subscriptionName: "Calendar",
            colorHex: "#0000FF"
        )

        XCTAssertEqual(syncableEvent.endDate, endDate)
    }

    func testConvertEventWithoutOptionalFields() {
        sut = ICSCalendarService()
        let icsEvent = ICSEvent(
            uid: "minimal-uid",
            summary: "Minimal Event",
            description: nil,
            startDate: Date(),
            endDate: nil,
            isAllDay: false,
            location: nil,
            recurrenceRule: nil
        )

        let syncableEvent = sut.convertToSyncableEvent(
            icsEvent,
            subscriptionId: "sub-1",
            subscriptionName: "Calendar",
            colorHex: "#FF00FF"
        )

        XCTAssertNil(syncableEvent.notes)
        XCTAssertNil(syncableEvent.location)
        XCTAssertNil(syncableEvent.endDate)
    }

    // MARK: - Event Source Tests

    func testConvertedEventHasCorrectSource() {
        sut = ICSCalendarService()
        let icsEvent = ICSEvent(
            uid: "test",
            summary: "Test",
            description: nil,
            startDate: Date(),
            endDate: nil,
            isAllDay: false,
            location: nil,
            recurrenceRule: nil
        )

        let syncableEvent = sut.convertToSyncableEvent(
            icsEvent,
            subscriptionId: "sub",
            subscriptionName: "Cal",
            colorHex: "#000000"
        )

        XCTAssertEqual(syncableEvent.sourceEnum, .icsSubscription)
    }

    func testConvertedEventIsSynced() {
        sut = ICSCalendarService()
        let icsEvent = ICSEvent(
            uid: "test",
            summary: "Test",
            description: nil,
            startDate: Date(),
            endDate: nil,
            isAllDay: false,
            location: nil,
            recurrenceRule: nil
        )

        let syncableEvent = sut.convertToSyncableEvent(
            icsEvent,
            subscriptionId: "sub",
            subscriptionName: "Cal",
            colorHex: "#000000"
        )

        XCTAssertEqual(syncableEvent.syncStatusEnum, .synced)
    }
}
