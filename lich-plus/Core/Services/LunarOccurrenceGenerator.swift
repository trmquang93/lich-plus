//
//  LunarOccurrenceGenerator.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 07/12/25.
//

import Foundation

/// Generates occurrence dates for lunar calendar recurrence rules
///
/// This engine calculates all future solar dates that match a given lunar calendar
/// recurrence pattern, handling leap months and various recurrence parameters.
struct LunarOccurrenceGenerator {
    /// Shared date formatter for deduplication
    private static let iso8601Formatter = ISO8601DateFormatter()
    /// Generate occurrence dates for a lunar recurrence rule
    ///
    /// - Parameters:
    ///   - rule: The lunar recurrence rule defining the pattern
    ///   - masterStartDate: The original event's start date (used to infer lunar details)
    ///   - rangeStart: Start of the date range to generate occurrences
    ///   - rangeEnd: End of the date range to generate occurrences
    /// - Returns: Array of occurrence dates within the range, sorted chronologically
    static func generateOccurrences(
        rule: SerializableLunarRecurrenceRule,
        masterStartDate: Date,
        rangeStart: Date,
        rangeEnd: Date
    ) -> [Date] {
        // Get the master lunar date information
        let masterLunar = LunarCalendar.solarToLunar(masterStartDate)
        let targetLunarDay = rule.lunarDay

        // For yearly recurrence, use the specified month or the master's month
        // For monthly recurrence, targetLunarMonth is used differently
        let targetLunarMonth: Int?
        if rule.frequency == .yearly {
            targetLunarMonth = rule.lunarMonth ?? masterLunar.month
        } else {
            // For monthly, use the specified month (if any), but the actual processing
            // will iterate through all 12 months
            targetLunarMonth = rule.lunarMonth
        }

        // Get the master lunar year as starting point
        let masterLunarYear = masterLunar.year

        // Determine how many years to generate (use wide range to be safe)
        // Convert master lunar year to approximate solar year for calculation
        let masterSolarDate = LunarCalendar.lunarToSolar(day: 1, month: 1, year: masterLunarYear)
        let masterSolarYear = Calendar.current.component(.year, from: masterSolarDate)
        let endSolarYear = Calendar.current.component(.year, from: rangeEnd)
        let yearsToGenerate = (endSolarYear - masterSolarYear) + 5

        var allOccurrences: [Date] = []

        // Generate occurrences for each lunar year starting from master lunar year
        for yearOffset in 0..<yearsToGenerate {
            let lunarYear = masterLunarYear + yearOffset

            let monthsToProcess: [Int]
            if rule.frequency == .monthly {
                monthsToProcess = Array(1...12)
            } else {
                // Yearly recurrence - use the target month (which is not nil for yearly)
                monthsToProcess = [targetLunarMonth ?? masterLunar.month]
            }

            for month in monthsToProcess {
                // Generate occurrences for this lunar date
                let occurrencesForMonth = generateOccurrencesForMonth(
                    day: targetLunarDay,
                    month: month,
                    year: lunarYear,
                    leapMonthBehavior: rule.leapMonthBehavior
                )

                for occurrence in occurrencesForMonth {
                    // Check if this date already exists (using same-day comparison)
                    let isDuplicate = allOccurrences.contains { existing in
                        Calendar.current.isDate(existing, inSameDayAs: occurrence)
                    }
                    if !isDuplicate {
                        allOccurrences.append(occurrence)
                    }
                }
            }
        }

        // Sort occurrences
        let sortedOccurrences = allOccurrences.sorted()

        // Apply interval
        var filteredOccurrences = applyInterval(sortedOccurrences, interval: rule.interval)

        // Apply recurrence end
        if let recurrenceEnd = rule.recurrenceEnd {
            filteredOccurrences = applyRecurrenceEnd(filteredOccurrences, recurrenceEnd: recurrenceEnd)
        }

        // Filter by date range
        let finalOccurrences = filteredOccurrences.filter { $0 >= rangeStart && $0 <= rangeEnd }

        // Return sorted final occurrences
        return finalOccurrences.sorted()
    }

    // MARK: - Helper Methods

    /// Generate occurrences for a specific lunar month/year combination
    ///
    /// - Parameters:
    ///   - day: Lunar day (1-30)
    ///   - month: Lunar month (1-12)
    ///   - year: Lunar year
    ///   - leapMonthBehavior: How to handle leap months
    /// - Returns: Array of solar dates for the occurrences
    private static func generateOccurrencesForMonth(
        day: Int,
        month: Int,
        year: Int,
        leapMonthBehavior: LeapMonthBehavior
    ) -> [Date] {
        var occurrences: [Date] = []

        // Get leap month information for this year
        // Convert lunar year to solar year for leap month detection
        let approxSolarDate = LunarCalendar.lunarToSolar(day: 1, month: 1, year: year)
        let solarYear = Calendar.current.component(.year, from: approxSolarDate)
        let leapInfo = LunarCalendar.getLeapMonthInfo(forSolarYear: solarYear)

        // Check if this month is the leap month
        let isLeapMonth = leapInfo.hasLeapMonth && leapInfo.leapMonth == month

        if isLeapMonth {
            // Handle leap month based on behavior
            switch leapMonthBehavior {
            case .includeLeap:
                // Generate both regular and leap occurrences
                let regularDate = LunarCalendar.lunarToSolar(day: day, month: month, year: year, isLeapMonth: false)
                let leapDate = LunarCalendar.lunarToSolar(day: day, month: month, year: year, isLeapMonth: true)

                // Only add if they differ (to avoid duplicates)
                occurrences.append(regularDate)
                if leapDate != regularDate {
                    occurrences.append(leapDate)
                }

            case .skipLeap:
                // Only generate regular occurrence
                let regularDate = LunarCalendar.lunarToSolar(day: day, month: month, year: year, isLeapMonth: false)
                occurrences.append(regularDate)

            case .leapOnly:
                // Only generate leap occurrence
                let leapDate = LunarCalendar.lunarToSolar(day: day, month: month, year: year, isLeapMonth: true)
                occurrences.append(leapDate)
            }
        } else {
            // Regular month (not a leap month)
            let date = LunarCalendar.lunarToSolar(day: day, month: month, year: year, isLeapMonth: false)
            occurrences.append(date)
        }

        return occurrences
    }

    /// Apply interval to occurrences
    ///
    /// This filters occurrences to only include every Nth occurrence based on the interval.
    /// For example, interval = 2 means every 2nd occurrence.
    ///
    /// - Parameters:
    ///   - occurrences: The sorted list of occurrences
    ///   - interval: The interval value (1 = every occurrence, 2 = every 2nd, etc.)
    /// - Returns: Filtered occurrences respecting the interval
    private static func applyInterval(_ occurrences: [Date], interval: Int) -> [Date] {
        guard interval > 0 else { return occurrences }
        guard interval != 1 else { return occurrences }

        let sorted = occurrences.sorted()
        var result: [Date] = []

        for (index, occurrence) in sorted.enumerated() {
            if index % interval == 0 {
                result.append(occurrence)
            }
        }

        return result
    }

    /// Apply recurrence end rule to occurrences
    ///
    /// This filters occurrences based on the recurrence end condition
    /// (either by occurrence count or by end date).
    ///
    /// - Parameters:
    ///   - occurrences: The sorted list of occurrences
    ///   - recurrenceEnd: The recurrence end rule
    /// - Returns: Filtered occurrences respecting the recurrence end
    private static func applyRecurrenceEnd(
        _ occurrences: [Date],
        recurrenceEnd: SerializableRecurrenceEnd
    ) -> [Date] {
        switch recurrenceEnd {
        case .occurrenceCount(let count):
            // Limit to the specified number of occurrences
            return Array(occurrences.prefix(max(0, count)))

        case .endDate(let date):
            // Limit to occurrences on or before the end date
            return occurrences.filter { $0 <= date }
        }
    }
}
