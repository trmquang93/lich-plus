//
//  LunarDatePickerView.swift
//  lich-plus
//
//  Picker for lunar calendar dates with solar preview
//

import SwiftUI

struct LunarDatePickerView: View {
    @Binding var lunarDay: Int
    @Binding var lunarMonth: Int
    @Binding var includeLeapMonth: Bool

    private let lunarDays = Array(1...30)
    private let lunarMonths = Array(1...12)

    var solarDatePreview: Date {
        LunarCalendar.lunarToSolar(day: lunarDay, month: lunarMonth, year: Calendar.current.component(.year, from: Date()))
    }

    private var solarDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM, yyyy"
        return formatter
    }

    var body: some View {
        VStack(spacing: AppTheme.spacing16) {
            // Title
            Text(String(localized: "createItem.lunarDate"))
                .font(.system(size: AppTheme.fontTitle3, weight: .bold))
                .foregroundStyle(AppColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, AppTheme.spacing16)
                .padding(.top, AppTheme.spacing16)

            // Lunar Day and Month Pickers
            HStack(spacing: AppTheme.spacing16) {
                VStack(spacing: AppTheme.spacing8) {
                    Text(String(localized: "createItem.lunarDay"))
                        .font(.system(size: AppTheme.fontCaption, weight: .medium))
                        .foregroundStyle(AppColors.textSecondary)

                    Picker("", selection: $lunarDay) {
                        ForEach(lunarDays, id: \.self) { day in
                            Text("\(day)").tag(day)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxHeight: 120)
                }

                VStack(spacing: AppTheme.spacing8) {
                    Text(String(localized: "createItem.lunarMonth"))
                        .font(.system(size: AppTheme.fontCaption, weight: .medium))
                        .foregroundStyle(AppColors.textSecondary)

                    Picker("", selection: $lunarMonth) {
                        ForEach(lunarMonths, id: \.self) { month in
                            Text(getLunarMonthDisplayName(month)).tag(month)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxHeight: 120)
                }
            }
            .padding(.horizontal, AppTheme.spacing16)

            // Solar Date Preview
            VStack(spacing: AppTheme.spacing8) {
                Text(String(localized: "createItem.solarDatePreview"))
                    .font(.system(size: AppTheme.fontCaption, weight: .medium))
                    .foregroundStyle(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: AppTheme.spacing8) {
                    Image(systemName: "calendar")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(AppColors.primary)

                    Text(solarDateFormatter.string(from: solarDatePreview))
                        .font(.system(size: AppTheme.fontBody))
                        .foregroundStyle(AppColors.textPrimary)

                    Spacer()
                }
                .padding(AppTheme.spacing12)
                .background(AppColors.background)
                .cornerRadius(AppTheme.cornerRadiusLarge)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge)
                        .stroke(AppColors.borderLight, lineWidth: 1)
                )
            }
            .padding(.horizontal, AppTheme.spacing16)

            // Leap Month Toggle
            VStack(spacing: AppTheme.spacing8) {
                HStack(spacing: AppTheme.spacing12) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(AppColors.primary)

                    Text(String(localized: "createItem.includeLeapMonth"))
                        .font(.system(size: AppTheme.fontBody))
                        .foregroundStyle(AppColors.textPrimary)

                    Spacer()

                    Toggle("", isOn: $includeLeapMonth)
                        .labelsHidden()
                }
                .padding(AppTheme.spacing12)
                .background(AppColors.background)
                .cornerRadius(AppTheme.cornerRadiusLarge)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge)
                        .stroke(AppColors.borderLight, lineWidth: 1)
                )

                Text(String(localized: "createItem.leapMonthDescription"))
                    .font(.system(size: AppTheme.fontCaption))
                    .foregroundStyle(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, AppTheme.spacing16)

            Spacer()
        }
        .background(AppColors.backgroundLightGray)
    }

    // MARK: - Helper Methods

    private func getLunarMonthDisplayName(_ month: Int) -> String {
        switch month {
        case 1: return String(localized: "lunar.month.1")
        case 2: return String(localized: "lunar.month.2")
        case 3: return String(localized: "lunar.month.3")
        case 4: return String(localized: "lunar.month.4")
        case 5: return String(localized: "lunar.month.5")
        case 6: return String(localized: "lunar.month.6")
        case 7: return String(localized: "lunar.month.7")
        case 8: return String(localized: "lunar.month.8")
        case 9: return String(localized: "lunar.month.9")
        case 10: return String(localized: "lunar.month.10")
        case 11: return String(localized: "lunar.month.11")
        case 12: return String(localized: "lunar.month.12")
        default: return String(localized: "lunar.month.unknown", defaultValue: "Month \(month)")
        }
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var day = 15
    @Previewable @State var month = 4
    @Previewable @State var leap = false

    LunarDatePickerView(
        lunarDay: $day,
        lunarMonth: $month,
        includeLeapMonth: $leap
    )
}
