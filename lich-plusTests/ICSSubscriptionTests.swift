//
//  ICSSubscriptionTests.swift
//  lich-plusTests
//
//  Created by Quang Tran Minh on 30/11/25.
//

import XCTest
@testable import lich_plus

final class ICSSubscriptionTests: XCTestCase {

    // MARK: - Initialization Tests

    func testInitializationWithDefaults() {
        let subscription = ICSSubscription(
            name: "Test Calendar",
            url: "https://example.com/calendar.ics"
        )

        XCTAssertEqual(subscription.name, "Test Calendar")
        XCTAssertEqual(subscription.url, "https://example.com/calendar.ics")
        XCTAssertTrue(subscription.isEnabled)
        XCTAssertNil(subscription.lastSyncDate)
        XCTAssertEqual(subscription.colorHex, "#C7251D")
        XCTAssertNotNil(subscription.createdAt)
        XCTAssertNotNil(subscription.id)
    }

    func testInitializationWithCustomValues() {
        let now = Date()
        let customId = UUID()
        let subscription = ICSSubscription(
            id: customId,
            name: "Custom Calendar",
            url: "https://custom.com/events.ics",
            isEnabled: false,
            lastSyncDate: now,
            colorHex: "#FF0000",
            createdAt: now
        )

        XCTAssertEqual(subscription.id, customId)
        XCTAssertEqual(subscription.name, "Custom Calendar")
        XCTAssertEqual(subscription.url, "https://custom.com/events.ics")
        XCTAssertFalse(subscription.isEnabled)
        XCTAssertEqual(subscription.lastSyncDate, now)
        XCTAssertEqual(subscription.colorHex, "#FF0000")
        XCTAssertEqual(subscription.createdAt, now)
    }

    // MARK: - Update Last Sync Date Tests

    func testUpdateLastSyncDate() {
        let subscription = ICSSubscription(
            name: "Test",
            url: "https://example.com/calendar.ics"
        )

        XCTAssertNil(subscription.lastSyncDate)

        let beforeUpdate = Date()
        subscription.updateLastSyncDate()
        let afterUpdate = Date()

        XCTAssertNotNil(subscription.lastSyncDate)
        if let syncDate = subscription.lastSyncDate {
            XCTAssertGreaterThanOrEqual(syncDate, beforeUpdate)
            XCTAssertLessThanOrEqual(syncDate, afterUpdate)
        }
    }

    func testMultipleUpdatesToLastSyncDate() {
        let subscription = ICSSubscription(
            name: "Test",
            url: "https://example.com/calendar.ics"
        )

        subscription.updateLastSyncDate()
        let firstSyncDate = subscription.lastSyncDate

        // Add a small delay to ensure different timestamps
        Thread.sleep(forTimeInterval: 0.01)

        subscription.updateLastSyncDate()
        let secondSyncDate = subscription.lastSyncDate

        XCTAssertNotNil(firstSyncDate)
        XCTAssertNotNil(secondSyncDate)
        if let first = firstSyncDate, let second = secondSyncDate {
            XCTAssertLessThan(first, second)
        }
    }

    // MARK: - Enable/Disable Tests

    func testToggleEnabled() {
        let subscription = ICSSubscription(
            name: "Test",
            url: "https://example.com/calendar.ics",
            isEnabled: true
        )

        XCTAssertTrue(subscription.isEnabled)

        subscription.isEnabled = false
        XCTAssertFalse(subscription.isEnabled)

        subscription.isEnabled = true
        XCTAssertTrue(subscription.isEnabled)
    }

    // MARK: - URL Validation Tests

    func testVariousURLFormats() {
        let httpURL = ICSSubscription(
            name: "HTTP Calendar",
            url: "http://example.com/calendar.ics"
        )
        XCTAssertEqual(httpURL.url, "http://example.com/calendar.ics")

        let httpsURL = ICSSubscription(
            name: "HTTPS Calendar",
            url: "https://example.com/calendar.ics"
        )
        XCTAssertEqual(httpsURL.url, "https://example.com/calendar.ics")

        let complexURL = ICSSubscription(
            name: "Complex URL",
            url: "https://calendar.example.com/path/to/calendar.ics?key=value&other=param"
        )
        XCTAssertEqual(complexURL.url, "https://calendar.example.com/path/to/calendar.ics?key=value&other=param")
    }

    // MARK: - Color Tests

    func testDefaultColor() {
        let subscription = ICSSubscription(
            name: "Test",
            url: "https://example.com/calendar.ics"
        )
        XCTAssertEqual(subscription.colorHex, "#C7251D")
    }

    func testCustomColor() {
        let subscription = ICSSubscription(
            name: "Test",
            url: "https://example.com/calendar.ics",
            colorHex: "#FF00FF"
        )
        XCTAssertEqual(subscription.colorHex, "#FF00FF")
    }

    // MARK: - UniqueID Property Tests

    func testUniqueIDProperty() {
        let subscription = ICSSubscription(
            name: "Test",
            url: "https://example.com/calendar.ics"
        )

        // ID should be unique
        XCTAssertNotNil(subscription.id)
        XCTAssertNotEqual(subscription.id, UUID())
    }

    func testTwoSubscriptionsHaveDifferentIDs() {
        let sub1 = ICSSubscription(
            name: "Calendar 1",
            url: "https://example1.com/calendar.ics"
        )

        let sub2 = ICSSubscription(
            name: "Calendar 2",
            url: "https://example2.com/calendar.ics"
        )

        XCTAssertNotEqual(sub1.id, sub2.id)
    }

    // MARK: - Name and URL Tests

    func testNameValidation() {
        let subscription = ICSSubscription(
            name: "My Calendar Name",
            url: "https://example.com/calendar.ics"
        )

        XCTAssertEqual(subscription.name, "My Calendar Name")
        XCTAssertFalse(subscription.name.isEmpty)
    }

    func testURLValidation() {
        let subscription = ICSSubscription(
            name: "Test",
            url: "https://example.com/very/long/path/to/calendar.ics"
        )

        XCTAssertEqual(subscription.url, "https://example.com/very/long/path/to/calendar.ics")
        XCTAssertTrue(subscription.url.starts(with: "https://"))
    }

    // MARK: - Type Field Tests

    func testDefaultTypeIsUser() {
        let subscription = ICSSubscription(
            name: "Test Calendar",
            url: "https://example.com/calendar.ics"
        )

        XCTAssertEqual(subscription.type, SubscriptionType.user.rawValue)
    }

    func testCustomTypeCanBeSetToBuiltin() {
        let subscription = ICSSubscription(
            name: "Built-in Calendar",
            url: "https://example.com/calendar.ics",
            type: SubscriptionType.builtin.rawValue
        )

        XCTAssertEqual(subscription.type, SubscriptionType.builtin.rawValue)
    }

    func testCustomTypeCanBeSetToUser() {
        let subscription = ICSSubscription(
            name: "User Calendar",
            url: "https://example.com/calendar.ics",
            type: SubscriptionType.user.rawValue
        )

        XCTAssertEqual(subscription.type, SubscriptionType.user.rawValue)
    }

    // MARK: - isBuiltIn Computed Property Tests

    func testIsBuiltInReturnsTrueForBuiltinType() {
        let subscription = ICSSubscription(
            name: "Built-in Calendar",
            url: "https://example.com/calendar.ics",
            type: SubscriptionType.builtin.rawValue
        )

        XCTAssertTrue(subscription.isBuiltIn)
    }

    func testIsBuiltInReturnsFalseForUserType() {
        let subscription = ICSSubscription(
            name: "User Calendar",
            url: "https://example.com/calendar.ics",
            type: SubscriptionType.user.rawValue
        )

        XCTAssertFalse(subscription.isBuiltIn)
    }

    // MARK: - isDeletable Computed Property Tests

    func testIsDeletableReturnsTrueForUserType() {
        let subscription = ICSSubscription(
            name: "User Calendar",
            url: "https://example.com/calendar.ics",
            type: SubscriptionType.user.rawValue
        )

        XCTAssertTrue(subscription.isDeletable)
    }

    func testIsDeletableReturnsFalseForBuiltinType() {
        let subscription = ICSSubscription(
            name: "Built-in Calendar",
            url: "https://example.com/calendar.ics",
            type: SubscriptionType.builtin.rawValue
        )

        XCTAssertFalse(subscription.isDeletable)
    }

    func testIsDeletableReturnsTrueByDefault() {
        let subscription = ICSSubscription(
            name: "Default Calendar",
            url: "https://example.com/calendar.ics"
        )

        XCTAssertTrue(subscription.isDeletable)
    }

    // MARK: - SubscriptionType Enum Tests

    func testSubscriptionTypeEnum() {
        XCTAssertEqual(SubscriptionType.user.rawValue, "user")
        XCTAssertEqual(SubscriptionType.builtin.rawValue, "builtin")
    }

    func testSubscriptionTypeEnumRawValueInit() {
        let userType = SubscriptionType(rawValue: "user")
        let builtinType = SubscriptionType(rawValue: "builtin")

        XCTAssertEqual(userType, SubscriptionType.user)
        XCTAssertEqual(builtinType, SubscriptionType.builtin)
    }

    func testSubscriptionTypeEnumInvalidRawValue() {
        let invalidType = SubscriptionType(rawValue: "invalid")
        XCTAssertNil(invalidType)
    }
}
