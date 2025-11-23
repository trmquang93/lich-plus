//
//  TaskModels.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 23/11/25.
//

import Foundation

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

    var color: String {
        switch self {
        case .work:
            return "eventBlue"
        case .personal:
            return "primary"
        case .birthday:
            return "eventPink"
        case .holiday:
            return "eventOrange"
        case .meeting:
            return "eventYellow"
        case .other:
            return "secondary"
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

    var id: String { rawValue }

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
        }
    }
}

// MARK: - Task Model

struct Task: Identifiable, Equatable {
    let id: UUID
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
        updatedAt: Date = Date()
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
    }

    // MARK: - Computed Properties

    var timeDisplay: String? {
        guard let startTime = startTime else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: startTime)
    }

    var timeRangeDisplay: String? {
        guard let startTime = startTime, let endTime = endTime else { return timeDisplay }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: startTime)) - \(formatter.string(from: endTime))"
    }

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
        let formatter = DateFormatter()
        if isToday {
            return String(localized: "task.today")
        } else if isTomorrow {
            return String(localized: "task.tomorrow")
        } else {
            formatter.dateFormat = "MMM d, yyyy"
            return formatter.string(from: date)
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

    static func == (lhs: Task, rhs: Task) -> Bool {
        lhs.id == rhs.id
    }
}
