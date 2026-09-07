//
//  AnalyticsParameterPolicy.swift
//  lich-plus
//
//  Guards analytics payloads so private calendar/event/profile content never ships.
//

import Foundation

/// Validates analytics event names and parameters before they reach Firebase.
enum AnalyticsParameterPolicy {
    static let allowedEventNames: Set<String> = [
        "screen_view",
        "feature_used",
        "app_open",
        "notif_permission",
        "notif_opt_in",
        "widget_install",
    ]

    static let allowedParameterKeys: Set<String> = [
        "screen_name",
        "feature_id",
        "widget_kind",
        "granted",
        "opted_in",
        "source",
        "app_version",
        "build_number",
    ]

    /// Substrings that suggest user-entered or sensitive content in keys or values.
    private static let blockedContentSubstrings: [String] = [
        "title",
        "note",
        "notes",
        "greeting",
        "khan",
        "ancestor",
        "giod",
        "giỗ",
        "event_name",
        "description",
        "content",
        "profile",
        "email",
        "password",
        "token",
    ]

    static func isAllowedEventName(_ name: String) -> Bool {
        allowedEventNames.contains(name)
    }

    static func isAllowedScreenName(_ screenName: String) -> Bool {
        AnalyticsScreen.allCases.map(\.rawValue).contains(screenName)
    }

    static func isAllowedFeatureID(_ featureID: String) -> Bool {
        AnalyticsFeature.allCases.map(\.rawValue).contains(featureID)
    }

    static func sanitizedParameters(
        for eventName: String,
        parameters: [String: Any]
    ) -> [String: Any]? {
        guard isAllowedEventName(eventName) else { return nil }

        var sanitized: [String: Any] = [:]

        for (key, value) in parameters {
            guard allowedParameterKeys.contains(key) else { return nil }
            guard !containsBlockedContent(in: key) else { return nil }

            switch key {
            case "screen_name":
                guard let screenName = value as? String, isAllowedScreenName(screenName) else {
                    return nil
                }
                sanitized[key] = screenName
            case "feature_id":
                guard let featureID = value as? String, isAllowedFeatureID(featureID) else {
                    return nil
                }
                sanitized[key] = featureID
            case "widget_kind":
                guard let widgetKind = value as? String,
                      isAllowedWidgetKind(widgetKind) else {
                    return nil
                }
                sanitized[key] = widgetKind
            case "granted", "opted_in":
                guard let boolValue = value as? Bool else { return nil }
                sanitized[key] = boolValue ? "true" : "false"
            case "source":
                guard let source = value as? String, isAllowedSource(source) else {
                    return nil
                }
                sanitized[key] = source
            case "app_version", "build_number":
                guard let version = value as? String, isNonPIIVersionString(version) else {
                    return nil
                }
                sanitized[key] = version
            default:
                return nil
            }

            if let stringValue = sanitized[key] as? String, containsBlockedContent(in: stringValue) {
                return nil
            }
        }

        return sanitized
    }

    static func containsBlockedContent(in text: String) -> Bool {
        let normalized = text.lowercased()
        return blockedContentSubstrings.contains { normalized.contains($0) }
    }

    private static func isAllowedWidgetKind(_ kind: String) -> Bool {
        let allowedKinds: Set<String> = ["today", "month", "timeline"]
        return allowedKinds.contains(kind)
    }

    private static func isAllowedSource(_ source: String) -> Bool {
        let allowedSources: Set<String> = ["cold_start", "foreground", "notification", "deep_link"]
        return allowedSources.contains(source)
    }

    private static func isNonPIIVersionString(_ value: String) -> Bool {
        let pattern = #"^[0-9A-Za-z._+-]+$"#
        return value.range(of: pattern, options: .regularExpression) != nil
    }
}
