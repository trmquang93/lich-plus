//
//  TodayWidgetProvider.swift
//  LichPlusWidgets
//

import Foundation
import WidgetKit

struct TodayWidgetProvider: TimelineProvider {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Ho_Chi_Minh") ?? .current
        return calendar
    }

    func placeholder(in context: Context) -> TodayWidgetEntry {
        TodayWidgetEntry(
            date: Date(),
            day: placeholderDay,
            localeCode: "vi",
            isPlaceholder: true
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (TodayWidgetEntry) -> Void) {
        completion(makeEntry(for: Date(), isPreview: context.isPreview))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TodayWidgetEntry>) -> Void) {
        let snapshot = WidgetSnapshotStore.load()
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)

        var entries: [TodayWidgetEntry] = []
        if let snapshot {
            for day in snapshot.days {
                entries.append(
                    TodayWidgetEntry(
                        date: day.date,
                        day: day,
                        localeCode: snapshot.localeCode,
                        isPlaceholder: false
                    )
                )
            }
        } else {
            entries.append(makeEntry(for: now, isPreview: false))
        }

        let reloadDate = calendar.date(byAdding: .day, value: 1, to: startOfToday)?
            .addingTimeInterval(60) ?? now.addingTimeInterval(3600)

        completion(Timeline(entries: entries, policy: .after(reloadDate)))
    }

    private func makeEntry(for date: Date, isPreview: Bool) -> TodayWidgetEntry {
        let snapshot = WidgetSnapshotStore.load()
        let localeCode = snapshot?.localeCode ?? WidgetSnapshotStore.readLanguageCode()
        let day = snapshot?.entryOrFirst(for: date, calendar: calendar)

        return TodayWidgetEntry(
            date: date,
            day: day ?? (isPreview ? placeholderDay : nil),
            localeCode: localeCode,
            isPlaceholder: day == nil && !isPreview
        )
    }

    private var placeholderDay: WidgetDayEntry {
        WidgetDayEntry(
            date: Date(),
            solarDay: 7,
            solarMonth: 9,
            solarYear: 2026,
            lunarDay: 16,
            lunarMonth: 7,
            lunarYear: 2026,
            dayCanChi: "Giáp Thìn",
            specialChips: ["Ngày Rằm"],
            nextHolidayTitle: "Tết",
            nextHolidayDate: Date().addingTimeInterval(86400 * 120),
            nextHolidayDaysUntil: 120
        )
    }
}
