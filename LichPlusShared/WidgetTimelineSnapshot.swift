//
//  WidgetTimelineSnapshot.swift
//  LichPlusShared
//
//  Privacy-safe widget payload. Never include private event titles, giỗ names, or văn khấn text.
//

import Foundation

/// A single day's public calendar facts for widget rendering.
struct WidgetDayEntry: Codable, Equatable, Sendable {
    let date: Date
    let solarDay: Int
    let solarMonth: Int
    let solarYear: Int
    let lunarDay: Int
    let lunarMonth: Int
    let lunarYear: Int
    let dayCanChi: String
    /// Public chips only — e.g. Mùng 1, Rằm, Tết Nguyên Đán, national holidays.
    let specialChips: [String]
    let nextHolidayTitle: String?
    let nextHolidayDate: Date?
    let nextHolidayDaysUntil: Int?
}

/// Precomputed multi-day snapshot written by the main app, read by the widget extension.
struct WidgetTimelineSnapshot: Codable, Equatable, Sendable {
    let generatedAt: Date
    let localeCode: String
    let days: [WidgetDayEntry]

    func entry(for date: Date, calendar: Calendar = .current) -> WidgetDayEntry? {
        let target = calendar.startOfDay(for: date)
        return days.first { calendar.isDate($0.date, inSameDayAs: target) }
    }

    func entryOrFirst(for date: Date, calendar: Calendar = .current) -> WidgetDayEntry? {
        entry(for: date, calendar: calendar) ?? days.first
    }
}
