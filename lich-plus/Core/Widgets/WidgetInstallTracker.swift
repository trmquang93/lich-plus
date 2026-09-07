//
//  WidgetInstallTracker.swift
//  lich-plus
//
//  Logs privacy-safe widget_install analytics when Today widgets are added.
//

import Foundation
import WidgetKit

@MainActor
enum WidgetInstallTracker {
    private static let trackedKindsKey = "analytics_tracked_widget_kinds"

    static func trackInstalledWidgetsIfNeeded() async {
        guard let configurations = try? await WidgetCenter.shared.currentConfigurations() else {
            return
        }

        let installedTodayKinds = configurations
            .filter { $0.kind == TodayWidgetConstants.kind }
            .map(\.family.description)

        guard !installedTodayKinds.isEmpty else { return }

        var tracked = trackedWidgetKinds()
        for family in installedTodayKinds {
            let token = "today:\(family)"
            guard !tracked.contains(token) else { continue }
            AnalyticsService.shared.logWidgetInstall(kind: "today")
            tracked.insert(token)
        }
        saveTrackedWidgetKinds(tracked)
    }

    private static func trackedWidgetKinds() -> Set<String> {
        let values = UserDefaults.standard.stringArray(forKey: trackedKindsKey) ?? []
        return Set(values)
    }

    private static func saveTrackedWidgetKinds(_ kinds: Set<String>) {
        UserDefaults.standard.set(Array(kinds), forKey: trackedKindsKey)
    }
}
