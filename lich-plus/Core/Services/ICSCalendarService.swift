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
        colorHex: String,
        defaultCategory: String = "other"
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
            category: defaultCategory,
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

    /// Expand a recurring ICS event into individual occurrence events
    ///
    /// If the event has a recurrence rule, this method will:
    /// 1. Parse the RRULE string into a SerializableRecurrenceRule
    /// 2. Parse EXDATE strings into Date array
    /// 3. Use ICSRecurrenceExpander to generate all occurrence dates
    /// 4. Create a SyncableEvent for each occurrence
    ///
    /// If the event has no recurrence rule, returns a single event.
    ///
    /// - Parameters:
    ///   - icsEvent: The ICS event to expand
    ///   - subscriptionId: The subscription ID
    ///   - subscriptionName: The subscription name
    ///   - colorHex: The color hex code
    ///   - defaultCategory: The default category
    /// - Returns: Array of SyncableEvents (one per occurrence)
    func expandRecurringEvent(
        _ icsEvent: ICSEvent,
        subscriptionId: String,
        subscriptionName: String,
        colorHex: String,
        defaultCategory: String = "other"
    ) -> [SyncableEvent] {

        // If no recurrence rule, return single event
        guard let rruleString = icsEvent.recurrenceRule else {
            let event = convertToSyncableEvent(
                icsEvent,
                subscriptionId: subscriptionId,
                subscriptionName: subscriptionName,
                colorHex: colorHex,
                defaultCategory: defaultCategory
            )
            return [event]
        }

        // Parse RRULE string into SerializableRecurrenceRule
        let rule: SerializableRecurrenceRule
        do {
            rule = try ICSRRuleParser.parse(rruleString)
        } catch {
            // If parsing fails, log and return single event
            print("⚠️ Failed to parse RRULE '\(rruleString)': \(error)")
            let event = convertToSyncableEvent(
                icsEvent,
                subscriptionId: subscriptionId,
                subscriptionName: subscriptionName,
                colorHex: colorHex,
                defaultCategory: defaultCategory
            )
            return [event]
        }

        // Parse EXDATE strings into Date array
        let excludedDates: [Date]
        do {
            excludedDates = try ICSRRuleParser.parseExDates(icsEvent.exDates)
        } catch {
            // If EXDATE parsing fails, log warning and proceed without exclusions
            print("⚠️ Failed to parse EXDATE for event '\(icsEvent.summary)': \(error)")
            excludedDates = []
        }

        // Expand recurrence rule into individual occurrences
        let occurrences = ICSRecurrenceExpander.expandOccurrences(
            masterStartDate: icsEvent.startDate,
            masterEndDate: icsEvent.endDate,
            rule: rule,
            excludedDates: excludedDates
        )

        // If expansion produces no occurrences, return single event at master date
        guard !occurrences.isEmpty else {
            print("⚠️ Recurrence expansion produced 0 occurrences for event '\(icsEvent.summary)'")
            let event = convertToSyncableEvent(
                icsEvent,
                subscriptionId: subscriptionId,
                subscriptionName: subscriptionName,
                colorHex: colorHex,
                defaultCategory: defaultCategory
            )
            return [event]
        }

        // Create SyncableEvent for each occurrence
        return occurrences.enumerated().map { (index, occurrence) in
            createOccurrenceEvent(
                from: icsEvent,
                occurrenceIndex: index,
                startDate: occurrence.startDate,
                endDate: occurrence.endDate,
                subscriptionId: subscriptionId,
                subscriptionName: subscriptionName,
                colorHex: colorHex,
                defaultCategory: defaultCategory
            )
        }
    }

    /// Create a SyncableEvent for a single occurrence of a recurring event
    ///
    /// The occurrence UID follows the pattern: "{masterUID}_occ_{index}"
    ///
    /// - Parameters:
    ///   - icsEvent: The master ICS event
    ///   - occurrenceIndex: The index of this occurrence (0-based)
    ///   - startDate: The start date of this occurrence
    ///   - endDate: The end date of this occurrence
    ///   - subscriptionId: The subscription ID
    ///   - subscriptionName: The subscription name
    ///   - colorHex: The color hex code
    ///   - defaultCategory: The default category
    /// - Returns: A SyncableEvent for this occurrence
    private func createOccurrenceEvent(
        from icsEvent: ICSEvent,
        occurrenceIndex: Int,
        startDate: Date,
        endDate: Date?,
        subscriptionId: String,
        subscriptionName: String,
        colorHex: String,
        defaultCategory: String
    ) -> SyncableEvent {

        // Generate unique UID for this occurrence
        let occurrenceUID = "\(icsEvent.uid)_occ_\(occurrenceIndex)"

        let event = SyncableEvent(
            icsEventUid: occurrenceUID,
            icsSubscriptionId: subscriptionId,
            title: icsEvent.summary,
            startDate: startDate,
            endDate: endDate,
            isAllDay: icsEvent.isAllDay,
            notes: icsEvent.description,
            isCompleted: false,
            category: defaultCategory,
            reminderMinutes: nil,
            recurrenceRuleData: nil,  // Each occurrence is stored as individual event
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
