//
//  DayDetailView.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 25/11/25.
//

import SwiftUI

// MARK: - Day Detail View

struct DayDetailView: View {
    let day: CalendarDay
    @Environment(\.dismiss) var dismiss

    private var dayQuality: DayQuality {
        HoangDaoCalculator.determineDayQuality(for: day.date)
    }

    private var hourlyZodiacs: [HourlyZodiac] {
        HoangDaoCalculator.getHourlyZodiacs(for: day.date)
    }

    private var luckyHours: [LuckyHour] {
        hourlyZodiacs
            .filter { $0.isAuspicious }
            .map { zodiac in
                let chi = zodiac.chi
                let range = chi.hourRange
                let startTime = chi == .ty ? "23:00" : String(format: "%02d:00", range.start)
                let endTime = chi == .ty ? "01:00" : String(format: "%02d:00", range.end)

                return LuckyHour(
                    chiName: chi.vietnameseName,
                    startTime: startTime,
                    endTime: endTime,
                    luckyActivities: zodiac.suitableActivities
                )
            }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.spacing16) {
                    // Header section with date info
                    headerSection

                    Divider()
                        .padding(.vertical, AppTheme.spacing8)

                    // Day quality section
                    dayQualitySection

                    // 12 Truc section
                    trucSection

                    // Lucky hours section
                    luckyHoursSection

                    // Stars section (if available)
                    if let goodStars = dayQuality.goodStars, !goodStars.isEmpty {
                        starsSection(
                            title: "Sao tốt",
                            stars: goodStars.map { $0.rawValue },
                            isGood: true
                        )
                    }

                    if let badStars = dayQuality.badStars, !badStars.isEmpty {
                        starsSection(
                            title: "Sao xấu",
                            stars: badStars.map { $0.rawValue },
                            isGood: false
                        )
                    }

                    // Activities sections
                    activitiesSection

                    // Lucky info section
                    luckyInfoSection
                }
                .padding(AppTheme.spacing16)
            }
            .background(AppColors.backgroundLightGray)
            .navigationTitle("Chi tiết ngày")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing12) {
            // Solar date
            HStack(spacing: AppTheme.spacing8) {
                Text("Dương lịch:")
                    .font(.system(size: AppTheme.fontBody, weight: .medium))
                    .foregroundStyle(AppColors.textSecondary)
                Text(String(format: "%d/%d/%d", day.solarDay, day.solarMonth, day.solarYear))
                    .font(.system(size: AppTheme.fontBody, weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)
            }

            // Lunar date
            HStack(spacing: AppTheme.spacing8) {
                Text("Âm lịch:")
                    .font(.system(size: AppTheme.fontBody, weight: .medium))
                    .foregroundStyle(AppColors.textSecondary)
                Text(String(format: "%d/%d/%d", day.lunarDay, day.lunarMonth, day.lunarYear))
                    .font(.system(size: AppTheme.fontBody, weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)
            }

            // Can-Chi
            HStack(spacing: AppTheme.spacing8) {
                Text("Can-Chi:")
                    .font(.system(size: AppTheme.fontBody, weight: .medium))
                    .foregroundStyle(AppColors.textSecondary)
                Text(dayQuality.dayCanChi)
                    .font(.system(size: AppTheme.fontBody, weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)
            }
        }
    }

    // MARK: - Day Quality Section

    private var dayQualitySection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing12) {
            Text("Chất lượng ngày")
                .font(.system(size: AppTheme.fontSubheading, weight: .semibold))
                .foregroundStyle(AppColors.textPrimary)

            HStack(spacing: AppTheme.spacing12) {
                // Quality badge
                HStack(spacing: AppTheme.spacing8) {
                    Image(systemName: qualityIcon)
                        .font(.system(size: 16, weight: .semibold))
                    Text(dayQuality.finalQuality.displayName)
                        .font(.system(size: AppTheme.fontBody, weight: .semibold))
                }
                .padding(AppTheme.spacing12)
                .background(qualityBadgeColor)
                .cornerRadius(AppTheme.cornerRadiusMedium)
                .foregroundStyle(AppColors.white)

                Spacer()
            }

            // Quality description
            Text(dayQuality.finalQuality.description)
                .font(.system(size: AppTheme.fontCaption))
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(3)
        }
        .padding(AppTheme.spacing12)
        .background(AppColors.background)
        .cornerRadius(AppTheme.cornerRadiusMedium)
    }

    // MARK: - 12 Truc Section

    private var trucSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing12) {
            Text("12 Trực")
                .font(.system(size: AppTheme.fontSubheading, weight: .semibold))
                .foregroundStyle(AppColors.textPrimary)

            VStack(alignment: .leading, spacing: AppTheme.spacing8) {
                // Truc name with quality
                HStack(spacing: AppTheme.spacing8) {
                    Text(dayQuality.zodiacHour.vietnameseName)
                        .font(.system(size: AppTheme.fontBody, weight: .semibold))
                        .foregroundStyle(AppColors.textPrimary)

                    Text(qualityLabel)
                        .font(.system(size: AppTheme.fontCaption, weight: .medium))
                        .padding(.horizontal, AppTheme.spacing8)
                        .padding(.vertical, AppTheme.spacing4)
                        .background(qualityLabelColor)
                        .cornerRadius(AppTheme.cornerRadiusSmall)
                        .foregroundStyle(AppColors.white)
                }

                // Description
                Text(dayQuality.zodiacHour.fullDescription)
                    .font(.system(size: AppTheme.fontCaption))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(4)
            }
        }
        .padding(AppTheme.spacing12)
        .background(AppColors.background)
        .cornerRadius(AppTheme.cornerRadiusMedium)
    }

    // MARK: - Lucky Hours Section

    private var luckyHoursSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing12) {
            Text("Giờ Hoàng Đạo")
                .font(.system(size: AppTheme.fontSubheading, weight: .semibold))
                .foregroundStyle(AppColors.textPrimary)

            if luckyHours.isEmpty {
                Text("Không có giờ Hoàng Đạo trong ngày này")
                    .font(.system(size: AppTheme.fontCaption))
                    .foregroundStyle(AppColors.textSecondary)
                    .padding(AppTheme.spacing12)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(spacing: AppTheme.spacing8) {
                    ForEach(luckyHours) { hour in
                        luckyHourItem(hour)
                    }
                }
            }
        }
        .padding(AppTheme.spacing12)
        .background(AppColors.background)
        .cornerRadius(AppTheme.cornerRadiusMedium)
    }

    private func luckyHourItem(_ hour: LuckyHour) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing8) {
            HStack(spacing: AppTheme.spacing12) {
                VStack(alignment: .leading, spacing: AppTheme.spacing4) {
                    Text(hour.chiName)
                        .font(.system(size: AppTheme.fontBody, weight: .semibold))
                        .foregroundStyle(AppColors.textPrimary)
                    Text(hour.timeRange)
                        .font(.system(size: AppTheme.fontCaption))
                        .foregroundStyle(AppColors.textSecondary)
                }

                Spacer()

                Image(systemName: "star.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(AppColors.accent)
            }

            // Activities
            VStack(alignment: .leading, spacing: AppTheme.spacing4) {
                ForEach(hour.luckyActivities, id: \.self) { activity in
                    HStack(spacing: AppTheme.spacing8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(AppColors.accent)
                        Text(activity)
                            .font(.system(size: AppTheme.fontCaption))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
            }
        }
        .padding(AppTheme.spacing12)
        .background(AppColors.accentLight)
        .cornerRadius(AppTheme.cornerRadiusMedium)
    }

    // MARK: - Stars Section

    private func starsSection(title: String, stars: [String], isGood: Bool) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing12) {
            Text(title)
                .font(.system(size: AppTheme.fontSubheading, weight: .semibold))
                .foregroundStyle(AppColors.textPrimary)

            VStack(alignment: .leading, spacing: AppTheme.spacing8) {
                ForEach(stars, id: \.self) { star in
                    HStack(spacing: AppTheme.spacing8) {
                        Image(systemName: isGood ? "star.fill" : "exclamationmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(isGood ? AppColors.accent : AppColors.primary)
                        Text(star)
                            .font(.system(size: AppTheme.fontBody))
                            .foregroundStyle(AppColors.textPrimary)
                        Spacer()
                    }
                }
            }
        }
        .padding(AppTheme.spacing12)
        .background(AppColors.background)
        .cornerRadius(AppTheme.cornerRadiusMedium)
    }

    // MARK: - Activities Section

    private var activitiesSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing16) {
            // Suitable activities
            VStack(alignment: .leading, spacing: AppTheme.spacing12) {
                Text("Việc nên làm")
                    .font(.system(size: AppTheme.fontSubheading, weight: .semibold))
                    .foregroundStyle(AppColors.accent)

                VStack(alignment: .leading, spacing: AppTheme.spacing8) {
                    ForEach(dayQuality.suitableActivities, id: \.self) { activity in
                        HStack(spacing: AppTheme.spacing8) {
                            Image(systemName: "checkmark.circle")
                                .font(.system(size: 14))
                                .foregroundStyle(AppColors.accent)
                            Text(activity)
                                .font(.system(size: AppTheme.fontBody))
                                .foregroundStyle(AppColors.textPrimary)
                            Spacer()
                        }
                    }
                }
            }
            .padding(AppTheme.spacing12)
            .background(AppColors.accentLight)
            .cornerRadius(AppTheme.cornerRadiusMedium)

            // Taboo activities
            VStack(alignment: .leading, spacing: AppTheme.spacing12) {
                Text("Việc nên tránh")
                    .font(.system(size: AppTheme.fontSubheading, weight: .semibold))
                    .foregroundStyle(AppColors.primary)

                VStack(alignment: .leading, spacing: AppTheme.spacing8) {
                    ForEach(dayQuality.tabooActivities, id: \.self) { activity in
                        HStack(spacing: AppTheme.spacing8) {
                            Image(systemName: "xmark.circle")
                                .font(.system(size: 14))
                                .foregroundStyle(AppColors.primary)
                            Text(activity)
                                .font(.system(size: AppTheme.fontBody))
                                .foregroundStyle(AppColors.textPrimary)
                            Spacer()
                        }
                    }
                }
            }
            .padding(AppTheme.spacing12)
            .background(Color(red: 255 / 255, green: 244 / 255, blue: 244 / 255))
            .cornerRadius(AppTheme.cornerRadiusMedium)
        }
    }

    // MARK: - Lucky Info Section

    private var luckyInfoSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing12) {
            Text("Thông tin may mắn")
                .font(.system(size: AppTheme.fontSubheading, weight: .semibold))
                .foregroundStyle(AppColors.textPrimary)

            VStack(alignment: .leading, spacing: AppTheme.spacing12) {
                // Lucky direction
                if let direction = dayQuality.luckyDirection, !direction.isEmpty {
                    HStack(spacing: AppTheme.spacing12) {
                        VStack(alignment: .leading, spacing: AppTheme.spacing4) {
                            Text("Hướng may mắn")
                                .font(.system(size: AppTheme.fontCaption, weight: .medium))
                                .foregroundStyle(AppColors.textSecondary)
                            Text(direction)
                                .font(.system(size: AppTheme.fontBody, weight: .semibold))
                                .foregroundStyle(AppColors.textPrimary)
                        }

                        Spacer()

                        Image(systemName: "location.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(AppColors.accent)
                    }
                    .padding(AppTheme.spacing12)
                    .background(AppColors.background)
                    .cornerRadius(AppTheme.cornerRadiusMedium)
                }

                // Lucky color
                if let color = dayQuality.luckyColor, !color.isEmpty {
                    HStack(spacing: AppTheme.spacing12) {
                        VStack(alignment: .leading, spacing: AppTheme.spacing4) {
                            Text("Màu may mắn")
                                .font(.system(size: AppTheme.fontCaption, weight: .medium))
                                .foregroundStyle(AppColors.textSecondary)
                            Text(color)
                                .font(.system(size: AppTheme.fontBody, weight: .semibold))
                                .foregroundStyle(AppColors.textPrimary)
                        }

                        Spacer()

                        Image(systemName: "paintpalette.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(AppColors.accent)
                    }
                    .padding(AppTheme.spacing12)
                    .background(AppColors.background)
                    .cornerRadius(AppTheme.cornerRadiusMedium)
                }
            }
        }
        .padding(AppTheme.spacing12)
        .background(AppColors.background)
        .cornerRadius(AppTheme.cornerRadiusMedium)
    }

    // MARK: - Computed Properties

    private var qualityIcon: String {
        switch dayQuality.finalQuality {
        case .good: return "star.fill"
        case .bad: return "exclamationmark.triangle.fill"
        case .neutral: return "circle.fill"
        }
    }

    private var qualityBadgeColor: Color {
        switch dayQuality.finalQuality {
        case .good: return AppColors.accent
        case .bad: return AppColors.primary
        case .neutral: return AppColors.textSecondary
        }
    }

    private var qualityLabel: String {
        switch dayQuality.zodiacHour.quality {
        case .veryAuspicious: return "Hoàng Đạo"
        case .neutral: return "Khả Dụng"
        case .inauspicious: return "Hắc Đạo"
        case .severelyInauspicious: return "Rất Hung"
        }
    }

    private var qualityLabelColor: Color {
        switch dayQuality.zodiacHour.quality {
        case .veryAuspicious: return AppColors.accent
        case .neutral: return AppColors.secondary
        case .inauspicious: return AppColors.primary
        case .severelyInauspicious: return Color(red: 220 / 255, green: 53 / 255, blue: 69 / 255)
        }
    }
}

// MARK: - Preview

#Preview {
    let mockDay = CalendarDay(
        date: Date(),
        solarDay: 25,
        solarMonth: 11,
        solarYear: 2025,
        lunarDay: 25,
        lunarMonth: 10,
        lunarYear: 2024,
        dayType: .good,
        isCurrentMonth: true,
        isToday: false,
        events: [],
        isWeekend: false
    )

    return DayDetailView(day: mockDay)
}
