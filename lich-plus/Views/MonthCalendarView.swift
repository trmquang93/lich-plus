import SwiftUI
import SwiftData

// MARK: - Month Calendar View
struct MonthCalendarView: View {
    @State private var currentDate = Date()
    @State private var selectedDate: Date?
    @State private var showDayAgenda = false
    @State private var showEventForm = false

    @Query private var events: [CalendarEvent]

    let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)
    let dayHeaders = ["CN", "T2", "T3", "T4", "T5", "T6", "T7"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Navigation Header
                MonthYearPicker(
                    currentDate: $currentDate,
                    onPreviousMonth: { goToPreviousMonth() },
                    onNextMonth: { goToNextMonth() }
                )

                // Day Headers
                HStack {
                    ForEach(dayHeaders, id: \.self) { day in
                        Text(day)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 16)

                // Calendar Grid
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(Array(getDaysInMonth().enumerated()), id: \.offset) { (_, day) in
                        let isCurrentMonth = Calendar.current.component(.month, from: day) == Calendar.current.component(.month, from: currentDate)
                        let lunarDate = LunarCalendarConverter.getLunarDate(for: day)
                        let dayEvents = events.filter { Calendar.current.isDate($0.date, inSameDayAs: day) }
                        let isToday = Calendar.current.isDateInToday(day)
                        let isSelected = selectedDate.map { Calendar.current.isDate(day, inSameDayAs: $0) } ?? false

                        CalendarCellView(
                            day: isCurrentMonth ? Calendar.current.component(.day, from: day) : nil,
                            lunarDay: lunarDate.displayString,
                            hasEvents: !dayEvents.isEmpty,
                            isCurrentMonth: isCurrentMonth,
                            isToday: isToday,
                            isSelected: isSelected,
                            action: {
                                selectedDate = day
                                showDayAgenda = true
                            }
                        )
                    }
                }
                .padding(.horizontal, 16)

                Spacer()
            }
            .background(Color.white)
            .navigationDestination(isPresented: $showDayAgenda) {
                if let selectedDate = selectedDate {
                    DayAgendaView(
                        date: selectedDate,
                        showEventForm: $showEventForm,
                        showDayAgenda: $showDayAgenda
                    )
                }
            }
            .sheet(isPresented: $showEventForm) {
                EventFormView(
                    isPresented: $showEventForm,
                    initialDate: selectedDate ?? currentDate,
                    eventToEdit: nil
                )
            }
        }
        .overlay(alignment: .bottomTrailing) {
            FloatingActionButton(action: {
                showEventForm = true
            })
            .padding()
        }
    }

    // MARK: - Helper Methods
    private func getDaysInMonth() -> [Date] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: currentDate)!
        let numDays = range.count

        // Get the first day of the month
        var components = calendar.dateComponents([.year, .month], from: currentDate)
        components.day = 1
        let firstDay = calendar.date(from: components)!

        // Get the weekday of the first day (0 = Sunday, 6 = Saturday)
        let firstWeekday = calendar.component(.weekday, from: firstDay) - 1

        // Create array with empty days before month starts
        var days: [Date] = []

        // Add days from previous month
        if firstWeekday > 0 {
            let previousMonthDate = calendar.date(byAdding: .month, value: -1, to: currentDate)!
            let previousMonthRange = calendar.range(of: .day, in: .month, for: previousMonthDate)!
            let previousMonthDays = previousMonthRange.count

            for i in (previousMonthDays - firstWeekday + 1)...previousMonthDays {
                var prevComponents = calendar.dateComponents([.year, .month], from: previousMonthDate)
                prevComponents.day = i
                if let date = calendar.date(from: prevComponents) {
                    days.append(date)
                }
            }
        }

        // Add days of current month
        for day in 1...numDays {
            components.day = day
            if let date = calendar.date(from: components) {
                days.append(date)
            }
        }

        // Add days from next month to fill the grid
        let remainingDays = 42 - days.count // 6 rows * 7 columns
        let nextMonthDate = calendar.date(byAdding: .month, value: 1, to: currentDate)!
        for day in 1...remainingDays {
            var nextComponents = calendar.dateComponents([.year, .month], from: nextMonthDate)
            nextComponents.day = day
            if let date = calendar.date(from: nextComponents) {
                days.append(date)
            }
        }

        return days
    }

    private func goToPreviousMonth() {
        currentDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
    }

    private func goToNextMonth() {
        currentDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
    }
}

// MARK: - Preview
#Preview {
    MonthCalendarView()
        .modelContainer(for: CalendarEvent.self, inMemory: true)
}
