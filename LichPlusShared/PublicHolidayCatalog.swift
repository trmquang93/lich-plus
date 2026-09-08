//
//  PublicHolidayCatalog.swift
//  LichPlusShared
//
//  Static public lunar festivals and helpers for widget chips / next-holiday labels.
//  Only named public holidays — never user events or giỗ.
//

import Foundation

struct PublicHolidayOccurrence: Equatable, Sendable {
    let title: String
    let solarDate: Date
}

enum PublicHolidayCatalog {
    /// Traditional lunar festivals shown on widgets when they fall on a given day.
    static let lunarFestivals: [(month: Int, day: Int, title: String)] = [
        (1, 1, String(localized: "Tet Holiday")),
        (1, 15, String(localized: "Lantern Festival")),
        (3, 3, String(localized: "Cold Food Festival")),
        (5, 5, String(localized: "Doan Ngo Festival")),
        (7, 15, String(localized: "Vu Lan Festival")),
        (8, 15, String(localized: "Mid-Autumn Festival")),
        (10, 10, String(localized: "Thuong Tan Festival")),
    ]

    static func specialChips(
        lunarDay: Int,
        lunarMonth: Int
    ) -> [String] {
        var chips: [String] = []

        if lunarDay == 1 {
            chips.append(String(localized: "Mùng 1"))
        }
        if lunarDay == 15 {
            chips.append(String(localized: "Ngày Rằm"))
        }

        for festival in lunarFestivals where festival.month == lunarMonth && festival.day == lunarDay {
            chips.append(festival.title)
        }

        return chips
    }

    /// Finds the soonest named public lunar festival on or after `referenceDate`.
    static func nextLunarFestival(
        from referenceDate: Date,
        currentLunarYear: Int,
        lunarToSolar: (Int, Int, Int) -> Date,
        calendar: Calendar = .current
    ) -> PublicHolidayOccurrence? {
        let startOfReference = calendar.startOfDay(for: referenceDate)
        var candidates: [PublicHolidayOccurrence] = []

        for yearOffset in 0...1 {
            let lunarYear = currentLunarYear + yearOffset
            for festival in lunarFestivals {
                let solarDate = calendar.startOfDay(
                    for: lunarToSolar(festival.day, festival.month, lunarYear)
                )
                if solarDate >= startOfReference {
                    candidates.append(PublicHolidayOccurrence(title: festival.title, solarDate: solarDate))
                }
            }
        }

        return candidates.min { $0.solarDate < $1.solarDate }
    }

    static func pickSoonest(
        _ first: PublicHolidayOccurrence?,
        _ second: PublicHolidayOccurrence?
    ) -> PublicHolidayOccurrence? {
        switch (first, second) {
        case (nil, nil):
            return nil
        case (let value?, nil):
            return value
        case (nil, let value?):
            return value
        case (let left?, let right?):
            return left.solarDate <= right.solarDate ? left : right
        }
    }

    static func daysUntil(
        from referenceDate: Date,
        to targetDate: Date,
        calendar: Calendar = .current
    ) -> Int {
        let start = calendar.startOfDay(for: referenceDate)
        let end = calendar.startOfDay(for: targetDate)
        return calendar.dateComponents([.day], from: start, to: end).day ?? 0
    }
}
