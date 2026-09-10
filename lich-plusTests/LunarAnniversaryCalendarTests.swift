//
//  LunarAnniversaryCalendarTests.swift
//  lich-plusTests
//

import XCTest
@testable import lich_plus

final class LunarAnniversaryCalendarTests: XCTestCase {

    private var vietnamCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Ho_Chi_Minh") ?? .current
        return calendar
    }

    func testDay30FallsBackToLastDayOf29DayMonth() throws {
        // WHY: giỗ on lunar day 30 must still fire in 29-day months, on the real last solar day.
        let calendar = vietnamCalendar
        var shortMonthLastDay: Date?

        for year in 2020...2030 {
            let day29 = calendar.startOfDay(for: LunarCalendar.lunarToSolar(day: 29, month: 6, year: year))
            let lunar = LunarCalendar.solarToLunarWithLeap(day29)
            guard lunar.month == 6, lunar.day == 29, !lunar.isLeap else { continue }
            guard let next = calendar.date(byAdding: .day, value: 1, to: day29) else { continue }
            let nextLunar = LunarCalendar.solarToLunarWithLeap(next)
            if nextLunar.month != 6 {
                shortMonthLastDay = day29
                break
            }
        }

        let lastDay = try XCTUnwrap(shortMonthLastDay, "expected a 29-day lunar month 6 between 2020-2030")
        let parts = calendar.dateComponents([.year, .month, .day], from: lastDay)
        XCTAssertNotNil(parts.year)
        XCTAssertNotNil(parts.month)
        XCTAssertNotNil(parts.day)

        XCTAssertTrue(
            LunarAnniversaryCalendar.matchesAnniversary(
                date: lastDay,
                lunarDay: 30,
                lunarMonth: 6,
                isLeapMonthAnniversary: false
            ),
            "day-30 giỗ must match the last solar day of a 29-day month"
        )

        guard let from = calendar.date(byAdding: .day, value: -1, to: lastDay) else {
            XCTFail("could not build horizon start")
            return
        }
        let dates = LunarAnniversaryCalendar.upcomingAnniversaryDates(
            lunarDay: 30,
            lunarMonth: 6,
            leapMonthBehavior: .includeLeap,
            from: from,
            horizonMonths: 3
        )
        XCTAssertTrue(
            dates.contains { calendar.isDate($0, inSameDayAs: lastDay) },
            "upcoming dates must include the 29-day fallback solar date \(lastDay)"
        )
    }

    func testLeapOnlyAnniversaryUsesRealLeapMonthSolarDates() throws {
        // WHY: leap-only giỗ must include the nhuận occurrence as a real solar date, not a skipped placeholder.
        let leapInfo = LunarCalendar.getLeapMonthInfo(forSolarYear: 2023)
        XCTAssertTrue(leapInfo.hasLeapMonth, "2023 is a known leap lunar year")
        let leapMonth = try XCTUnwrap(leapInfo.leapMonth)

        let behavior = LunarAnniversaryCalendar.leapMonthBehavior(isLeapMonthAnniversary: true)
        XCTAssertEqual(behavior, .leapOnly)

        let leapSolar = vietnamCalendar.startOfDay(
            for: LunarCalendar.lunarToSolar(
                day: 10,
                month: leapMonth,
                year: leapInfo.lunarYear,
                isLeapMonth: true
            )
        )
        let leapBack = LunarCalendar.solarToLunarWithLeap(leapSolar)
        XCTAssertEqual(leapBack.month, leapMonth)
        XCTAssertEqual(leapBack.day, 10)
        XCTAssertTrue(leapBack.isLeap, "fixture must be the 2023 leap month")

        XCTAssertTrue(
            LunarAnniversaryCalendar.matchesAnniversary(
                date: leapSolar,
                lunarDay: 10,
                lunarMonth: leapMonth,
                isLeapMonthAnniversary: true
            )
        )

        guard let start = vietnamCalendar.date(byAdding: .day, value: -1, to: leapSolar) else {
            XCTFail("could not build horizon start")
            return
        }
        let dates = LunarAnniversaryCalendar.upcomingAnniversaryDates(
            lunarDay: 10,
            lunarMonth: leapMonth,
            leapMonthBehavior: behavior,
            from: start,
            horizonMonths: 6
        )
        XCTAssertFalse(dates.isEmpty, "leap-only giỗ must produce at least one solar date")
        XCTAssertTrue(
            dates.contains { vietnamCalendar.isDate($0, inSameDayAs: leapSolar) },
            "upcoming leap-only dates must include solar \(leapSolar)"
        )
    }

    func testKinhDichProducesValidReading() {
        // WHY: coin tosses must compile as Bool.random and always map to a 6-line hexagram.
        var rng = SeededRandomNumberGenerator(seed: 42)
        let reading = KinhDichEngine.randomReading(rng: &rng)
        XCTAssertEqual(reading.lines.count, 6)
        XCTAssertFalse(reading.hexagram.name.isEmpty)
        XCTAssertFalse(reading.summary.isEmpty)
        for line in reading.lines {
            XCTAssertTrue((6...9).contains(line.rawValue))
        }
    }

    func testKinhDichLibraryHas64HexagramsAndTossesMap() {
        // WHY: three coins sum to 6...9 and every pattern must resolve to one of 64 hexagrams.
        XCTAssertEqual(HexagramLibrary.all.count, 64)
        XCTAssertEqual(Set(HexagramLibrary.all.map(\.pattern)).count, 64)
        XCTAssertEqual(Set(HexagramLibrary.all.map(\.id)).count, 64)

        var rng = SeededRandomNumberGenerator(seed: 7)
        for _ in 0..<48 {
            let line = KinhDichEngine.tossCoins(rng: &rng)
            XCTAssertNotNil(KinhDichLineValue(rawValue: line.rawValue))
            XCTAssertTrue((6...9).contains(line.rawValue))
        }
    }

    func testGioChecklistStorageKeyIncludesLunarYearAndRelative() {
        // WHY: checklist must not stay checked forever; a new lunar year / relative gets a fresh key.
        let relative = UUID()
        let yearA = GioChecklistStorage.key(lunarYear: 2026, relativeId: relative)
        let yearB = GioChecklistStorage.key(lunarYear: 2027, relativeId: relative)
        let otherRelative = GioChecklistStorage.key(lunarYear: 2026, relativeId: UUID())
        let shared = GioChecklistStorage.key(lunarYear: 2026, relativeId: nil)

        XCTAssertNotEqual(yearA, yearB)
        XCTAssertNotEqual(yearA, otherRelative)
        XCTAssertNotEqual(yearA, shared)
        XCTAssertTrue(yearA.contains("2026"))
        XCTAssertTrue(yearA.contains(relative.uuidString))
        XCTAssertTrue(yearB.contains("2027"))
    }
}

/// Deterministic RNG for tests.
struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1
        return state
    }
}
