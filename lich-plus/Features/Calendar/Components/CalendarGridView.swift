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
    @Binding var selectedDay: CalendarDay?
    let onDaySelected: (CalendarDay) -> Void

    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    var body: some View {
        LazyVGrid(columns: columns, spacing: AppTheme.spacing8) {
            ForEach(month.days) { day in
                CalendarDayCell(
                    day: day,
                    isSelected: selectedDay?.id == day.id,
                    onTap: {
                        selectedDay = day
                        onDaySelected(day)
                    }
                )
            }
        }
        .padding(.horizontal, AppTheme.spacing16)
        .padding(.vertical, AppTheme.spacing12)
    }
}

// MARK: - Calendar Day Cell

struct CalendarDayCell: View {
    let day: CalendarDay
    let isSelected: Bool
    let onTap: () -> Void

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
        VStack(spacing: AppTheme.spacing4) {
            Spacer().frame(height: 4)

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
            if day.hasEvents {
                HStack(spacing: 2) {
                    ForEach(0..<min(day.events.count, 3), id: \.self) { _ in
                        Circle()
                            .fill(AppColors.eventOrange)
                            .frame(width: 4, height: 4)
                    }
                }
            } else {
                Spacer()
            }
            Spacer().frame(height: 4)
        }
        .frame(height: 45)
        .frame(maxWidth: .infinity)
        .padding(AppTheme.spacing8)
        .background(backgroundColor)
        .border(borderColor, width: borderWidth)
        .cornerRadius(AppTheme.cornerRadiusSmall)
        .contentShape(Rectangle())
        .onTapGesture {
            if day.isCurrentMonth {
                onTap()
            }
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
                ? [Event(title: "Sample Event", time: "10:00", category: .work, description: nil)]
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

    return VStack {
        CalendarGridView(
            month: month,
            selectedDay: .constant(nil),
            onDaySelected: { _ in }
        )

        Spacer()
    }
    .background(AppColors.background)
}
