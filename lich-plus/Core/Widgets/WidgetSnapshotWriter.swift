//
//  WidgetSnapshotWriter.swift
//  lich-plus
//
//  Builds privacy-safe widget snapshots from public calendar facts only.
//

import Foundation
import SwiftData

@MainActor
enum WidgetSnapshotWriter {
    private static let horizonDays = 14
    private static var vietnameseCalendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Ho_Chi_Minh") ?? .current
        calendar.locale = Locale(identifier: "vi_VN")
        return calendar
    }()

    static func refresh(modelContext: ModelContext) {
        let now = Date()
        let localeCode = LanguageManager.shared.currentLanguageCode
        mirrorLanguageToAppGroup(localeCode)

        let currentLunar = LunarCalendar.solarToLunar(now)
        let upcomingSolarHoliday = fetchNextPublicSolarHoliday(from: now, modelContext: modelContext)
        let upcomingLunarHoliday = PublicHolidayCatalog.nextLunarFestival(
            from: now,
            currentLunarYear: currentLunar.year,
            lunarToSolar: { day, month, year in
                LunarCalendar.lunarToSolar(day: day, month: month, year: year)
            },
            calendar: vietnameseCalendar
        )

        let nextHoliday = PublicHolidayCatalog.pickSoonest(
            upcomingSolarHoliday.map { PublicHolidayOccurrence(title: $0.title, solarDate: $0.date) },
            upcomingLunarHoliday
        )

        var dayEntries: [WidgetDayEntry] = []
        dayEntries.reserveCapacity(horizonDays + 1)

        for offset in 0...horizonDays {
            guard let date = vietnameseCalendar.date(byAdding: .day, value: offset, to: vietnameseCalendar.startOfDay(for: now)) else {
                continue
            }
            dayEntries.append(
                makeDayEntry(
                    for: date,
                    nextHoliday: nextHoliday,
                    referenceDate: now
                )
            )
        }

        let snapshot = WidgetTimelineSnapshot(
            generatedAt: now,
            localeCode: localeCode,
            days: dayEntries
        )
        WidgetSnapshotStore.save(snapshot)
    }

    private static func makeDayEntry(
        for date: Date,
        nextHoliday: PublicHolidayOccurrence?,
        referenceDate: Date
    ) -> WidgetDayEntry {
        let lunar = LunarCalendar.solarToLunar(date)
        let dayCanChi = CanChiCalculator.calculateDayCanChi(for: date).displayName
        let chips = PublicHolidayCatalog.specialChips(
            lunarDay: lunar.day,
            lunarMonth: lunar.month
        )
        let xuatHanh = XuatHanhSummary.forDate(date)

        let daysUntil = nextHoliday.map {
            PublicHolidayCatalog.daysUntil(from: referenceDate, to: $0.solarDate, calendar: vietnameseCalendar)
        }

        return WidgetDayEntry(
            date: vietnameseCalendar.startOfDay(for: date),
            solarDay: vietnameseCalendar.component(.day, from: date),
            solarMonth: vietnameseCalendar.component(.month, from: date),
            solarYear: vietnameseCalendar.component(.year, from: date),
            lunarDay: lunar.day,
            lunarMonth: lunar.month,
            lunarYear: lunar.year,
            dayCanChi: dayCanChi,
            specialChips: chips,
            nextHolidayTitle: nextHoliday?.title,
            nextHolidayDate: nextHoliday?.solarDate,
            nextHolidayDaysUntil: daysUntil,
            luckyHourSummary: xuatHanh.luckySummary.isEmpty ? nil : xuatHanh.luckySummary,
            avoidHourSummary: xuatHanh.avoidSummary.isEmpty ? nil : xuatHanh.avoidSummary,
            auspiciousDirection: xuatHanh.luckyDirection
        )
    }

    private static func fetchNextPublicSolarHoliday(
        from referenceDate: Date,
        modelContext: ModelContext
    ) -> (title: String, date: Date)? {
        let startOfDay = vietnameseCalendar.startOfDay(for: referenceDate)
        var descriptor = FetchDescriptor<SyncableEvent>(
            predicate: #Predicate<SyncableEvent> { event in
                !event.isDeleted && event.category == "holiday" && event.startDate >= startOfDay
            },
            sortBy: [SortDescriptor(\.startDate)]
        )
        descriptor.fetchLimit = 1

        guard let event = try? modelContext.fetch(descriptor).first else {
            return nil
        }

        return (title: event.title, date: vietnameseCalendar.startOfDay(for: event.startDate))
    }

    private static func mirrorLanguageToAppGroup(_ localeCode: String) {
        WidgetAppGroup.sharedDefaults?.set(localeCode, forKey: WidgetAppGroup.languageKey)
    }
}
