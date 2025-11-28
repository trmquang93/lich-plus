import Foundation

// MARK: - Calendar List Response

struct MicrosoftCalendarListResponse: Codable {
    let value: [MicrosoftCalendar]
    let nextLink: String?

    enum CodingKeys: String, CodingKey {
        case value
        case nextLink = "@odata.nextLink"
    }
}

struct MicrosoftCalendar: Codable, Identifiable {
    let id: String
    let name: String
    let color: String?              // "auto", "lightBlue", "lightGreen", etc.
    let hexColor: String?           // Actual hex if available
    let isDefaultCalendar: Bool?
    let canEdit: Bool?
    let owner: MicrosoftEmailAddress?

    enum CodingKeys: String, CodingKey {
        case id, name, color, hexColor, isDefaultCalendar, canEdit, owner
    }
}

struct MicrosoftEmailAddress: Codable {
    let name: String?
    let address: String?
}

// MARK: - Event List Response

struct MicrosoftEventListResponse: Codable {
    let value: [MicrosoftEvent]?
    let nextLink: String?

    enum CodingKeys: String, CodingKey {
        case value
        case nextLink = "@odata.nextLink"
    }
}

struct MicrosoftEvent: Codable, Identifiable {
    let id: String
    let subject: String?
    let bodyPreview: String?
    let start: MicrosoftDateTime?
    let end: MicrosoftDateTime?
    let location: MicrosoftLocation?
    let isAllDay: Bool?
    let isCancelled: Bool?
    let lastModifiedDateTime: String?
    let recurrence: MicrosoftRecurrence?
    let showAs: String?             // "free", "tentative", "busy", "oof", "unknown"
    let importance: String?         // "low", "normal", "high"

    enum CodingKeys: String, CodingKey {
        case id, subject, bodyPreview, start, end, location
        case isAllDay, isCancelled, lastModifiedDateTime, recurrence
        case showAs, importance
    }
}

struct MicrosoftDateTime: Codable {
    let dateTime: String            // "2025-11-28T10:00:00.0000000"
    let timeZone: String            // "UTC" or specific timezone

    /// Parse the dateTime string into a Swift Date
    func toDate() -> Date? {
        // Microsoft Graph returns dates in format: "2025-11-28T10:00:00.0000000"
        let formatters = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS",
            "yyyy-MM-dd'T'HH:mm:ss.SSS",
            "yyyy-MM-dd'T'HH:mm:ss",
            "yyyy-MM-dd"
        ]

        for format in formatters {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            formatter.locale = Locale(identifier: "en_US_POSIX")

            // Handle timezone
            if timeZone == "UTC" {
                formatter.timeZone = TimeZone(identifier: "UTC")
            } else if let tz = TimeZone(identifier: timeZone) {
                formatter.timeZone = tz
            } else {
                formatter.timeZone = TimeZone.current
            }

            if let date = formatter.date(from: dateTime) {
                return date
            }
        }

        return nil
    }
}

struct MicrosoftLocation: Codable {
    let displayName: String?
    let address: MicrosoftAddress?
    let coordinates: MicrosoftCoordinates?
}

struct MicrosoftAddress: Codable {
    let street: String?
    let city: String?
    let state: String?
    let countryOrRegion: String?
    let postalCode: String?
}

struct MicrosoftCoordinates: Codable {
    let latitude: Double?
    let longitude: Double?
}

struct MicrosoftRecurrence: Codable {
    let pattern: MicrosoftRecurrencePattern?
    let range: MicrosoftRecurrenceRange?
}

struct MicrosoftRecurrencePattern: Codable {
    let type: String?               // "daily", "weekly", "absoluteMonthly", "relativeMonthly", "absoluteYearly", "relativeYearly"
    let interval: Int?
    let daysOfWeek: [String]?       // "sunday", "monday", etc.
    let dayOfMonth: Int?
    let month: Int?
    let firstDayOfWeek: String?
}

struct MicrosoftRecurrenceRange: Codable {
    let type: String?               // "endDate", "noEnd", "numbered"
    let startDate: String?
    let endDate: String?
    let numberOfOccurrences: Int?
}

// MARK: - Color Mapping

struct MicrosoftCalendarColor {
    /// Map Microsoft color names to hex values
    static let colorMap: [String: String] = [
        "auto": "#0078D4",
        "lightBlue": "#71AFE5",
        "lightGreen": "#7BD148",
        "lightOrange": "#FFB878",
        "lightGray": "#B3B3B3",
        "lightYellow": "#FBD75B",
        "lightTeal": "#92E1C0",
        "lightPink": "#F691B2",
        "lightBrown": "#AC725E",
        "lightRed": "#F83A22",
        "maxColor": "#0078D4"
    ]

    static func hexColor(for colorName: String?) -> String {
        guard let name = colorName else { return "#0078D4" }
        return colorMap[name] ?? "#0078D4"
    }
}
