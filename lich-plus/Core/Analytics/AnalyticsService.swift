//
//  AnalyticsService.swift
//  lich-plus
//
//  Privacy-safe Firebase Analytics + Crashlytics facade.
//  Never log calendar titles, event notes, giỗ names, or văn khấn text.
//

import Foundation
import FirebaseAnalytics
import FirebaseCore
import FirebaseCrashlytics

/// Central analytics entry point. All instrumentation should go through this type.
@MainActor
final class AnalyticsService {
    static let shared = AnalyticsService()

    private(set) var isConfigured = false

    private init() {}

    /// Configures Firebase when `GoogleService-Info.plist` is present in the app bundle.
    func configureIfNeeded() {
        guard !isConfigured else { return }

        guard Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil else {
            #if DEBUG
            print("[Analytics] GoogleService-Info.plist missing — Firebase not configured")
            #endif
            return
        }

        FirebaseApp.configure()
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
        setDefaultUserProperties()
        isConfigured = true
    }

    func logAppOpen(source: AppOpenSource = .coldStart) {
        logEvent(
            "app_open",
            parameters: [
                "source": source.rawValue,
                "app_version": appVersion,
                "build_number": buildNumber,
            ]
        )
    }

    func logScreen(_ screen: AnalyticsScreen) {
        logEvent(
            "screen_view",
            parameters: ["screen_name": screen.rawValue]
        )
    }

    func logFeatureUsed(_ feature: AnalyticsFeature) {
        logEvent(
            "feature_used",
            parameters: ["feature_id": feature.rawValue]
        )
    }

    func logNotificationPermission(granted: Bool) {
        logEvent(
            "notif_permission",
            parameters: ["granted": granted]
        )
    }

    func logNotificationOptIn(optedIn: Bool) {
        logEvent(
            "notif_opt_in",
            parameters: ["opted_in": optedIn]
        )
    }

    func logWidgetInstall(kind: String) {
        logEvent(
            "widget_install",
            parameters: ["widget_kind": kind]
        )
    }

    /// Records a non-PII breadcrumb for Crashlytics debugging. Never pass user content.
    func recordBreadcrumb(_ message: String) {
        guard isConfigured else { return }
        guard !AnalyticsParameterPolicy.containsBlockedContent(in: message) else { return }
        Crashlytics.crashlytics().log(message)
    }

    /// Sets a Crashlytics custom key. Keys and values must be non-PII product identifiers.
    func setCrashlyticsValue(_ value: String, forKey key: String) {
        guard isConfigured else { return }
        guard AnalyticsParameterPolicy.allowedParameterKeys.contains(key) else { return }
        guard !AnalyticsParameterPolicy.containsBlockedContent(in: key),
              !AnalyticsParameterPolicy.containsBlockedContent(in: value) else {
            return
        }
        Crashlytics.crashlytics().setCustomValue(value, forKey: key)
    }

    #if DEBUG
    /// Triggers a test crash. Use only in debug builds to verify Crashlytics wiring.
    func triggerTestCrash() {
        fatalError("Analytics test crash — debug only")
    }
    #endif

    // MARK: - Private

    private func logEvent(_ name: String, parameters: [String: Any]) {
        guard let sanitized = AnalyticsParameterPolicy.sanitizedParameters(
            for: name,
            parameters: parameters
        ) else {
            #if DEBUG
            assertionFailure("Blocked analytics event: \(name)")
            #endif
            return
        }

        guard isConfigured else {
            #if DEBUG
            print("[Analytics] \(name) \(sanitized)")
            #endif
            return
        }

        Analytics.logEvent(name, parameters: sanitized)
    }

    private func setDefaultUserProperties() {
        Analytics.setUserProperty(appVersion, forName: "app_version")
        Analytics.setUserProperty(buildNumber, forName: "build_number")
        setCrashlyticsValue(appVersion, forKey: "app_version")
        setCrashlyticsValue(buildNumber, forKey: "build_number")
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "unknown"
    }
}

enum AppOpenSource: String, Sendable {
    case coldStart = "cold_start"
    case foreground = "foreground"
}
