//
//  AnalyticsParameterPolicyTests.swift
//  lich-plusTests
//

import XCTest
@testable import lich_plus

final class AnalyticsParameterPolicyTests: XCTestCase {
    func testAllowedScreenViewEvent() {
        let params = AnalyticsParameterPolicy.sanitizedParameters(
            for: "screen_view",
            parameters: ["screen_name": AnalyticsScreen.calendar.rawValue]
        )

        XCTAssertEqual(params?["screen_name"] as? String, "calendar")
    }

    func testRejectsPrivateContentInParameters() {
        let params = AnalyticsParameterPolicy.sanitizedParameters(
            for: "feature_used",
            parameters: ["feature_id": "calendar_title_leak"]
        )

        XCTAssertNil(params)
    }

    func testRejectsUnknownEventName() {
        let params = AnalyticsParameterPolicy.sanitizedParameters(
            for: "event_created",
            parameters: ["screen_name": AnalyticsScreen.calendar.rawValue]
        )

        XCTAssertNil(params)
    }

    func testRejectsBlockedKeys() {
        XCTAssertTrue(AnalyticsParameterPolicy.containsBlockedContent(in: "event_title"))
        XCTAssertTrue(AnalyticsParameterPolicy.containsBlockedContent(in: "van_khan_text"))
    }

    func testNotificationPermissionEvent() {
        let params = AnalyticsParameterPolicy.sanitizedParameters(
            for: "notif_permission",
            parameters: ["granted": true]
        )

        XCTAssertEqual(params?["granted"] as? String, "true")
    }

    func testAppOpenEventIncludesVersionMetadata() {
        let params = AnalyticsParameterPolicy.sanitizedParameters(
            for: "app_open",
            parameters: [
                "source": "cold_start",
                "app_version": "1.0.5",
                "build_number": "42",
            ]
        )

        XCTAssertEqual(params?["source"] as? String, "cold_start")
        XCTAssertEqual(params?["app_version"] as? String, "1.0.5")
        XCTAssertEqual(params?["build_number"] as? String, "42")
    }
}
