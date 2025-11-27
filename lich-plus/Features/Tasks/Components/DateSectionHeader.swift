//
//  DateSectionHeader.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 26/11/25.
//

import SwiftUI

struct DateSectionHeader: View {
    let date: Date
    var showTodayBadge: Bool = false

    var vietnameseWeekday: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.dateFormat = "EEEE, dd/MM"
        return formatter.string(from: date).uppercased()
    }

    var lunarDateDisplay: String {
        let (day, month, _) = LunarCalendar.solarToLunar(date)
        let yearCanChi = CanChiCalculator.calculateYearCanChi(for: date)
        return String(localized: "date.lunarFormat \(day) \(month) \(yearCanChi.displayName)")
    }

    var body: some View {
        HStack(spacing: AppTheme.spacing12) {
            VStack(alignment: .leading, spacing: AppTheme.spacing8) {
                // Solar date with Vietnamese weekday
                Text(vietnameseWeekday)
                    .font(.system(size: AppTheme.fontSubheading, weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)

                // Lunar date with year Can-Chi
                Text(lunarDateDisplay)
                    .font(.system(size: AppTheme.fontBody, weight: .regular))
                    .foregroundStyle(AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if showTodayBadge {
                Text(String(localized: "date.today"))
                    .font(.system(size: AppTheme.fontCaption, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, AppTheme.spacing8)
                    .padding(.vertical, AppTheme.spacing4)
                    .background(AppColors.primary)
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, AppTheme.spacing16)
        .padding(.vertical, AppTheme.spacing12)
    }
}

#Preview {
    DateSectionHeader(date: Date())
        .background(AppColors.backgroundLightGray)
}
