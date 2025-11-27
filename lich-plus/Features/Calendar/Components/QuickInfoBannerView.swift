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
    let onTap: () -> Void

    private var dateLabel: String {
        if day.isToday {
            return "Hom nay"
        } else {
            return "\(day.solarDay)/\(day.solarMonth)"
        }
    }

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    // Title: "Hom nay - Ngay tot" or "DD/MM - Ngay tot"
                    HStack(spacing: 4) {
                        Text(dateLabel)
                            .foregroundStyle(AppColors.textPrimary)
                        Text("-")
                            .foregroundStyle(AppColors.textSecondary)
                        Text(day.dayType.displayName)
                            .foregroundStyle(dayTypeColor)
                    }
                    .font(.system(size: AppTheme.fontBody, weight: .semibold))

                    // Lucky hours line
                    Text(luckyHoursText)
                        .font(.system(size: AppTheme.fontCaption))
                        .foregroundStyle(AppColors.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppColors.textSecondary)
            }
            .padding(AppTheme.spacing12)
            .background(AppColors.background)
            .cornerRadius(AppTheme.cornerRadiusMedium)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, AppTheme.spacing16)
    }

    private var dayTypeColor: Color {
        switch day.dayType {
        case .good: return AppColors.accent
        case .bad: return AppColors.primary
        case .neutral: return AppColors.textSecondary
        }
    }

    private var luckyHoursText: String {
        let hoursText = luckyHours.map { $0.compactDisplay }.joined(separator: ", ")
        return "Gio hoang dao: \(hoursText)"
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
            chiName: "Mão",
            startTime: "05:00",
            endTime: "07:00",
            luckyActivities: ["Bắt đầu công việc", "Khởi động dự án"]
        ),
        LuckyHour(
            chiName: "Tỵ",
            startTime: "09:00",
            endTime: "11:00",
            luckyActivities: ["Làm việc quan trọng", "Gặp khách hàng"]
        ),
    ]

    return VStack {
        QuickInfoBannerView(day: mockDay, luckyHours: mockLuckyHours) {
            // onTap action
        }

        Spacer()
    }
    .background(AppColors.background)
}
