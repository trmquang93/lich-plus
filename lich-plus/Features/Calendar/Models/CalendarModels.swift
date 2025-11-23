//
//  CalendarModels.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 23/11/25.
//

import Foundation

// MARK: - Day Type

enum DayType {
    case good
    case bad
    case neutral

    var displayName: String {
        switch self {
        case .good:
            return "Ngày tốt"
        case .bad:
            return "Ngày xấu"
        case .neutral:
            return "Ngày thường"
        }
    }

    var description: String {
        switch self {
        case .good:
            return "Thích hợp cho các hoạt động quan trọng"
        case .bad:
            return "Nên tránh các quyết định lớn"
        case .neutral:
            return "Ngày bình thường"
        }
    }
}

// MARK: - Calendar Day

struct CalendarDay: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    let solarDay: Int
    let solarMonth: Int
    let solarYear: Int
    let lunarDay: Int
    let lunarMonth: Int
    let lunarYear: Int
    let dayType: DayType
    let isCurrentMonth: Bool
    let isToday: Bool
    let events: [Event]
    let isWeekend: Bool

    var displaySolar: String {
        String(solarDay)
    }

    var displayLunar: String {
        String(format: "%d/%d", lunarDay, lunarMonth)
    }

    var hasEvents: Bool {
        !events.isEmpty
    }

    var lunarMonthYear: String {
        String(format: "%d/%d", lunarMonth, lunarYear)
    }
}

// MARK: - Event

struct Event: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let time: String
    let category: EventCategory
    let description: String?

    var categoryColor: String {
        category.rawValue
    }
}

// MARK: - Event Category

enum EventCategory: String, CaseIterable {
    case work = "Work"
    case personal = "Personal"
    case birthday = "Birthday"
    case holiday = "Holiday"
    case meeting = "Meeting"
    case other = "Other"
}

// MARK: - Lucky Hour

struct LuckyHour: Identifiable, Equatable {
    let id = UUID()
    let startTime: String
    let endTime: String
    let luckyActivities: [String]

    var timeRange: String {
        "\(startTime) - \(endTime)"
    }
}

// MARK: - Calendar Month

struct CalendarMonth: Identifiable, Equatable {
    let id = UUID()
    let month: Int
    let year: Int
    let days: [CalendarDay]
    let lunarMonth: Int
    let lunarYear: Int

    var monthYearDisplay: String {
        String(format: "Tháng %d, %d", month, year)
    }

    var lunarMonthYearDisplay: String {
        String(format: "Tháng %d, Năm %d (AL)", lunarMonth, lunarYear)
    }

    var weeksOfDays: [[CalendarDay]] {
        var weeks: [[CalendarDay]] = []
        var currentWeek: [CalendarDay] = []

        for day in days {
            currentWeek.append(day)
            if currentWeek.count == 7 {
                weeks.append(currentWeek)
                currentWeek = []
            }
        }

        if !currentWeek.isEmpty {
            while currentWeek.count < 7 {
                // Pad with empty days
                if let lastDay = currentWeek.last {
                    let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: lastDay.date) ?? Date()
                    currentWeek.append(CalendarDay(
                        date: nextDate,
                        solarDay: 0,
                        solarMonth: 0,
                        solarYear: 0,
                        lunarDay: 0,
                        lunarMonth: 0,
                        lunarYear: 0,
                        dayType: .neutral,
                        isCurrentMonth: false,
                        isToday: false,
                        events: [],
                        isWeekend: false
                    ))
                }
            }
            weeks.append(currentWeek)
        }

        return weeks
    }
}

// MARK: - Festival/Holiday

struct Festival: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let date: Date
    let lunarDate: String
    let solarDate: String
    let type: FestivalType
    let description: String?

    enum FestivalType {
        case lunar
        case solar
        case traditional
    }
}
