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
        // Algorithmic shape: walk solar dates forward from the master start date once,
        // testing each day's lunar tuple against the target day (and month, for yearly).
        // Previous implementation searched lunar→solar 192 times per event, each search
        // brute-forcing up to 425 days. This rewrite makes the work O(rangeDays) instead
        // of O(years × 12 × 425), and leans on the cached `solarToLunar`.

        let masterLunar = LunarCalendar.solarToLunar(masterStartDate)
        let targetDay = rule.lunarDay

        // Monthly recurrence: any lunar month qualifies (matches prior behavior).
        // Yearly: must match a specific lunar month — rule.lunarMonth or the master's.
        let targetMonth: Int?
        if rule.frequency == .yearly {
            targetMonth = rule.lunarMonth ?? masterLunar.month
        } else {
            targetMonth = nil
        }

        // Walk window: start at the master so interval/occurrenceCount are anchored there
        // (matches prior semantics); end at min(rangeEnd, rule's endDate) if any.
        let calendar = Calendar.current
        let walkStart = masterStartDate
        var walkEnd = rangeEnd
        if case .endDate(let endDate) = rule.recurrenceEnd, endDate < walkEnd {
            walkEnd = endDate
        }

        // After a match we know the next match is at least ~28 days away (lunar months are
        // 29–30 days). For yearly, the next match in a different year is ~340+ days away.
        // For occurrenceCount termination, we can stop the walk once we have enough.
        let skipAfterMatch = (rule.frequency == .yearly) ? 340 : 28
        let occurrenceCountLimit: Int? = {
            if case .occurrenceCount(let count) = rule.recurrenceEnd { return count }
            return nil
        }()

        var candidates: [(date: Date, year: Int, month: Int)] = []

        var current = walkStart
        while current <= walkEnd {
            let lunar = LunarCalendar.solarToLunar(current)
            let dayMatch = lunar.day == targetDay
            let monthMatch = (targetMonth == nil) || (targetMonth == lunar.month)

            if dayMatch && monthMatch {
                candidates.append((current, lunar.year, lunar.month))
                var lastMatch = current

                // Probe for a leap-month variant: same (year, month, day) reappearing
                // ~29 or ~30 days later. Two probes are enough to catch it.
                for offset in [29, 30] {
                    guard let probe = calendar.date(byAdding: .day, value: offset, to: current),
                          probe <= walkEnd else { break }
                    let probeLunar = LunarCalendar.solarToLunar(probe)
                    if probeLunar.day == targetDay
                        && probeLunar.month == lunar.month
                        && probeLunar.year == lunar.year {
                        candidates.append((probe, probeLunar.year, probeLunar.month))
                        lastMatch = probe
                        break
                    }
                }

                // Cheap termination: if we already have enough candidates to satisfy
                // occurrenceCount post-interval, stop walking. Worst case overshoot is
                // small (interval/leap behavior may discard some, so add a buffer).
                if let limit = occurrenceCountLimit,
                   candidates.count >= max(limit * rule.interval, limit) + 4 {
                    break
                }

                guard let next = calendar.date(byAdding: .day, value: skipAfterMatch, to: lastMatch) else { break }
                current = next
            } else {
                guard let next = calendar.date(byAdding: .day, value: 1, to: current) else { break }
                current = next
            }
        }

        // Group candidates by (year, month) so we can identify leap variants:
        // a group with two entries means the month repeats — first is regular, second is leap.
        // Packed `year * 100 + month` is cheaper than a string key in this hot path.
        var dateGroups: [Int: [Date]] = [:]
        for c in candidates {
            let key = c.year * 100 + c.month
            dateGroups[key, default: []].append(c.date)
        }

        var resolved: [Date] = []
        resolved.reserveCapacity(candidates.count)
        for c in candidates {
            let key = c.year * 100 + c.month
            guard let group = dateGroups[key] else { continue }

            if group.count <= 1 {
                resolved.append(c.date)
                continue
            }

            // Group has 2 entries: earliest = regular, latest = leap.
            let isLeap = (c.date == (group.max() ?? c.date))
            switch rule.leapMonthBehavior {
            case .includeLeap:
                resolved.append(c.date)
            case .skipLeap:
                if !isLeap { resolved.append(c.date) }
            case .leapOnly:
                if isLeap { resolved.append(c.date) }
            }
        }

        // `resolved` is already in forward order (candidates are appended during
        // a forward solar walk; applyInterval / applyRecurrenceEnd preserve order;
        // walkEnd already caps the upper bound), so no extra sorts or rangeEnd
        // filter are needed.
        var filtered = applyInterval(resolved, interval: rule.interval)

        if let recurrenceEnd = rule.recurrenceEnd {
            filtered = applyRecurrenceEnd(filtered, recurrenceEnd: recurrenceEnd)
        }

        return filtered.filter { $0 >= rangeStart }
    }

    // MARK: - Helper Methods

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
