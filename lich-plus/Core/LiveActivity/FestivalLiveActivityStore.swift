//
//  FestivalLiveActivityStore.swift
//  lich-plus
//
//  User preference for auto-starting the festival Live Activity.
//

import Foundation
import Combine

@MainActor
final class FestivalLiveActivityStore: ObservableObject {
    static let shared = FestivalLiveActivityStore()

    @Published private(set) var autoStartEnabled: Bool

    private init() {
        let stored = UserDefaults.standard.object(forKey: FestivalLiveActivityConstants.autoStartEnabledKey) as? Bool
        autoStartEnabled = stored ?? true
        mirrorToAppGroup()
    }

    func setAutoStartEnabled(_ enabled: Bool) {
        guard enabled != autoStartEnabled else { return }
        autoStartEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: FestivalLiveActivityConstants.autoStartEnabledKey)
        mirrorToAppGroup()
    }

    private func mirrorToAppGroup() {
        WidgetAppGroup.sharedDefaults?.set(autoStartEnabled, forKey: WidgetAppGroup.liveActivityAutoStartKey)
    }
}
