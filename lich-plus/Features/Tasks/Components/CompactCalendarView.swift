//
//  CompactCalendarView.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 26/11/25.
//

import SwiftUI

struct CompactCalendarView: View {
    @Binding var selectedDate: Date
    let daysWithItems: Set<DateComponents>

    let columns: [GridItem] = Array(repeating: GridItem(.flexible()), count: 7)

    var dayLabels: [String] {
        [
            String(localized: "day.sun"),
            String(localized: "day.mon"),
            String(localized: "day.tue"),
            String(localized: "day.wed"),
            String(localized: "day.thu"),
            String(localized: "day.fri"),
            String(localized: "day.sat")
        ]
    }

    var calendar: Calendar = Calendar.current

    private var dateKeySet: Set<String> {
        Set(daysWithItems.map { "\($0.year ?? 0)-\($0.month ?? 0)-\($0.day ?? 0)" })
    }

    private var monthYearDisplay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedDate)
    }

    private var daysInMonth: Int {
        let range = calendar.range(of: .day, in: .month, for: selectedDate)!
        return range.count
    }

    private var firstWeekdayOfMonth: Int {
        let components = calendar.dateComponents([.weekday], from: firstDayOfMonth)
        return components.weekday! - 1
    }

    private var firstDayOfMonth: Date {
        let components = calendar.dateComponents([.year, .month], from: selectedDate)
        return calendar.date(from: components)!
    }

    var body: some View {
        VStack(spacing: AppTheme.spacing12) {
            // Month and Year Header
            Text(monthYearDisplay)
                .font(.system(size: AppTheme.fontSubheading, weight: .semibold))
                .foregroundStyle(AppColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, AppTheme.spacing16)

            // Day Labels
            HStack {
                ForEach(dayLabels, id: \.self) { day in
                    Text(day)
                        .font(.system(size: AppTheme.fontCaption, weight: .medium))
                        .foregroundStyle(AppColors.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, AppTheme.spacing16)

            // Calendar Grid
            LazyVGrid(columns: columns, spacing: AppTheme.spacing8) {
                // Empty cells for days before month starts
                ForEach(0..<firstWeekdayOfMonth, id: \.self) { _ in
                    Color.clear
                        .frame(height: 40)
                }

                // Days of month
                ForEach(1...daysInMonth, id: \.self) { day in
                    let date = calendar.date(
                        byAdding: .day,
                        value: day - 1,
                        to: firstDayOfMonth
                    )!

                    ZStack {
                        // Background
                        if calendar.isDateInToday(date) {
                            Circle()
                                .fill(AppColors.primary)
                        } else if calendar.isDate(date, inSameDayAs: selectedDate) {
                            Circle()
                                .fill(AppColors.backgroundLight)
                                .overlay(
                                    Circle()
                                        .stroke(AppColors.primary, lineWidth: 2)
                                )
                        }

                        VStack(spacing: 2) {
                            Text("\(day)")
                                .font(.system(size: AppTheme.fontBody, weight: .medium))
                                .foregroundStyle(
                                    calendar.isDateInToday(date) ? .white :
                                    calendar.isDate(date, inSameDayAs: selectedDate) ? AppColors.textPrimary :
                                    AppColors.textPrimary
                                )

                            // Dot indicator if has items
                            if hasItemsForDate(date) {
                                Circle()
                                    .fill(AppColors.accent)
                                    .frame(width: 4, height: 4)
                            }
                        }
                    }
                    .frame(height: 40)
                    .onTapGesture {
                        selectedDate = date
                    }
                }
            }
            .padding(.horizontal, AppTheme.spacing16)
        }
        .padding(.vertical, AppTheme.spacing16)
        .background(AppColors.backgroundLightGray)
        .cornerRadius(AppTheme.cornerRadiusMedium)
    }

    private func hasItemsForDate(_ date: Date) -> Bool {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let dateKey = "\(components.year ?? 0)-\(components.month ?? 0)-\(components.day ?? 0)"
        return dateKeySet.contains(dateKey)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var selectedDate = Date()

        var body: some View {
            CompactCalendarView(
                selectedDate: $selectedDate,
                daysWithItems: {
                    var days = Set<DateComponents>()
                    let calendar = Calendar.current
                    for i in 0..<5 {
                        if let date = calendar.date(byAdding: .day, value: i, to: Date()) {
                            let components = calendar.dateComponents([.year, .month, .day], from: date)
                            days.insert(components)
                        }
                    }
                    return days
                }()
            )
            .padding()
            .background(AppColors.background)
        }
    }

    return PreviewWrapper()
}
