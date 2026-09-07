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

    func testEveryTaxonomyIDSurvivesSanitization() {
        // WHY: screen/feature IDs are product taxonomy, not PII. Substring denylist
        // collisions ("note"/"profile"/"khan"/"greeting") must not drop real events.
        for screen in AnalyticsScreen.allCases {
            let params = AnalyticsParameterPolicy.sanitizedParameters(
                for: "screen_view",
                parameters: ["screen_name": screen.rawValue]
            )
            XCTAssertEqual(
                params?["screen_name"] as? String,
                screen.rawValue,
                "Taxonomy screen_name \(screen.rawValue) must ship"
            )
        }

        for feature in AnalyticsFeature.allCases {
            let params = AnalyticsParameterPolicy.sanitizedParameters(
                for: "feature_used",
                parameters: ["feature_id": feature.rawValue]
            )
            XCTAssertEqual(
                params?["feature_id"] as? String,
                feature.rawValue,
                "Taxonomy feature_id \(feature.rawValue) must ship"
            )
        }

        let widget = AnalyticsParameterPolicy.sanitizedParameters(
            for: "widget_install",
            parameters: ["widget_kind": "today"]
        )
        XCTAssertEqual(widget?["widget_kind"] as? String, "today")
    }

    func testRejectsPrivateUserContentAsParametersAndKeys() {
        // WHY: fail-closed privacy contract — calendar titles, event notes, greeting
        // text, văn khấn body, and ancestor/giỗ names must never ship as params/keys.
        let privateValues: [(event: String, key: String, value: String)] = [
            ("screen_view", "screen_name", "Họp team tuần này"),
            ("feature_used", "feature_id", "Nhớ mang quà sinh nhật"),
            ("feature_used", "feature_id", "Chúc mừng năm mới an khang thịnh vượng"),
            ("feature_used", "feature_id", "Con kính lạy tổ tiên ông bà"),
            ("feature_used", "feature_id", "Nguyễn Văn A"),
            ("feature_used", "feature_id", "Giỗ ông nội"),
            ("feature_used", "event_title", "calendar"),
            ("feature_used", "notes", "calendar"),
            ("feature_used", "greeting_text", "calendar"),
            ("feature_used", "van_khan_body", "calendar"),
            ("feature_used", "ancestor_name", "calendar"),
            ("feature_used", "giỗ_name", "calendar"),
        ]

        for payload in privateValues {
            let params = AnalyticsParameterPolicy.sanitizedParameters(
                for: payload.event,
                parameters: [payload.key: payload.value]
            )
            XCTAssertNil(params, "Private \(payload.key)=\(payload.value) must not ship")
        }

        XCTAssertTrue(AnalyticsParameterPolicy.containsBlockedContent(in: "event_title"))
        XCTAssertTrue(AnalyticsParameterPolicy.containsBlockedContent(in: "notes"))
        XCTAssertTrue(AnalyticsParameterPolicy.containsBlockedContent(in: "greeting_text"))
        XCTAssertTrue(AnalyticsParameterPolicy.containsBlockedContent(in: "van_khan_body"))
        XCTAssertTrue(AnalyticsParameterPolicy.containsBlockedContent(in: "ancestor_name"))
        XCTAssertTrue(AnalyticsParameterPolicy.containsBlockedContent(in: "Giỗ ông nội"))
    }
}
