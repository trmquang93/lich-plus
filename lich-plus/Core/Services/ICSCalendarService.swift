//
//  ICSCalendarService.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 30/11/25.
//

import Foundation

@MainActor
class ICSCalendarService {
    private let parser = ICSParser()
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    // MARK: - Public Methods

    /// Fetch and parse events from an ICS URL
    func fetchEvents(from url: URL) async throws -> [ICSEvent] {
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 30

        let (data, response) = try await session.data(for: request)

        try validateResponse(response, data: data)

        guard let icsContent = String(data: data, encoding: .utf8) else {
            throw ICSParserError.invalidFormat
        }

        return try parser.parse(icsContent)
    }

    /// Convert ICSEvent to SyncableEvent for local storage
    func convertToSyncableEvent(
        _ icsEvent: ICSEvent,
        subscriptionId: String,
        subscriptionName: String,
        colorHex: String
    ) -> SyncableEvent {
        let event = SyncableEvent(
            icsEventUid: icsEvent.uid,
            icsSubscriptionId: subscriptionId,
            title: icsEvent.summary,
            startDate: icsEvent.startDate,
            endDate: icsEvent.endDate,
            isAllDay: icsEvent.isAllDay,
            notes: icsEvent.description,
            isCompleted: false,
            category: "other",
            reminderMinutes: nil,
            recurrenceRuleData: nil,
            source: EventSource.icsSubscription.rawValue,
            itemType: "event",
            priority: "none",
            location: icsEvent.location
        )

        event.syncStatus = SyncStatus.synced.rawValue
        event.lastModifiedRemote = Date()

        return event
    }

    // MARK: - Private Helpers

    private func validateResponse(_ response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ICSParserError.invalidURL
        }

        switch httpResponse.statusCode {
        case 200...299:
            return // Success
        case 401, 403:
            throw ICSParserError.networkError("Access denied")
        case 404:
            throw ICSParserError.networkError("Calendar not found")
        case 429:
            throw ICSParserError.networkError("Too many requests")
        default:
            throw ICSParserError.networkError("HTTP \(httpResponse.statusCode)")
        }
    }
}
