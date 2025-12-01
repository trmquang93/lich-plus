//
//  BuiltInCalendarManager.swift
//  lich-plus
//
//

import Foundation
import SwiftData

struct BuiltInCalendarConfig {
    let id: String
    let name: String
    let url: String
    let category: String
    let colorHex: String
    let enabledByDefault: Bool
}

@MainActor
class BuiltInCalendarManager {
    private let initializationKey = "builtInCalendars_initialized_v1"

    private let builtInCalendars = [
        BuiltInCalendarConfig(
            id: "vietnamese-holidays",
            name: "Vietnamese Holidays",
            url: "https://www.officeholidays.com/ics/ics_country.php?tbl_country=Vietnam",
            category: "holiday",
            colorHex: "#C7251D",
            enabledByDefault: true
        )
    ]

    // MARK: - Public Methods

    /// Check if built-in calendars have been initialized
    func isInitialized() -> Bool {
        UserDefaults.standard.bool(forKey: initializationKey)
    }

    /// Initialize built-in calendars by creating ICSSubscription entries
    func initializeBuiltInCalendars(modelContext: ModelContext) async throws {
        // Check if already initialized
        guard !isInitialized() else {
            return
        }

        // Create subscription for each built-in calendar
        for config in builtInCalendars {
            // Use a deterministic UUID for the subscription ID
            let subscriptionId = UUID(uuidString: config.id) ?? UUID()

            let subscription = ICSSubscription(
                id: subscriptionId,
                name: config.name,
                url: config.url,
                isEnabled: config.enabledByDefault,
                colorHex: config.colorHex,
                type: SubscriptionType.builtin.rawValue
            )

            modelContext.insert(subscription)
        }

        // Save all subscriptions
        try modelContext.save()

        // Mark as initialized
        UserDefaults.standard.set(true, forKey: initializationKey)
    }
}
