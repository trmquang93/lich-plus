//
//  TimeRulerCell.swift
//  lich-plus
//
//  Single hour cell in the TimeRuler showing hour label, Chi name, and auspicious indicators
//

import SwiftUI

struct TimeRulerCell: View {
    let hour: Int              // 0-23
    let chiHour: String        // "Tý", "Sửu", etc.
    let hoangDaoLevel: Int     // 0, 1, or 2 stars
    let isPast: Bool           // For dimming past hours
    let hourHeight: CGFloat    // Height of this cell

    private var hourLabel: String {
        String(format: "%02dh", hour)
    }

    private var cellOpacity: Double {
        isPast ? 0.5 : 1.0
    }

    var body: some View {
        VStack(spacing: AppTheme.spacing4) {
            // Hour label
            Text(hourLabel)
                .font(.system(size: AppTheme.fontCaption, weight: .medium))
                .foregroundColor(AppColors.textSecondary)

            // Chi name
            Text(chiHour)
                .font(.system(size: AppTheme.fontCaption, weight: .semibold))
                .foregroundColor(AppColors.lunarAccent)

            // Hoang Dao stars
            HoangDaoIndicator(level: hoangDaoLevel)

            Spacer()
        }
        .frame(width: 50, height: hourHeight)
        .padding(.vertical, AppTheme.spacing4)
        .background(AppColors.background)
        .border(
            AppColors.timelineGridLine,
            width: 1
        )
        .opacity(cellOpacity)
    }
}

#Preview {
    VStack(spacing: 0) {
        // Morning auspicious hour
        TimeRulerCell(
            hour: 10,
            chiHour: "Tỵ",
            hoangDaoLevel: 2,
            isPast: false,
            hourHeight: 60
        )

        // Midday hour
        TimeRulerCell(
            hour: 12,
            chiHour: "Ngọ",
            hoangDaoLevel: 1,
            isPast: false,
            hourHeight: 60
        )

        // Evening past hour
        TimeRulerCell(
            hour: 18,
            chiHour: "Dậu",
            hoangDaoLevel: 0,
            isPast: true,
            hourHeight: 60
        )
    }
    .background(AppColors.background)
}
