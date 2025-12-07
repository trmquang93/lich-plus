//
//  SerializableLunarRecurrenceRule.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 07/12/25.
//

import Foundation

// MARK: - LunarFrequency

/// The frequency of lunar calendar recurrence
///
/// Defines how often a recurring event repeats in the lunar calendar system.
enum LunarFrequency: String, Codable {
    /// Recurs on the same day of every lunar month
    case monthly = "monthly"

    /// Recurs on the same day of the same lunar month every year
    case yearly = "yearly"
}

// MARK: - LeapMonthBehavior

/// Defines how leap months are handled in lunar recurrence
///
/// The lunar calendar includes leap months (intercalary months) that occur periodically.
/// This enum specifies the behavior when a recurrence falls on a leap month.
enum LeapMonthBehavior: String, Codable {
    /// Include occurrences in leap months (events occur both in regular and leap months)
    case includeLeap = "includeLeap"

    /// Skip leap months (events only occur in regular months)
    case skipLeap = "skipLeap"

    /// Only occur in leap months (events only occur when a leap month exists)
    case leapOnly = "leapOnly"
}

// MARK: - SerializableLunarRecurrenceRule

/// A Codable wrapper for lunar calendar recurrence rules
///
/// Provides a serializable alternative to EventKit's recurrence rules
/// that captures lunar calendar-specific properties.
struct SerializableLunarRecurrenceRule: Codable {
    /// The frequency of lunar recurrence (monthly or yearly)
    var frequency: LunarFrequency

    /// The lunar day of the month (1-30)
    var lunarDay: Int

    /// The lunar month (1-12, nil for monthly recurrence)
    var lunarMonth: Int?

    /// How to handle leap months
    var leapMonthBehavior: LeapMonthBehavior

    /// The recurrence interval (default: 1)
    var interval: Int

    /// When the recurrence ends (occurrence count or end date)
    var recurrenceEnd: SerializableRecurrenceEnd?

    // MARK: - Initialization

    /// Initialize with all parameters
    ///
    /// - Parameters:
    ///   - frequency: The recurrence frequency (monthly or yearly)
    ///   - lunarDay: The lunar day of the month (1-30)
    ///   - lunarMonth: The lunar month (1-12, nil for monthly recurrence)
    ///   - leapMonthBehavior: How to handle leap months
    ///   - interval: The recurrence interval (default: 1)
    ///   - recurrenceEnd: When the recurrence ends
    init(
        frequency: LunarFrequency,
        lunarDay: Int,
        lunarMonth: Int? = nil,
        leapMonthBehavior: LeapMonthBehavior = .includeLeap,
        interval: Int = 1,
        recurrenceEnd: SerializableRecurrenceEnd? = nil
    ) {
        self.frequency = frequency
        self.lunarDay = lunarDay
        self.lunarMonth = lunarMonth
        self.leapMonthBehavior = leapMonthBehavior
        self.interval = interval
        self.recurrenceEnd = recurrenceEnd
    }
}
