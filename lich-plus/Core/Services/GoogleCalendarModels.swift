//
//  GoogleCalendarModels.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 27/11/25.
//

import Foundation

// MARK: - Calendar List Response

struct GoogleCalendarListResponse: Codable {
    let kind: String?
    let etag: String?
    let items: [GoogleCalendar]
    let nextPageToken: String?
}

struct GoogleCalendar: Codable, Identifiable {
    let id: String
    let summary: String
    let description: String?
    let backgroundColor: String?
    let foregroundColor: String?
    let primary: Bool?
    let accessRole: String?
    let selected: Bool?

    enum CodingKeys: String, CodingKey {
        case id, summary, description, backgroundColor, foregroundColor
        case primary, accessRole, selected
    }
}

// MARK: - Event List Response

struct GoogleEventListResponse: Codable {
    let kind: String?
    let etag: String?
    let summary: String?
    let items: [GoogleEvent]?
    let nextPageToken: String?
    let nextSyncToken: String?
}

struct GoogleEvent: Codable, Identifiable {
    let id: String
    let status: String?
    let htmlLink: String?
    let created: String?
    let updated: String?
    let summary: String?
    let description: String?
    let location: String?
    let start: GoogleDateTime?
    let end: GoogleDateTime?
    let recurrence: [String]?
    let recurringEventId: String?

    enum CodingKeys: String, CodingKey {
        case id, status, htmlLink, created, updated, summary
        case description, location, start, end, recurrence, recurringEventId
    }
}

struct GoogleDateTime: Codable {
    let date: String?           // For all-day events (YYYY-MM-DD)
    let dateTime: String?       // For timed events (ISO8601)
    let timeZone: String?

    /// Parse the date/dateTime into a Swift Date
    func toDate() -> Date? {
        if let dateTime = dateTime {
            // ISO8601 format for timed events
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = formatter.date(from: dateTime) {
                return date
            }
            // Try without fractional seconds
            formatter.formatOptions = [.withInternetDateTime]
            return formatter.date(from: dateTime)
        } else if let date = date {
            // YYYY-MM-DD format for all-day events
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.timeZone = TimeZone.current
            return formatter.date(from: date)
        }
        return nil
    }

    /// Check if this is an all-day event
    var isAllDay: Bool {
        return date != nil && dateTime == nil
    }
}
