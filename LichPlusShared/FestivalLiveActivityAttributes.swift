//
//  FestivalLiveActivityAttributes.swift
//  LichPlusShared
//
//  Privacy-safe ActivityKit attributes for public festival countdown.
//  Only catalog holiday titles and dates — never user events or giỗ.
//

import ActivityKit
import Foundation

struct FestivalLiveActivityAttributes: ActivityAttributes {
    /// Dynamic state updated as the countdown changes.
    struct ContentState: Codable, Hashable {
        /// Public catalog festival title (e.g. "Tet Holiday").
        var festivalTitle: String
        /// Whole days until the festival solar date.
        var daysUntil: Int
        /// Localized solar date label for display.
        var solarDateLabel: String
        /// App language code (`en` / `vi`) for widget strings.
        var localeCode: String
        /// True when the festival is lunar 1/1 (Tết).
        var isTet: Bool
    }

    /// Stable festival identifier from the public catalog (e.g. `1-1`).
    var festivalId: String
}
