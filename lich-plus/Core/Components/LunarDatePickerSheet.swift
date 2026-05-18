//
//  LunarDatePickerSheet.swift
//  lich-plus
//
//  Reusable date picker that mirrors the Lich tab calendar grid
//  (solar + lunar dates, good/bad-day tint). Present in a sheet.
//

import SwiftUI

struct LunarDatePickerSheet: View {
    @Binding var selectedDate: Date
    @Environment(\.dismiss) private var dismiss
    @State private var displayedMonth: Date

    init(selectedDate: Binding<Date>) {
        self._selectedDate = selectedDate
        self._displayedMonth = State(initialValue: selectedDate.wrappedValue)
    }

    private var month: CalendarMonth {
        CalendarDataManager.generateCalendarMonth(for: displayedMonth)
    }

    private var monthTitle: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "vi_VN")
        f.dateFormat = "'tháng' M yyyy"
        return f.string(from: displayedMonth)
    }

    var body: some View {
        VStack(spacing: AppTheme.spacing8) {
            header
            weekdayRow
            Divider().foregroundStyle(AppColors.borderLight)
            grid
            Spacer(minLength: 0)
        }
        .padding(.top, AppTheme.spacing16)
        .background(AppColors.background)
    }

    private var header: some View {
        HStack {
            Button { shiftMonth(-1) } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: AppTheme.fontTitle3, weight: .semibold))
                    .foregroundStyle(AppColors.primary)
                    .frame(width: 40, height: 40)
            }
            Spacer()
            Text(monthTitle)
                .font(.system(size: AppTheme.fontTitle2, weight: .bold))
                .foregroundStyle(AppColors.textPrimary)
            Spacer()
            Button { shiftMonth(1) } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: AppTheme.fontTitle3, weight: .semibold))
                    .foregroundStyle(AppColors.primary)
                    .frame(width: 40, height: 40)
            }
        }
        .padding(.horizontal, AppTheme.spacing16)
        .frame(height: 36)
    }

    private var weekdayRow: some View {
        HStack(spacing: 0) {
            ForEach(CalendarDisplayMode.weekdayHeaders, id: \.self) { day in
                Text(day)
                    .font(.system(size: AppTheme.fontCaption, weight: .semibold))
                    .foregroundStyle(AppColors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 28)
            }
        }
        .padding(.horizontal, AppTheme.spacing16)
    }

    private var grid: some View {
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
                                selectedDate = day.date
                                dismiss()
                            }
                        )
                    }
                }
                .frame(height: CalendarDisplayMode.rowHeight)
            }
        }
        .padding(.horizontal, AppTheme.spacing16)
    }

    private func shiftMonth(_ delta: Int) {
        if let new = Calendar.current.date(byAdding: .month, value: delta, to: displayedMonth) {
            displayedMonth = new
        }
    }
}
