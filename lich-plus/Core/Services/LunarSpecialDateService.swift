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
        let category = specialDate.uniqueCategory

        let predicate = #Predicate<SyncableEvent> { event in
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

    // MARK: - Internal

    func createMasterEvent(_ specialDate: LunarSpecialDate) -> SyncableEvent {
        // Use a representative date (first of next lunar month)
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: Date())

        // Create recurrence rule
        let rule = specialDate.createRecurrenceRule()
        let container = RecurrenceRuleContainer.lunar(rule)

        // Encode to JSON
        let recurrenceData: Data?
        do {
            recurrenceData = try JSONEncoder().encode(container)
        } catch {
            print("[LunarSpecialDateService] Error encoding recurrence rule: \(error)")
            recurrenceData = nil
        }

        return SyncableEvent(
            id: UUID(),
            title: specialDate.title,
            startDate: startDate,
            endDate: nil,
            isAllDay: true,
            notes: nil,
            isCompleted: false,
            category: specialDate.uniqueCategory,
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

    func hasMasterEvent(for specialDate: LunarSpecialDate) -> Bool {
        let category = specialDate.uniqueCategory

        let predicate = #Predicate<SyncableEvent> { event in
            event.category == category
        }

        let descriptor = FetchDescriptor<SyncableEvent>(predicate: predicate)

        do {
            let events = try modelContext.fetch(descriptor)
            return !events.isEmpty
        } catch {
            print("[LunarSpecialDateService] Error checking master event: \(error)")
            return false
        }
    }
}
