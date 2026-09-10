//
//  LunarAnniversaryCalendarTests.swift
//  lich-plusTests
//

import XCTest
@testable import lich_plus

final class LunarAnniversaryCalendarTests: XCTestCase {

    func testDay30MatchesLastDayOfShortMonth() {
        // 2023 leap month 2 — find a 29-day month ending on day 29 for month 6
        let rule = LunarAnniversaryCalendar.recurrenceRule(lunarDay: 30, lunarMonth: 6)
        let start = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 1))!
        let end = Calendar.current.date(from: DateComponents(year: 2026, month: 12, day: 31))!

        let dates = LunarAnniversaryCalendar.upcomingAnniversaryDates(
            lunarDay: 30,
            lunarMonth: 6,
            leapMonthBehavior: rule.leapMonthBehavior,
            from: start,
            horizonMonths: 48
        )

        XCTAssertFalse(dates.isEmpty)

        for date in dates {
            XCTAssertTrue(
                LunarAnniversaryCalendar.matchesAnniversary(
                    date: date,
                    lunarDay: 30,
                    lunarMonth: 6,
                    isLeapMonthAnniversary: false
                )
            )
        }
    }

    func testLeapOnlyBehaviorUsesLeapMonthBehavior() {
        let behavior = LunarAnniversaryCalendar.leapMonthBehavior(isLeapMonthAnniversary: true)
        XCTAssertEqual(behavior, .leapOnly)
    }

    func testKinhDichProducesValidReading() {
        var rng = SeededRandomNumberGenerator(seed: 42)
        let reading = KinhDichEngine.randomReading(rng: &rng)
        XCTAssertEqual(reading.lines.count, 6)
        XCTAssertFalse(reading.hexagram.name.isEmpty)
        XCTAssertFalse(reading.summary.isEmpty)
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
