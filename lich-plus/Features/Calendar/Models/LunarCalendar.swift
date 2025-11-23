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
    /// Determine if a date is a good or bad day using Vietnamese astrology
    /// Uses the 12 Zodiac Hours (12 Kiến Trừ) system based on lunar calendar
    /// - Parameter date: Solar date to evaluate
    /// - Returns: DayType (good/bad/neutral) based on the zodiac hour
    static func determineDayType(for date: Date) -> DayType {
        // Use the HoangDaoCalculator to determine day type based on lunar calendar
        return HoangDaoCalculator.determineDayType(for: date)
    }

    /// Get lucky hours for a specific date
    /// Returns the auspicious hours (Giờ Hoàng Đạo) for the day
    /// Each hour represents a 2-hour period in traditional Vietnamese timekeeping
    /// - Parameter date: Solar date
    /// - Returns: Array of LuckyHour with auspicious times and activities
    static func getLuckyHours(for date: Date) -> [LuckyHour] {
        // Get the auspicious hours from the HoangDaoCalculator
        let auspiciousHours = HoangDaoCalculator.getAuspiciousHoursOnly(for: date)

        // Convert HourlyZodiac to LuckyHour format
        return auspiciousHours.map { hourlyZodiac in
            LuckyHour(
                startTime: formatHourStart(hourlyZodiac.hour),
                endTime: formatHourEnd(hourlyZodiac.hour),
                luckyActivities: hourlyZodiac.suitableActivities
            )
        }
    }

    // MARK: - Helper Functions

    /// Format the start time of a 2-hour period
    /// - Parameter hour: Hour index (0-11)
    /// - Returns: Formatted time string (e.g., "23:00", "01:00")
    private static func formatHourStart(_ hour: Int) -> String {
        let chi = ChiEnum(rawValue: hour) ?? .ty
        let range = chi.hourRange

        if chi == .ty {
            return "23:00"
        }

        return String(format: "%02d:00", range.start)
    }

    /// Format the end time of a 2-hour period
    /// - Parameter hour: Hour index (0-11)
    /// - Returns: Formatted time string (e.g., "01:00", "03:00")
    private static func formatHourEnd(_ hour: Int) -> String {
        let chi = ChiEnum(rawValue: hour) ?? .ty
        let range = chi.hourRange

        if chi == .ty {
            return "01:00"
        }

        return String(format: "%02d:00", range.end)
    }
}
