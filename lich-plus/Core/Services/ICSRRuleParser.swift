//
//  ICSRRuleParser.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 08/12/25.
//

import Foundation

// MARK: - ICSRRuleParserError

/// Errors that can occur during RRULE parsing
enum ICSRRuleParserError: Error, LocalizedError {
    case missingFrequency
    case invalidFrequency(String)
    case invalidInterval
    case invalidByDay(String)
    case invalidByMonthDay(String)
    case invalidByMonth(String)
    case invalidCount
    case invalidUntil(String)
    case invalidExDate(String)

    var errorDescription: String? {
        switch self {
        case .missingFrequency:
            return "RRULE must contain FREQ parameter"
        case .invalidFrequency(let freq):
            return "Invalid FREQ value: \(freq). Expected DAILY, WEEKLY, MONTHLY, or YEARLY"
        case .invalidInterval:
            return "Invalid INTERVAL value. Must be a positive integer"
        case .invalidByDay(let value):
            return "Invalid BYDAY value: \(value)"
        case .invalidByMonthDay(let value):
            return "Invalid BYMONTHDAY value: \(value)"
        case .invalidByMonth(let value):
            return "Invalid BYMONTH value: \(value)"
        case .invalidCount:
            return "Invalid COUNT value. Must be a positive integer"
        case .invalidUntil(let value):
            return "Invalid UNTIL value: \(value). Expected format YYYYMMDD, YYYYMMDDThhmmss, or YYYYMMDDThhmmssZ"
        case .invalidExDate(let value):
            return "Invalid EXDATE value: \(value). Expected format YYYYMMDD, YYYYMMDDThhmmss, or YYYYMMDDThhmmssZ"
        }
    }
}

// MARK: - ICSRRuleParser

/// Parser for RFC 5545 RRULE (recurrence rule) strings
///
/// Parses RRULE strings into SerializableRecurrenceRule objects.
/// Supports all common RRULE components: FREQ, INTERVAL, BYDAY, BYMONTHDAY, BYMONTH, UNTIL, COUNT
///
/// Example usage:
/// ```swift
/// let rule = try ICSRRuleParser.parse("FREQ=WEEKLY;BYDAY=MO,WE,FR;UNTIL=20251231T235959Z")
/// ```
struct ICSRRuleParser {

    // MARK: - Public API

    /// Parse an RRULE string into a SerializableRecurrenceRule
    ///
    /// - Parameter rruleString: The RRULE string to parse (e.g., "FREQ=DAILY;INTERVAL=1")
    /// - Returns: A SerializableRecurrenceRule containing the parsed recurrence data
    /// - Throws: ICSRRuleParserError if the RRULE string is invalid
    static func parse(_ rruleString: String) throws -> SerializableRecurrenceRule {
        let trimmed = rruleString.trimmingCharacters(in: .whitespaces)

        // Parse key-value pairs
        let components = trimmed.split(separator: ";").map(String.init)
        var parameters: [String: String] = [:]

        for component in components {
            let parts = component.split(separator: "=", maxSplits: 1).map(String.init)
            guard parts.count == 2 else { continue }

            let key = parts[0].trimmingCharacters(in: .whitespaces).uppercased()
            let value = parts[1].trimmingCharacters(in: .whitespaces)
            parameters[key] = value
        }

        // Parse FREQ (required)
        guard let freqValue = parameters["FREQ"] else {
            throw ICSRRuleParserError.missingFrequency
        }

        let frequency = try parseFrequency(freqValue)

        // Parse INTERVAL (optional, default 1)
        let interval = try parseInterval(parameters["INTERVAL"])

        // Parse BYDAY (optional)
        let daysOfTheWeek = try parseByday(parameters["BYDAY"])

        // Parse BYMONTHDAY (optional)
        let daysOfTheMonth = try parseBymonthday(parameters["BYMONTHDAY"])

        // Parse BYMONTH (optional)
        let monthsOfTheYear = try parseBymonth(parameters["BYMONTH"])

        // Parse recurrence end: COUNT or UNTIL (optional)
        let recurrenceEnd = try parseRecurrenceEnd(count: parameters["COUNT"], until: parameters["UNTIL"])

        return SerializableRecurrenceRule(
            frequency: frequency,
            interval: interval,
            daysOfTheWeek: daysOfTheWeek,
            daysOfTheMonth: daysOfTheMonth,
            monthsOfTheYear: monthsOfTheYear,
            recurrenceEnd: recurrenceEnd
        )
    }

    /// Parse EXDATE strings into Date objects
    ///
    /// - Parameter exdateStrings: Array of EXDATE value strings (may contain comma-separated dates)
    /// - Returns: Array of Date objects parsed from EXDATE strings
    /// - Throws: ICSRRuleParserError.invalidExDate if any date cannot be parsed
    ///
    /// Supports four date formats:
    /// 1. UTC: YYYYMMDDThhmmssZ (e.g., "20251231T235959Z")
    /// 2. Local: YYYYMMDDThhmmss (e.g., "20251231T235959")
    /// 3. Date with trailing T: YYYYMMDDT (e.g., "20251231T")
    /// 4. Date only: YYYYMMDD (e.g., "20251231")
    static func parseExDates(_ exdateStrings: [String]) throws -> [Date] {
        var dates: [Date] = []

        for exdateString in exdateStrings {
            // Split by comma to handle multiple dates in one EXDATE line
            let dateStrings = exdateString.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }

            for dateString in dateStrings {
                let date = try parseExDate(dateString)
                dates.append(date)
            }
        }

        return dates
    }

    // MARK: - Private Parsing Functions

    /// Parse FREQ parameter
    /// Maps: DAILY=0, WEEKLY=1, MONTHLY=2, YEARLY=3
    private static func parseFrequency(_ value: String) throws -> Int {
        let upperValue = value.uppercased()

        switch upperValue {
        case "DAILY":
            return 0
        case "WEEKLY":
            return 1
        case "MONTHLY":
            return 2
        case "YEARLY":
            return 3
        default:
            throw ICSRRuleParserError.invalidFrequency(value)
        }
    }

    /// Parse INTERVAL parameter
    /// Default: 1 if not provided
    private static func parseInterval(_ value: String?) throws -> Int {
        guard let value = value else {
            return 1 // Default
        }

        guard let interval = Int(value), interval > 0 else {
            throw ICSRRuleParserError.invalidInterval
        }

        return interval
    }

    /// Parse BYDAY parameter
    /// Supports formats:
    /// - Simple: "MO,TU,WE" -> [Mon, Tue, Wed]
    /// - Week numbers: "1MO,2TU,-1FR" -> [First Mon, Second Tue, Last Fri]
    /// - Mixed: "MO,2TU,SA"
    private static func parseByday(_ value: String?) throws -> [SerializableDayOfWeek]? {
        guard let value = value else {
            return nil
        }

        let dayStrings = value.split(separator: ",").map(String.init)
        var days: [SerializableDayOfWeek] = []

        for dayString in dayStrings {
            let trimmed = dayString.trimmingCharacters(in: .whitespaces)
            let (dayOfWeek, week) = try parseDayOfWeekWithOptionalWeek(trimmed)
            var dayOfWeekObj = SerializableDayOfWeek(dayOfWeek: dayOfWeek, week: week)
            days.append(dayOfWeekObj)
        }

        return days.isEmpty ? nil : days
    }

    /// Parse a single day of week entry, which may include an optional week number
    /// Examples:
    /// - "MO" -> (2, nil)
    /// - "2TU" -> (3, 2)
    /// - "-1FR" -> (6, -1)
    private static func parseDayOfWeekWithOptionalWeek(_ value: String) throws -> (dayOfWeek: Int, week: Int?) {
        let upperValue = value.uppercased()

        // Check if value starts with a number (week number format)
        var weekNumber: Int? = nil
        var dayCode: String = upperValue

        // Try to extract week number from the beginning
        let pattern = "^([+-]?\\d+)([A-Z]{2})$"
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let range = NSRange(upperValue.startIndex..<upperValue.endIndex, in: upperValue)
            if let match = regex.firstMatch(in: upperValue, range: range) {
                if let weekRange = Range(match.range(at: 1), in: upperValue),
                   let dayRange = Range(match.range(at: 2), in: upperValue) {
                    if let week = Int(String(upperValue[weekRange])) {
                        weekNumber = week
                        dayCode = String(upperValue[dayRange])
                    }
                }
            }
        } catch {
            // If regex fails, continue with default parsing
        }

        // Parse the day code (last 2 characters)
        let dayOfWeek = try parseDayCode(dayCode)
        return (dayOfWeek, weekNumber)
    }

    /// Parse day code (SU, MO, TU, WE, TH, FR, SA)
    /// Maps to: 1=SU, 2=MO, 3=TU, 4=WE, 5=TH, 6=FR, 7=SA
    private static func parseDayCode(_ code: String) throws -> Int {
        let upperCode = code.uppercased()

        switch upperCode {
        case "SU":
            return 1
        case "MO":
            return 2
        case "TU":
            return 3
        case "WE":
            return 4
        case "TH":
            return 5
        case "FR":
            return 6
        case "SA":
            return 7
        default:
            throw ICSRRuleParserError.invalidByDay(code)
        }
    }

    /// Parse BYMONTHDAY parameter
    /// Supports positive (1-31) and negative (-1 to -31) values
    private static func parseBymonthday(_ value: String?) throws -> [Int]? {
        guard let value = value else {
            return nil
        }

        let dayStrings = value.split(separator: ",").map(String.init)
        var days: [Int] = []

        for dayString in dayStrings {
            let trimmed = dayString.trimmingCharacters(in: .whitespaces)
            guard let day = Int(trimmed) else {
                throw ICSRRuleParserError.invalidByMonthDay(dayString)
            }
            days.append(day)
        }

        return days.isEmpty ? nil : days
    }

    /// Parse BYMONTH parameter
    /// Valid values: 1-12
    private static func parseBymonth(_ value: String?) throws -> [Int]? {
        guard let value = value else {
            return nil
        }

        let monthStrings = value.split(separator: ",").map(String.init)
        var months: [Int] = []

        for monthString in monthStrings {
            let trimmed = monthString.trimmingCharacters(in: .whitespaces)
            guard let month = Int(trimmed), (1...12).contains(month) else {
                throw ICSRRuleParserError.invalidByMonth(monthString)
            }
            months.append(month)
        }

        return months.isEmpty ? nil : months
    }

    /// Parse COUNT and UNTIL parameters to create recurrence end
    /// Exactly one should be provided; COUNT takes precedence if both are present
    private static func parseRecurrenceEnd(count: String?, until: String?) throws -> SerializableRecurrenceEnd? {
        // COUNT takes precedence
        if let countValue = count {
            guard let count = Int(countValue), count > 0 else {
                throw ICSRRuleParserError.invalidCount
            }
            return .occurrenceCount(count)
        }

        // UNTIL
        if let untilValue = until {
            let date = try parseUntilDate(untilValue)
            return .endDate(date)
        }

        return nil
    }

    /// Parse UNTIL date value
    /// Supports three formats:
    /// 1. UTC: YYYYMMDDThhmmssZ (e.g., "20251231T235959Z")
    /// 2. Local: YYYYMMDDThhmmss (e.g., "20251231T235959")
    /// 3. Date only: YYYYMMDD (e.g., "20251231")
    private static func parseUntilDate(_ value: String) throws -> Date {
        let trimmed = value.trimmingCharacters(in: .whitespaces)

        var formatter: DateFormatter

        // Try UTC format first (with Z suffix)
        if trimmed.hasSuffix("Z") {
            formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
            formatter.timeZone = TimeZone(abbreviation: "UTC")

            if let date = formatter.date(from: trimmed) {
                return date
            }
        }

        // Try datetime format (without Z)
        if trimmed.count >= 15 && trimmed.contains("T") {
            formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd'T'HHmmss"
            formatter.timeZone = TimeZone.current

            if let date = formatter.date(from: trimmed) {
                return date
            }
        }

        // Try date-only format
        if trimmed.count == 8 {
            formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd"
            formatter.timeZone = TimeZone.current

            if let date = formatter.date(from: trimmed) {
                return date
            }
        }

        throw ICSRRuleParserError.invalidUntil(value)
    }

    /// Parse a single EXDATE value
    /// Supports three formats:
    /// 1. UTC: YYYYMMDDThhmmssZ (e.g., "20251231T235959Z")
    /// 2. Local: YYYYMMDDThhmmss (e.g., "20251231T235959")
    /// 3. Date only: YYYYMMDD (e.g., "20251231")
    private static func parseExDate(_ value: String) throws -> Date {
        let trimmed = value.trimmingCharacters(in: .whitespaces)

        var formatter: DateFormatter

        // Try UTC format first (with Z suffix)
        if trimmed.hasSuffix("Z") {
            formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
            formatter.timeZone = TimeZone(abbreviation: "UTC")

            if let date = formatter.date(from: trimmed) {
                return date
            }
        }

        // Try datetime format (without Z)
        if trimmed.count >= 15 && trimmed.contains("T") {
            formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd'T'HHmmss"
            formatter.timeZone = TimeZone.current

            if let date = formatter.date(from: trimmed) {
                return date
            }
        }

        // Try date with trailing T format (e.g., "20251009T")
        if trimmed.count == 9 && trimmed.hasSuffix("T") {
            formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd'T'"
            formatter.timeZone = TimeZone.current

            if let date = formatter.date(from: trimmed) {
                return date
            }
        }

        // Try date-only format
        if trimmed.count == 8 {
            formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd"
            formatter.timeZone = TimeZone.current

            if let date = formatter.date(from: trimmed) {
                return date
            }
        }

        throw ICSRRuleParserError.invalidExDate(value)
    }
}
