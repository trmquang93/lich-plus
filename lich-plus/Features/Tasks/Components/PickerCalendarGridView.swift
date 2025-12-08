//
//  PickerCalendarGridView.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 08/12/25.
//

import SwiftUI

/// A calendar grid layout for use in date picker sheets
/// Displays weekday headers and a 6-week grid of days with date selection and time preservation
struct PickerCalendarGridView: View {
    let month: CalendarMonth
    @Binding var selectedDate: Date

    var body: some View {
        VStack(spacing: CalendarDisplayMode.spacingBetweenItems) {
            // Weekday headers
            HStack(spacing: CalendarDisplayMode.spacingBetweenItems) {
                ForEach(CalendarDisplayMode.weekdayHeaders, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, AppTheme.spacing16)
            .padding(.bottom, AppTheme.spacing8)

            // Calendar grid - 6 weeks
            VStack(spacing: CalendarDisplayMode.spacingBetweenItems) {
                ForEach(month.weeksOfDays.indices, id: \.self) { weekIndex in
                    HStack(spacing: CalendarDisplayMode.spacingBetweenItems) {
                        ForEach(month.weeksOfDays[weekIndex]) { day in
                            CalendarDayCell(
                                day: day,
                                isSelected: Calendar.current.isDate(
                                    selectedDate, inSameDayAs: day.date),
                                showEvents: false,
                                onTap: {
                                    updateSelectedDate(with: day)
                                }
                            )
                        }
                    }
                    .frame(height: CalendarDisplayMode.rowHeight)
                }
            }
            .padding(.horizontal, AppTheme.spacing16)
        }
    }

    // MARK: - Helper Methods

    /// Updates the selected date while preserving the time components
    /// - Parameter day: The calendar day that was selected
    private func updateSelectedDate(with day: CalendarDay) {
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: selectedDate)
        var newDateComponents = calendar.dateComponents([.year, .month, .day], from: day.date)
        newDateComponents.hour = timeComponents.hour
        newDateComponents.minute = timeComponents.minute
        selectedDate = calendar.date(from: newDateComponents) ?? day.date
    }
}

// MARK: - Preview

#Preview {
    let sampleDays = (1...30).map { dayNum -> CalendarDay in
        let isWeekend = dayNum % 7 < 2
        let dayType: DayType = dayNum % 3 == 0 ? .good : (dayNum % 3 == 1 ? .bad : .neutral)

        return CalendarDay(
            date: Calendar.current.date(byAdding: .day, value: dayNum - 1, to: Date()) ?? Date(),
            solarDay: dayNum,
            solarMonth: 11,
            solarYear: 2025,
            lunarDay: dayNum,
            lunarMonth: 10,
            lunarYear: 2024,
            dayType: dayType,
            isCurrentMonth: true,
            isToday: dayNum == 8,
            events: [],
            isWeekend: isWeekend
        )
    }

    let month = CalendarMonth(
        month: 11,
        year: 2025,
        days: sampleDays,
        lunarMonth: 10,
        lunarYear: 2024
    )

    return VStack {
        PickerCalendarGridView(
            month: month,
            selectedDate: .constant(Date())
        )

        Spacer()
    }
    .background(AppColors.background)
    .padding()
}
