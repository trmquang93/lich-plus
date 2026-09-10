//
//  FestivalCountdownCardView.swift
//  lich-plus
//
//  In-app countdown to Tết and other public lunar festivals.
//

import SwiftUI

struct FestivalCountdownCardView: View {
    let referenceDate: Date

    private var entries: [FestivalCountdownEntry] {
        FestivalCountdownProvider.upcoming(from: referenceDate, limit: 4)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing12) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundStyle(AppColors.hoangDaoGold)
                Text(String(localized: "Upcoming festivals"))
                    .elderModeFont(size: AppTheme.fontTitle3, weight: .bold)
                    .foregroundStyle(AppColors.textPrimary)
            }

            ForEach(entries) { entry in
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: AppTheme.spacing2) {
                        Text(entry.title)
                            .elderModeFont(size: AppTheme.fontBody, weight: .semibold)
                            .foregroundStyle(AppColors.textPrimary)
                        Text(entry.solarDateLabel)
                            .elderModeFont(size: AppTheme.fontCaption)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    Spacer(minLength: AppTheme.spacing8)
                    Text(entry.daysLabel)
                        .elderModeFont(size: AppTheme.fontTitle3, weight: .bold)
                        .foregroundStyle(entry.isTet ? AppColors.primary : AppColors.accent)
                }
                if entry.id != entries.last?.id {
                    Divider()
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .elderModePadding(.all, AppTheme.spacing16)
        .background(AppColors.backgroundLight)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge))
        .accessibilityIdentifier("festival.countdown")
        .onAppear {
            AnalyticsService.shared.logFeatureUsed(.tet_countdown)
        }
    }
}

struct FestivalCountdownEntry: Identifiable, Equatable {
    let id: String
    let title: String
    let solarDate: Date
    let daysUntil: Int

    var isTet: Bool { id == "1-1" }

    var daysLabel: String {
        if daysUntil == 0 { return String(localized: "Today") }
        if daysUntil == 1 { return String(localized: "Tomorrow") }
        return String(format: String(localized: "%lld days"), daysUntil)
    }

    var solarDateLabel: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: solarDate)
    }
}

enum FestivalCountdownProvider {
    private static var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Ho_Chi_Minh") ?? .current
        return calendar
    }

    static func upcoming(from referenceDate: Date, limit: Int) -> [FestivalCountdownEntry] {
        let start = calendar.startOfDay(for: referenceDate)
        let currentLunar = LunarCalendar.solarToLunar(start)
        var results: [FestivalCountdownEntry] = []

        for yearOffset in 0...1 {
            let lunarYear = currentLunar.year + yearOffset
            for festival in PublicHolidayCatalog.lunarFestivals {
                let solar = calendar.startOfDay(
                    for: LunarCalendar.lunarToSolar(
                        day: festival.day,
                        month: festival.month,
                        year: lunarYear
                    )
                )
                guard solar >= start else { continue }
                let days = PublicHolidayCatalog.daysUntil(from: start, to: solar, calendar: calendar)
                results.append(FestivalCountdownEntry(
                    id: "\(festival.month)-\(festival.day)-\(lunarYear)",
                    title: festival.title,
                    solarDate: solar,
                    daysUntil: days
                ))
            }
        }

        return results
            .sorted { $0.solarDate < $1.solarDate }
            .prefix(limit)
            .map { $0 }
    }

    static func nextFestival(from referenceDate: Date) -> FestivalCountdownEntry? {
        upcoming(from: referenceDate, limit: 1).first
    }
}

#Preview {
    FestivalCountdownCardView(referenceDate: Date())
        .padding()
}
