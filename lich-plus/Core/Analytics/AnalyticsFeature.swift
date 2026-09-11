//
//  AnalyticsFeature.swift
//  lich-plus
//
//  Feature identifiers for privacy-safe `feature_used` events.
//  See docs/ANALYTICS.md for the full taxonomy.
//

import Foundation

/// Allowed `feature_id` values. Opaque product identifiers only — no user content.
enum AnalyticsFeature: String, CaseIterable, Sendable {
    case google_calendar_connect
    case microsoft_calendar_connect
    case apple_calendar_sync
    case ics_calendar_subscribe
    case share_app
    case rate_app
    case greeting_generate
    case van_khan_export_pdf
    case xem_ngay
    case xuat_hanh
    case birth_year_setting
    case gio_reminder_preset
    case tet_countdown
    case live_activity_start
    case live_activity_end
    case xem_que
    case huong_xuat_hanh
    case elder_mode
}
