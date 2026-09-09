//
//  TodayWidgetViews.swift
//  LichPlusWidgets
//

import SwiftUI
import WidgetKit

struct TodayWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    let entry: TodayWidgetEntry

    var body: some View {
        switch family {
        case .systemSmall:
            TodaySmallWidgetView(entry: entry)
        case .systemMedium:
            TodayMediumWidgetView(entry: entry)
        case .accessoryRectangular:
            TodayLockRectangularView(entry: entry)
        case .accessoryCircular:
            TodayLockCircularView(entry: entry)
        default:
            TodaySmallWidgetView(entry: entry)
        }
    }
}

private struct TodaySmallWidgetView: View {
    let entry: TodayWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(WidgetLocalizedStrings.todayTitle(localeCode: entry.localeCode))
                .font(.caption.weight(.semibold))
                .foregroundStyle(WidgetTheme.primary)

            if let day = entry.day {
                Text(solarLine(for: day))
                    .font(.title2.weight(.bold))
                    .foregroundStyle(WidgetTheme.textPrimary)
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)

                Text(WidgetLocalizedStrings.lunarLine(
                    day: day.lunarDay,
                    month: day.lunarMonth,
                    year: day.lunarYear,
                    localeCode: entry.localeCode
                ))
                    .font(.caption)
                    .foregroundStyle(WidgetTheme.textSecondary)
                    .lineLimit(2)

                if let chip = day.specialChips.first {
                    ChipView(title: chip)
                } else if let lucky = day.luckyHourSummary {
                    ChipView(title: WidgetLocalizedStrings.luckyHoursTitle(localeCode: entry.localeCode) + ": " + lucky)
                } else if let holiday = nextHolidayLabel(for: day, localeCode: entry.localeCode) {
                    ChipView(title: holiday)
                }
            } else {
                Text(WidgetLocalizedStrings.openAppPrompt(localeCode: entry.localeCode))
                    .font(.caption)
                    .foregroundStyle(WidgetTheme.textSecondary)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(12)
        .containerBackground(for: .widget) {
            WidgetTheme.backgroundLight
        }
    }
}

private struct TodayMediumWidgetView: View {
    let entry: TodayWidgetEntry

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(WidgetLocalizedStrings.todayTitle(localeCode: entry.localeCode))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(WidgetTheme.primary)

                if let day = entry.day {
                    Text(solarLine(for: day))
                        .font(.title.weight(.bold))
                        .foregroundStyle(WidgetTheme.textPrimary)
                        .lineLimit(1)

                    Text(WidgetLocalizedStrings.lunarLine(
                        day: day.lunarDay,
                        month: day.lunarMonth,
                        year: day.lunarYear,
                        localeCode: entry.localeCode
                    ))
                        .font(.subheadline)
                        .foregroundStyle(WidgetTheme.textSecondary)
                        .lineLimit(2)

                    Text(day.dayCanChi)
                        .font(.caption)
                        .foregroundStyle(WidgetTheme.textSecondary)
                } else {
                    Text(WidgetLocalizedStrings.openAppRefreshPrompt(localeCode: entry.localeCode))
                        .font(.caption)
                        .foregroundStyle(WidgetTheme.textSecondary)
                }
            }

            Spacer(minLength: 0)

            VStack(alignment: .trailing, spacing: 8) {
                if let day = entry.day {
                    ForEach(Array(day.specialChips.prefix(2)), id: \.self) { chip in
                        ChipView(title: chip)
                    }

                    if let lucky = day.luckyHourSummary {
                        HourChipView(
                            title: WidgetLocalizedStrings.luckyHoursTitle(localeCode: entry.localeCode),
                            detail: lucky
                        )
                    }

                    if let avoid = day.avoidHourSummary {
                        HourChipView(
                            title: WidgetLocalizedStrings.avoidHoursTitle(localeCode: entry.localeCode),
                            detail: avoid
                        )
                    }

                    if let holiday = nextHolidayLabel(for: day, localeCode: entry.localeCode) {
                        NextHolidayChipView(
                            title: holiday,
                            daysUntil: day.nextHolidayDaysUntil,
                            localeCode: entry.localeCode
                        )
                    }
                }
            }
        }
        .padding(14)
        .containerBackground(for: .widget) {
            WidgetTheme.backgroundLight
        }
    }
}

private struct TodayLockRectangularView: View {
    let entry: TodayWidgetEntry

    var body: some View {
        if let day = entry.day {
            VStack(alignment: .leading, spacing: 2) {
                Text(WidgetLocalizedStrings.lunarLine(
                    day: day.lunarDay,
                    month: day.lunarMonth,
                    year: day.lunarYear,
                    localeCode: entry.localeCode
                ))
                    .font(.caption2.weight(.semibold))
                    .lineLimit(1)
                if let holiday = nextHolidayLabel(for: day, localeCode: entry.localeCode) {
                    Text(holiday)
                        .font(.caption2)
                        .lineLimit(1)
                } else if let lucky = day.luckyHourSummary {
                    Text(WidgetLocalizedStrings.luckyHoursTitle(localeCode: entry.localeCode) + ": " + lucky)
                        .font(.caption2)
                        .lineLimit(2)
                } else {
                    Text(day.dayCanChi)
                        .font(.caption2)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            Text("Lich+")
                .font(.caption2.weight(.semibold))
        }
    }
}

private struct TodayLockCircularView: View {
    let entry: TodayWidgetEntry

    var body: some View {
        if let day = entry.day {
            VStack(spacing: 0) {
                Text("\(day.lunarDay)")
                    .font(.headline.weight(.bold))
                Text("\(day.lunarMonth)")
                    .font(.caption2)
            }
        } else {
            Image(systemName: "calendar")
                .font(.caption)
        }
    }
}

private struct ChipView: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(WidgetTheme.chipText)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(WidgetTheme.chipBackground)
            .clipShape(Capsule())
            .lineLimit(1)
    }
}

private struct HourChipView: View {
    let title: String
    let detail: String

    var body: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(WidgetTheme.textSecondary)
            Text(detail)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(WidgetTheme.chipText)
                .multilineTextAlignment(.trailing)
                .lineLimit(2)
        }
        .padding(8)
        .background(WidgetTheme.chipBackground.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

private struct NextHolidayChipView: View {
    let title: String
    let daysUntil: Int?
    let localeCode: String

    var body: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(WidgetLocalizedStrings.nextHolidayTitle(localeCode: localeCode))
                .font(.caption2)
                .foregroundStyle(WidgetTheme.textSecondary)
            Text(title)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(WidgetTheme.chipText)
                .multilineTextAlignment(.trailing)
                .lineLimit(2)
            if let daysUntil, daysUntil >= 0 {
                Text(WidgetLocalizedStrings.daysLabel(daysUntil, localeCode: localeCode))
                    .font(.caption2)
                    .foregroundStyle(WidgetTheme.textSecondary)
            }
        }
        .padding(8)
        .background(WidgetTheme.chipBackground.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

private func solarLine(for day: WidgetDayEntry) -> String {
    "\(day.solarDay)/\(day.solarMonth)/\(day.solarYear)"
}

private func nextHolidayLabel(for day: WidgetDayEntry, localeCode: String) -> String? {
    guard let title = day.nextHolidayTitle else { return nil }
    if let daysUntil = day.nextHolidayDaysUntil, daysUntil >= 0 {
        return "\(title) · \(WidgetLocalizedStrings.daysLabel(daysUntil, localeCode: localeCode))"
    }
    return title
}

#Preview(as: .systemSmall) {
    TodayWidget()
} timeline: {
    TodayWidgetEntry(
        date: .now,
        day: WidgetDayEntry(
            date: .now,
            solarDay: 7,
            solarMonth: 9,
            solarYear: 2026,
            lunarDay: 16,
            lunarMonth: 7,
            lunarYear: 2026,
            dayCanChi: "Giáp Thìn",
            specialChips: ["Ngày Rằm"],
            nextHolidayTitle: "Tết",
            nextHolidayDate: .now.addingTimeInterval(86400 * 30),
            nextHolidayDaysUntil: 30
        ),
        localeCode: "vi",
        isPlaceholder: false
    )
}
