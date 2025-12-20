//
//  GoogleCalendarService.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 27/11/25.
//

import Foundation

@MainActor
class GoogleCalendarService {
    private let authService: GoogleAuthService
    private let baseURL = "https://www.googleapis.com/calendar/v3"
    private let session: URLSession

    init(authService: GoogleAuthService) {
        self.authService = authService
        self.session = URLSession.shared
    }

    // MARK: - Fetch Calendar List

    /// Fetch all calendars for the signed-in user
    func fetchCalendarList() async throws -> [GoogleCalendar] {
        let accessToken = try await authService.getAccessToken()

        var allCalendars: [GoogleCalendar] = []
        var pageToken: String?

        repeat {
            var urlComponents = URLComponents(string: "\(baseURL)/users/me/calendarList")!
            var queryItems = [URLQueryItem(name: "maxResults", value: "250")]
            if let token = pageToken {
                queryItems.append(URLQueryItem(name: "pageToken", value: token))
            }
            urlComponents.queryItems = queryItems

            guard let url = urlComponents.url else {
                throw GoogleCalendarError.invalidURL
            }

            var request = URLRequest(url: url)
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Accept")

            let (data, response) = try await session.data(for: request)

            try validateResponse(response, data: data)

            let calendarResponse = try JSONDecoder().decode(GoogleCalendarListResponse.self, from: data)
            allCalendars.append(contentsOf: calendarResponse.items)
            pageToken = calendarResponse.nextPageToken

        } while pageToken != nil

        return allCalendars
    }

    // MARK: - Fetch Events

    /// Fetch events from a specific calendar within a date range
    func fetchEvents(
        calendarId: String,
        from startDate: Date,
        to endDate: Date
    ) async throws -> [GoogleEvent] {
        let accessToken = try await authService.getAccessToken()

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]

        var allEvents: [GoogleEvent] = []
        var pageToken: String?

        repeat {
            var urlComponents = URLComponents(string: "\(baseURL)/calendars/\(calendarId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? calendarId)/events")!
            var queryItems = [
                URLQueryItem(name: "maxResults", value: "2500"),
                URLQueryItem(name: "singleEvents", value: "true"),
                URLQueryItem(name: "orderBy", value: "startTime"),
                URLQueryItem(name: "timeMin", value: formatter.string(from: startDate)),
                URLQueryItem(name: "timeMax", value: formatter.string(from: endDate))
            ]
            if let token = pageToken {
                queryItems.append(URLQueryItem(name: "pageToken", value: token))
            }
            urlComponents.queryItems = queryItems

            guard let url = urlComponents.url else {
                throw GoogleCalendarError.invalidURL
            }

            var request = URLRequest(url: url)
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Accept")

            let (data, response) = try await session.data(for: request)

            try validateResponse(response, data: data)

            let eventResponse = try JSONDecoder().decode(GoogleEventListResponse.self, from: data)
            if let items = eventResponse.items {
                // Filter out cancelled events
                let activeEvents = items.filter { $0.status != "cancelled" }
                allEvents.append(contentsOf: activeEvents)
            }
            pageToken = eventResponse.nextPageToken

        } while pageToken != nil

        return allEvents
    }

    /// Fetch ALL events from a specific calendar without date limits
    /// - Parameters:
    ///   - calendarId: The calendar ID
    ///   - progressHandler: Optional callback for progress updates (events fetched so far)
    /// - Returns: Array of all GoogleEvent objects
    func fetchAllEvents(
        calendarId: String,
        progressHandler: ((Int) -> Void)? = nil
    ) async throws -> [GoogleEvent] {
        let accessToken = try await authService.getAccessToken()

        var allEvents: [GoogleEvent] = []
        var pageToken: String?

        repeat {
            var urlComponents = URLComponents(string: "\(baseURL)/calendars/\(calendarId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? calendarId)/events")!
            var queryItems = [
                URLQueryItem(name: "maxResults", value: "2500"),
                URLQueryItem(name: "singleEvents", value: "true"),
                URLQueryItem(name: "orderBy", value: "updated")
            ]
            if let token = pageToken {
                queryItems.append(URLQueryItem(name: "pageToken", value: token))
            }
            urlComponents.queryItems = queryItems

            guard let url = urlComponents.url else {
                throw GoogleCalendarError.invalidURL
            }

            var request = URLRequest(url: url)
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Accept")

            // Use RetryUtility for rate limit handling
            let (data, response) = try await RetryUtility.withExponentialBackoff {
                try await session.data(for: request)
            }

            try validateResponse(response, data: data)

            let eventResponse = try JSONDecoder().decode(GoogleEventListResponse.self, from: data)
            if let items = eventResponse.items {
                // Filter out cancelled events
                let activeEvents = items.filter { $0.status != "cancelled" }
                allEvents.append(contentsOf: activeEvents)
                progressHandler?(allEvents.count)
            }
            pageToken = eventResponse.nextPageToken

        } while pageToken != nil

        return allEvents
    }

    // MARK: - Push Operations (Create/Update/Delete)

    /// Create event in Google Calendar
    ///
    /// - Parameters:
    ///   - event: The SyncableEvent to create
    ///   - calendarId: The calendar ID to create in
    /// - Returns: The newly created event's Google event ID
    /// - Throws: GoogleCalendarError if the operation fails
    func createEvent(_ event: SyncableEvent, calendarId: String) async throws -> String {
        let accessToken = try await authService.getAccessToken()

        let payload = convertToGoogleEventPayload(event)
        let jsonData = try JSONSerialization.data(withJSONObject: payload)

        let urlString = "\(baseURL)/calendars/\(calendarId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? calendarId)/events"
        guard let url = URL(string: urlString) else {
            throw GoogleCalendarError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        let (data, response) = try await RetryUtility.withExponentialBackoff {
            try await session.data(for: request)
        }

        try validateResponse(response, data: data)

        let eventResponse = try JSONDecoder().decode(GoogleEvent.self, from: data)
        return eventResponse.id
    }

    /// Update event in Google Calendar
    ///
    /// - Parameters:
    ///   - event: The SyncableEvent with updated values
    ///   - calendarId: The calendar ID
    ///   - eventId: The Google event ID to update
    /// - Throws: GoogleCalendarError if the operation fails
    func updateEvent(_ event: SyncableEvent, calendarId: String, eventId: String) async throws {
        let accessToken = try await authService.getAccessToken()

        let payload = convertToGoogleEventPayload(event)
        let jsonData = try JSONSerialization.data(withJSONObject: payload)

        let urlString = "\(baseURL)/calendars/\(calendarId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? calendarId)/events/\(eventId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? eventId)"
        guard let url = URL(string: urlString) else {
            throw GoogleCalendarError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        let (data, response) = try await RetryUtility.withExponentialBackoff {
            try await session.data(for: request)
        }

        try validateResponse(response, data: data)
    }

    /// Delete event from Google Calendar
    ///
    /// - Parameters:
    ///   - calendarId: The calendar ID
    ///   - eventId: The Google event ID to delete
    /// - Throws: GoogleCalendarError if the operation fails
    func deleteEvent(calendarId: String, eventId: String) async throws {
        let accessToken = try await authService.getAccessToken()

        let urlString = "\(baseURL)/calendars/\(calendarId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? calendarId)/events/\(eventId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? eventId)"
        guard let url = URL(string: urlString) else {
            throw GoogleCalendarError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let (_, response) = try await RetryUtility.withExponentialBackoff {
            try await session.data(for: request)
        }

        try validateResponse(response, data: Data())
    }

    // MARK: - Payload Conversion

    /// Convert SyncableEvent to Google Calendar event payload
    private func convertToGoogleEventPayload(_ event: SyncableEvent) -> [String: Any] {
        var payload: [String: Any] = [:]

        // Required fields
        payload["summary"] = event.title

        // Optional fields
        if let notes = event.notes, !notes.isEmpty {
            payload["description"] = notes
        }

        if let location = event.location, !location.isEmpty {
            payload["location"] = location
        }

        // DateTime handling
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]

        if event.isAllDay {
            // All-day events use "date" format (YYYY-MM-DD)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            let startDateStr = dateFormatter.string(from: event.startDate)
            var endDateStr = dateFormatter.string(from: event.endDate ?? event.startDate)
            
            // Google Calendar requires end date to be exclusive for all-day events
            // If end date is same as start, add 1 day
            if event.startDate.timeIntervalSince1970 == event.endDate?.timeIntervalSince1970 {
                let calendar = Calendar.current
                let nextDay = calendar.date(byAdding: .day, value: 1, to: event.startDate)!
                endDateStr = dateFormatter.string(from: nextDay)
            }
            
            payload["start"] = ["date": startDateStr]
            payload["end"] = ["date": endDateStr]
        } else {
            // Timed events use "dateTime" format with timezone
            let startStr = formatter.string(from: event.startDate)
            let endStr = formatter.string(from: event.endDate ?? event.startDate.addingTimeInterval(3600))
            
            payload["start"] = [
                "dateTime": startStr,
                "timeZone": TimeZone.current.identifier
            ]
            payload["end"] = [
                "dateTime": endStr,
                "timeZone": TimeZone.current.identifier
            ]
        }

        return payload
    }

    // MARK: - Convert to SyncableEvent

    /// Convert a GoogleEvent to SyncableEvent for local storage
    func convertToSyncableEvent(_ googleEvent: GoogleEvent, calendarId: String) -> SyncableEvent {
        let startDate = googleEvent.start?.toDate() ?? Date()
        let endDate = googleEvent.end?.toDate()
        let isAllDay = googleEvent.start?.isAllDay ?? false

        let event = SyncableEvent(
            title: googleEvent.summary ?? "Untitled Event",
            startDate: startDate,
            endDate: endDate,
            isAllDay: isAllDay,
            notes: googleEvent.description,
            isCompleted: false,
            category: "other",
            reminderMinutes: nil,
            recurrenceRuleData: nil,
            itemType: "event",
            priority: "none",
            location: googleEvent.location
        )

        // Set Google-specific fields
        event.googleEventId = googleEvent.id
        event.googleCalendarId = calendarId
        event.source = EventSource.googleCalendar.rawValue
        event.syncStatus = SyncStatus.synced.rawValue

        // Parse updated timestamp
        if let updated = googleEvent.updated {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            event.lastModifiedRemote = formatter.date(from: updated)
        }

        return event
    }

    // MARK: - Private Helpers

    private func validateResponse(_ response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GoogleCalendarError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            return // Success
        case 401:
            throw GoogleCalendarError.unauthorized
        case 403:
            throw GoogleCalendarError.forbidden
        case 404:
            throw GoogleCalendarError.notFound
        case 429:
            throw GoogleCalendarError.rateLimited
        default:
            // Try to extract error message from response
            if let errorResponse = try? JSONDecoder().decode(GoogleErrorResponse.self, from: data) {
                throw GoogleCalendarError.apiError(errorResponse.error.message)
            }
            throw GoogleCalendarError.httpError(httpResponse.statusCode)
        }
    }
}

// MARK: - Errors

enum GoogleCalendarError: LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case forbidden
    case notFound
    case rateLimited
    case httpError(Int)
    case apiError(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid response from Google Calendar API"
        case .unauthorized:
            return "Authentication expired. Please sign in again."
        case .forbidden:
            return "Access denied to Google Calendar"
        case .notFound:
            return "Calendar not found"
        case .rateLimited:
            return "Too many requests. Please try again later."
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .apiError(let message):
            return message
        }
    }
}

// MARK: - Error Response Model

private struct GoogleErrorResponse: Codable {
    let error: GoogleAPIError
}

private struct GoogleAPIError: Codable {
    let code: Int
    let message: String
    let status: String?
}
