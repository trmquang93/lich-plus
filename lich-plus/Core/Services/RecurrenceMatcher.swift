//
//  RecurrenceMatcher.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 07/12/25.
//

import Foundation

/// Fast date-matching service for recurring events
///
/// Checks if a recurring event occurs on a specific date without generating
/// all occurrences. This provides O(1) checking instead of O(N) generation + filtering.
struct RecurrenceMatcher {
    /// Check if a recurring event occurs on a specific date
    ///
    /// - Parameters:
    ///   - event: The recurring event to check
    ///   - targetDate: The specific date to check against
    /// - Returns: true if the event occurs on the target date
    static func occursOnDate(_ event: SyncableEvent, targetDate: Date) -> Bool {
        guard let recurrenceData = event.recurrenceRuleData else {
            return false
        }

        do {
            let container = try JSONDecoder().decode(RecurrenceRuleContainer.self, from: recurrenceData)

            switch container {
            case .lunar(let rule):
                return lunarRuleMatchesDate(
                    rule: rule,
                    masterStartDate: event.startDate,
                    targetDate: targetDate
                )

            case .solar(let rule):
                return solarRuleMatchesDate(
                    rule: rule,
                    masterStartDate: event.startDate,
                    targetDate: targetDate
                )

            case .none:
                return false
            }
        } catch {
            return false
        }
    }

    /// Check if a lunar recurrence rule matches a target date
    ///
    /// - Parameters:
    ///   - rule: The lunar recurrence rule
    ///   - masterStartDate: The master event's start date
    ///   - targetDate: The date to check
    /// - Returns: true if the rule produces an occurrence on target date
    static func lunarRuleMatchesDate(
        rule: SerializableLunarRecurrenceRule,
        masterStartDate: Date,
        targetDate: Date
    ) -> Bool {
        // Target date must be on or after master start date
        if targetDate < masterStartDate {
            return false
        }

        // Convert target solar date to lunar
        let targetLunar = LunarCalendar.solarToLunar(targetDate)

        // Check if lunar day matches
        if targetLunar.day != rule.lunarDay {
            return false
        }

        // For yearly recurrence, check if lunar month matches
        if rule.frequency == .yearly {
            // Get the target lunar month from rule or master
            let masterLunar = LunarCalendar.solarToLunar(masterStartDate)
            let targetLunarMonth = rule.lunarMonth ?? masterLunar.month

            if targetLunar.month != targetLunarMonth {
                return false
            }
        }

        // Apply interval check
        if rule.interval > 1 {
            let masterLunar = LunarCalendar.solarToLunar(masterStartDate)

            if rule.frequency == .monthly {
                // For monthly: count lunar months between master and target, accounting for leap months
                let totalMonths = countLunarMonthsBetween(from: masterLunar, to: targetLunar)
                if totalMonths < 0 || totalMonths % rule.interval != 0 {
                    return false
                }
            } else if rule.frequency == .yearly {
                // For yearly: count years between master and target
                let yearsBetween = targetLunar.year - masterLunar.year
                if yearsBetween < 0 || yearsBetween % rule.interval != 0 {
                    return false
                }
            }
        }

        // Apply recurrence end check
        if let recurrenceEnd = rule.recurrenceEnd {
            switch recurrenceEnd {
            case .endDate(let endDate):
                if targetDate > endDate {
                    return false
                }
            case .occurrenceCount(let count):
                // Generate occurrences from master to target and count them
                let occurrences = LunarOccurrenceGenerator.generateOccurrences(
                    rule: rule,
                    masterStartDate: masterStartDate,
                    rangeStart: masterStartDate,
                    rangeEnd: targetDate
                )
                // If we've exceeded the occurrence limit, this date is not valid
                if occurrences.count > count {
                    return false
                }
            }
        }

        return true
    }

    /// Check if a solar/Gregorian recurrence rule matches a target date
    ///
    /// - Parameters:
    ///   - rule: The solar recurrence rule
    ///   - masterStartDate: The master event's start date
    ///   - targetDate: The date to check
    /// - Returns: true if the rule produces an occurrence on target date
    static func solarRuleMatchesDate(
        rule: SerializableRecurrenceRule,
        masterStartDate: Date,
        targetDate: Date
    ) -> Bool {
        // Target date must be on or after master start date
        if targetDate < masterStartDate {
            return false
        }

        let calendar = Calendar.current

        // Apply recurrence end check first
        if let recurrenceEnd = rule.recurrenceEnd {
            switch recurrenceEnd {
            case .endDate(let endDate):
                if targetDate > endDate {
                    return false
                }
            case .occurrenceCount(let count):
                // Calculate occurrence count efficiently based on frequency
                let occurrenceCount: Int
                switch rule.frequency {
                case 0: // Daily
                    let daysBetween = calendar.dateComponents([.day], from: masterStartDate, to: targetDate).day ?? 0
                    occurrenceCount = (daysBetween / rule.interval) + 1
                case 1: // Weekly
                    let weeksBetween = calendar.dateComponents([.weekOfYear], from: masterStartDate, to: targetDate).weekOfYear ?? 0
                    occurrenceCount = (weeksBetween / rule.interval) + 1
                case 2: // Monthly
                    let monthsBetween = calendar.dateComponents([.month], from: masterStartDate, to: targetDate).month ?? 0
                    occurrenceCount = (monthsBetween / rule.interval) + 1
                case 3: // Yearly
                    let yearsBetween = calendar.dateComponents([.year], from: masterStartDate, to: targetDate).year ?? 0
                    occurrenceCount = (yearsBetween / rule.interval) + 1
                default:
                    occurrenceCount = 0
                }

                // If we've exceeded the occurrence limit, this date is not valid
                if occurrenceCount > count {
                    return false
                }
            }
        }

        // Check frequency and interval
        switch rule.frequency {
        case 0: // Daily
            let daysBetween = calendar.dateComponents([.day], from: masterStartDate, to: targetDate).day ?? 0
            return daysBetween >= 0 && daysBetween % rule.interval == 0

        case 1: // Weekly
            let weeksBetween = calendar.dateComponents([.weekOfYear], from: masterStartDate, to: targetDate).weekOfYear ?? 0
            let masterWeekday = calendar.component(.weekday, from: masterStartDate)
            let targetWeekday = calendar.component(.weekday, from: targetDate)

            // Must be the same weekday and correct interval
            return weeksBetween >= 0 && weeksBetween % rule.interval == 0 && masterWeekday == targetWeekday

        case 2: // Monthly
            let monthsBetween = calendar.dateComponents([.month], from: masterStartDate, to: targetDate).month ?? 0
            let masterDay = calendar.component(.day, from: masterStartDate)
            let targetDay = calendar.component(.day, from: targetDate)

            // Must be the same day of month and correct interval
            return monthsBetween >= 0 && monthsBetween % rule.interval == 0 && masterDay == targetDay

        case 3: // Yearly
            let yearsBetween = calendar.dateComponents([.year], from: masterStartDate, to: targetDate).year ?? 0
            let masterMonth = calendar.component(.month, from: masterStartDate)
            let targetMonth = calendar.component(.month, from: targetDate)
            let masterDay = calendar.component(.day, from: masterStartDate)
            let targetDay = calendar.component(.day, from: targetDate)

            // Must be the same month and day, and correct interval
            return yearsBetween >= 0
                && yearsBetween % rule.interval == 0
                && masterMonth == targetMonth
                && masterDay == targetDay

        default:
            return false
        }
    }

    // MARK: - Helper Methods

    /// Count lunar months between two lunar dates, accounting for leap months
    ///
    /// - Parameters:
    ///   - from: Starting lunar date (day, month, year)
    ///   - to: Ending lunar date (day, month, year)
    /// - Returns: Total number of lunar months between dates (can be negative if to < from)
    private static func countLunarMonthsBetween(
        from: (day: Int, month: Int, year: Int),
        to: (day: Int, month: Int, year: Int)
    ) -> Int {
        // If same year, simple calculation
        if from.year == to.year {
            return to.month - from.month
        }

        var totalMonths = 0

        // Add months from starting month to end of starting year
        totalMonths += (12 - from.month)

        // Add months for complete years in between
        for year in (from.year + 1)..<to.year {
            // Check if this year has a leap month
            let solarDate = LunarCalendar.lunarToSolar(day: 1, month: 1, year: year)
            let solarYear = Calendar.current.component(.year, from: solarDate)
            let leapInfo = LunarCalendar.getLeapMonthInfo(forSolarYear: solarYear)

            totalMonths += leapInfo.hasLeapMonth ? 13 : 12
        }

        // Add months from start of ending year to target month
        totalMonths += to.month

        return totalMonths
    }
}
