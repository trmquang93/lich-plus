//
//  ClaudeNLPService.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 27/11/25.
//

import Foundation

// MARK: - Claude NLP Service

/// Implementation of NLPService using Claude API
class ClaudeNLPService: NLPService {
    private let apiKey: String
    private let apiURL = URL(string: "https://api.anthropic.com/v1/messages")!
    private let modelID = "claude-3-5-haiku-20241022"

    // MARK: - Initialization

    init(apiKey: String? = nil) {
        if let apiKey = apiKey {
            self.apiKey = apiKey
        } else if let storedKey = NLPConfiguration.retrieveAPIKey() {
            self.apiKey = storedKey
        } else if let envKey = ProcessInfo.processInfo.environment["CLAUDE_API_KEY"] {
            self.apiKey = envKey
        } else {
            self.apiKey = ""
        }
    }

    // MARK: - Public Methods

    func parseEventInput(_ text: String, currentDate: Date) async throws -> ParsedEvent {
        let systemPrompt = buildEventSystemPrompt(currentDate: currentDate)
        let response = try await callClaudeAPI(userMessage: text, systemPrompt: systemPrompt)
        return try decodeEventResponse(response)
    }

    func parseTaskInput(_ text: String, currentDate: Date) async throws -> ParsedTask {
        let systemPrompt = buildTaskSystemPrompt(currentDate: currentDate)
        let response = try await callClaudeAPI(userMessage: text, systemPrompt: systemPrompt)
        return try decodeTaskResponse(response)
    }

    func parseSearchQuery(_ text: String, currentDate: Date) async throws -> SearchFilter {
        let systemPrompt = buildSearchSystemPrompt(currentDate: currentDate)
        let response = try await callClaudeAPI(userMessage: text, systemPrompt: systemPrompt)
        return try decodeSearchResponse(response)
    }

    // MARK: - Private Methods

    private func callClaudeAPI(userMessage: String, systemPrompt: String) async throws -> String {
        guard !apiKey.isEmpty else {
            throw NLPError.apiKeyMissing
        }

        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")

        let payload = ClaudeAPIRequest(
            model: modelID,
            max_tokens: 1024,
            system: systemPrompt,
            messages: [
                ClaudeMessage(role: "user", content: userMessage)
            ]
        )

        request.httpBody = try JSONEncoder().encode(payload)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NLPError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200:
            let decodedResponse = try JSONDecoder().decode(ClaudeAPIResponse.self, from: data)
            guard let textContent = decodedResponse.content.first?.text else {
                throw NLPError.invalidResponse
            }
            return textContent

        case 429:
            throw NLPError.rateLimited

        case 401, 403:
            throw NLPError.apiKeyMissing

        default:
            throw NLPError.networkError(
                NSError(domain: "HTTP", code: httpResponse.statusCode, userInfo: nil)
            )
        }
    }

    private func decodeEventResponse(_ jsonString: String) throws -> ParsedEvent {
        let cleanedJSON = cleanJSONResponse(jsonString)
        guard let data = cleanedJSON.data(using: .utf8) else {
            throw NLPError.decodingError("Invalid UTF-8 encoding")
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let response = try decoder.decode(EventResponseJSON.self, from: data)
        return ParsedEvent(
            title: response.title,
            startDate: response.startDate,
            endDate: response.endDate,
            location: response.location,
            notes: response.notes,
            isAllDay: response.isAllDay ?? false
        )
    }

    private func decodeTaskResponse(_ jsonString: String) throws -> ParsedTask {
        let cleanedJSON = cleanJSONResponse(jsonString)
        guard let data = cleanedJSON.data(using: .utf8) else {
            throw NLPError.decodingError("Invalid UTF-8 encoding")
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let response = try decoder.decode(TaskResponseJSON.self, from: data)

        let dueTime = response.dueTime != nil ? parseTimeString(response.dueTime!) : nil

        return ParsedTask(
            title: response.title,
            dueDate: response.dueDate,
            dueTime: dueTime,
            category: response.category,
            notes: response.notes,
            hasReminder: response.hasReminder ?? false
        )
    }

    private func decodeSearchResponse(_ jsonString: String) throws -> SearchFilter {
        let cleanedJSON = cleanJSONResponse(jsonString)
        guard let data = cleanedJSON.data(using: .utf8) else {
            throw NLPError.decodingError("Invalid UTF-8 encoding")
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let response = try decoder.decode(SearchResponseJSON.self, from: data)

        let dateRange: (start: Date, end: Date)? = {
            guard let start = response.startDate, let end = response.endDate else {
                return nil
            }
            return (start, end)
        }()

        return SearchFilter(
            keywords: response.keywords,
            dateRange: dateRange,
            categories: response.categories,
            includeCompleted: response.includeCompleted ?? false
        )
    }

    private func cleanJSONResponse(_ response: String) -> String {
        var cleaned = response.trimmingCharacters(in: .whitespaces)

        if cleaned.hasPrefix("```json") {
            cleaned = String(cleaned.dropFirst(7))
        } else if cleaned.hasPrefix("```") {
            cleaned = String(cleaned.dropFirst(3))
        }

        if cleaned.hasSuffix("```") {
            cleaned = String(cleaned.dropLast(3))
        }

        return cleaned.trimmingCharacters(in: .whitespaces)
    }

    private func parseTimeString(_ timeString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone.current

        if let date = formatter.date(from: timeString) {
            return date
        }

        return nil
    }

    private func buildEventSystemPrompt(currentDate: Date) -> String {
        let dateFormatter = ISO8601DateFormatter()
        let currentDateString = dateFormatter.string(from: currentDate)

        return """
        You are a calendar assistant. Parse the user's natural language input into structured event data.
        Current date and time: \(currentDateString)

        Return ONLY valid JSON with these fields (omit fields that cannot be inferred):
        {
            "title": "string",
            "startDate": "ISO8601 date string or null",
            "endDate": "ISO8601 date string or null",
            "location": "string or null",
            "notes": "string or null",
            "isAllDay": boolean
        }

        For dates:
        - Use ISO8601 format (e.g., "2025-11-27T14:30:00Z")
        - If only a date is provided without time, set the appropriate hour (9 AM for start, 5 PM for end)
        - Handle relative dates like "tomorrow", "next week", "this Friday" based on the current date
        - If end date is not specified, it can be null or the same as start date
        """
    }

    private func buildTaskSystemPrompt(currentDate: Date) -> String {
        let dateFormatter = ISO8601DateFormatter()
        let currentDateString = dateFormatter.string(from: currentDate)

        return """
        You are a task assistant. Parse the user's natural language input into structured task data.
        Current date and time: \(currentDateString)

        Return ONLY valid JSON with these fields (omit fields that cannot be inferred):
        {
            "title": "string",
            "dueDate": "ISO8601 date string or null",
            "dueTime": "HH:mm format string or null",
            "category": "work|personal|birthday|holiday|meeting|other or null",
            "notes": "string or null",
            "hasReminder": boolean
        }

        For dates:
        - Use ISO8601 format for dueDate (e.g., "2025-11-27")
        - Use HH:mm format for dueTime (e.g., "14:30")
        - Handle relative dates like "tomorrow", "next week", "this Friday" based on the current date
        - If a time is mentioned, extract it to dueTime field

        For categories:
        - Map user input to one of: work, personal, birthday, holiday, meeting, other
        - Only include if clearly identifiable from the input
        """
    }

    private func buildSearchSystemPrompt(currentDate: Date) -> String {
        let dateFormatter = ISO8601DateFormatter()
        let currentDateString = dateFormatter.string(from: currentDate)

        return """
        You are a search assistant. Parse the user's search query into filter criteria.
        Current date and time: \(currentDateString)

        Return ONLY valid JSON with these fields (omit fields that cannot be inferred):
        {
            "keywords": ["string array of search terms"],
            "startDate": "ISO8601 date string or null",
            "endDate": "ISO8601 date string or null",
            "categories": ["work", "personal", "birthday", "holiday", "meeting", "other"] or null,
            "includeCompleted": boolean
        }

        For dates:
        - Use ISO8601 format (e.g., "2025-11-27")
        - Handle relative dates like "this week", "last month", "next 7 days" based on the current date
        - If a date range is implied, set both startDate and endDate

        For categories:
        - Extract any mentioned categories from the query
        - Only include if categories are explicitly mentioned or clearly implied
        """
    }
}

// MARK: - API Request/Response Models

private struct ClaudeAPIRequest: Codable {
    let model: String
    let max_tokens: Int
    let system: String
    let messages: [ClaudeMessage]
}

private struct ClaudeMessage: Codable {
    let role: String
    let content: String
}

private struct ClaudeAPIResponse: Codable {
    let content: [ContentBlock]
}

private struct ContentBlock: Codable {
    let type: String
    let text: String
}

// MARK: - Response JSON Models

private struct EventResponseJSON: Codable {
    let title: String
    let startDate: Date?
    let endDate: Date?
    let location: String?
    let notes: String?
    let isAllDay: Bool?

    enum CodingKeys: String, CodingKey {
        case title
        case startDate
        case endDate
        case location
        case notes
        case isAllDay
    }
}

private struct TaskResponseJSON: Codable {
    let title: String
    let dueDate: Date?
    let dueTime: String?
    let category: String?
    let notes: String?
    let hasReminder: Bool?

    enum CodingKeys: String, CodingKey {
        case title
        case dueDate
        case dueTime
        case category
        case notes
        case hasReminder
    }
}

private struct SearchResponseJSON: Codable {
    let keywords: [String]
    let startDate: Date?
    let endDate: Date?
    let categories: [String]?
    let includeCompleted: Bool?

    enum CodingKeys: String, CodingKey {
        case keywords
        case startDate
        case endDate
        case categories
        case includeCompleted
    }
}
