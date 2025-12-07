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

@MainActor
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

    /// Refresh the current month with latest data from the database
    func refreshCurrentMonth() {
        currentMonth = generateCalendarMonth(for: selectedDate)
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

    /// Calculate month offset from today for any given date
    func calculateMonthOffsetFromToday(for date: Date) -> Int {
        let today = Date()
        let todayComponents = calendar.dateComponents([.year, .month], from: today)
        let dateComponents = calendar.dateComponents([.year, .month], from: date)

        guard let todayYear = todayComponents.year,
              let todayMonth = todayComponents.month,
              let dateYear = dateComponents.year,
              let dateMonth = dateComponents.month else {
            return 0
        }

        return (dateYear - todayYear) * 12 + (dateMonth - todayMonth)
    }

    // MARK: - Calendar Generation

    func generateCalendarMonth(for date: Date) -> CalendarMonth {
        return Self.generateCalendarMonthCoreStatic(for: date, createDay: createCalendarDay)
    }

    // MARK: - Static Helper Method

    /// Generate calendar month without database access (for testing)
    static func generateCalendarMonth(for date: Date) -> CalendarMonth {
        return generateCalendarMonthCoreStatic(for: date, createDay: createCalendarDayStatic)
    }

    /// Static core calendar month generation logic
    private static func generateCalendarMonthCoreStatic(
        for date: Date,
        createDay: (Date, Bool, Bool) -> CalendarDay
    ) -> CalendarMonth {
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
                days.append(createDay(paddingDate, false, false))
            }
        }

        for dayNumber in 1...numberOfDays {
            let dateComponents = DateComponents(year: year, month: month, day: dayNumber)
            guard let date = calendar.date(from: dateComponents) else { continue }

            let isToday = calendar.isDateInToday(date)
            days.append(createDay(date, true, isToday))
        }

        let totalNeeded = 42
        if days.count < totalNeeded {
            for i in 1...(totalNeeded - days.count) {
                let paddingDate = calendar.date(byAdding: .day, value: i, to: firstDay.addingTimeInterval(TimeInterval(numberOfDays - 1) * 86400)) ?? Date()
                days.append(createDay(paddingDate, false, false))
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

    func createCalendarDay(
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
    func fetchEvents(for date: Date) -> [Event] {
        guard let context = modelContext else { return [] }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        var results: [Event] = []

        do {
            // 1. Fetch non-recurring events for this date (optimized query)
            let nonRecurringPredicate = #Predicate<SyncableEvent> { event in
                !event.isDeleted &&
                event.recurrenceRuleData == nil &&
                event.startDate >= startOfDay &&
                event.startDate < endOfDay
            }

            let nonRecurringDescriptor = FetchDescriptor<SyncableEvent>(
                predicate: nonRecurringPredicate,
                sortBy: [SortDescriptor(\SyncableEvent.startDate)]
            )

            let nonRecurring = try context.fetch(nonRecurringDescriptor)
            results.append(contentsOf: nonRecurring.map { convertToEvent($0) })

            // 2. Fetch recurring events only
            let recurringPredicate = #Predicate<SyncableEvent> { event in
                !event.isDeleted && event.recurrenceRuleData != nil
            }

            let recurringDescriptor = FetchDescriptor<SyncableEvent>(predicate: recurringPredicate)
            let recurring = try context.fetch(recurringDescriptor)

            // 3. Check each recurring event against target date
            for event in recurring {
                if RecurrenceMatcher.occursOnDate(event, targetDate: date) {
                    results.append(convertToEvent(event))
                }
            }

            return results.sorted { $0.time < $1.time }
        } catch {
            print("Error fetching events for date \(date): \(error)")
            return []
        }
    }

    /// Convert a SyncableEvent to an Event for display
    /// - Parameter syncable: The SyncableEvent to convert
    /// - Returns: An Event object
    private func convertToEvent(_ syncable: SyncableEvent) -> Event {
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
