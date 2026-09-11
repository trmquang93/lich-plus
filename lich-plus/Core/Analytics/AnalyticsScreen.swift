//
//  AnalyticsScreen.swift
//  lich-plus
//
//  Product-surface screen identifiers for privacy-safe analytics.
//  See docs/ANALYTICS.md for the full taxonomy.
//

import Foundation

/// Allowed `screen_name` values. Never pass user-entered or calendar content here.
enum AnalyticsScreen: String, CaseIterable, Sendable {
    case calendar
    case timeline
    case customs
    case settings
    case notification_settings
    case calendar_sync_settings
    case google_calendar_settings
    case microsoft_calendar_settings
    case ics_calendar_settings
    case lunar_special_dates_settings
    case language_settings
    case personal_profile
    case van_khan
    case greetings
    case day_detail
    case phong_tuc_presets
    case kinh_dich
    case elder_mode_settings
    case festival_live_activity_settings
}
