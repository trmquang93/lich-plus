//
//  LunarCalendar.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 23/11/25.
//

import Foundation
import VietnameseLunar

// MARK: - Lunar Calendar Converter

struct LunarCalendar {
    // Real Vietnamese lunar calendar using the VietnameseLunar library
    // Based on Hồ Ngọc Đức's algorithm - the gold standard for Vietnamese lunar calendar

    /// Convert solar date to lunar date
    /// - Parameter date: Solar date to convert
    /// - Returns: Tuple of (lunarDay, lunarMonth, lunarYear)
    static func solarToLunar(_ date: Date) -> (day: Int, month: Int, year: Int) {
        let vietnameseCalendar = VietnameseCalendar(date: date)
        guard let lunarDate = vietnameseCalendar.vietnameseDate else {
            return (1, 1, 2025)
        }

        // Convert year from String to Int
        let year = Int(lunarDate.year) ?? 2025

        return (day: lunarDate.day, month: lunarDate.month, year: year)
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

    /// Convert lunar date to solar date using brute force search
    /// Since VietnameseLunar doesn't directly support lunar-to-solar conversion,
    /// we search through dates until we find the matching lunar date
    private static func convertLunarToSolar(lunarDay: Int, lunarMonth: Int, lunarYear: Int) -> (day: Int, month: Int, year: Int) {
        // Start from January 1st of the lunar year
        var testDate = Calendar.current.date(from: DateComponents(year: lunarYear, month: 1, day: 1)) ?? Date()

        // Search forward through the year for a match
        for _ in 0..<365 {
            let lunar = solarToLunar(testDate)
            if lunar.day == lunarDay && lunar.month == lunarMonth && lunar.year == lunarYear {
                let components = Calendar.current.dateComponents([.year, .month, .day], from: testDate)
                return (day: components.day ?? 1, month: components.month ?? 1, year: components.year ?? lunarYear)
            }

            // Move to next day
            testDate = Calendar.current.date(byAdding: .day, value: 1, to: testDate) ?? testDate
        }

        // Fallback if not found
        return (day: lunarDay, month: lunarMonth, year: lunarYear)
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
