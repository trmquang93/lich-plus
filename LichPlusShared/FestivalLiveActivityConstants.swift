//
//  FestivalLiveActivityConstants.swift
//  LichPlusShared
//
//  Shared constants for the public-holiday Live Activity window.
//

import Foundation

enum FestivalLiveActivityConstants {
    /// ActivityKit activity type identifier (must match the widget extension).
    static let activityType = "FestivalCountdownLiveActivity"

    /// Auto-start the Live Activity when the next public festival is within this many days.
    static let autoStartDaysBefore = 45

    /// UserDefaults / App Group key for the auto-start preference.
    static let autoStartEnabledKey = "festival_live_activity_auto_start_v1"
}
