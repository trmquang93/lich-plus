//
//  TaskModels.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 23/11/25.
//

import Foundation
import SwiftData
import SwiftUI

// MARK: - Item Type

enum ItemType: String, CaseIterable, Identifiable {
    case task = "task"
    case event = "event"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .task:
            return String(localized: "item.task")
        case .event:
            return String(localized: "item.event")
        }
    }
}

// MARK: - Priority

enum Priority: String, CaseIterable, Identifiable {
    case none = "none"
    case low = "low"
    case medium = "medium"
    case high = "high"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .none:
            return String(localized: "priority.none")
        case .low:
            return String(localized: "priority.low")
        case .medium:
            return String(localized: "priority.medium")
        case .high:
            return String(localized: "priority.high")
        }
    }

    var color: Color {
        switch self {
        case .none:
            return AppColors.textSecondary
        case .low:
            return AppColors.eventBlue
        case .medium:
            return AppColors.eventYellow
        case .high:
            return AppColors.primary
        }
    }
}

// MARK: - Task Category

enum TaskCategory: String, CaseIterable, Identifiable {
    case work = "Work"
    case personal = "Personal"
    case birthday = "Birthday"
    case holiday = "Holiday"
    case meeting = "Meeting"
    case other = "Other"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .work:
            return String(localized: "category.work")
        case .personal:
            return String(localized: "category.personal")
        case .birthday:
            return String(localized: "category.birthday")
        case .holiday:
            return String(localized: "category.holiday")
        case .meeting:
            return String(localized: "category.meeting")
        case .other:
            return String(localized: "category.other")
        }
    }

    var colorValue: Color {
        switch self {
        case .work:
            return AppColors.eventBlue
        case .personal:
            return AppColors.primary
        case .birthday:
            return AppColors.eventPink
        case .holiday:
            return AppColors.eventOrange
        case .meeting:
            return AppColors.eventYellow
        case .other:
            return AppColors.secondary
        }
    }

    /// SF Symbol icon for visual representation of the category
    var icon: String {
        switch self {
        case .birthday:
            return "gift"
        case .holiday:
            return "star.fill"
        case .meeting:
            return "person.3"
        case .work:
            return "briefcase"
        case .personal:
            return "person"
        case .other:
            return "calendar"
        }
    }
}

// MARK: - Recurrence Type

enum RecurrenceType: String, CaseIterable, Identifiable {
    case none = "None"
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
    case lunarMonthly = "LunarMonthly"
    case lunarYearly = "LunarYearly"

    var id: String { rawValue }

    /// Whether this recurrence type uses the lunar calendar
    var isLunar: Bool {
        self == .lunarMonthly || self == .lunarYearly
    }

    var displayName: String {
        switch self {
        case .none:
            return String(localized: "recurrence.none")
        case .daily:
            return String(localized: "recurrence.daily")
        case .weekly:
            return String(localized: "recurrence.weekly")
        case .monthly:
            return String(localized: "recurrence.monthly")
        case .yearly:
            return String(localized: "recurrence.yearly")
        case .lunarMonthly:
            return String(localized: "recurrence.lunarMonthly")
        case .lunarYearly:
            return String(localized: "recurrence.lunarYearly")
        }
    }
}

// MARK: - Task Model

struct TaskItem: Identifiable, Equatable {
    var id: UUID
    var title: String
    var date: Date
    var startTime: Date?
    var endTime: Date?
    var category: TaskCategory
    var notes: String?
    var isCompleted: Bool
    var reminderMinutes: Int?
    var recurrence: RecurrenceType
    var createdAt: Date
    var updatedAt: Date
    var itemType: ItemType
    var priority: Priority
    var location: String?
    var source: EventSource

    /// Whether this item can be edited locally
    /// ICS subscription events are read-only and cannot be edited
    var isEditable: Bool {
        source != .icsSubscription
    }

    /// ID of the master event if this is an occurrence, nil if this is a master event
    var masterEventId: UUID?

    /// Occurrence date for recurring events (distinct from master start date)
    var occurrenceDate: Date?

    init(
        id: UUID = UUID(),
        title: String,
        date: Date,
        startTime: Date? = nil,
        endTime: Date? = nil,
        category: TaskCategory = .personal,
        notes: String? = nil,
        isCompleted: Bool = false,
        reminderMinutes: Int? = nil,
        recurrence: RecurrenceType = .none,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        itemType: ItemType = .task,
        priority: Priority = .none,
        location: String? = nil,
        source: EventSource = .local,
        masterEventId: UUID? = nil,
        occurrenceDate: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.category = category
        self.notes = notes
        self.isCompleted = isCompleted
        self.reminderMinutes = reminderMinutes
        self.recurrence = recurrence
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.itemType = itemType
        self.priority = priority
        self.location = location
        self.source = source
        self.masterEventId = masterEventId
        self.occurrenceDate = occurrenceDate
    }

    // MARK: - Date Formatters (Cached)

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }()

    // MARK: - Computed Properties

    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }

    var isTomorrow: Bool {
        Calendar.current.isDateInTomorrow(date)
    }

    var isThisWeek: Bool {
        Calendar.current.isDate(date, equalTo: Date(), toGranularity: .weekOfYear)
    }

    var isThisMonth: Bool {
        Calendar.current.isDate(date, equalTo: Date(), toGranularity: .month)
    }

    var dateDisplay: String {
        if isToday {
            return String(localized: "task.today")
        } else if isTomorrow {
            return String(localized: "task.tomorrow")
        } else {
            return Self.dateFormatter.string(from: date)
        }
    }

    var reminderDisplay: String? {
        guard let minutes = reminderMinutes else { return nil }
        switch minutes {
        case 15:
            return String(localized: "reminder.15min")
        case 30:
            return String(localized: "reminder.30min")
        case 60:
            return String(localized: "reminder.1hr")
        default:
            return "\(minutes) " + String(localized: "task.reminderMinutes")
        }
    }

    /// Returns true if this is an all-day event, false if it has a specific start time
    var isAllDay: Bool {
        startTime == nil
    }

    /// Returns true if this is an occurrence instance, false if this is a master event
    var isOccurrence: Bool {
        masterEventId != nil
    }

    static func == (lhs: TaskItem, rhs: TaskItem) -> Bool {
        lhs.id == rhs.id
    }

    // MARK: - SwiftData Conversion Methods

    /// Create a TaskItem from a SyncableEvent
    /// - Parameter syncable: The SyncableEvent to convert
    init(from syncable: SyncableEvent) {
        self.id = syncable.id
        self.title = syncable.title
        self.date = syncable.startDate
        self.startTime = syncable.isAllDay ? nil : syncable.startDate
        self.endTime = syncable.endDate
        self.category = TaskCategory.allCases.first(where: {
            $0.rawValue.caseInsensitiveCompare(syncable.category) == .orderedSame
        }) ?? .other
        self.notes = syncable.notes
        self.isCompleted = syncable.isCompleted
        self.reminderMinutes = syncable.reminderMinutes
        self.recurrence = Self.decodeRecurrenceType(from: syncable.recurrenceRuleData)
        self.createdAt = syncable.createdAt
        self.updatedAt = syncable.lastModifiedLocal
        self.itemType = ItemType(rawValue: syncable.itemType) ?? .task
        self.priority = Priority(rawValue: syncable.priority) ?? .none
        self.location = syncable.location
        self.source = syncable.sourceEnum
        self.masterEventId = nil
        self.occurrenceDate = nil
    }

    /// Create an occurrence instance from a master SyncableEvent
    /// - Parameters:
    ///   - master: The master SyncableEvent
    ///   - occurrenceDate: The date this occurrence happens
    ///   - virtualID: Deterministic ID for this occurrence
    /// - Returns: TaskItem configured as an occurrence
    static func createOccurrence(
        from master: SyncableEvent,
        occurrenceDate: Date,
        virtualID: UUID
    ) -> TaskItem {
        var occurrence = TaskItem(from: master)
        occurrence.id = virtualID
        occurrence.masterEventId = master.id
        occurrence.occurrenceDate = occurrenceDate
        occurrence.date = occurrenceDate

        // Helper to adjust time components to a new date
        func adjustTime(of date: Date?, to newDate: Date) -> Date? {
            guard let date = date else { return nil }
            let calendar = Calendar.current
            let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: date)
            return calendar.date(bySettingHour: timeComponents.hour ?? 0,
                                 minute: timeComponents.minute ?? 0,
                                 second: timeComponents.second ?? 0,
                                 of: newDate)
        }

        // Adjust start/end times to occurrence date if present
        occurrence.startTime = adjustTime(of: occurrence.startTime, to: occurrenceDate)
        occurrence.endTime = adjustTime(of: occurrence.endTime, to: occurrenceDate)

        return occurrence
    }

    /// Decode RecurrenceType from serialized recurrence rule data
    /// - Parameter data: The serialized recurrence rule data
    /// - Returns: The decoded RecurrenceType, or .none if data is invalid
    private static func decodeRecurrenceType(from data: Data?) -> RecurrenceType {
        guard let data = data, !data.isEmpty else {
            return .none
        }

        do {
            let container = try JSONDecoder().decode(RecurrenceRuleContainer.self, from: data)

            switch container {
            case .solar(let rule):
                // Convert solar frequency to RecurrenceType
                switch rule.frequency {
                case 0:
                    return .daily
                case 1:
                    return .weekly
                case 2:
                    return .monthly
                case 3:
                    return .yearly
                default:
                    return .none
                }

            case .lunar(let rule):
                // Convert lunar frequency to RecurrenceType
                switch rule.frequency {
                case .monthly:
                    return .lunarMonthly
                case .yearly:
                    return .lunarYearly
                }

            case .none:
                return .none
            }
        } catch {
            return .none
        }
    }

    /// Convert TaskItem to SyncableEvent for persistence
    /// - Parameter existing: Optional existing SyncableEvent to update instead of creating new
    /// - Returns: A SyncableEvent with properties from this TaskItem
    func toSyncableEvent(existing: SyncableEvent? = nil) -> SyncableEvent {
        if let existing = existing {
            // Update existing event
            existing.title = self.title
            existing.startDate = self.startTime ?? self.date
            existing.endDate = self.endTime
            existing.isAllDay = self.startTime == nil
            existing.category = self.category.rawValue
            existing.notes = self.notes
            existing.isCompleted = self.isCompleted
            existing.reminderMinutes = self.reminderMinutes
            existing.itemType = self.itemType.rawValue
            existing.priority = self.priority.rawValue
            existing.location = self.location
            existing.lastModifiedLocal = Date()
            return existing
        } else {
            // Create new event
            return SyncableEvent(
                id: self.id,
                title: self.title,
                startDate: self.startTime ?? self.date,
                endDate: self.endTime,
                isAllDay: self.startTime == nil,
                notes: self.notes,
                isCompleted: self.isCompleted,
                category: self.category.rawValue,
                reminderMinutes: self.reminderMinutes,
                syncStatus: SyncStatus.pending.rawValue,
                createdAt: self.createdAt,
                itemType: self.itemType.rawValue,
                priority: self.priority.rawValue,
                location: self.location,
                timeZone: TimeZone.current.identifier
            )
        }
    }
}
