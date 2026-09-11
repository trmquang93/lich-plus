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
    @Published private(set) var userDismissedFestivalId: String?

    private init() {
        let stored = UserDefaults.standard.object(forKey: FestivalLiveActivityConstants.autoStartEnabledKey) as? Bool
        autoStartEnabled = stored ?? true
        userDismissedFestivalId = UserDefaults.standard.string(
            forKey: FestivalLiveActivityConstants.userDismissedFestivalIdKey
        )
        mirrorToAppGroup()
    }

    func setAutoStartEnabled(_ enabled: Bool) {
        guard enabled != autoStartEnabled else { return }
        autoStartEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: FestivalLiveActivityConstants.autoStartEnabledKey)
        if enabled {
            clearDismissedFestival()
        }
        mirrorToAppGroup()
    }

    func dismissFestival(id: String) {
        guard userDismissedFestivalId != id else { return }
        userDismissedFestivalId = id
        UserDefaults.standard.set(id, forKey: FestivalLiveActivityConstants.userDismissedFestivalIdKey)
        mirrorToAppGroup()
    }

    func clearDismissedFestival() {
        guard userDismissedFestivalId != nil else { return }
        userDismissedFestivalId = nil
        UserDefaults.standard.removeObject(forKey: FestivalLiveActivityConstants.userDismissedFestivalIdKey)
        mirrorToAppGroup()
    }

    func isAutoStartBlocked(for festivalId: String) -> Bool {
        userDismissedFestivalId == festivalId
    }

    private func mirrorToAppGroup() {
        let defaults = WidgetAppGroup.sharedDefaults
        defaults?.set(autoStartEnabled, forKey: WidgetAppGroup.liveActivityAutoStartKey)
        if let userDismissedFestivalId {
            defaults?.set(userDismissedFestivalId, forKey: WidgetAppGroup.liveActivityDismissedFestivalIdKey)
        } else {
            defaults?.removeObject(forKey: WidgetAppGroup.liveActivityDismissedFestivalIdKey)
        }
    }
}
