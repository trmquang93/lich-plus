//
//  LunarCalendar.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 23/11/25.
//

import Foundation

// MARK: - Lunar Calendar Converter

struct LunarCalendar {
    // Based on the Vietnamese lunar calendar algorithm
    // Reference: Traditional Vietnamese calendar calculations

    /// Convert solar date to lunar date
    /// - Parameter date: Solar date to convert
    /// - Returns: Tuple of (lunarDay, lunarMonth, lunarYear)
    static func solarToLunar(_ date: Date) -> (day: Int, month: Int, year: Int) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)

        guard let solarDay = components.day,
              let solarMonth = components.month,
              let solarYear = components.year else {
            return (1, 1, 2025)
        }

        return convertSolarToLunar(solarDay: solarDay, solarMonth: solarMonth, solarYear: solarYear)
    }

    /// Convert lunar date to solar date
    /// - Parameter lunarDay: Day of lunar month
    /// - Parameter lunarMonth: Lunar month
    /// - Parameter lunarYear: Lunar year
    /// - Returns: Solar date
    static func lunarToSolar(day: Int, month: Int, year: Int) -> Date {
        let components = convertLunarToSolar(lunarDay: day, lunarMonth: month, lunarYear: year)

        var dateComponents = DateComponents()
        dateComponents.year = components.year
        dateComponents.month = components.month
        dateComponents.day = components.day

        return Calendar.current.date(from: dateComponents) ?? Date()
    }

    // MARK: - Private Conversion Methods

    private static func convertSolarToLunar(solarDay: Int, solarMonth: Int, solarYear: Int) -> (day: Int, month: Int, year: Int) {
        // Algorithm based on traditional Vietnamese lunar calendar
        // This is a simplified implementation for demonstration

        // Days from epoch to solar date
        let jd = jdnFromSolar(day: solarDay, month: solarMonth, year: solarYear)

        // Calculate lunar date
        let a = jd + 1
        let b = Double(a - 1948440) + 10632.0 / 30.6001
        let c = Int(b) % 10631

        let d = c / 5957
        let year = d + 11
        let month = (c % 5957) / 29 + 1
        let day = (c % 5957) % 29 + 1

        return (day: day, month: month, year: year)
    }

    private static func convertLunarToSolar(lunarDay: Int, lunarMonth: Int, lunarYear: Int) -> (day: Int, month: Int, year: Int) {
        // Simplified inverse calculation
        let offset = (lunarYear - 11) * 354 + (lunarMonth - 1) * 29 + lunarDay
        let jd = 1948440 - 10632 + Int(Double(offset) * 30.6001)

        return jdnToSolar(jdn: jd)
    }

    // MARK: - Julian Day Number Conversion

    private static func jdnFromSolar(day: Int, month: Int, year: Int) -> Int {
        let a = (14 - month) / 12
        let y = year + 4800 - a
        let m = month + 12 * a - 3

        let jdn = day + (153 * m + 2) / 5 + 365 * y + y / 4 - y / 100 + y / 400 - 32045

        return jdn
    }

    private static func jdnToSolar(jdn: Int) -> (day: Int, month: Int, year: Int) {
        let f = jdn + 1401 + (((4 * jdn + 274277) / 146097) * 3) / 4 - 38
        let e = 4 * f + 3
        let g = (e % 1461) / 4
        let h = 5 * g + 2

        let day = (h % 153) / 5 + 1
        let month = ((h / 153 + 2) % 12) + 1
        let year = (e / 1461) - 4716 + ((12 + 2 - month) / 12)

        return (day: day, month: month, year: year)
    }
}

// MARK: - Day Type Determiner

struct DayTypeCalculator {
    /// Determine if a date is a good or bad day (simplified version)
    /// In production, this would load from a database or external source
    static func determineDayType(for date: Date) -> DayType {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .month], from: date)

        guard let day = components.day, let month = components.month else {
            return .neutral
        }

        // Simplified algorithm - in production, use a comprehensive database
        // This is just a demo calculation based on lunar calendar patterns

        let dayTypeIndex = (day + month) % 3

        switch dayTypeIndex {
        case 0:
            return .good
        case 1:
            return .bad
        default:
            return .neutral
        }
    }

    /// Get lucky hours for a specific date
    static func getLuckyHours(for date: Date) -> [LuckyHour] {
        // Mock data - in production, load from database based on lunar calendar
        return [
            LuckyHour(
                startTime: "05:00",
                endTime: "07:00",
                luckyActivities: ["Bắt đầu công việc", "Khởi động dự án"]
            ),
            LuckyHour(
                startTime: "09:00",
                endTime: "11:00",
                luckyActivities: ["Làm việc quan trọng", "Gặp khách hàng"]
            ),
            LuckyHour(
                startTime: "13:00",
                endTime: "15:00",
                luckyActivities: ["Quyết định lớn", "Ký hợp đồng"]
            ),
            LuckyHour(
                startTime: "19:00",
                endTime: "21:00",
                luckyActivities: ["Gặp gỡ xã hội", "Ăn uống"]
            ),
        ]
    }
}
