import Foundation

@MainActor
class MicrosoftCalendarService {
    private let authService: MicrosoftAuthService
    private let baseURL = "https://graph.microsoft.com/v1.0"
    private let session: URLSession

    init(authService: MicrosoftAuthService) {
        self.authService = authService
        self.session = URLSession.shared
    }

    // MARK: - Fetch Calendar List

    /// Fetch all calendars for the signed-in user
    func fetchCalendarList() async throws -> [MicrosoftCalendar] {
        let accessToken = try await authService.getAccessToken()

        var allCalendars: [MicrosoftCalendar] = []
        var nextLink: String? = "\(baseURL)/me/calendars?$top=100"

        while let urlString = nextLink {
            guard let url = URL(string: urlString) else {
                throw MicrosoftCalendarError.invalidURL
            }

            var request = URLRequest(url: url)
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Accept")

            let (data, response) = try await session.data(for: request)

            try validateResponse(response, data: data)

            let calendarResponse = try JSONDecoder().decode(MicrosoftCalendarListResponse.self, from: data)
            allCalendars.append(contentsOf: calendarResponse.value)
            nextLink = calendarResponse.nextLink
        }

        return allCalendars
    }

    // MARK: - Fetch Events

    /// Fetch events from a specific calendar within a date range
    func fetchEvents(
        calendarId: String,
        from startDate: Date,
        to endDate: Date
    ) async throws -> [MicrosoftEvent] {
        let accessToken = try await authService.getAccessToken()

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]

        let startString = formatter.string(from: startDate)
        let endString = formatter.string(from: endDate)

        var allEvents: [MicrosoftEvent] = []
        var nextLink: String? = "\(baseURL)/me/calendars/\(calendarId)/calendarView?startDateTime=\(startString)&endDateTime=\(endString)&$top=100&$orderby=start/dateTime"

        while let urlString = nextLink {
            guard let url = URL(string: urlString) else {
                throw MicrosoftCalendarError.invalidURL
            }

            var request = URLRequest(url: url)
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("Pacific Standard Time", forHTTPHeaderField: "Prefer")

            let (data, response) = try await session.data(for: request)

            try validateResponse(response, data: data)

            let eventResponse = try JSONDecoder().decode(MicrosoftEventListResponse.self, from: data)
            if let items = eventResponse.value {
                // Filter out cancelled events
                let activeEvents = items.filter { $0.isCancelled != true }
                allEvents.append(contentsOf: activeEvents)
            }
            nextLink = eventResponse.nextLink
        }

        return allEvents
    }

    // MARK: - Convert to SyncableEvent

    /// Convert a MicrosoftEvent to SyncableEvent for local storage
    func convertToSyncableEvent(_ microsoftEvent: MicrosoftEvent, calendarId: String) -> SyncableEvent {
        let startDate = microsoftEvent.start?.toDate() ?? Date()
        let endDate = microsoftEvent.end?.toDate()
        let isAllDay = microsoftEvent.isAllDay ?? false

        // Build location string
        var locationString: String? = nil
        if let location = microsoftEvent.location {
            if let displayName = location.displayName, !displayName.isEmpty {
                locationString = displayName
            } else if let address = location.address {
                let parts = [address.street, address.city, address.state].compactMap { $0 }
                if !parts.isEmpty {
                    locationString = parts.joined(separator: ", ")
                }
            }
        }

        let event = SyncableEvent(
            title: microsoftEvent.subject ?? "Untitled Event",
            startDate: startDate,
            endDate: endDate,
            isAllDay: isAllDay,
            notes: microsoftEvent.bodyPreview,
            isCompleted: false,
            category: "other",
            reminderMinutes: nil,
            recurrenceRuleData: nil,
            itemType: ItemType.event.rawValue,
            priority: mapImportance(microsoftEvent.importance),
            location: locationString
        )

        // Set Microsoft-specific fields
        event.microsoftEventId = microsoftEvent.id
        event.microsoftCalendarId = calendarId
        event.source = EventSource.microsoftExchange.rawValue
        event.syncStatus = SyncStatus.synced.rawValue

        // Parse lastModifiedDateTime
        if let modified = microsoftEvent.lastModifiedDateTime {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = formatter.date(from: modified) {
                event.lastModifiedRemote = date
            } else {
                // Try without fractional seconds
                formatter.formatOptions = [.withInternetDateTime]
                event.lastModifiedRemote = formatter.date(from: modified)
            }
        }

        return event
    }

    // MARK: - Private Helpers

    private func mapImportance(_ importance: String?) -> String {
        switch importance {
        case "high":
            return Priority.high.rawValue
        case "low":
            return Priority.low.rawValue
        default:
            return Priority.none.rawValue
        }
    }

    private func validateResponse(_ response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw MicrosoftCalendarError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            return // Success
        case 401:
            throw MicrosoftCalendarError.unauthorized
        case 403:
            throw MicrosoftCalendarError.forbidden
        case 404:
            throw MicrosoftCalendarError.notFound
        case 429:
            throw MicrosoftCalendarError.rateLimited
        default:
            // Try to extract error message from response
            if let errorResponse = try? JSONDecoder().decode(MicrosoftErrorResponse.self, from: data) {
                throw MicrosoftCalendarError.apiError(errorResponse.error.message)
            }
            throw MicrosoftCalendarError.httpError(httpResponse.statusCode)
        }
    }
}

// MARK: - Errors

enum MicrosoftCalendarError: LocalizedError {
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
            return "Invalid response from Microsoft Graph API"
        case .unauthorized:
            return "Authentication expired. Please sign in again."
        case .forbidden:
            return "Access denied to Microsoft Calendar"
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

private struct MicrosoftErrorResponse: Codable {
    let error: MicrosoftAPIError
}

private struct MicrosoftAPIError: Codable {
    let code: String
    let message: String
}
