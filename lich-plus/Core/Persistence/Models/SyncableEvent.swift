//
//  SyncableEvent.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 25/11/25.
//

import Foundation
import SwiftData

@Model
final class SyncableEvent {
    @Attribute(.unique) var id: UUID
    var ekEventIdentifier: String?
    var calendarIdentifier: String?
    var googleEventId: String?
    var googleCalendarId: String?
    var microsoftEventId: String?
    var microsoftCalendarId: String?
    var icsEventUid: String?
    var icsSubscriptionId: String?
    var title: String
    var startDate: Date
    var endDate: Date?
    var isAllDay: Bool
    var notes: String?
    var isCompleted: Bool
    var category: String
    var reminderMinutes: Int?
    var recurrenceRuleData: Data?
    var lastModifiedLocal: Date
    var lastModifiedRemote: Date?
    var syncStatus: String  // SyncStatus.rawValue
    var source: String      // EventSource.rawValue
    var isDeleted: Bool
    var createdAt: Date
    var itemType: String        // "task" or "event" - default: "task"
    var priority: String        // "none", "low", "medium", "high" - default: "none"
    var location: String?       // For events (meeting room, address)

    init(
        id: UUID = UUID(),
        ekEventIdentifier: String? = nil,
        calendarIdentifier: String? = nil,
        googleEventId: String? = nil,
        googleCalendarId: String? = nil,
        microsoftEventId: String? = nil,
        microsoftCalendarId: String? = nil,
        icsEventUid: String? = nil,
        icsSubscriptionId: String? = nil,
        title: String,
        startDate: Date,
        endDate: Date? = nil,
        isAllDay: Bool = false,
        notes: String? = nil,
        isCompleted: Bool = false,
        category: String = "other",
        reminderMinutes: Int? = nil,
        recurrenceRuleData: Data? = nil,
        lastModifiedLocal: Date = Date(),
        lastModifiedRemote: Date? = nil,
        syncStatus: String = SyncStatus.pending.rawValue,
        source: String = EventSource.local.rawValue,
        isDeleted: Bool = false,
        createdAt: Date = Date(),
        itemType: String = "task",
        priority: String = "none",
        location: String? = nil
    ) {
        self.id = id
        self.ekEventIdentifier = ekEventIdentifier
        self.calendarIdentifier = calendarIdentifier
        self.googleEventId = googleEventId
        self.googleCalendarId = googleCalendarId
        self.microsoftEventId = microsoftEventId
        self.microsoftCalendarId = microsoftCalendarId
        self.icsEventUid = icsEventUid
        self.icsSubscriptionId = icsSubscriptionId
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.isAllDay = isAllDay
        self.notes = notes
        self.isCompleted = isCompleted
        self.category = category
        self.reminderMinutes = reminderMinutes
        self.recurrenceRuleData = recurrenceRuleData
        self.lastModifiedLocal = lastModifiedLocal
        self.lastModifiedRemote = lastModifiedRemote
        self.syncStatus = syncStatus
        self.source = source
        self.isDeleted = isDeleted
        self.createdAt = createdAt
        self.itemType = itemType
        self.priority = priority
        self.location = location
    }

    // Computed properties for type-safe enum access
    var syncStatusEnum: SyncStatus {
        SyncStatus(rawValue: syncStatus) ?? .pending
    }

    var sourceEnum: EventSource {
        EventSource(rawValue: source) ?? .local
    }

    var itemTypeEnum: ItemType {
        ItemType(rawValue: itemType) ?? .task
    }

    var priorityEnum: Priority {
        Priority(rawValue: priority) ?? .none
    }

    // Update sync status
    func setSyncStatus(_ status: SyncStatus) {
        self.syncStatus = status.rawValue
        self.lastModifiedLocal = Date()
    }

    // Mark as synced with Apple Calendar
    func markAsSynced(withEkIdentifier ekId: String?, calendarId: String?) {
        self.ekEventIdentifier = ekId
        self.calendarIdentifier = calendarId
        self.syncStatus = SyncStatus.synced.rawValue
        self.lastModifiedLocal = Date()
        self.lastModifiedRemote = Date()
    }
}
