//
//  QuickInfoBannerView.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 23/11/25.
//

import SwiftUI

// MARK: - Quick Info Banner View

struct QuickInfoBannerView: View {
    let day: CalendarDay
    let luckyHours: [LuckyHour]

    var dayTypeEmoji: String {
        switch day.dayType {
        case .good:
            return "✨"
        case .bad:
            return "⚠️"
        case .neutral:
            return "📅"
        }
    }

    var body: some View {
        VStack(spacing: AppTheme.spacing16) {
            // Day Type Section
            HStack(spacing: AppTheme.spacing12) {
                VStack(alignment: .leading, spacing: AppTheme.spacing4) {
                    HStack(spacing: AppTheme.spacing8) {
                        Text(dayTypeEmoji)
                            .font(.system(size: 24))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(day.dayType.displayName)
                                .font(.system(size: AppTheme.fontTitle3, weight: .bold))
                                .foregroundStyle(AppColors.textPrimary)

                            Text(day.displaySolar + " tháng " + String(day.solarMonth))
                                .font(.system(size: AppTheme.fontCaption, weight: .regular))
                                .foregroundStyle(AppColors.textSecondary)
                        }
                    }

                    Text(day.dayType.description)
                        .font(.system(size: AppTheme.fontCaption, weight: .regular))
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(2)
                }

                Spacer()

                VStack(alignment: .leading, spacing: AppTheme.spacing4) {
                    Text("Âm lịch")
                        .font(.system(size: AppTheme.fontCaption, weight: .semibold))
                        .foregroundStyle(AppColors.textSecondary)

                    Text(day.displayLunar)
                        .font(.system(size: AppTheme.fontTitle3, weight: .bold))
                        .foregroundStyle(AppColors.primary)
                }
            }
            .padding(AppTheme.spacing12)
            .background(dayTypeBackgroundColor)
            .cornerRadius(AppTheme.cornerRadiusMedium)

            // Lucky Hours Section
            VStack(alignment: .leading, spacing: AppTheme.spacing8) {
                Text("Giờ hoàng đạo hôm nay")
                    .font(.system(size: AppTheme.fontBody, weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)

                VStack(spacing: AppTheme.spacing8) {
                    ForEach(luckyHours.prefix(2)) { hour in
                        LuckyHourRow(hour: hour)
                    }
                }
            }
            .padding(AppTheme.spacing12)
            .background(AppColors.backgroundLightGray)
            .cornerRadius(AppTheme.cornerRadiusMedium)
        }
        .padding(AppTheme.spacing16)
        .background(AppColors.background)
        .shadow(radius: 1)
    }

    private var dayTypeBackgroundColor: Color {
        switch day.dayType {
        case .good:
            return AppColors.accentLight
        case .bad:
            return Color(red: 1, green: 0.93, blue: 0.93)
        case .neutral:
            return AppColors.background
        }
    }
}

// MARK: - Lucky Hour Row

struct LuckyHourRow: View {
    let hour: LuckyHour

    var body: some View {
        HStack(spacing: AppTheme.spacing12) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: AppTheme.spacing8) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AppColors.primary)

                    Text(hour.timeRange)
                        .font(.system(size: AppTheme.fontBody, weight: .semibold))
                        .foregroundStyle(AppColors.textPrimary)
                }

                Text(hour.luckyActivities.joined(separator: ", "))
                    .font(.system(size: AppTheme.fontCaption, weight: .regular))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            Image(systemName: "star.fill")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppColors.eventYellow)
        }
        .padding(AppTheme.spacing8)
        .background(AppColors.background)
        .cornerRadius(AppTheme.cornerRadiusSmall)
    }
}

// MARK: - Preview

#Preview {
    let mockDay = CalendarDay(
        date: Date(),
        solarDay: 23,
        solarMonth: 11,
        solarYear: 2025,
        lunarDay: 23,
        lunarMonth: 10,
        lunarYear: 2024,
        dayType: .good,
        isCurrentMonth: true,
        isToday: true,
        events: [],
        isWeekend: false
    )

    let mockLuckyHours = [
        LuckyHour(
            startTime: "05:00",
            endTime: "07:00",
            luckyActivities: ["Bắt đầu công việc", "Khởi động dự án"]
        ),
        LuckyHour(
            startTime: "09:00",
            endTime: "11:00",
            luckyActivities: ["Làm việc quan trọng", "Gặp khách hàng"]
        ),
    ]

    return VStack {
        QuickInfoBannerView(day: mockDay, luckyHours: mockLuckyHours)

        Spacer()
    }
    .background(AppColors.background)
}
