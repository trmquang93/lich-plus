//
//  SerializableRecurrenceRule.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 26/11/25.
//

import Foundation
import EventKit

// MARK: - SerializableRecurrenceRule

/// A Codable wrapper for EKRecurrenceRule that can be serialized with JSONEncoder/JSONDecoder
///
/// EKRecurrenceRule does not conform to NSSecureCoding, so this struct provides
/// a serializable alternative that captures all recurrence properties.
struct SerializableRecurrenceRule: Codable {
    var frequency: Int  // EKRecurrenceFrequency rawValue
    var interval: Int
    var daysOfTheWeek: [SerializableDayOfWeek]?
    var daysOfTheMonth: [Int]?
    var monthsOfTheYear: [Int]?
    var weeksOfTheYear: [Int]?
    var daysOfTheYear: [Int]?
    var setPositions: [Int]?
    var recurrenceEnd: SerializableRecurrenceEnd?

    // MARK: - Initialization

    /// Initialize with all parameters
    ///
    /// - Parameters:
    ///   - frequency: The recurrence frequency (EKRecurrenceFrequency rawValue)
    ///   - interval: The recurrence interval
    ///   - daysOfTheWeek: Optional array of days of the week
    ///   - daysOfTheMonth: Optional array of days of the month
    ///   - monthsOfTheYear: Optional array of months of the year
    ///   - weeksOfTheYear: Optional array of weeks of the year
    ///   - daysOfTheYear: Optional array of days of the year
    ///   - setPositions: Optional array of set positions
    ///   - recurrenceEnd: Optional recurrence end
    init(
        frequency: Int,
        interval: Int,
        daysOfTheWeek: [SerializableDayOfWeek]? = nil,
        daysOfTheMonth: [Int]? = nil,
        monthsOfTheYear: [Int]? = nil,
        weeksOfTheYear: [Int]? = nil,
        daysOfTheYear: [Int]? = nil,
        setPositions: [Int]? = nil,
        recurrenceEnd: SerializableRecurrenceEnd? = nil
    ) {
        self.frequency = frequency
        self.interval = interval
        self.daysOfTheWeek = daysOfTheWeek
        self.daysOfTheMonth = daysOfTheMonth
        self.monthsOfTheYear = monthsOfTheYear
        self.weeksOfTheYear = weeksOfTheYear
        self.daysOfTheYear = daysOfTheYear
        self.setPositions = setPositions
        self.recurrenceEnd = recurrenceEnd
    }

    /// Initialize from an EKRecurrenceRule
    ///
    /// - Parameter ekRule: The EKRecurrenceRule to convert
    init(from ekRule: EKRecurrenceRule) {
        self.frequency = ekRule.frequency.rawValue
        self.interval = ekRule.interval

        // Convert days of the week if present
        if let daysOfWeek = ekRule.daysOfTheWeek {
            self.daysOfTheWeek = daysOfWeek.map { SerializableDayOfWeek(from: $0) }
        }

        self.daysOfTheMonth = ekRule.daysOfTheMonth as? [Int]
        self.monthsOfTheYear = ekRule.monthsOfTheYear as? [Int]
        self.weeksOfTheYear = ekRule.weeksOfTheYear as? [Int]
        self.daysOfTheYear = ekRule.daysOfTheYear as? [Int]
        self.setPositions = ekRule.setPositions as? [Int]

        // Convert recurrence end if present
        if let recurrenceEnd = ekRule.recurrenceEnd {
            self.recurrenceEnd = SerializableRecurrenceEnd(from: recurrenceEnd)
        }
    }

    // MARK: - Conversion

    /// Convert to an EKRecurrenceRule
    ///
    /// - Returns: An EKRecurrenceRule with the serialized properties
    /// - Throws: EventKitServiceError.recurrenceError if conversion fails
    func toEKRecurrenceRule() throws -> EKRecurrenceRule {
        guard let frequency = EKRecurrenceFrequency(rawValue: self.frequency) else {
            throw EventKitServiceError.recurrenceError("Invalid recurrence frequency: \(self.frequency)")
        }

        // Convert days of the week back
        var daysOfWeek: [EKRecurrenceDayOfWeek]?
        if let serializedDays = self.daysOfTheWeek {
            daysOfWeek = serializedDays.map { $0.toEKRecurrenceDayOfWeek() }
        }

        // Convert Int arrays to NSNumber arrays (EKRecurrenceRule requires NSNumber arrays)
        let daysOfTheMonth = self.daysOfTheMonth?.map { NSNumber(value: $0) }
        let monthsOfTheYear = self.monthsOfTheYear?.map { NSNumber(value: $0) }
        let weeksOfTheYear = self.weeksOfTheYear?.map { NSNumber(value: $0) }
        let daysOfTheYear = self.daysOfTheYear?.map { NSNumber(value: $0) }
        let setPositions = self.setPositions?.map { NSNumber(value: $0) }

        // Create the recurrence rule with all parameters
        let rule = EKRecurrenceRule(
            recurrenceWith: frequency,
            interval: self.interval,
            daysOfTheWeek: daysOfWeek,
            daysOfTheMonth: daysOfTheMonth,
            monthsOfTheYear: monthsOfTheYear,
            weeksOfTheYear: weeksOfTheYear,
            daysOfTheYear: daysOfTheYear,
            setPositions: setPositions,
            end: self.recurrenceEnd?.toEKRecurrenceEnd()
        )

        return rule
    }
}

// MARK: - SerializableDayOfWeek

/// A Codable wrapper for EKRecurrenceDayOfWeek
struct SerializableDayOfWeek: Codable {
    var dayOfWeek: Int  // EKWeekday rawValue
    var week: Int?      // Optional week number

    // MARK: - Initialization

    /// Initialize from an EKRecurrenceDayOfWeek
    ///
    /// - Parameter dayOfWeek: The EKRecurrenceDayOfWeek to convert
    init(from dayOfWeek: EKRecurrenceDayOfWeek) {
        self.dayOfWeek = dayOfWeek.dayOfTheWeek.rawValue
        // weekNumber of 0 means no specific week, so treat as nil
        self.week = dayOfWeek.weekNumber == 0 ? nil : dayOfWeek.weekNumber
    }

    // MARK: - Conversion

    /// Convert to an EKRecurrenceDayOfWeek
    ///
    /// - Returns: An EKRecurrenceDayOfWeek with the serialized properties
    func toEKRecurrenceDayOfWeek() -> EKRecurrenceDayOfWeek {
        guard let weekday = EKWeekday(rawValue: self.dayOfWeek) else {
            // Fallback to a default valid weekday if conversion fails
            return EKRecurrenceDayOfWeek(EKWeekday.monday)
        }

        if let week = self.week {
            return EKRecurrenceDayOfWeek(weekday, weekNumber: week)
        } else {
            return EKRecurrenceDayOfWeek(weekday)
        }
    }
}

// MARK: - SerializableRecurrenceEnd

/// A Codable wrapper for EKRecurrenceEnd
enum SerializableRecurrenceEnd: Codable {
    case occurrenceCount(Int)
    case endDate(Date)

    // MARK: - Initialization

    /// Initialize from an EKRecurrenceEnd
    ///
    /// - Parameter recurrenceEnd: The EKRecurrenceEnd to convert
    init(from recurrenceEnd: EKRecurrenceEnd) {
        if recurrenceEnd.occurrenceCount > 0 {
            self = .occurrenceCount(recurrenceEnd.occurrenceCount)
        } else if let endDate = recurrenceEnd.endDate {
            self = .endDate(endDate)
        } else {
            // Fallback to occurrence count of 1
            self = .occurrenceCount(1)
        }
    }

    // MARK: - Conversion

    /// Convert to an EKRecurrenceEnd
    ///
    /// - Returns: An EKRecurrenceEnd with the serialized properties
    func toEKRecurrenceEnd() -> EKRecurrenceEnd {
        switch self {
        case .occurrenceCount(let count):
            return EKRecurrenceEnd(occurrenceCount: count)
        case .endDate(let date):
            return EKRecurrenceEnd(end: date)
        }
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case type
        case occurrenceCount
        case endDate
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case "occurrenceCount":
            let count = try container.decode(Int.self, forKey: .occurrenceCount)
            self = .occurrenceCount(count)
        case "endDate":
            let date = try container.decode(Date.self, forKey: .endDate)
            self = .endDate(date)
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown type: \(type)")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .occurrenceCount(let count):
            try container.encode("occurrenceCount", forKey: .type)
            try container.encode(count, forKey: .occurrenceCount)
        case .endDate(let date):
            try container.encode("endDate", forKey: .type)
            try container.encode(date, forKey: .endDate)
        }
    }
}
