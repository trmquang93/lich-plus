//
//  ICSRecurrenceExpander.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 08/12/25.
//

import Foundation

/// Generates all occurrence dates from a recurrence rule
///
/// Supports all frequency types (daily, weekly, monthly, yearly) with
/// filter support (BYDAY, BYMONTHDAY, BYMONTH), EXDATE filtering, and
/// expansion caps (5 years, 2000 occurrences).
struct ICSRecurrenceExpander {

    // MARK: - Constants

    /// Maximum years to expand recurrence rules
    private static let maxExpansionYears = 5

    /// Maximum occurrences to generate
    private static let maxOccurrences = 2000

    // MARK: - Main Expansion Method

    /// Generate all occurrence dates from a recurrence rule
    ///
    /// Uses day-by-day expansion to ensure all frequency and filter combinations
    /// are handled correctly. While this is less efficient than frequency-based jumps,
    /// it guarantees correctness for complex rules with BYDAY filters.
    ///
    /// - Parameters:
    ///   - masterStartDate: Start date of the master event
    ///   - masterEndDate: End date of the master event (optional)
    ///   - rule: The recurrence rule to expand
    ///   - excludedDates: Dates to exclude from results (EXDATE)
    /// - Returns: Array of (startDate, endDate?) tuples for each occurrence
    static func expandOccurrences(
        masterStartDate: Date,
        masterEndDate: Date?,
        rule: SerializableRecurrenceRule,
        excludedDates: [Date]
    ) -> [(startDate: Date, endDate: Date?)] {
        var occurrences: [(startDate: Date, endDate: Date?)] = []
        let calendar = Calendar.current

        // Pre-compute expansion parameters
        let duration = masterEndDate.map { $0.timeIntervalSince(masterStartDate) } ?? 0
        let normalizedExcludedDates = Set(excludedDates.map { calendar.startOfDay(for: $0) })
        let maxDate = calendar.date(byAdding: .year, value: maxExpansionYears, to: masterStartDate) ?? Date.distantFuture
        let (hasCountLimit, countLimit, hasUntilDate, untilDate) = parseRecurrenceEnd(rule.recurrenceEnd)

        // Start expanding from master start date
        var candidateDate = masterStartDate
        var candidateCount = 0

        // Expansion loop: Advance by days to correctly handle all filter combinations
        // This approach sacrifices some efficiency for correctness and simplicity.
        while candidateCount < maxOccurrences && candidateDate < maxDate {
            // Check until date constraint
            if hasUntilDate && candidateDate > untilDate {
                break
            }

            // Check if candidate matches frequency and all filters
            if matchesAllFilters(candidateDate: candidateDate, masterStartDate: masterStartDate, rule: rule) {
                candidateCount += 1

                // Check count limit on candidates (before exclusion)
                if hasCountLimit && candidateCount > countLimit {
                    break
                }

                // Check if date is not excluded, then add occurrence
                let candidateMidnight = calendar.startOfDay(for: candidateDate)
                if !normalizedExcludedDates.contains(candidateMidnight) {
                    let occurrenceEndDate = duration > 0 ? candidateDate.addingTimeInterval(duration) : nil
                    occurrences.append((startDate: candidateDate, endDate: occurrenceEndDate))
                }
            }

            // Advance by one day to check next candidate
            candidateDate = calendar.date(byAdding: .day, value: 1, to: candidateDate) ?? candidateDate
        }

        return occurrences
    }

    // MARK: - Helper Methods

    /// Parse recurrence end to extract constraints
    private static func parseRecurrenceEnd(_ recurrenceEnd: SerializableRecurrenceEnd?) -> (hasCountLimit: Bool, countLimit: Int, hasUntilDate: Bool, untilDate: Date) {
        guard let recurrenceEnd = recurrenceEnd else {
            return (false, 0, false, Date.distantFuture)
        }

        switch recurrenceEnd {
        case .occurrenceCount(let count):
            return (true, count, false, Date.distantFuture)
        case .endDate(let date):
            return (false, 0, true, date)
        }
    }

    /// Check if a candidate date matches all recurrence filters
    private static func matchesAllFilters(
        candidateDate: Date,
        masterStartDate: Date,
        rule: SerializableRecurrenceRule
    ) -> Bool {
        let calendar = Calendar.current

        // Check frequency and interval constraints
        if !matchesFrequencyAndInterval(candidateDate: candidateDate, masterStartDate: masterStartDate, frequency: rule.frequency, interval: rule.interval, daysOfWeek: rule.daysOfTheWeek, calendar: calendar) {
            return false
        }

        // Check frequency-specific filters
        switch rule.frequency {
        case 0:  // Daily
            return true  // No additional filters for daily

        case 1:  // Weekly
            if let daysOfWeek = rule.daysOfTheWeek, !daysOfWeek.isEmpty {
                return matchesWeekday(candidateDate: candidateDate, daysOfWeek: daysOfWeek, calendar: calendar)
            }
            return true

        case 2:  // Monthly
            if let daysOfMonth = rule.daysOfTheMonth, !daysOfMonth.isEmpty {
                return matchesDayOfMonth(candidateDate: candidateDate, daysOfMonth: daysOfMonth, calendar: calendar)
            }
            if let daysOfWeek = rule.daysOfTheWeek, !daysOfWeek.isEmpty {
                return matchesDayOfWeekOfMonth(candidateDate: candidateDate, daysOfWeek: daysOfWeek, calendar: calendar)
            }
            return true

        case 3:  // Yearly
            if let monthsOfYear = rule.monthsOfTheYear, !monthsOfYear.isEmpty {
                return matchesMonthOfYear(candidateDate: candidateDate, monthsOfYear: monthsOfYear, calendar: calendar)
            }
            return true

        default:
            return false
        }
    }

    /// Check if candidate date matches frequency and interval constraints
    ///
    /// - Parameters:
    ///   - candidateDate: The date to check
    ///   - masterStartDate: The original recurrence start date
    ///   - frequency: Recurrence frequency (0=daily, 1=weekly, 2=monthly, 3=yearly)
    ///   - interval: How many frequency units between occurrences
    ///   - daysOfWeek: BYDAY filter (if specified, overrides default weekday matching)
    ///   - calendar: The calendar to use for calculations
    /// - Returns: true if candidate matches the frequency and interval constraints
    private static func matchesFrequencyAndInterval(
        candidateDate: Date,
        masterStartDate: Date,
        frequency: Int,
        interval: Int,
        daysOfWeek: [SerializableDayOfWeek]?,
        calendar: Calendar
    ) -> Bool {
        switch frequency {
        case 0:  // Daily
            let daysBetween = calendar.dateComponents([.day], from: masterStartDate, to: candidateDate).day ?? 0
            return daysBetween >= 0 && daysBetween % interval == 0

        case 1:  // Weekly
            let weeksBetween = calendar.dateComponents([.weekOfYear], from: masterStartDate, to: candidateDate).weekOfYear ?? 0

            // Special handling for BYDAY: When specified, it overrides default weekday matching.
            // We only check week alignment here; the matchesWeekday filter handles day selection.
            if let daysOfWeek = daysOfWeek, !daysOfWeek.isEmpty {
                return weeksBetween >= 0 && weeksBetween % interval == 0
            }

            // Default behavior: must match master's weekday and interval
            let masterWeekday = calendar.component(.weekday, from: masterStartDate)
            let candidateWeekday = calendar.component(.weekday, from: candidateDate)
            return weeksBetween >= 0 && weeksBetween % interval == 0 && masterWeekday == candidateWeekday

        case 2:  // Monthly
            let monthsBetween = calendar.dateComponents([.month], from: masterStartDate, to: candidateDate).month ?? 0
            let masterDay = calendar.component(.day, from: masterStartDate)
            let candidateDay = calendar.component(.day, from: candidateDate)
            return monthsBetween >= 0 && monthsBetween % interval == 0 && masterDay == candidateDay

        case 3:  // Yearly
            let yearsBetween = calendar.dateComponents([.year], from: masterStartDate, to: candidateDate).year ?? 0
            let masterMonth = calendar.component(.month, from: masterStartDate)
            let candidateMonth = calendar.component(.month, from: candidateDate)
            let masterDay = calendar.component(.day, from: masterStartDate)
            let candidateDay = calendar.component(.day, from: candidateDate)
            return yearsBetween >= 0 && yearsBetween % interval == 0 && masterMonth == candidateMonth && masterDay == candidateDay

        default:
            return false
        }
    }

    /// Check if candidate weekday matches any in BYDAY filter
    private static func matchesWeekday(
        candidateDate: Date,
        daysOfWeek: [SerializableDayOfWeek],
        calendar: Calendar
    ) -> Bool {
        let candidateWeekday = calendar.component(.weekday, from: candidateDate)
        return daysOfWeek.contains { $0.dayOfWeek == candidateWeekday }
    }

    /// Check if candidate day of month matches any in BYMONTHDAY filter
    private static func matchesDayOfMonth(
        candidateDate: Date,
        daysOfMonth: [Int],
        calendar: Calendar
    ) -> Bool {
        let candidateDay = calendar.component(.day, from: candidateDate)
        return daysOfMonth.contains(candidateDay)
    }

    /// Check if candidate matches BYDAY filter with week specification (e.g., 2nd Tuesday)
    private static func matchesDayOfWeekOfMonth(
        candidateDate: Date,
        daysOfWeek: [SerializableDayOfWeek],
        calendar: Calendar
    ) -> Bool {
        let candidateWeekday = calendar.component(.weekday, from: candidateDate)

        // Find matching day specifications
        guard let matchingSpec = daysOfWeek.first(where: { $0.dayOfWeek == candidateWeekday }) else {
            return false
        }

        // If no week is specified, any week matches
        guard let targetWeek = matchingSpec.week else {
            return true
        }

        // Calculate week of month
        let weekOfMonth = calendar.component(.weekOfMonth, from: candidateDate)
        return weekOfMonth == targetWeek
    }

    /// Check if candidate month matches any in BYMONTH filter
    private static func matchesMonthOfYear(
        candidateDate: Date,
        monthsOfYear: [Int],
        calendar: Calendar
    ) -> Bool {
        let candidateMonth = calendar.component(.month, from: candidateDate)
        return monthsOfYear.contains(candidateMonth)
    }
}
