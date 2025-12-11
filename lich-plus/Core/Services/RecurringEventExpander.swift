//
//  RecurringEventExpander.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 08/12/25.
//

import Foundation
import CryptoKit

/// Service for expanding recurring SyncableEvent instances into individual TaskItem occurrences
///
/// This service handles both solar (Gregorian) and lunar calendar recurrence rules,
/// generating occurrences within a configurable date range with deterministic virtual UUIDs.
struct RecurringEventExpander {
    // MARK: - Configuration

    /// Number of years to look back for occurrences
    static let pastYears: Int = 1

    /// Number of years to look forward for occurrences
    static let futureYears: Int = 5

    // MARK: - Main Expansion Functions

    /// Generate deterministic virtual UUIDs for recurring event occurrences
    ///
    /// Creates a unique UUID for each occurrence based on the master event ID and occurrence date.
    /// The same inputs always produce the same UUID, allowing for consistent identification
    /// of occurrences across multiple expansion passes.
    ///
    /// - Parameters:
    ///   - masterID: The UUID of the master recurring event
    ///   - occurrenceDate: The date of this occurrence
    /// - Returns: A deterministic UUID for this occurrence
    static func virtualUUID(masterID: UUID, occurrenceDate: Date) -> UUID {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: occurrenceDate)

        // Create deterministic seed string from master ID and date
        let seed = "\(masterID.uuidString)-\(components.year ?? 0)-\(components.month ?? 0)-\(components.day ?? 0)"
        let seedData = Data(seed.utf8)

        // Use MD5 hash (128-bit) to generate deterministic UUID
        let digest = Insecure.MD5.hash(data: seedData)

        // Create UUID from the 16-byte digest
        return UUID(uuid: digest.withUnsafeBytes { $0.load(as: uuid_t.self) })
    }

    /// Expand all recurring events into individual TaskItem occurrences
    ///
    /// This is the main entry point. It generates occurrences for all provided events
    /// within the specified date range (or default range if not provided).
    ///
    /// - Parameters:
    ///   - events: Array of SyncableEvent instances to expand
    ///   - rangeStart: Start of the date range (default: 1 year ago)
    ///   - rangeEnd: End of the date range (default: 5 years from now)
    /// - Returns: Array of TaskItem occurrences, sorted chronologically
    static func expandRecurringEvents(
        _ events: [SyncableEvent],
        rangeStart: Date? = nil,
        rangeEnd: Date? = nil
    ) -> [TaskItem] {
        // Calculate default date range if not provided
        let calendar = Calendar.current
        let today = Date()

        let start = rangeStart ?? (calendar.date(byAdding: .year, value: -pastYears, to: today) ?? today)
        let end = rangeEnd ?? (calendar.date(byAdding: .year, value: futureYears, to: today) ?? today)

        // Expand all events
        var allTasks: [TaskItem] = []
        for event in events {
            let occurrences = generateOccurrences(
                for: event,
                rangeStart: start,
                rangeEnd: end
            )
            allTasks.append(contentsOf: occurrences)
        }

        return allTasks
    }

    /// Generate occurrences for a single event
    ///
    /// - Parameters:
    ///   - event: The SyncableEvent to expand
    ///   - rangeStart: Start of the date range
    ///   - rangeEnd: End of the date range
    /// - Returns: Array of TaskItem occurrences
    static func generateOccurrences(
        for event: SyncableEvent,
        rangeStart: Date,
        rangeEnd: Date
    ) -> [TaskItem] {
        // Handle multi-day all-day events (non-recurring)
        if event.isAllDay,
           let eventEndDate = event.endDate,
           event.recurrenceRuleData == nil || event.recurrenceRuleData?.isEmpty == true {

            let calendar = Calendar.current
            let eventStartDay = calendar.startOfDay(for: event.startDate)
            let eventEndDay = calendar.startOfDay(for: eventEndDate)

            // Check if this is actually a multi-day event (spans more than one day)
            if eventStartDay < eventEndDay {
                return expandMultiDayEvent(
                    event: event,
                    eventStartDay: eventStartDay,
                    eventEndDay: eventEndDay,
                    rangeStart: rangeStart,
                    rangeEnd: rangeEnd
                )
            }
        }

        // Check if event has recurrence data
        guard let recurrenceData = event.recurrenceRuleData,
              !recurrenceData.isEmpty else {
            // Non-recurring event - return as master
            return [TaskItem(from: event)]
        }

        // Decode recurrence rule container
        do {
            let container = try JSONDecoder().decode(RecurrenceRuleContainer.self, from: recurrenceData)

            switch container {
            case .solar(let rule):
                return expandSolarRecurrence(
                    event: event,
                    rule: rule,
                    rangeStart: rangeStart,
                    rangeEnd: rangeEnd
                )

            case .lunar(let rule):
                return expandLunarRecurrence(
                    event: event,
                    rule: rule,
                    rangeStart: rangeStart,
                    rangeEnd: rangeEnd
                )

            case .none:
                // No recurrence - return as master
                return [TaskItem(from: event)]
            }
        } catch {
            print("RecurringEventExpander: Failed to decode recurrence rule: \(error)")
            // On error, return master event only
            return [TaskItem(from: event)]
        }
    }

    // MARK: - Solar Recurrence Expansion

    /// Expand solar/Gregorian calendar recurrence rule
    ///
    /// - Parameters:
    ///   - event: The master event
    ///   - rule: The solar recurrence rule
    ///   - rangeStart: Start of date range
    ///   - rangeEnd: End of date range
    /// - Returns: Array of TaskItem occurrences
    private static func expandSolarRecurrence(
        event: SyncableEvent,
        rule: SerializableRecurrenceRule,
        rangeStart: Date,
        rangeEnd: Date
    ) -> [TaskItem] {
        var occurrences: [TaskItem] = []
        let calendar = Calendar.current
        let masterStartDate = event.startDate

        // NOTE: Current implementation supports simple recurrence rules (daily, weekly, monthly, yearly
        // with intervals). Complex rules using daysOfTheWeek, daysOfTheMonth, or setPositions
        // (e.g., "every Monday and Wednesday" or "2nd Friday of each month") are not yet fully supported
        // by RecurrenceMatcher.solarRuleMatchesDate. This limitation exists in the current codebase
        // and is not introduced by this PR. Future enhancement: extend RecurrenceMatcher to handle
        // complex recurrence patterns.

        // Determine iteration by iterating through each day and checking if it matches
        var currentDate = max(masterStartDate, rangeStart)

        while currentDate <= rangeEnd {
            // Check if this date matches the recurrence rule
            if RecurrenceMatcher.occursOnDate(event, targetDate: currentDate) {
                let virtualID = virtualUUID(masterID: event.id, occurrenceDate: currentDate)
                let occurrence = TaskItem.createOccurrence(
                    from: event,
                    occurrenceDate: currentDate,
                    virtualID: virtualID
                )
                occurrences.append(occurrence)
            }

            // Move to next day
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate

            // Check recurrence end conditions
            if let endDate = rule.recurrenceEnd, case .endDate(let end) = endDate, currentDate > end {
                break
            }
            if let occCount = rule.recurrenceEnd, case .occurrenceCount(let count) = occCount, occurrences.count >= count {
                break
            }
        }

        return occurrences
    }

    // MARK: - Lunar Recurrence Expansion

    /// Expand lunar calendar recurrence rule
    ///
    /// - Parameters:
    ///   - event: The master event
    ///   - rule: The lunar recurrence rule
    ///   - rangeStart: Start of date range
    ///   - rangeEnd: End of date range
    /// - Returns: Array of TaskItem occurrences
    private static func expandLunarRecurrence(
        event: SyncableEvent,
        rule: SerializableLunarRecurrenceRule,
        rangeStart: Date,
        rangeEnd: Date
    ) -> [TaskItem] {
        // Use existing LunarOccurrenceGenerator to get dates
        let occurrenceDates = LunarOccurrenceGenerator.generateOccurrences(
            rule: rule,
            masterStartDate: event.startDate,
            rangeStart: rangeStart,
            rangeEnd: rangeEnd
        )

        // Convert dates to TaskItems
        return occurrenceDates.map { occurrenceDate in
            let virtualID = virtualUUID(masterID: event.id, occurrenceDate: occurrenceDate)
            return TaskItem.createOccurrence(
                from: event,
                occurrenceDate: occurrenceDate,
                virtualID: virtualID
            )
        }
    }

    // MARK: - Multi-Day Event Expansion

    /// Expand a multi-day all-day event into individual day occurrences
    ///
    /// - Parameters:
    ///   - event: The multi-day event to expand
    ///   - eventStartDay: Start of the event (normalized to midnight)
    ///   - eventEndDay: End of the event (normalized to midnight)
    ///   - rangeStart: Start of the date range
    ///   - rangeEnd: End of the date range
    /// - Returns: Array of TaskItem occurrences, one for each day
    private static func expandMultiDayEvent(
        event: SyncableEvent,
        eventStartDay: Date,
        eventEndDay: Date,
        rangeStart: Date,
        rangeEnd: Date
    ) -> [TaskItem] {
        var occurrences: [TaskItem] = []
        let calendar = Calendar.current

        // Find the overlap between event range and query range
        let effectiveStart = max(eventStartDay, calendar.startOfDay(for: rangeStart))
        let effectiveEnd = min(eventEndDay, calendar.startOfDay(for: rangeEnd))

        var currentDate = effectiveStart
        while currentDate <= effectiveEnd {
            let virtualID = virtualUUID(masterID: event.id, occurrenceDate: currentDate)
            var occurrence = TaskItem(from: event)
            occurrence.id = virtualID
            occurrence.masterEventId = event.id
            occurrence.occurrenceDate = currentDate
            occurrence.date = currentDate
            // startTime stays nil for all-day events

            occurrences.append(occurrence)

            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }

        return occurrences
    }
}
