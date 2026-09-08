//
//  PublicHolidayCatalogTests.swift
//  lich-plusTests
//

import XCTest
@testable import lich_plus

final class PublicHolidayCatalogTests: XCTestCase {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Ho_Chi_Minh") ?? .current
        return calendar
    }

    func testSpecialChipsIncludesMung1AndRam() {
        let mung1 = PublicHolidayCatalog.specialChips(lunarDay: 1, lunarMonth: 3)
        XCTAssertTrue(mung1.contains(String(localized: "Mùng 1")))

        let ram = PublicHolidayCatalog.specialChips(lunarDay: 15, lunarMonth: 3)
        XCTAssertTrue(ram.contains(String(localized: "Ngày Rằm")))
    }

    func testPickSoonestPrefersEarlierDate() {
        let earlier = PublicHolidayOccurrence(
            title: "Earlier",
            solarDate: Date(timeIntervalSince1970: 1_000_000)
        )
        let later = PublicHolidayOccurrence(
            title: "Later",
            solarDate: Date(timeIntervalSince1970: 2_000_000)
        )

        let picked = PublicHolidayCatalog.pickSoonest(earlier, later)
        XCTAssertEqual(picked?.title, "Earlier")
    }

    func testDaysUntilCountsWholeDays() {
        let start = calendar.date(from: DateComponents(year: 2026, month: 9, day: 7))!
        let end = calendar.date(from: DateComponents(year: 2026, month: 9, day: 10))!
        XCTAssertEqual(PublicHolidayCatalog.daysUntil(from: start, to: end, calendar: calendar), 3)
    }
}
