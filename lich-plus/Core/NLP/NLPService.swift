//
//  NLPService.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 27/11/25.
//

import Foundation

// MARK: - NLP Service Protocol

/// Protocol for natural language processing services
protocol NLPService {
    /// Parse natural language input into event data
    /// - Parameters:
    ///   - text: The natural language text describing the event
    ///   - currentDate: The current date for resolving relative dates
    /// - Returns: Structured event data parsed from the input
    func parseEventInput(_ text: String, currentDate: Date) async throws -> ParsedEvent

    /// Parse natural language input into task data
    /// - Parameters:
    ///   - text: The natural language text describing the task
    ///   - currentDate: The current date for resolving relative dates
    /// - Returns: Structured task data parsed from the input
    func parseTaskInput(_ text: String, currentDate: Date) async throws -> ParsedTask

    /// Parse natural language search query into filter criteria
    /// - Parameters:
    ///   - text: The natural language search query
    ///   - currentDate: The current date for resolving relative dates
    /// - Returns: Search filter criteria parsed from the query
    func parseSearchQuery(_ text: String, currentDate: Date) async throws -> SearchFilter
}

// MARK: - NLP Errors

/// Errors that can occur during NLP processing
enum NLPError: LocalizedError {
    case networkError(Error)
    case invalidResponse
    case parsingFailed(String)
    case apiKeyMissing
    case rateLimited
    case decodingError(String)

    var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from AI service"
        case .parsingFailed(let reason):
            return "Failed to parse input: \(reason)"
        case .apiKeyMissing:
            return "API key not configured"
        case .rateLimited:
            return "Rate limited, please try again later"
        case .decodingError(let reason):
            return "Failed to decode response: \(reason)"
        }
    }
}
