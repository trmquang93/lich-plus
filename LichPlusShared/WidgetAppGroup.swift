//
//  WidgetAppGroup.swift
//  LichPlusShared
//
//  Shared App Group identifiers for the main app and widget extension.
//

import Foundation

enum WidgetAppGroup {
    /// App Group used to share privacy-safe widget snapshots between targets.
    /// Quang must enable this identifier in Xcode Signing & Capabilities and in App Store Connect.
    static let identifier = "group.com.qtran.lich-plus"

    static let snapshotKey = "widget_timeline_snapshot_v1"
    static let languageKey = "app_language"

    static var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: identifier)
    }
}
