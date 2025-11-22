//
//  lich_plusApp.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 22/11/25.
//
// MARK: - Main App Entry Point
// Lịch Việt - Vietnamese Calendar Application
// A production-ready SwiftUI app featuring lunar and solar calendar integration.

import SwiftUI
import SwiftData

@main
struct lich_plusApp: App {
    /// Shared SwiftData ModelContainer for persistent event storage.
    ///
    /// This container is initialized once at app launch and manages the lifecycle of
    /// the SwiftData schema. It persists CalendarEvent data to the device filesystem.
    ///
    /// **First Launch Behavior**:
    /// - On initial app install, the database is empty
    /// - 10 sample events are created for August 2024
    /// - ~120-130 lunar events are generated for 5 years (current year + 4 years)
    /// - Total: 130+ events loaded into the database
    /// - Subsequent launches use cached data (no regeneration)
    ///
    /// **Data Persistence**:
    /// - All CalendarEvent objects are persisted to SwiftData store
    /// - EventCategory is not persisted (it's a helper enum)
    /// - Settings (toggles) are stored in UserDefaults separately
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            CalendarEvent.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])

            // Initialize database with sample and lunar events on first launch
            let context = ModelContext(container)

            // Check if we have any existing events (first launch check)
            let descriptor = FetchDescriptor<CalendarEvent>()
            let existingEvents = try context.fetch(descriptor)

            if existingEvents.isEmpty {
                // First launch: populate with sample data

                // Add 10 sample events for August 2024 (user-created event examples)
                let sampleEvents = CalendarEvent.createSampleEvents(for: 2024, month: 8)
                for event in sampleEvents {
                    context.insert(event)
                }

                // Generate lunar calendar events for 5-year coverage
                // Lunar events are system events (isRecurring=true) and protected from editing
                let currentYear = Calendar.current.component(.year, from: Date())
                let lunarEvents = CalendarEvent.createLunarEvents(startYear: currentYear, yearCount: 5)
                for event in lunarEvents {
                    context.insert(event)
                }

                // Persist all data to device storage
                try context.save()
            }

            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .modelContainer(sharedModelContainer)
    }
}
