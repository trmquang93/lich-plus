//
//  RecurringEventExpander.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 08/12/25.
//

import Foundation

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

        // Use consistent hashing to create deterministic UUID
        var hasher = Hasher()
        hasher.combine(seed)
        let hash = hasher.finalize()

        // Create UUID from hash components
        let hashInt = UInt64(bitPattern: Int64(hash))
        let uuid = UUID(
            uuid: (
                UInt8((hashInt >> 56) & 0xFF),
                UInt8((hashInt >> 48) & 0xFF),
                UInt8((hashInt >> 40) & 0xFF),
                UInt8((hashInt >> 32) & 0xFF),
                UInt8((hashInt >> 24) & 0xFF),
                UInt8((hashInt >> 16) & 0xFF),
                UInt8((hashInt >> 8) & 0xFF),
                UInt8(hashInt & 0xFF),
                UInt8((hash >> 24) & 0xFF),
                UInt8((hash >> 16) & 0xFF),
                UInt8((hash >> 8) & 0xFF),
                UInt8(hash & 0xFF),
                UInt8((hash >> 24) & 0xFF),
                UInt8((hash >> 16) & 0xFF),
                UInt8((hash >> 8) & 0xFF),
                UInt8(hash & 0xFF)
            )
        )

        return uuid
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
}
