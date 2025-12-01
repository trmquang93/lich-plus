//
//  ICSParser.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 30/11/25.
//

import Foundation

struct ICSEvent {
    let uid: String
    let summary: String
    let description: String?
    let startDate: Date
    let endDate: Date?
    let isAllDay: Bool
    let location: String?
    let recurrenceRule: String?
}

enum ICSParserError: LocalizedError, Equatable {
    case invalidFormat
    case missingUID
    case missingSummary
    case invalidDateFormat
    case invalidURL
    case networkError(String)
    case emptyContent

    var errorDescription: String? {
        switch self {
        case .invalidFormat:
            return "Invalid ICS format"
        case .missingUID:
            return "Event missing UID"
        case .missingSummary:
            return "Event missing summary"
        case .invalidDateFormat:
            return "Invalid date format in ICS"
        case .invalidURL:
            return "Invalid calendar URL"
        case .networkError(let message):
            return "Network error: \(message)"
        case .emptyContent:
            return "Calendar is empty"
        }
    }
}

class ICSParser {
    private let dateFormatter = ISO8601DateFormatter()
    private let dateFormatterWithoutTime = DateFormatter()

    init() {
        dateFormatter.formatOptions = [.withInternetDateTime]
        dateFormatterWithoutTime.dateFormat = "yyyyMMdd"
        dateFormatterWithoutTime.timeZone = TimeZone(abbreviation: "UTC")
    }

    // MARK: - Parsing Methods

    /// Parse ICS content string and return array of ICSEvents
    func parse(_ icsContent: String) throws -> [ICSEvent] {
        guard !icsContent.isEmpty else {
            throw ICSParserError.emptyContent
        }

        let lines = icsContent.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        guard lines.contains("BEGIN:VCALENDAR") && lines.contains("END:VCALENDAR") else {
            throw ICSParserError.invalidFormat
        }

        var events: [ICSEvent] = []
        var currentEventLines: [String] = []
        var inEvent = false
        var lastParseError: Error?

        for line in lines {
            if line == "BEGIN:VEVENT" {
                inEvent = true
                currentEventLines = []
            } else if line == "END:VEVENT" {
                inEvent = false
                if !currentEventLines.isEmpty {
                    do {
                        let event = try parseEvent(currentEventLines)
                        events.append(event)
                    } catch {
                        // Track the last error for reporting if no events parse successfully
                        lastParseError = error
                        // Continue parsing other events
                        continue
                    }
                }
                currentEventLines = []
            } else if inEvent {
                currentEventLines.append(line)
            }
        }

        // If no events were successfully parsed but we had parsing errors, throw the last error
        if events.isEmpty, let error = lastParseError {
            throw error
        }

        return events
    }

    // MARK: - Private Parsing Methods

    private func parseEvent(_ lines: [String]) throws -> ICSEvent {
        var uid: String?
        var summary: String?
        var description: String?
        var startDate: Date?
        var endDate: Date?
        var isAllDay = false
        var location: String?
        var recurrenceRule: String?

        for line in lines {
            // Handle line folding (continuation lines)
            let cleanLine = line.replacingOccurrences(of: "\\n", with: "\n")

            if cleanLine.starts(with: "UID:") {
                uid = extractValue(from: cleanLine, prefix: "UID:")
            } else if cleanLine.hasPrefix("SUMMARY") {
                // Handle both SUMMARY: and SUMMARY;params: formats
                summary = extractValueWithParams(from: cleanLine)
            } else if cleanLine.hasPrefix("DESCRIPTION") {
                // Handle both DESCRIPTION: and DESCRIPTION;params: formats
                description = extractValueWithParams(from: cleanLine)
            } else if cleanLine.starts(with: "DTSTART") {
                (startDate, isAllDay) = try parseDateTime(cleanLine)
            } else if cleanLine.starts(with: "DTEND") {
                (endDate, _) = try parseDateTime(cleanLine)
            } else if cleanLine.starts(with: "LOCATION:") {
                location = extractValue(from: cleanLine, prefix: "LOCATION:")
            } else if cleanLine.starts(with: "RRULE:") {
                recurrenceRule = extractValue(from: cleanLine, prefix: "RRULE:")
            }
        }

        guard let uid = uid else {
            throw ICSParserError.missingUID
        }

        guard let summary = summary else {
            throw ICSParserError.missingSummary
        }

        guard let startDate = startDate else {
            throw ICSParserError.invalidDateFormat
        }

        return ICSEvent(
            uid: uid,
            summary: summary,
            description: description,
            startDate: startDate,
            endDate: endDate,
            isAllDay: isAllDay,
            location: location,
            recurrenceRule: recurrenceRule
        )
    }

    private func parseDateTime(_ line: String) throws -> (date: Date, isAllDay: Bool) {
        // Line format can be:
        // DTSTART:20231225T100000Z
        // DTSTART:20231225
        // DTSTART;TZID=America/New_York:20231225T100000

        let colonIndex = line.firstIndex(of: ":") ?? line.endIndex
        let valuePart = String(line[line.index(after: colonIndex)...])

        // Check if it's an all-day event (no time component and VALUE=DATE)
        if line.contains("VALUE=DATE") || (!valuePart.contains("T") && valuePart.count == 8) {
            if let date = dateFormatterWithoutTime.date(from: valuePart) {
                return (date, true)
            }
        }

        // Try to parse compact ICS format with Z (UTC): 20231225T100000Z
        let compactUTCFormatter = DateFormatter()
        compactUTCFormatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        compactUTCFormatter.timeZone = TimeZone(abbreviation: "UTC")
        if let date = compactUTCFormatter.date(from: valuePart) {
            return (date, false)
        }

        // Try to parse as ISO8601 datetime with Z (UTC): 2023-12-25T10:00:00Z
        if let date = dateFormatter.date(from: valuePart) {
            return (date, false)
        }

        // Try to parse datetime without timezone info (local interpretation): 20231225T100000
        let localFormatter = DateFormatter()
        localFormatter.dateFormat = "yyyyMMdd'T'HHmmss"
        if let date = localFormatter.date(from: valuePart) {
            return (date, false)
        }

        throw ICSParserError.invalidDateFormat
    }

    private func extractValue(from line: String, prefix: String) -> String {
        guard let colonIndex = line.firstIndex(of: ":") else {
            return ""
        }
        let value = String(line[line.index(after: colonIndex)...])
        return unescapeICSString(value)
    }

    /// Extract value from ICS property that may have parameters
    /// Handles both "PROP:value" and "PROP;param=x:value" formats
    private func extractValueWithParams(from line: String) -> String {
        guard let colonIndex = line.firstIndex(of: ":") else {
            return ""
        }
        let value = String(line[line.index(after: colonIndex)...])
        return unescapeICSString(value)
    }

    private func unescapeICSString(_ str: String) -> String {
        var result = str
        result = result.replacingOccurrences(of: "\\n", with: "\n")
        result = result.replacingOccurrences(of: "\\,", with: ",")
        result = result.replacingOccurrences(of: "\\;", with: ";")
        result = result.replacingOccurrences(of: "\\\\", with: "\\")
        return result
    }
}
