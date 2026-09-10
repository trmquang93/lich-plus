//
//  CountdownWidget.swift
//  LichPlusWidgets
//

import SwiftUI
import WidgetKit

struct CountdownWidget: Widget {
    let kind = CountdownWidgetConstants.kind

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CountdownWidgetProvider()) { entry in
            CountdownWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Festival Countdown")
        .description("Days until Tết and the next public lunar festival.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct CountdownWidgetEntry: TimelineEntry {
    let date: Date
    let festivalTitle: String?
    let daysUntil: Int?
    let localeCode: String
    let isPlaceholder: Bool
}

struct CountdownWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> CountdownWidgetEntry {
        CountdownWidgetEntry(
            date: .now,
            festivalTitle: String(localized: "Tet Holiday"),
            daysUntil: 42,
            localeCode: "vi",
            isPlaceholder: true
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (CountdownWidgetEntry) -> Void) {
        completion(currentEntry(isPreview: context.isPreview))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CountdownWidgetEntry>) -> Void) {
        let entry = currentEntry(isPreview: false)
        let nextRefresh = Calendar.current.date(byAdding: .hour, value: 6, to: .now) ?? .now.addingTimeInterval(21600)
        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }

    private func currentEntry(isPreview: Bool) -> CountdownWidgetEntry {
        let localeCode = WidgetAppGroup.sharedDefaults?.string(forKey: WidgetAppGroup.languageKey) ?? "vi"
        let snapshot = WidgetSnapshotStore.load()
        let day = snapshot?.entryOrFirst(for: .now)

        return CountdownWidgetEntry(
            date: .now,
            festivalTitle: day?.nextHolidayTitle,
            daysUntil: day?.nextHolidayDaysUntil,
            localeCode: localeCode,
            isPlaceholder: isPreview && snapshot == nil
        )
    }
}

struct CountdownWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    let entry: CountdownWidgetEntry

    var body: some View {
        switch family {
        case .systemMedium:
            mediumView
        default:
            smallView
        }
    }

    private var smallView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(WidgetLocalizedStrings.nextHolidayTitle(localeCode: entry.localeCode))
                .font(.caption.weight(.semibold))
                .foregroundStyle(WidgetTheme.primary)

            if let title = entry.festivalTitle, let days = entry.daysUntil {
                Text(title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(WidgetTheme.textPrimary)
                    .lineLimit(2)
                Text(WidgetLocalizedStrings.daysLabel(days, localeCode: entry.localeCode))
                    .font(.title2.weight(.bold))
                    .foregroundStyle(WidgetTheme.chipText)
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

    private var mediumView: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(WidgetLocalizedStrings.nextHolidayTitle(localeCode: entry.localeCode))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(WidgetTheme.primary)
                if let title = entry.festivalTitle {
                    Text(title)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(WidgetTheme.textPrimary)
                        .lineLimit(2)
                }
            }
            Spacer(minLength: 0)
            if let days = entry.daysUntil {
                VStack(spacing: 4) {
                    Text("\(days)")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundStyle(WidgetTheme.primary)
                    Text(WidgetLocalizedStrings.daysLabel(days, localeCode: entry.localeCode))
                        .font(.caption)
                        .foregroundStyle(WidgetTheme.textSecondary)
                }
            }
        }
        .padding(14)
        .containerBackground(for: .widget) {
            WidgetTheme.backgroundLight
        }
    }
}

#Preview(as: .systemSmall) {
    CountdownWidget()
} timeline: {
    CountdownWidgetEntry(
        date: .now,
        festivalTitle: "Tet Holiday",
        daysUntil: 30,
        localeCode: "vi",
        isPlaceholder: false
    )
}
