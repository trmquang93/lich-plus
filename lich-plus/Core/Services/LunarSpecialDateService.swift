//
//  LunarSpecialDateService.swift
//  lich-plus
//
//  Created by Claude Code
//

import Foundation
import SwiftData

/// Service for managing lunar special date events
@MainActor
final class LunarSpecialDateService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// Enable a lunar special date by generating master event with recurrence
    func enableSpecialDate(_ specialDate: LunarSpecialDate) throws {
        // Check if already exists
        if hasMasterEvent(for: specialDate) {
            return
        }

        // Create master event with lunar recurrence rule
        let masterEvent = createMasterEvent(specialDate)
        modelContext.insert(masterEvent)

        try modelContext.save()

        // Post notification to refresh calendar
        NotificationCenter.default.post(name: .calendarDataDidChange, object: nil)
    }

    /// Disable a lunar special date by deleting its master event
    func disableSpecialDate(_ specialDate: LunarSpecialDate) throws {
        let title = specialDate.title
        let category = specialDate.category

        let predicate = #Predicate<SyncableEvent> { event in
            event.title == title &&
            event.category == category
        }

        let descriptor = FetchDescriptor<SyncableEvent>(predicate: predicate)
        let events = try modelContext.fetch(descriptor)

        for event in events {
            modelContext.delete(event)
        }

        try modelContext.save()

        // Post notification to refresh calendar
        NotificationCenter.default.post(name: .calendarDataDidChange, object: nil)
    }

    /// Check if a special date is enabled (has master event)
    func isEnabled(_ specialDate: LunarSpecialDate) -> Bool {
        hasMasterEvent(for: specialDate)
    }

    // MARK: - Private

    private func createMasterEvent(_ specialDate: LunarSpecialDate) -> SyncableEvent {
        // Use a representative date (first of next lunar month)
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: Date())

        // Create recurrence rule
        let rule = specialDate.createRecurrenceRule()
        let container = RecurrenceRuleContainer.lunar(rule)

        // Encode to JSON
        let recurrenceData = try? JSONEncoder().encode(container)

        return SyncableEvent(
            id: UUID(),
            title: specialDate.title,
            startDate: startDate,
            endDate: nil,
            isAllDay: true,
            notes: nil,
            isCompleted: false,
            category: specialDate.category,
            reminderMinutes: nil,
            recurrenceRuleData: recurrenceData,
            lastModifiedLocal: Date(),
            lastModifiedRemote: nil,
            syncStatus: SyncStatus.localOnly.rawValue,
            source: EventSource.local.rawValue,
            isDeleted: false,
            createdAt: Date(),
            itemType: ItemType.event.rawValue,
            priority: Priority.none.rawValue,
            location: nil,
            timeZone: nil
        )
    }

    private func hasMasterEvent(for specialDate: LunarSpecialDate) -> Bool {
        let title = specialDate.title
        let category = specialDate.category

        let predicate = #Predicate<SyncableEvent> { event in
            event.title == title &&
            event.category == category
        }

        let descriptor = FetchDescriptor<SyncableEvent>(predicate: predicate)

        do {
            let events = try modelContext.fetch(descriptor)
            return !events.isEmpty
        } catch {
            return false
        }
    }
}
