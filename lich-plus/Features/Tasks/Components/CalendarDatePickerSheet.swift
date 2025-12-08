//
//  CalendarDatePickerSheet.swift
//  lich-plus
//
//  Modal sheet for calendar-based date and time selection with lunar calendar support
//

import SwiftUI

struct CalendarDatePickerSheet: View {
    let title: String
    @Binding var selectedDate: Date
    let onDone: () -> Void

    @State private var displayMonth: Int
    @State private var displayYear: Int
    @State private var calendarMonth: CalendarMonth

    init(title: String, selectedDate: Binding<Date>, onDone: @escaping () -> Void) {
        self.title = title
        self._selectedDate = selectedDate
        self.onDone = onDone

        // Initialize display month/year from selectedDate
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: selectedDate.wrappedValue)
        let month = components.month ?? Calendar.current.component(.month, from: Date())
        let year = components.year ?? Calendar.current.component(.year, from: Date())

        self._displayMonth = State(initialValue: month)
        self._displayYear = State(initialValue: year)

        let date = calendar.date(from: DateComponents(year: year, month: month, day: 1)) ?? Date()
        self._calendarMonth = State(initialValue: CalendarDataManager.generateCalendarMonth(for: date))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: AppTheme.spacing16) {
                // Month/Year Navigation Header
                HStack(spacing: AppTheme.spacing16) {
                    // Previous month button
                    Button(action: previousMonth) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(AppColors.primary)
                    }

                    Spacer()

                    // Month/Year Display
                    VStack(spacing: AppTheme.spacing4) {
                        // Solar month/year: "Tháng 12, 2025"
                        Text(formatSolarMonthYear())
                            .font(.system(size: AppTheme.fontTitle3, weight: .semibold))
                            .foregroundStyle(AppColors.textPrimary)

                        // Lunar month/year with Can-Chi: "Tháng 11 năm Giáp Thìn"
                        Text(formatLunarMonthYear())
                            .font(.system(size: AppTheme.fontCaption, weight: .regular))
                            .foregroundStyle(AppColors.textSecondary)
                    }

                    Spacer()

                    // Next month button
                    Button(action: nextMonth) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(AppColors.primary)
                    }
                }
                .padding(.horizontal, AppTheme.spacing16)
                .padding(.vertical, AppTheme.spacing12)

                // Calendar Grid
                PickerCalendarGridView(
                    month: calendarMonth,
                    selectedDate: $selectedDate
                )
                .padding(.bottom, AppTheme.spacing16)

                // Time Picker
                VStack(alignment: .leading, spacing: AppTheme.spacing8) {
                    Text(String(localized: "datePicker.selectTime"))
                        .font(.system(size: AppTheme.fontBody, weight: .medium))
                        .foregroundStyle(AppColors.textPrimary)
                        .padding(.horizontal, AppTheme.spacing16)

                    DatePicker(
                        "",
                        selection: $selectedDate,
                        displayedComponents: [.hourAndMinute]
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .padding(.horizontal, AppTheme.spacing16)
                }

                Spacer()
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "task.done")) {
                        onDone()
                    }
                    .foregroundStyle(AppColors.primary)
                }
            }
        }
    }

    // MARK: - Month Navigation

    private func changeMonth(by offset: Int) {
        let calendar = Calendar.current
        let currentDate = calendar.date(from: DateComponents(year: displayYear, month: displayMonth, day: 1)) ?? Date()
        guard let newDate = calendar.date(byAdding: .month, value: offset, to: currentDate) else { return }
        let components = calendar.dateComponents([.year, .month], from: newDate)
        displayMonth = components.month ?? displayMonth
        displayYear = components.year ?? displayYear
        updateCalendarMonth()
    }

    private func previousMonth() {
        changeMonth(by: -1)
    }

    private func nextMonth() {
        changeMonth(by: 1)
    }

    private func updateCalendarMonth() {
        let dateComponents = DateComponents(year: displayYear, month: displayMonth, day: 1)
        guard let date = Calendar.current.date(from: dateComponents) else { return }
        calendarMonth = CalendarDataManager.generateCalendarMonth(for: date)
    }

    // MARK: - Formatting Helpers

    private func formatSolarMonthYear() -> String {
        String(format: String(localized: "datePicker.monthYear"), displayMonth, displayYear)
    }

    private func formatLunarMonthYear() -> String {
        let yearCanChi = CanChiCalculator.calculateYearCanChi(lunarYear: calendarMonth.lunarYear)
        return String(format: String(localized: "datePicker.lunarMonthYear"), calendarMonth.lunarMonth, yearCanChi.displayName)
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var selectedDate = Date()

    CalendarDatePickerSheet(
        title: "Chọn ngày bắt đầu",
        selectedDate: $selectedDate,
        onDone: {
            print("Selected date: \(selectedDate)")
        }
    )
}
