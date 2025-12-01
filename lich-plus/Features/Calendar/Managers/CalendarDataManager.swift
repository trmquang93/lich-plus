//
//  CalendarDataManager.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 23/11/25.
//

import Foundation
import Combine
import SwiftData

// MARK: - Calendar Data Manager

class CalendarDataManager: ObservableObject {
    @Published var currentMonth: CalendarMonth
    @Published var selectedDate: Date = Date()

    private let calendar = Calendar.current
    private var modelContext: ModelContext?
    private var hasInitialized = false

    var selectedDay: CalendarDay? {
        createCalendarDay(from: selectedDate, isCurrentMonth: true, isToday: Calendar.current.isDateInToday(selectedDate))
    }

    init() {
        let today = Date()
        self.currentMonth = CalendarMonth(
            month: Calendar.current.component(.month, from: today),
            year: Calendar.current.component(.year, from: today),
            days: [],
            lunarMonth: 0,
            lunarYear: 0
        )
        // Will be properly initialized when modelContext is set
    }

    // MARK: - SwiftData Integration

    /// Set the ModelContext for database access and regenerate calendar
    /// - Parameter context: The ModelContext from the SwiftUI environment
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context

        // Only do full initialization on first appear
        guard !hasInitialized else { return }
        hasInitialized = true

        let today = Date()
        self.currentMonth = generateCalendarMonth(for: today)
        self.selectedDate = Date()
    }

    // MARK: - Public Methods

    func goToPreviousMonth() {
        let currentDate = currentMonth.days.first { $0.isCurrentMonth }?.date ?? Date()
        guard let previousDate = calendar.date(byAdding: .month, value: -1, to: currentDate) else {
            return
        }
        currentMonth = generateCalendarMonth(for: previousDate)
    }

    func goToNextMonth() {
        let currentDate = currentMonth.days.first { $0.isCurrentMonth }?.date ?? Date()
        guard let nextDate = calendar.date(byAdding: .month, value: 1, to: currentDate) else {
            return
        }
        currentMonth = generateCalendarMonth(for: nextDate)
    }

    func selectDay(_ day: CalendarDay) {
        selectedDate = day.date
    }

    func goToMonth(_ month: Int, year: Int) {
        let dateComponents = DateComponents(year: year, month: month, day: 1)
        guard let date = calendar.date(from: dateComponents) else {
            return
        }
        currentMonth = generateCalendarMonth(for: date)
    }

    /// Get calendar month with offset from current month (-1 = previous, 0 = current, 1 = next)
    func getMonth(offset: Int) -> CalendarMonth {
        guard offset != 0 else { return currentMonth }

        let currentDate = currentMonth.days.first { $0.isCurrentMonth }?.date ?? Date()
        guard let targetDate = calendar.date(byAdding: .month, value: offset, to: currentDate) else {
            return currentMonth
        }
        return generateCalendarMonth(for: targetDate)
    }

    /// Get calendar month with offset from TODAY (not currentMonth)
    /// offset 0 = current month, -1 = previous month, 1 = next month
    func getMonthFromToday(offset: Int) -> CalendarMonth {
        let today = Date()
        guard let targetDate = calendar.date(byAdding: .month, value: offset, to: today) else {
            return generateCalendarMonth(for: today)
        }
        return generateCalendarMonth(for: targetDate)
    }

    /// Get calendar month containing the week at given offset from today
    /// offset 0 = current week, -1 = previous week, 1 = next week
    func getMonthForWeek(offset: Int) -> CalendarMonth {
        let today = Date()
        guard let targetDate = calendar.date(byAdding: .weekOfYear, value: offset, to: today) else {
            return generateCalendarMonth(for: today)
        }
        return generateCalendarMonth(for: targetDate)
    }

    /// Get the specific week containing a date within a month
    func getWeekDays(containing date: Date, in month: CalendarMonth) -> [CalendarDay] {
        let weeks = month.weeksOfDays
        for week in weeks {
            if week.contains(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
                return week
            }
        }
        return weeks.first ?? []
    }

    // MARK: - Calendar Generation

    func generateCalendarMonth(for date: Date) -> CalendarMonth {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)

        guard let year = components.year, let month = components.month else {
            return CalendarMonth(month: 1, year: 2025, days: [], lunarMonth: 1, lunarYear: 2024)
        }

        let firstDay = calendar.date(from: DateComponents(year: year, month: month, day: 1)) ?? Date()
        let range = calendar.range(of: .day, in: .month, for: firstDay) ?? 1..<2
        let numberOfDays = range.count

        let firstWeekday = calendar.component(.weekday, from: firstDay)
        // Adjust for Monday-first week: weekday 1=Sunday, 2=Monday, etc.
        // Convert to 0=Monday, 1=Tuesday, ..., 6=Sunday
        let paddingDays = (firstWeekday + 5) % 7

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

    // MARK: - Static Helper Method

    /// Generate calendar month without database access (for testing)
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
        let paddingDays = (firstWeekday + 5) % 7

        var days: [CalendarDay] = []
        if paddingDays > 0 {
            for i in 0..<paddingDays {
                let paddingDate = calendar.date(byAdding: .day, value: -(paddingDays - i), to: firstDay) ?? Date()
                days.append(createCalendarDayStatic(from: paddingDate, isCurrentMonth: false))
            }
        }

        for dayNumber in 1...numberOfDays {
            let dateComponents = DateComponents(year: year, month: month, day: dayNumber)
            guard let date = calendar.date(from: dateComponents) else { continue }

            let isToday = calendar.isDateInToday(date)
            days.append(createCalendarDayStatic(from: date, isCurrentMonth: true, isToday: isToday))
        }

        let totalNeeded = 42
        if days.count < totalNeeded {
            for i in 1...(totalNeeded - days.count) {
                let paddingDate = calendar.date(byAdding: .day, value: i, to: firstDay.addingTimeInterval(TimeInterval(numberOfDays - 1) * 86400)) ?? Date()
                days.append(createCalendarDayStatic(from: paddingDate, isCurrentMonth: false))
            }
        }

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

    private func createCalendarDay(
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
        let events = fetchEvents(for: date)

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

    /// Fetch events from SwiftData for a specific date
    /// - Parameter date: The date to fetch events for
    /// - Returns: Array of Event objects
    private func fetchEvents(for date: Date) -> [Event] {
        guard let context = modelContext else { return [] }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let predicate = #Predicate<SyncableEvent> {
            !$0.isDeleted &&
            $0.startDate >= startOfDay &&
            $0.startDate < endOfDay
        }

        let descriptor = FetchDescriptor<SyncableEvent>(
            predicate: predicate,
            sortBy: [SortDescriptor(\SyncableEvent.startDate)]
        )

        do {
            let syncableEvents = try context.fetch(descriptor)
            return syncableEvents.map { syncable in
                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "HH:mm"
                let timeString = timeFormatter.string(from: syncable.startDate)

                return Event(
                    title: syncable.title,
                    time: timeString,
                    category: parseEventCategory(from: syncable.category),
                    description: syncable.notes
                )
            }
        } catch {
            print("Error fetching events for date \(date): \(error)")
            return []
        }
    }

    /// Parse TaskCategory to EventCategory
    /// - Parameter categoryString: The category string from SyncableEvent
    /// - Returns: EventCategory
    private func parseEventCategory(from categoryString: String) -> EventCategory {
        let taskCategory = TaskCategory(rawValue: categoryString.prefix(1).uppercased() + categoryString.dropFirst()) ?? .other

        switch taskCategory {
        case .work:
            return .work
        case .personal:
            return .personal
        case .birthday:
            return .birthday
        case .holiday:
            return .holiday
        case .meeting:
            return .meeting
        case .other:
            return .other
        }
    }

    /// Static helper for creating calendar days without database access
    private static func createCalendarDayStatic(
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
            events: [],  // No events in static version
            isWeekend: isWeekend
        )
    }
}
