//
//  CalendarDataManager.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 23/11/25.
//

import Foundation
import Combine

// MARK: - Calendar Data Manager

class CalendarDataManager: ObservableObject {
    @Published var currentMonth: CalendarMonth
    @Published var selectedDay: CalendarDay?

    private let calendar = Calendar.current

    init() {
        let today = Date()
        self.currentMonth = Self.generateCalendarMonth(for: today)
        self.selectedDay = nil
    }

    // MARK: - Public Methods

    func goToPreviousMonth() {
        guard let previousDate = calendar.date(byAdding: .month, value: -1, to: currentMonth.days.first?.date ?? Date()) else {
            return
        }
        currentMonth = Self.generateCalendarMonth(for: previousDate)
        selectedDay = nil
    }

    func goToNextMonth() {
        guard let nextDate = calendar.date(byAdding: .month, value: 1, to: currentMonth.days.last?.date ?? Date()) else {
            return
        }
        currentMonth = Self.generateCalendarMonth(for: nextDate)
        selectedDay = nil
    }

    func selectDay(_ day: CalendarDay) {
        selectedDay = day
    }

    // MARK: - Static Methods

    static func generateCalendarMonth(for date: Date) -> CalendarMonth {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)

        guard let year = components.year, let month = components.month else {
            return CalendarMonth(month: 1, year: 2025, days: [], lunarMonth: 1, lunarYear: 2024)
        }

        let firstDay = calendar.date(from: DateComponents(year: year, month: month, day: 1)) ?? Date()
        let range = calendar.range(of: .day, in: .month, for: firstDay) ?? 1..<2
        let numberOfDays = range.count

        let firstWeekday = calendar.component(.weekday, from: firstDay)
        let paddingDays = firstWeekday - 1

        // Create padding for previous month
        var days: [CalendarDay] = []
        if paddingDays > 0 {
            for i in 0..<paddingDays {
                let paddingDate = calendar.date(byAdding: .day, value: -(paddingDays - i), to: firstDay) ?? Date()
                days.append(createCalendarDay(from: paddingDate, isCurrentMonth: false))
            }
        }

        // Create days for current month
        for dayNumber in 1...numberOfDays {
            let dateComponents = DateComponents(year: year, month: month, day: dayNumber)
            guard let date = calendar.date(from: dateComponents) else { continue }

            let isToday = calendar.isDateInToday(date)
            days.append(createCalendarDay(from: date, isCurrentMonth: true, isToday: isToday))
        }

        // Create padding for next month
        let totalNeeded = 42
        if days.count < totalNeeded {
            for i in 1...(totalNeeded - days.count) {
                let paddingDate = calendar.date(byAdding: .day, value: i, to: firstDay.addingTimeInterval(TimeInterval(numberOfDays - 1) * 86400)) ?? Date()
                days.append(createCalendarDay(from: paddingDate, isCurrentMonth: false))
            }
        }

        // Calculate lunar month/year for the first day
        let (_, lunarMonth, lunarYear) = LunarCalendar.solarToLunar(firstDay)

        return CalendarMonth(
            month: month,
            year: year,
            days: days,
            lunarMonth: lunarMonth,
            lunarYear: lunarYear
        )
    }

    // MARK: - Private Methods

    private static func createCalendarDay(
        from date: Date,
        isCurrentMonth: Bool,
        isToday: Bool = false
    ) -> CalendarDay {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .weekday], from: date)

        guard let day = components.day,
              let month = components.month,
              let year = components.year,
              let weekday = components.weekday else {
            return CalendarDay(
                date: date,
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
            )
        }

        let (lunarDay, lunarMonth, lunarYear) = LunarCalendar.solarToLunar(date)
        let dayType = DayTypeCalculator.determineDayType(for: date)
        let isWeekend = weekday == 1 || weekday == 7
        let events = generateMockEvents(for: date)

        return CalendarDay(
            date: date,
            solarDay: day,
            solarMonth: month,
            solarYear: year,
            lunarDay: lunarDay,
            lunarMonth: lunarMonth,
            lunarYear: lunarYear,
            dayType: dayType,
            isCurrentMonth: isCurrentMonth,
            isToday: isToday,
            events: events,
            isWeekend: isWeekend
        )
    }

    private static func generateMockEvents(for date: Date) -> [Event] {
        // Generate mock events based on the date
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)

        // Add events for specific days (demo purposes)
        var events: [Event] = []

        if day % 5 == 0 {
            events.append(Event(
                title: "Team Meeting",
                time: "10:00 AM",
                category: .meeting,
                description: "Weekly sync"
            ))
        }

        if day % 7 == 0 {
            events.append(Event(
                title: "Project Deadline",
                time: "05:00 PM",
                category: .work,
                description: "Final submission"
            ))
        }

        if day % 3 == 0 {
            events.append(Event(
                title: "Lunch",
                time: "12:00 PM",
                category: .personal,
                description: nil
            ))
        }

        return events
    }
}
