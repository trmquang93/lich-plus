//
//  TimelineDayHeader.swift
//  lich-plus
//
//  Vietnamese Calendar Timeline Day Header
//  Displays lunar calendar, astrological data, and day quality information
//  for the timeline view's day header section.
//

import SwiftUI

// MARK: - Day Quality Type

/// Represents the astrological quality of a day for display purposes
enum DayQualityDisplay {
    case good
    case neutral
    case bad

    /// Color associated with this quality
    var color: Color {
        switch self {
        case .good:
            return AppColors.dayQualityGood
        case .neutral:
            return AppColors.dayQualityNeutral
        case .bad:
            return AppColors.dayQualityBad
        }
    }

    /// Display label in Vietnamese
    var label: String {
        switch self {
        case .good:
            return "NGÀY TỐT"
        case .neutral:
            return "NGÀY BÌNH"
        case .bad:
            return "NGÀY XẤU"
        }
    }
}

// MARK: - Timeline Day Header View

/// TimelineDayHeader displays comprehensive lunar calendar and astrological information
/// for a specific day in the timeline view.
///
/// The header includes:
/// - Solar and lunar calendar cards showing date information
/// - Day quality badge with zodiac hour name and meaning
/// - Good stars list (if available)
/// - Optional expanded/collapsed state support
///
/// Layout (approximately 100pt height in normal state):
/// ```
/// ┌─────────────────────────────────────────────────┐
/// │  THỨ SÁU, 13 THÁNG 12                           │
/// │                                                 │
/// │  ┌──────────────┐  ┌──────────────────────────┐ │
/// │  │ ☀️ 13/12     │  │ 🌙 13/11 Ất Tỵ           │ │
/// │  │ Dương lịch   │  │ Âm lịch                  │ │
/// │  └──────────────┘  └──────────────────────────┘ │
/// │                                                 │
/// │  ┌───────────────────────────────────────────┐  │
/// │  │ ★ NGÀY TỐT   │ Trực: THÀNH (Thành công)   │ │
/// │  │              │ Sao tốt: Thiên ân, Trực linh│ │
/// │  └───────────────────────────────────────────┘  │
/// └─────────────────────────────────────────────────┘
/// ```
struct TimelineDayHeader: View {
    let date: Date
    let solarDay: Int
    let solarMonth: Int
    let solarYear: Int
    let lunarDay: Int
    let lunarMonth: Int
    let lunarYear: String           // Can-Chi pair (e.g., "Ất Tỵ")
    let dayQuality: DayQualityDisplay
    let trucName: String            // e.g., "THÀNH"
    let trucMeaning: String         // e.g., "Thành công"
    let goodStars: [String]         // e.g., ["Thiên ân", "Trực linh"]

    /// Optional state for expanded/collapsed mode
    @Binding var isExpanded: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing12) {
            // Day and date title
            dayTitleRow

            // Solar and lunar calendar cards
            HStack(spacing: AppTheme.spacing12) {
                solarCardView
                lunarCardView
            }

            // Day quality banner
            dayQualityBanner
        }
        .frame(height: TimelineConfiguration.headerHeight)
        .padding(AppTheme.spacing16)
        .background(AppColors.background)
        .border(AppColors.timelineGridLine, width: 0.5)
    }

    // MARK: - Day Title Row

    private var dayTitleRow: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing4) {
            Text(formattedWeekday)
                .font(.system(size: AppTheme.fontTitle3, weight: .bold))
                .foregroundStyle(AppColors.textPrimary)

            Text(formattedDateLabel)
                .font(.system(size: AppTheme.fontSubheading, weight: .semibold))
                .foregroundStyle(AppColors.textSecondary)
        }
    }

    // MARK: - Solar Calendar Card

    private var solarCardView: some View {
        VStack(alignment: .center, spacing: AppTheme.spacing8) {
            HStack(spacing: AppTheme.spacing4) {
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppColors.eventOrange)

                Text("\(solarDay)/\(solarMonth)")
                    .font(.system(size: AppTheme.fontBody, weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)

                Spacer()
            }

            Text("Dương lịch")
                .font(.system(size: AppTheme.fontCaption, weight: .regular))
                .foregroundStyle(AppColors.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(AppTheme.spacing12)
        .background(AppColors.backgroundLightGray)
        .cornerRadius(AppTheme.cornerRadiusMedium)
    }

    // MARK: - Lunar Calendar Card

    private var lunarCardView: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing8) {
            HStack(spacing: AppTheme.spacing4) {
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppColors.lunarAccent)

                VStack(alignment: .leading, spacing: AppTheme.spacing2) {
                    Text("\(lunarDay)/\(lunarMonth)")
                        .font(.system(size: AppTheme.fontBody, weight: .semibold))
                        .foregroundStyle(AppColors.textPrimary)

                    Text(lunarYear)
                        .font(.system(size: AppTheme.fontCaption, weight: .regular))
                        .foregroundStyle(AppColors.lunarAccent)
                }

                Spacer()
            }

            Text("Âm lịch")
                .font(.system(size: AppTheme.fontCaption, weight: .regular))
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(AppTheme.spacing12)
        .background(AppColors.backgroundLightGray)
        .cornerRadius(AppTheme.cornerRadiusMedium)
    }

    // MARK: - Day Quality Banner

    private var dayQualityBanner: some View {
        HStack(spacing: AppTheme.spacing12) {
            // Quality badge
            HStack(spacing: AppTheme.spacing4) {
                Image(systemName: "star.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(dayQuality.color)

                Text(dayQuality.label)
                    .font(.system(size: AppTheme.fontCaption, weight: .bold))
                    .foregroundStyle(dayQuality.color)
            }
            .padding(.vertical, 4)
            .padding(.horizontal, AppTheme.spacing12)
            .background(dayQuality.color.opacity(0.1))
            .cornerRadius(12)

            // Trực information
            VStack(alignment: .leading, spacing: AppTheme.spacing2) {
                Text("Trực: \(trucName) (\(trucMeaning))")
                    .font(.system(size: AppTheme.fontCaption, weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)

                if !goodStars.isEmpty {
                    Text("Sao tốt: \(goodStars.joined(separator: ", "))")
                        .font(.system(size: AppTheme.fontCaption, weight: .regular))
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()
        }
        .padding(AppTheme.spacing12)
        .background(dayQuality.color.opacity(0.06))
        .border(dayQuality.color.opacity(0.3), width: 0.5)
        .cornerRadius(AppTheme.cornerRadiusMedium)
    }

    // MARK: - Formatted Properties

    /// Formatted weekday in uppercase Vietnamese
    private var formattedWeekday: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.dateFormat = "EEEE"
        let weekday = formatter.string(from: date).uppercased()
        // Convert to Vietnamese day names if needed
        return vietnameseWeekday(weekday)
    }

    /// Formatted date label with month in Vietnamese
    private var formattedDateLabel: String {
        let monthNames = [
            "THÁNG 1", "THÁNG 2", "THÁNG 3", "THÁNG 4",
            "THÁNG 5", "THÁNG 6", "THÁNG 7", "THÁNG 8",
            "THÁNG 9", "THÁNG 10", "THÁNG 11", "THÁNG 12"
        ]
        return "\(solarDay) \(monthNames[solarMonth - 1])"
    }

    /// Convert gregorian weekday to Vietnamese name
    private func vietnameseWeekday(_ englishDay: String) -> String {
        let vietnameseDays: [String: String] = [
            "MONDAY": "THỨ HAI",
            "TUESDAY": "THỨ BA",
            "WEDNESDAY": "THỨ TƯ",
            "THURSDAY": "THỨ NĂM",
            "FRIDAY": "THỨ SÁU",
            "SATURDAY": "THỨ BẢY",
            "SUNDAY": "CHỦ NHẬT"
        ]
        return vietnameseDays[englishDay] ?? englishDay
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var isExpanded = false

    VStack {
        TimelineDayHeader(
            date: Date(),
            solarDay: 13,
            solarMonth: 12,
            solarYear: 2025,
            lunarDay: 13,
            lunarMonth: 11,
            lunarYear: "Ất Tỵ",
            dayQuality: .good,
            trucName: "THÀNH",
            trucMeaning: "Thành công",
            goodStars: ["Thiên ân", "Trực linh"],
            isExpanded: $isExpanded
        )

        Spacer()
    }
    .background(AppColors.backgroundLightGray)
}

#Preview("Bad Day") {
    @Previewable @State var isExpanded = false

    VStack {
        TimelineDayHeader(
            date: Date(),
            solarDay: 28,
            solarMonth: 4,
            solarYear: 2025,
            lunarDay: 9,
            lunarMonth: 3,
            lunarYear: "Bính Ngọ",
            dayQuality: .bad,
            trucName: "PHÁ",
            trucMeaning: "Phá bỏ",
            goodStars: [],
            isExpanded: $isExpanded
        )

        Spacer()
    }
    .background(AppColors.backgroundLightGray)
}

#Preview("Neutral Day") {
    @Previewable @State var isExpanded = false

    VStack {
        TimelineDayHeader(
            date: Date(),
            solarDay: 15,
            solarMonth: 7,
            solarYear: 2025,
            lunarDay: 20,
            lunarMonth: 6,
            lunarYear: "Giáp Thìn",
            dayQuality: .neutral,
            trucName: "THÀNH",
            trucMeaning: "Có thể dùng",
            goodStars: ["Thiên ân"],
            isExpanded: $isExpanded
        )

        Spacer()
    }
    .background(AppColors.backgroundLightGray)
}
