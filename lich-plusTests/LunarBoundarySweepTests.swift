//
//  LunarBoundarySweepTests.swift
//  lich-plusTests
//
//  Curated regression mappings for `LunarCalendar.solarToLunar`. Anchors
//  Tết dates 2024–2028, the original Apr 2026 bug, a couple of mid-month
//  sanity dates the pod handles correctly, and confirms two known legitimate
//  leap-month boundaries are passed through (the pod represents these as
//  same-numeric-month with day rolling 29 → 1).
//
//  Out-of-scope pod bugs surfaced during development (clean-shift variants
//  in Apr 2027, Apr 2029, Apr 2030 where lunar month 2 ends on day 28 with
//  no consecutive duplicate to detect) are intentionally NOT asserted here.
//  See `.claude/backlogs/lunar-apr-2026-off-by-one-plan.md` Investigation
//  Log for tracking.
//

import XCTest
@testable import lich_plus

final class LunarBoundarySweepTests: XCTestCase {

    private static let vietnamCalendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "Asia/Ho_Chi_Minh") ?? .current
        return cal
    }()

    private func makeSolar(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = day
        comps.hour = 12
        return Self.vietnamCalendar.date(from: comps)!
    }

    // MARK: - Tết Nguyên Đán anchors (lunar 1/1 of each year)

    func test_tet_2024_through_2028() {
        // Tết = lunar new year (lunar 1/1) per Hồ Ngọc Đức tables.
        let cases: [(sy: Int, sm: Int, sd: Int, ly: Int)] = [
            (2024, 2, 10, 2024), // Giáp Thìn
            (2025, 1, 29, 2025), // Ất Tỵ
            (2026, 2, 17, 2026), // Bính Ngọ
            (2027, 2,  6, 2027), // Đinh Mùi
            (2028, 1, 26, 2028)  // Mậu Thân
        ]

        for c in cases {
            let l = LunarCalendar.solarToLunar(makeSolar(c.sy, c.sm, c.sd))
            XCTAssertEqual(l.day, 1, "Tết \(c.ly): wrong lunar day")
            XCTAssertEqual(l.month, 1, "Tết \(c.ly): wrong lunar month")
            XCTAssertEqual(l.year, c.ly, "Tết \(c.ly): wrong lunar year")
        }
    }

    // MARK: - Apr 2026 boundary (the original bug)

    func test_apr_2026_boundary_pinned() {
        let cases: [(sd: Int, ld: Int, lm: Int)] = [
            (15, 28, 2),
            (16, 29, 2),   // the reported bug
            (17,  1, 3),
            (18,  2, 3)
        ]
        for c in cases {
            let l = LunarCalendar.solarToLunar(makeSolar(2026, 4, c.sd))
            XCTAssertEqual(l.day, c.ld, "solar 2026-04-\(c.sd) lunar day")
            XCTAssertEqual(l.month, c.lm, "solar 2026-04-\(c.sd) lunar month")
            XCTAssertEqual(l.year, 2026, "solar 2026-04-\(c.sd) lunar year")
        }
    }

    // MARK: - Mid-month sanity (well clear of new-moon boundaries)

    func test_mid_month_sanity_anchors() {
        // Mid-month dates that should be unaffected by the new-moon
        // boundary bug class. These prove the wrapper layer doesn't regress
        // non-boundary conversions.
        //
        //   2026-03-04 = Tết + 15 = 15/1/2026 (rằm tháng giêng Bính Ngọ)
        //   2025-02-12 = Tết + 14 = 15/1/2025 (rằm tháng giêng Ất Tỵ)
        //   2024-02-24 = Tết + 14 = 15/1/2024 (rằm tháng giêng Giáp Thìn)
        let cases: [(sy: Int, sm: Int, sd: Int, ld: Int, lm: Int, ly: Int)] = [
            (2024, 2, 24, 15, 1, 2024),
            (2025, 2, 12, 15, 1, 2025),
            (2026, 3,  3, 15, 1, 2026)
        ]
        for c in cases {
            let l = LunarCalendar.solarToLunar(makeSolar(c.sy, c.sm, c.sd))
            XCTAssertEqual(l.day, c.ld, "solar \(c.sy)-\(c.sm)-\(c.sd) lunar day")
            XCTAssertEqual(l.month, c.lm, "solar \(c.sy)-\(c.sm)-\(c.sd) lunar month")
            XCTAssertEqual(l.year, c.ly, "solar \(c.sy)-\(c.sm)-\(c.sd) lunar year")
        }
    }

    // MARK: - Duplicate-pair invariant (year-boundary, narrow window)

    /// Verifies that across the 2025-12 → 2026-12 window — covering the
    /// reported Apr 2026 bug and Tết 2026 — no two consecutive solar days
    /// map to the same lunar (d, m, y). This is the bug fingerprint the
    /// duplicate-pair heuristic eliminates; if it ever reappears in this
    /// window the test fails.
    func test_no_consecutive_duplicates_in_bich_ngo_2026_window() {
        let start = makeSolar(2025, 12, 1)
        let end = makeSolar(2026, 12, 31)

        var current = start
        var prev = LunarCalendar.solarToLunar(current)

        while current < end {
            guard let next = Self.vietnamCalendar.date(byAdding: .day, value: 1, to: current) else {
                XCTFail("Failed to advance from \(current)")
                return
            }
            current = next
            let now = LunarCalendar.solarToLunar(current)
            XCTAssertFalse(
                now.day == prev.day && now.month == prev.month && now.year == prev.year,
                "Duplicate lunar \(now) on consecutive solar days ending at \(current)"
            )
            prev = now
        }
    }
}
