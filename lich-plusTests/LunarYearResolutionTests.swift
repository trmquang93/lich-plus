//
//  LunarYearResolutionTests.swift
//  lich-plusTests
//
//  Regression tests for LunarCalendar.solarToLunar lunar-year resolution.
//  The VietnameseLunar pod exposes VietnameseDate.year as a String ("<Can> <Chi>"),
//  not an Int. A previous bug parsed that string with Int(...), always falling
//  back to 2025 (Ất Tỵ) — these tests pin the corrected behavior.
//

import XCTest
@testable import lich_plus

final class LunarYearResolutionTests: XCTestCase {

    private func solar(_ y: Int, _ m: Int, _ d: Int) -> Date {
        var comps = DateComponents()
        comps.year = y
        comps.month = m
        comps.day = d
        comps.hour = 12
        return Calendar.current.date(from: comps)!
    }

    // MARK: - Today / Bính Ngọ regression

    func testLunarYear_MidYear2026_IsBinhNgo() {
        let result = LunarCalendar.solarToLunar(solar(2026, 5, 17))
        XCTAssertEqual(result.year, 2026, "Mid-2026 solar dates fall in lunar year 2026")
        let canChi = CanChiCalculator.calculateYearCanChi(lunarYear: result.year)
        XCTAssertEqual(canChi.displayName, "Bính Ngọ")
    }

    // MARK: - Tết 2026 boundary (Feb 17 2026)

    func testLunarYear_BeforeTet2026_IsAtTy() {
        let result = LunarCalendar.solarToLunar(solar(2026, 2, 16))
        XCTAssertEqual(result.year, 2025, "Feb 16, 2026 is still lunar year 2025 (Ất Tỵ)")
        XCTAssertEqual(
            CanChiCalculator.calculateYearCanChi(lunarYear: result.year).displayName,
            "Ất Tỵ"
        )
    }

    func testLunarYear_OnTet2026_IsBinhNgo() {
        let result = LunarCalendar.solarToLunar(solar(2026, 2, 17))
        XCTAssertEqual(result.year, 2026, "Tết 2026 (Feb 17, 2026) is the start of lunar year 2026")
        XCTAssertEqual(
            CanChiCalculator.calculateYearCanChi(lunarYear: result.year).displayName,
            "Bính Ngọ"
        )
    }

    // MARK: - Tết 2025 boundary (Jan 29 2025)

    func testLunarYear_BeforeTet2025_IsGiapThin() {
        let result = LunarCalendar.solarToLunar(solar(2025, 1, 28))
        XCTAssertEqual(result.year, 2024)
        XCTAssertEqual(
            CanChiCalculator.calculateYearCanChi(lunarYear: result.year).displayName,
            "Giáp Thìn"
        )
    }

    func testLunarYear_OnTet2025_IsAtTy() {
        let result = LunarCalendar.solarToLunar(solar(2025, 1, 29))
        XCTAssertEqual(result.year, 2025)
        XCTAssertEqual(
            CanChiCalculator.calculateYearCanChi(lunarYear: result.year).displayName,
            "Ất Tỵ"
        )
    }

    // MARK: - No silent fallback to 2025

    func testLunarYear_FarFromTet_DoesNotFallBackTo2025() {
        // June dates are well past any Tết — lunar year must equal solar year.
        let result2027 = LunarCalendar.solarToLunar(solar(2027, 6, 1))
        XCTAssertEqual(result2027.year, 2027, "June 2027 must be lunar year 2027 (Đinh Mùi)")

        let result2024 = LunarCalendar.solarToLunar(solar(2024, 6, 1))
        XCTAssertEqual(result2024.year, 2024, "June 2024 must be lunar year 2024 (Giáp Thìn)")
    }

    // MARK: - Sanity: day/month still correct

    func testLunarYear_DayAndMonthStillPopulated() {
        let result = LunarCalendar.solarToLunar(solar(2026, 5, 17))
        XCTAssertGreaterThan(result.day, 0)
        XCTAssertGreaterThan(result.month, 0)
        XCTAssertLessThanOrEqual(result.month, 12)
        XCTAssertLessThanOrEqual(result.day, 30)
    }
}
