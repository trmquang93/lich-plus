//
//  LunarCalendar.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 23/11/25.
//

import Foundation
import VietnameseLunar

// MARK: - Leap Month Information

/// Information about leap months in a lunar year
public struct LeapMonthInfo {
    /// Whether the lunar year has a leap month
    public let hasLeapMonth: Bool

    /// Which month is the leap month (1-12), or nil if no leap month
    public let leapMonth: Int?

    /// The lunar year being analyzed
    public let lunarYear: Int

    public init(hasLeapMonth: Bool, leapMonth: Int?, lunarYear: Int) {
        self.hasLeapMonth = hasLeapMonth
        self.leapMonth = leapMonth
        self.lunarYear = lunarYear
    }
}

// MARK: - Lunar Calendar Converter

struct LunarCalendar {
    // Real Vietnamese lunar calendar using the VietnameseLunar library
    // Based on Hồ Ngọc Đức's algorithm - the gold standard for Vietnamese lunar calendar

    // MARK: - Performance Caching

    /// Cache for lunar-to-solar conversions: (day, month, year) -> (day, month, year)
    private static var lunarToSolarCache: [String: (day: Int, month: Int, year: Int)] = [:]

    /// Cache for leap month information: solarYear -> LeapMonthInfo
    private static var leapMonthCache: [Int: LeapMonthInfo] = [:]

    /// Maximum cache size before clearing (to prevent unbounded growth)
    private static let maxCacheSize = 1000

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

    /// Convert lunar date to solar date with leap month support
    /// - Parameters:
    ///   - day: Lunar day (1-30)
    ///   - month: Lunar month (1-12)
    ///   - year: Lunar year
    ///   - isLeapMonth: Whether this is the leap occurrence of the month
    /// - Returns: Solar date, or the best match if the exact leap month is not found
    static func lunarToSolar(day: Int, month: Int, year: Int, isLeapMonth: Bool) -> Date {
        if !isLeapMonth {
            // Use the existing conversion for non-leap months
            return lunarToSolar(day: day, month: month, year: year)
        }

        // For leap months, find the leap month occurrence
        // Convert lunar year to solar year for leap month detection
        let approxSolarDate = lunarToSolar(day: 1, month: 1, year: year)
        let solarYear = Calendar.current.component(.year, from: approxSolarDate)
        let leapInfo = getLeapMonthInfo(forSolarYear: solarYear)

        guard leapInfo.hasLeapMonth, let leapMonth = leapInfo.leapMonth, leapMonth == month else {
            // If the requested leap month doesn't exist, fall back to regular conversion
            return lunarToSolar(day: day, month: month, year: year)
        }

        // Search for dates in the leap month
        // Start from January 1 of the given lunar year and search
        var testDate = Calendar.current.date(from: DateComponents(year: year, month: 1, day: 1)) ?? Date()

        var foundDates: [Date] = []

        for _ in 0..<365 {
            let lunar = solarToLunarWithLeap(testDate)

            if lunar.day == day && lunar.month == month && lunar.year == year && lunar.isLeap {
                foundDates.append(testDate)
                if foundDates.count > 1 {
                    break
                }
            }

            testDate = Calendar.current.date(byAdding: .day, value: 1, to: testDate) ?? testDate
        }

        // Return the found leap month date, or fall back to regular conversion
        return foundDates.first ?? lunarToSolar(day: day, month: month, year: year)
    }

    /// Convert solar date to lunar date with leap month detection
    /// - Parameter date: Solar date to convert
    /// - Returns: Tuple with (day, month, year, isLeapMonth)
    static func solarToLunarWithLeap(_ date: Date) -> (day: Int, month: Int, year: Int, isLeap: Bool) {
        // Get the basic lunar date
        let basicLunar = solarToLunar(date)

        // Detect if this date is in a leap month
        let isLeap = detectLeapMonth(day: basicLunar.day, month: basicLunar.month, year: basicLunar.year)

        return (day: basicLunar.day, month: basicLunar.month, year: basicLunar.year, isLeap: isLeap)
    }

    /// Get leap month information for a solar year
    /// - Parameter forSolarYear: The solar year to check
    /// - Returns: LeapMonthInfo struct with leap month details
    static func getLeapMonthInfo(forSolarYear solarYear: Int) -> LeapMonthInfo {
        // Check cache first
        if let cached = leapMonthCache[solarYear] {
            return cached
        }

        // Clear cache if it gets too large
        if leapMonthCache.count > maxCacheSize {
            leapMonthCache.removeAll()
        }

        // Strategy: Check all lunar years that span this solar year
        // and return leap month info for the lunar year with the leap month

        var leapMonthsByLunarYear: [Int: Int] = [:]  // lunarYear -> leapMonth

        // Scan through the solar year and surrounding dates to find all lunar years
        let calendar = Calendar.current
        var currentDate = calendar.date(from: DateComponents(year: solarYear - 1, month: 1, day: 1)) ?? Date()

        // Track month occurrences per lunar year
        var monthCountsByLunarYear: [Int: [Int: Int]] = [:]  // lunarYear -> (month -> count)

        for _ in 0..<730 {  // Scan about 2 years worth of dates
            let lunar = solarToLunar(currentDate)

            // Initialize tracking for this lunar year if needed
            if monthCountsByLunarYear[lunar.year] == nil {
                monthCountsByLunarYear[lunar.year] = [:]
            }

            // Count this month
            monthCountsByLunarYear[lunar.year]?[lunar.month, default: 0] += 1

            // Check if we found a month that appears twice
            if let count = monthCountsByLunarYear[lunar.year]?[lunar.month], count == 2 {
                leapMonthsByLunarYear[lunar.year] = lunar.month
            }

            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }

        // Find which lunar year appears in this solar year and has a leap month
        let targetSolarDate = calendar.date(from: DateComponents(year: solarYear, month: 6, day: 15)) ?? Date()
        let targetLunarDate = solarToLunar(targetSolarDate)

        // If the target lunar year has a leap month, return it
        if let leapMonth = leapMonthsByLunarYear[targetLunarDate.year] {
            let result = LeapMonthInfo(
                hasLeapMonth: true,
                leapMonth: leapMonth,
                lunarYear: targetLunarDate.year
            )
            leapMonthCache[solarYear] = result
            return result
        }

        // Otherwise, check nearby lunar years
        for year in [targetLunarDate.year - 1, targetLunarDate.year, targetLunarDate.year + 1] {
            if let leapMonth = leapMonthsByLunarYear[year] {
                let result = LeapMonthInfo(
                    hasLeapMonth: true,
                    leapMonth: leapMonth,
                    lunarYear: year
                )
                leapMonthCache[solarYear] = result
                return result
            }
        }

        // No leap month found
        let result = LeapMonthInfo(
            hasLeapMonth: false,
            leapMonth: nil,
            lunarYear: targetLunarDate.year
        )
        leapMonthCache[solarYear] = result
        return result
    }

    // MARK: - Private Leap Month Detection

    /// Detect if a given lunar date falls in a leap month
    /// Uses heuristic: checks if adjacent days have the same month number
    private static func detectLeapMonth(day: Int, month: Int, year: Int) -> Bool {
        let calendar = Calendar.current

        // Convert this lunar date to solar to get a reference point
        let testSolarDate = lunarToSolar(day: day, month: month, year: year)

        // Get lunar dates for nearby dates (check backward and forward)
        let prevDate = calendar.date(byAdding: .day, value: -30, to: testSolarDate) ?? testSolarDate
        let nextDate = calendar.date(byAdding: .day, value: 30, to: testSolarDate) ?? testSolarDate

        let prevLunar = solarToLunar(prevDate)
        let nextLunar = solarToLunar(nextDate)

        // Check if the previous month (30 days back) has the SAME lunar month number
        let prevHasSameMonth = prevLunar.month == month && prevLunar.year == year

        // Check if the next month (30 days forward) has a DIFFERENT lunar month number
        let nextHasDifferentMonth = nextLunar.month != month || nextLunar.year != year

        // If previous check shows same month and next shows different, this is likely a leap month
        if prevHasSameMonth && nextHasDifferentMonth {
            return true
        }

        // Alternative check: see if 35 days forward still shows the same month
        // (leap months typically span about 29-30 days)
        let later = calendar.date(byAdding: .day, value: 35, to: testSolarDate) ?? testSolarDate
        let laterLunar = solarToLunar(later)

        // If 35 days forward we're in a different month, this could be leap
        if laterLunar.month != month || laterLunar.year != year {
            // Verify by checking if the month appears twice in the year
            // Convert lunar year to solar year for leap month detection
            let approxSolarDate = lunarToSolar(day: 1, month: 1, year: year)
            let solarYear = calendar.component(.year, from: approxSolarDate)
            let leapInfo = getLeapMonthInfo(forSolarYear: solarYear)
            if leapInfo.hasLeapMonth && leapInfo.leapMonth == month {
                return true
            }
        }

        return false
    }

    // MARK: - Private Conversion Methods

    /// Convert lunar date to solar date using brute force search with caching
    /// Since VietnameseLunar doesn't directly support lunar-to-solar conversion,
    /// we search through dates until we find the matching lunar date
    private static func convertLunarToSolar(lunarDay: Int, lunarMonth: Int, lunarYear: Int) -> (day: Int, month: Int, year: Int) {
        // Check cache first
        let cacheKey = "\(lunarDay)-\(lunarMonth)-\(lunarYear)"
        if let cached = lunarToSolarCache[cacheKey] {
            return cached
        }

        // Clear cache if it gets too large
        if lunarToSolarCache.count > maxCacheSize {
            lunarToSolarCache.removeAll()
        }

        let calendar = Calendar.current

        // Start from January 1st of the lunar year
        var testDate = calendar.date(from: DateComponents(year: lunarYear, month: 1, day: 1)) ?? Date()

        // Search forward through 425 days to cover lunar dates that fall in the next solar year
        // Lunar months 11-12 often fall in January/February of the following solar year
        // (e.g., lunar 11/20/2025 = solar January 8, 2026)
        for _ in 0..<425 {
            let lunar = solarToLunar(testDate)
            if lunar.day == lunarDay && lunar.month == lunarMonth && lunar.year == lunarYear {
                let components = calendar.dateComponents([.year, .month, .day], from: testDate)
                let result = (day: components.day ?? 1, month: components.month ?? 1, year: components.year ?? lunarYear)
                lunarToSolarCache[cacheKey] = result
                return result
            }
            testDate = calendar.date(byAdding: .day, value: 1, to: testDate) ?? testDate
        }

        // If still not found, try searching from next year (for edge cases)
        testDate = calendar.date(from: DateComponents(year: lunarYear + 1, month: 1, day: 1)) ?? Date()
        for _ in 0..<60 {
            let lunar = solarToLunar(testDate)
            if lunar.day == lunarDay && lunar.month == lunarMonth && lunar.year == lunarYear {
                let components = calendar.dateComponents([.year, .month, .day], from: testDate)
                let result = (day: components.day ?? 1, month: components.month ?? 1, year: components.year ?? lunarYear)
                lunarToSolarCache[cacheKey] = result
                return result
            }
            testDate = calendar.date(byAdding: .day, value: 1, to: testDate) ?? testDate
        }

        // Fallback: Return an estimated solar date instead of treating lunar as solar
        // Lunar new year typically falls in late January/early February
        // So lunar month N roughly maps to solar month N+1 (with year adjustment for late months)
        let estimatedSolarMonth = lunarMonth < 11 ? lunarMonth + 1 : (lunarMonth == 11 ? 12 : 1)
        let estimatedSolarYear = lunarMonth >= 11 ? lunarYear + 1 : lunarYear
        let fallback = (day: min(lunarDay, 28), month: estimatedSolarMonth, year: estimatedSolarYear)
        lunarToSolarCache[cacheKey] = fallback
        return fallback
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
            // Get Chi name from the hour index
            let chi = ChiEnum(rawValue: hourlyZodiac.hour) ?? .ty

            return LuckyHour(
                chiName: chi.vietnameseName,
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
