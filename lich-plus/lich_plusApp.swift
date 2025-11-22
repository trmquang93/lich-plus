//
//  lich_plusApp.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 22/11/25.
//

import SwiftUI
import SwiftData

@main
struct lich_plusApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            CalendarEvent.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])

            // Add sample data if database is empty
            let context = ModelContext(container)

            // Check if we have any events
            let descriptor = FetchDescriptor<CalendarEvent>()
            let existingEvents = try context.fetch(descriptor)

            if existingEvents.isEmpty {
                // Add sample events for August 2024
                let sampleEvents = CalendarEvent.createSampleEvents(for: 2024, month: 8)
                for event in sampleEvents {
                    context.insert(event)
                }

                // Generate lunar events (5 years from current year)
                let currentYear = Calendar.current.component(.year, from: Date())
                let lunarEvents = CalendarEvent.createLunarEvents(startYear: currentYear, yearCount: 5)
                for event in lunarEvents {
                    context.insert(event)
                }

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
