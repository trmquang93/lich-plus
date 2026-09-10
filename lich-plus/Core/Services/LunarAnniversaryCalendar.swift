//
//  LunarAnniversaryCalendar.swift
//  lich-plus
//
//  Leap-month-aware lunar anniversary matching and occurrence generation.
//  Handles ngày 30 → last day of 29-day months (Vietnamese giỗ convention).
//

import Foundation

enum LunarAnniversaryCalendar {

    /// Builds a yearly recurrence rule for a giỗ-style lunar anniversary.
    static func recurrenceRule(
        lunarDay: Int,
        lunarMonth: Int,
        leapMonthBehavior: LeapMonthBehavior = .includeLeap
    ) -> SerializableLunarRecurrenceRule {
        SerializableLunarRecurrenceRule(
            frequency: .yearly,
            lunarDay: lunarDay,
            lunarMonth: lunarMonth,
            leapMonthBehavior: leapMonthBehavior,
            interval: 1,
            recurrenceEnd: nil
        )
    }

    /// Upcoming solar dates for a lunar anniversary within a rolling horizon.
    static func upcomingAnniversaryDates(
        lunarDay: Int,
        lunarMonth: Int,
        leapMonthBehavior: LeapMonthBehavior,
        from referenceDate: Date,
        horizonMonths: Int
    ) -> [Date] {
        let calendar = vietnameseCalendar
        let start = calendar.startOfDay(for: referenceDate)
        guard let rangeEnd = calendar.date(byAdding: .month, value: horizonMonths, to: start) else {
            return []
        }

        let rule = recurrenceRule(
            lunarDay: lunarDay,
            lunarMonth: lunarMonth,
            leapMonthBehavior: leapMonthBehavior
        )

        var dates = LunarOccurrenceGenerator.generateOccurrences(
            rule: rule,
            masterStartDate: start,
            rangeStart: start,
            rangeEnd: rangeEnd
        )

        if lunarDay == 30 {
            dates.append(contentsOf: lastDayFallbackOccurrences(
                lunarMonth: lunarMonth,
                leapMonthBehavior: leapMonthBehavior,
                rangeStart: start,
                rangeEnd: rangeEnd
            ))
        }

        return Array(Set(dates.map { calendar.startOfDay(for: $0) })).sorted()
    }

    /// Whether `date` is the lunar anniversary (giỗ) for the given lunar tuple.
    static func matchesAnniversary(
        date: Date,
        lunarDay: Int,
        lunarMonth: Int,
        isLeapMonthAnniversary: Bool
    ) -> Bool {
        let lunar = LunarCalendar.solarToLunarWithLeap(date)
        guard lunar.month == lunarMonth else { return false }

        if isLeapMonthAnniversary {
            guard lunar.isLeap else { return false }
        } else if lunar.isLeap {
            // Regular-month anniversaries still occur in leap months when the day matches.
        }

        if lunar.day == lunarDay { return true }

        // Ngày 30 in a 29-day month: observe on the last lunar day of that month.
        if lunarDay == 30, isLastDayOfLunarMonth(date: date, lunarMonth: lunarMonth) {
            return true
        }

        return false
    }

    static func leapMonthBehavior(isLeapMonthAnniversary: Bool) -> LeapMonthBehavior {
        isLeapMonthAnniversary ? .leapOnly : .includeLeap
    }

    // MARK: - Private

    private static var vietnameseCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Ho_Chi_Minh") ?? .current
        return calendar
    }

    private static func isLastDayOfLunarMonth(date: Date, lunarMonth: Int) -> Bool {
        let lunar = LunarCalendar.solarToLunarWithLeap(date)
        guard lunar.month == lunarMonth else { return false }
        let calendar = vietnameseCalendar
        guard let nextDay = calendar.date(byAdding: .day, value: 1, to: date) else { return false }
        let next = LunarCalendar.solarToLunarWithLeap(nextDay)
        return next.month != lunarMonth || next.day == 1
    }

    /// When target day is 30 but a year’s month has only 29 days, match the 29th.
    private static func lastDayFallbackOccurrences(
        lunarMonth: Int,
        leapMonthBehavior: LeapMonthBehavior,
        rangeStart: Date,
        rangeEnd: Date
    ) -> [Date] {
        let calendar = vietnameseCalendar
        let startYear = LunarCalendar.solarToLunar(rangeStart).year
        let endYear = LunarCalendar.solarToLunar(rangeEnd).year
        var results: [Date] = []

        for year in startYear...endYear + 1 {
            for useLeap in [false, true] {
                if useLeap {
                    let approxSolar = LunarCalendar.lunarToSolar(day: 1, month: 1, year: year)
                    let solarYear = calendar.component(.year, from: approxSolar)
                    let leapInfo = LunarCalendar.getLeapMonthInfo(forSolarYear: solarYear)
                    guard leapInfo.hasLeapMonth, leapInfo.leapMonth == lunarMonth else { continue }
                    if leapMonthBehavior == .skipLeap { continue }
                } else if leapMonthBehavior == .leapOnly {
                    continue
                }

                let candidate = LunarCalendar.lunarToSolar(
                    day: 29,
                    month: lunarMonth,
                    year: year,
                    isLeapMonth: useLeap
                )
                let normalized = calendar.startOfDay(for: candidate)
                guard normalized >= rangeStart, normalized <= rangeEnd else { continue }

                let back = LunarCalendar.solarToLunarWithLeap(normalized)
                guard back.month == lunarMonth, back.day == 29 else { continue }
                guard isLastDayOfLunarMonth(date: normalized, lunarMonth: lunarMonth) else { continue }

                results.append(normalized)
            }
        }

        return results
    }
}
