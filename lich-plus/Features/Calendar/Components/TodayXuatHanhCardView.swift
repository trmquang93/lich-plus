//
//  TodayXuatHanhCardView.swift
//  lich-plus
//
//  Today's giờ hoàng đạo and hours to avoid.
//

import SwiftUI

struct TodayXuatHanhCardView: View {
    let date: Date
    private let summary: XuatHanhSummary

    init(date: Date = Date()) {
        self.date = date
        self.summary = XuatHanhSummary.forDate(date)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing12) {
            HStack(spacing: AppTheme.spacing8) {
                Image(systemName: "sun.max.fill")
                    .font(.system(size: AppTheme.fontBody, weight: .semibold))
                    .foregroundStyle(AppColors.accent)
                Text(String(localized: "Travel Hours Today"))
                    .font(.system(size: AppTheme.fontTitle3, weight: .bold))
                    .foregroundStyle(AppColors.textPrimary)
            }

            hourRow(
                title: String(localized: "Lucky Hours"),
                value: summary.luckySummary,
                tint: AppColors.accent
            )

            hourRow(
                title: String(localized: "Hours to Avoid"),
                value: summary.avoidSummary,
                tint: AppColors.primary
            )

            Text(String(localized: "Based on today's Can-Chi and giờ hoàng đạo table."))
                .font(.system(size: AppTheme.fontCaption))
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppTheme.spacing16)
        .background(AppColors.accentLight)
        .cornerRadius(AppTheme.cornerRadiusLarge)
        .onAppear {
            AnalyticsService.shared.logFeatureUsed(.xuat_hanh)
        }
    }

    private func hourRow(title: String, value: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing4) {
            Text(title)
                .font(.system(size: AppTheme.fontCaption, weight: .semibold))
                .foregroundStyle(tint)
            Text(value.isEmpty ? String(localized: "None") : value)
                .font(.system(size: AppTheme.fontBody))
                .foregroundStyle(AppColors.textPrimary)
        }
    }
}

#Preview {
    TodayXuatHanhCardView()
        .padding()
}
