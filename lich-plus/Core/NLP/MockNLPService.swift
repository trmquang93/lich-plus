//
//  MockNLPService.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 27/11/25.
//

import Foundation

// MARK: - Mock NLP Service

/// Mock implementation of NLPService for testing and previews
class MockNLPService: NLPService {
    private let simulateNetworkDelay: Bool
    private let shouldFail: Bool
    private let failureError: NLPError

    // MARK: - Initialization

    init(
        simulateNetworkDelay: Bool = false,
        shouldFail: Bool = false,
        failureError: NLPError = .parsingFailed("Mock error")
    ) {
        self.simulateNetworkDelay = simulateNetworkDelay
        self.shouldFail = shouldFail
        self.failureError = failureError
    }

    // MARK: - Public Methods

    func parseEventInput(_ text: String, currentDate: Date) async throws -> ParsedEvent {
        if simulateNetworkDelay {
            try await Task.sleep(nanoseconds: UInt64.random(in: 500_000_000...1_000_000_000))
        }

        if shouldFail {
            throw failureError
        }

        return ParsedEvent(
            title: extractTitleFromText(text),
            startDate: currentDate.addingTimeInterval(86400),
            endDate: nil,
            location: "Mock Location",
            notes: "Parsed from: \(text)",
            isAllDay: false
        )
    }

    func parseTaskInput(_ text: String, currentDate: Date) async throws -> ParsedTask {
        if simulateNetworkDelay {
            try await Task.sleep(nanoseconds: UInt64.random(in: 500_000_000...1_000_000_000))
        }

        if shouldFail {
            throw failureError
        }

        return ParsedTask(
            title: extractTitleFromText(text),
            dueDate: currentDate.addingTimeInterval(86400),
            dueTime: nil,
            category: "work",
            notes: "Parsed from: \(text)",
            hasReminder: false
        )
    }

    func parseSearchQuery(_ text: String, currentDate: Date) async throws -> SearchFilter {
        if simulateNetworkDelay {
            try await Task.sleep(nanoseconds: UInt64.random(in: 500_000_000...1_000_000_000))
        }

        if shouldFail {
            throw failureError
        }

        let keywords = text.split(separator: " ").map(String.init)

        return SearchFilter(
            keywords: keywords,
            dateRange: (currentDate, currentDate.addingTimeInterval(604800)),
            categories: ["work", "personal"],
            includeCompleted: false
        )
    }

    // MARK: - Private Methods

    private func extractTitleFromText(_ text: String) -> String {
        let words = text.split(separator: " ").prefix(3).joined(separator: " ")
        return words.isEmpty ? "Parsed Item" : words
    }
}
