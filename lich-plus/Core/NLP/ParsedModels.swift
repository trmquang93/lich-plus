//
//  ParsedModels.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 27/11/25.
//

import Foundation

// MARK: - Parsed Event

/// Parsed event data extracted from natural language input
struct ParsedEvent {
    var title: String
    var startDate: Date?
    var endDate: Date?
    var location: String?
    var notes: String?
    var isAllDay: Bool

    init(
        title: String,
        startDate: Date? = nil,
        endDate: Date? = nil,
        location: String? = nil,
        notes: String? = nil,
        isAllDay: Bool = false
    ) {
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.location = location
        self.notes = notes
        self.isAllDay = isAllDay
    }
}

// MARK: - Parsed Task

/// Parsed task data extracted from natural language input
struct ParsedTask {
    var title: String
    var dueDate: Date?
    var dueTime: Date?
    var category: String?
    var notes: String?
    var hasReminder: Bool

    init(
        title: String,
        dueDate: Date? = nil,
        dueTime: Date? = nil,
        category: String? = nil,
        notes: String? = nil,
        hasReminder: Bool = false
    ) {
        self.title = title
        self.dueDate = dueDate
        self.dueTime = dueTime
        self.category = category
        self.notes = notes
        self.hasReminder = hasReminder
    }
}

// MARK: - Search Filter

/// Search filter criteria parsed from natural language query
struct SearchFilter {
    var keywords: [String]
    var dateRange: (start: Date, end: Date)?
    var categories: [String]?
    var includeCompleted: Bool

    init(
        keywords: [String],
        dateRange: (start: Date, end: Date)? = nil,
        categories: [String]? = nil,
        includeCompleted: Bool = false
    ) {
        self.keywords = keywords
        self.dateRange = dateRange
        self.categories = categories
        self.includeCompleted = includeCompleted
    }
}
