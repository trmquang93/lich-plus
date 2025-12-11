//
//  CalendarGridView.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 23/11/25.
//

import SwiftUI

// MARK: - Calendar Grid View

struct CalendarGridView: View {
    let month: CalendarMonth
    @Binding var selectedDate: Date
    let onDaySelected: (CalendarDay) -> Void
    let collapseProgress: CGFloat

    private var selectedWeekIndex: Int {
        let weeks = month.weeksOfDays
        for (index, week) in weeks.enumerated() {
            if week.contains(where: { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) })
            {
                return index
            }
        }
        return 0
    }

    private var translationOffset: CGFloat {
        var maxTranslation = CGFloat(selectedWeekIndex) * CalendarDisplayMode.rowHeight
        maxTranslation =
            maxTranslation + CalendarDisplayMode.spacingBetweenItems * CGFloat(selectedWeekIndex)
        return -maxTranslation * collapseProgress
    }

    private var progressOffset: CGFloat {
        return (CalendarDisplayMode.maxHeight - CalendarDisplayMode.rowHeight) * collapseProgress
    }

    var body: some View {
        VStack(spacing: CalendarDisplayMode.spacingBetweenItems) {
            ForEach(month.weeksOfDays.indices, id: \.self) { weekIndex in
                HStack(spacing: CalendarDisplayMode.spacingBetweenItems) {
                    ForEach(month.weeksOfDays[weekIndex]) { day in
                        CalendarDayCell(
                            day: day,
                            isSelected: Calendar.current.isDate(
                                selectedDate, inSameDayAs: day.date),
                            onTap: {
                                selectedDate = day.date
                                onDaySelected(day)
                            }
                        )
                    }
                }
                .frame(height: CalendarDisplayMode.rowHeight)
            }
        }
        .offset(y: translationOffset + (progressOffset / 2))
        .padding(.horizontal, AppTheme.spacing16)
        .frame(height: CalendarDisplayMode.maxHeight, alignment: .top)
        .clipped()
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: collapseProgress)
    }
}

// MARK: - Calendar Day Cell

struct CalendarDayCell: View {
    let day: CalendarDay
    let isSelected: Bool
    let showEvents: Bool
    let onTap: () -> Void

    init(day: CalendarDay, isSelected: Bool, showEvents: Bool = true, onTap: @escaping () -> Void) {
        self.day = day
        self.isSelected = isSelected
        self.showEvents = showEvents
        self.onTap = onTap
    }

    var backgroundColor: Color {
        switch day.dayType {
        case .good:
            return AppColors.accentLight
        case .bad:
            return Color(red: 1, green: 0.93, blue: 0.93)
        case .neutral:
            return AppColors.background
        }
    }

    var borderColor: Color {
        if day.isToday {
            return AppColors.primary
        }
        if isSelected {
            return AppColors.accent
        }
        return AppColors.borderLight
    }

    var borderWidth: CGFloat {
        if day.isToday || isSelected {
            return 2
        }
        return 0
    }

    var textColor: Color {
        if !day.isCurrentMonth {
            return AppColors.textDisabled
        }
        return AppColors.textPrimary
    }

    var body: some View {
        VStack(spacing: AppTheme.spacing2) {
            Spacer().frame(height: 2)

            // Solar date (large)
            Text(day.displaySolar)
                .font(.system(size: AppTheme.fontSubheading, weight: .bold))
                .foregroundStyle(
                    day.isWeekend && day.isCurrentMonth ? AppColors.primary : textColor)

            // Lunar date (small, faint)
            Text(day.displayLunar)
                .font(.system(size: 9, weight: .regular))
                .foregroundStyle(AppColors.textSecondary.opacity(0.6))
                .lineLimit(1)

            // Event indicator dots
            if showEvents && day.hasEvents {
                HStack(spacing: 2) {
                    ForEach(Array(day.events.prefix(3)), id: \.id) { event in
                        Circle()
                            .fill(eventDotColor(for: event))
                            .frame(width: 4, height: 4)
                    }
                }
            } else {
                Spacer()
            }
            Spacer().frame(height: 2)
        }
        .frame(height: 38)
        .frame(maxWidth: .infinity)
        .padding(AppTheme.spacing4)
        .background(backgroundColor)
        .cornerRadius(AppTheme.cornerRadiusSmall)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall)
                .stroke(borderColor, lineWidth: borderWidth)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            if day.isCurrentMonth {
                onTap()
            }
        }
    }

    // MARK: - Helper Methods

    private func eventDotColor(for event: Event) -> Color {
        switch event.category {
        case .holiday:
            return AppColors.primary  // Red for holidays
        default:
            return AppColors.eventOrange  // Orange for other events
        }
    }
}

// MARK: - Preview

#Preview {
    let sampleDays = (1...30).map { dayNum -> CalendarDay in
        let isWeekend = dayNum % 7 < 2
        let dayType: DayType = dayNum % 3 == 0 ? .good : (dayNum % 3 == 1 ? .bad : .neutral)
        let hasEvents = dayNum % 5 == 0

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
            isToday: dayNum == 23,
            events: hasEvents
                ? [Event(title: "Sample Event", time: "10:00", isAllDay: false, category: .work, description: nil)]
                : [],
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

    VStack {
        CalendarGridView(
            month: month,
            selectedDate: .constant(Date()),
            onDaySelected: { _ in },
            collapseProgress: 0
        )

        Spacer()
    }
    .background(AppColors.background)
}
