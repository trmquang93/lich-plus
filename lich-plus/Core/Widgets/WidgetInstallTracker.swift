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
        guard let configurations = await currentWidgetConfigurations() else {
            return
        }

        let installedTodayKinds = configurations
            .filter { $0.kind == TodayWidgetConstants.kind }
            .map(\.family.description)

        let installedCountdownKinds = configurations
            .filter { $0.kind == CountdownWidgetConstants.kind }
            .map(\.family.description)

        guard !installedTodayKinds.isEmpty || !installedCountdownKinds.isEmpty else { return }

        var tracked = trackedWidgetKinds()
        for family in installedTodayKinds {
            let token = "today:\(family)"
            guard !tracked.contains(token) else { continue }
            AnalyticsService.shared.logWidgetInstall(kind: "today")
            tracked.insert(token)
        }
        for family in installedCountdownKinds {
            let token = "countdown:\(family)"
            guard !tracked.contains(token) else { continue }
            AnalyticsService.shared.logWidgetInstall(kind: "countdown")
            tracked.insert(token)
        }
        saveTrackedWidgetKinds(tracked)
    }

    /// `currentConfigurations()` is iOS 18+; WidgetKit on 17 still uses the completion-handler API.
    private static func currentWidgetConfigurations() async -> [WidgetInfo]? {
        if #available(iOS 18.0, *) {
            return try? await WidgetCenter.shared.currentConfigurations()
        }
        return await withCheckedContinuation { continuation in
            WidgetCenter.shared.getCurrentConfigurations { result in
                switch result {
                case .success(let configurations):
                    continuation.resume(returning: configurations)
                case .failure:
                    continuation.resume(returning: nil)
                }
            }
        }
    }

    private static func trackedWidgetKinds() -> Set<String> {
        let values = UserDefaults.standard.stringArray(forKey: trackedKindsKey) ?? []
        return Set(values)
    }

    private static func saveTrackedWidgetKinds(_ kinds: Set<String>) {
        UserDefaults.standard.set(Array(kinds), forKey: trackedKindsKey)
    }
}
