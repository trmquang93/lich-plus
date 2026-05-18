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
    @State private var pageOffset: Int
    @State private var showMonthPicker = false

    private let anchor: Date

    init(selectedDate: Binding<Date>) {
        self._selectedDate = selectedDate
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month], from: selectedDate.wrappedValue)
        self.anchor = cal.date(from: comps) ?? selectedDate.wrappedValue
        self._pageOffset = State(initialValue: 0)
    }

    private var displayedMonth: Date {
        Calendar.current.date(byAdding: .month, value: pageOffset, to: anchor) ?? anchor
    }

    private var monthTitle: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "vi_VN")
        f.dateFormat = "'tháng' M yyyy"
        return f.string(from: displayedMonth)
    }

    private var gridHeight: CGFloat {
        CalendarDisplayMode.rowHeight * 6 + CalendarDisplayMode.spacingBetweenItems * 5
    }

    var body: some View {
        VStack(spacing: AppTheme.spacing8) {
            header
            weekdayRow
            Divider().foregroundStyle(AppColors.borderLight)
            pager
            Spacer(minLength: 0)
        }
        .padding(.top, AppTheme.spacing16)
        .background(AppColors.background)
        .sheet(isPresented: $showMonthPicker) {
            MonthPickerView(
                selectedDate: displayedMonth,
                onMonthSelected: { month, year in
                    if let new = Calendar.current.date(
                        from: DateComponents(year: year, month: month, day: 1))
                    {
                        let diff = Calendar.current.dateComponents(
                            [.month], from: anchor, to: new
                        ).month ?? 0
                        pageOffset = diff
                    }
                },
                onDismiss: { showMonthPicker = false }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }

    private var header: some View {
        HStack {
            Button {
                pageOffset -= 1
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: AppTheme.fontTitle3, weight: .semibold))
                    .foregroundStyle(AppColors.primary)
                    .frame(width: 40, height: 40)
            }
            Spacer()
            Button {
                showMonthPicker = true
            } label: {
                HStack(spacing: AppTheme.spacing4) {
                    Text(monthTitle)
                        .font(.system(size: AppTheme.fontTitle2, weight: .bold))
                        .foregroundStyle(AppColors.textPrimary)
                    Image(systemName: "chevron.down")
                        .font(.system(size: AppTheme.fontCaption, weight: .semibold))
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
            Spacer()
            Button {
                pageOffset += 1
            } label: {
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

    private var pager: some View {
        InfinitePageView(
            initialIndex: pageOffset,
            currentValue: pageOffset,
            content: { offset in
                let date =
                    Calendar.current.date(byAdding: .month, value: offset, to: anchor)
                    ?? anchor
                let month = CalendarDataManager.generateCalendarMonth(for: date)
                return VStack(spacing: CalendarDisplayMode.spacingBetweenItems) {
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
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, AppTheme.spacing16)
            },
            onPageChanged: { newOffset in
                pageOffset = newOffset
            }
        )
        .frame(height: gridHeight)
    }
}
