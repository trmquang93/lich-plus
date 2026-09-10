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
    /// Compact giờ hoàng đạo labels, e.g. "Mão (5-7), Tỵ (9-11)" — public calendar facts only.
    let luckyHourSummary: String?
    /// Compact hours to avoid, e.g. "Tý (23-1), Ngọ (11-13)".
    let avoidHourSummary: String?
    /// Public auspicious travel direction, e.g. "Đông Nam" — no private data.
    let auspiciousDirection: String?

    init(
        date: Date,
        solarDay: Int,
        solarMonth: Int,
        solarYear: Int,
        lunarDay: Int,
        lunarMonth: Int,
        lunarYear: Int,
        dayCanChi: String,
        specialChips: [String],
        nextHolidayTitle: String?,
        nextHolidayDate: Date?,
        nextHolidayDaysUntil: Int?,
        luckyHourSummary: String? = nil,
        avoidHourSummary: String? = nil,
        auspiciousDirection: String? = nil
    ) {
        self.date = date
        self.solarDay = solarDay
        self.solarMonth = solarMonth
        self.solarYear = solarYear
        self.lunarDay = lunarDay
        self.lunarMonth = lunarMonth
        self.lunarYear = lunarYear
        self.dayCanChi = dayCanChi
        self.specialChips = specialChips
        self.nextHolidayTitle = nextHolidayTitle
        self.nextHolidayDate = nextHolidayDate
        self.nextHolidayDaysUntil = nextHolidayDaysUntil
        self.luckyHourSummary = luckyHourSummary
        self.avoidHourSummary = avoidHourSummary
        self.auspiciousDirection = auspiciousDirection
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        date = try container.decode(Date.self, forKey: .date)
        solarDay = try container.decode(Int.self, forKey: .solarDay)
        solarMonth = try container.decode(Int.self, forKey: .solarMonth)
        solarYear = try container.decode(Int.self, forKey: .solarYear)
        lunarDay = try container.decode(Int.self, forKey: .lunarDay)
        lunarMonth = try container.decode(Int.self, forKey: .lunarMonth)
        lunarYear = try container.decode(Int.self, forKey: .lunarYear)
        dayCanChi = try container.decode(String.self, forKey: .dayCanChi)
        specialChips = try container.decode([String].self, forKey: .specialChips)
        nextHolidayTitle = try container.decodeIfPresent(String.self, forKey: .nextHolidayTitle)
        nextHolidayDate = try container.decodeIfPresent(Date.self, forKey: .nextHolidayDate)
        nextHolidayDaysUntil = try container.decodeIfPresent(Int.self, forKey: .nextHolidayDaysUntil)
        luckyHourSummary = try container.decodeIfPresent(String.self, forKey: .luckyHourSummary)
        avoidHourSummary = try container.decodeIfPresent(String.self, forKey: .avoidHourSummary)
        auspiciousDirection = try container.decodeIfPresent(String.self, forKey: .auspiciousDirection)
    }
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
