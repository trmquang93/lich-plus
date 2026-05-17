//
//  LunarApr2026BugTests.swift
//  lich-plusTests
//
//  Diagnostic test for reported bug: solar 16/04/2026 should be lunar 29/02/2026
//  but the app displays lunar 01/03/2026.
//

import XCTest
@testable import lich_plus

final class LunarApr2026BugTests: XCTestCase {

    private func makeSolar(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = day
        comps.hour = 12
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "Asia/Ho_Chi_Minh") ?? TimeZone.current
        return cal.date(from: comps)!
    }

    func test_solar_16_04_2026_should_be_lunar_29_02_2026() {
        let date = makeSolar(2026, 4, 16)
        let lunar = LunarCalendar.solarToLunar(date)
        XCTAssertEqual(lunar.day, 29, "Expected lunar day 29, got \(lunar.day)")
        XCTAssertEqual(lunar.month, 2, "Expected lunar month 2, got \(lunar.month)")
        XCTAssertEqual(lunar.year, 2026, "Expected lunar year 2026, got \(lunar.year)")
    }

    func test_neighbor_dates_around_apr_2026_lunar_boundary() {
        // Expected mapping (solar -> lunar) based on standard Hồ Ngọc Đức tables:
        //   2026-04-15 -> 28/02/2026
        //   2026-04-16 -> 29/02/2026   <-- bug case
        //   2026-04-17 -> 01/03/2026
        //   2026-04-18 -> 02/03/2026
        let cases: [(Int, Int, Int, Int, Int)] = [
            (15, 28, 2, 2026, 4),
            (16, 29, 2, 2026, 4),
            (17, 1, 3, 2026, 4),
            (18, 2, 3, 2026, 4),
        ]

        for (solarDay, expDay, expMonth, expYear, solarMonth) in cases {
            let d = makeSolar(2026, solarMonth, solarDay)
            let l = LunarCalendar.solarToLunar(d)
            print("solar 2026-\(solarMonth)-\(solarDay) -> lunar \(l.day)/\(l.month)/\(l.year)")
            XCTAssertEqual(l.day, expDay, "day mismatch on solar 2026-04-\(solarDay)")
            XCTAssertEqual(l.month, expMonth, "month mismatch on solar 2026-04-\(solarDay)")
            XCTAssertEqual(l.year, expYear, "year mismatch on solar 2026-04-\(solarDay)")
        }
    }
}
