//
//  LunarSpecialDate.swift
//  lich-plus
//
//  Created by Claude Code
//

import Foundation

/// Defines a special lunar date that can be generated as calendar events
struct LunarSpecialDate {
    let id: String
    let title: String
    let lunarDay: Int
    let category: String  // "spiritual"
    let colorHex: String
    let enabledByDefault: Bool

    /// All supported lunar special dates
    static let allDates: [LunarSpecialDate] = [
        LunarSpecialDate(
            id: "lunar-mung1",
            title: String(localized: "Mùng 1"),
            lunarDay: 1,
            category: "spiritual",
            colorHex: "#9B59B6",  // Purple
            enabledByDefault: false
        ),
        LunarSpecialDate(
            id: "lunar-ram",
            title: String(localized: "Ngày Rằm"),
            lunarDay: 15,
            category: "spiritual",
            colorHex: "#D4AC0D",  // Gold
            enabledByDefault: false
        )
    ]

    /// Creates the lunar recurrence rule for this special date
    func createRecurrenceRule() -> SerializableLunarRecurrenceRule {
        SerializableLunarRecurrenceRule(
            frequency: .monthly,
            lunarDay: lunarDay,
            lunarMonth: nil,
            leapMonthBehavior: .includeLeap,
            interval: 1,
            recurrenceEnd: nil
        )
    }

    /// Lookup by ID
    static func forId(_ id: String) -> LunarSpecialDate? {
        allDates.first { $0.id == id }
    }
}
