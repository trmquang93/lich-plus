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
}
