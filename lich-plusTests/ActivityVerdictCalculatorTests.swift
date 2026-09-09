//
//  ActivityVerdictCalculatorTests.swift
//  lich-plusTests
//

import XCTest
@testable import lich_plus

final class ActivityVerdictCalculatorTests: XCTestCase {

    func testVerdictReturnsIncompleteWhenStarDataMissingForCanChi() {
        // Month 3 has partial star data — many Can-Chi combos lack entries.
        var components = DateComponents()
        components.year = 2026
        components.month = 4
        components.day = 20
        components.timeZone = TimeZone(identifier: "Asia/Ho_Chi_Minh")
        let calendar = Calendar(identifier: .gregorian)
        guard let date = calendar.date(from: components) else {
            XCTFail("Could not build test date")
            return
        }

        let lunar = LunarCalendar.solarToLunar(date)
        XCTAssertEqual(lunar.month, 3, "Test date should fall in lunar month 3")

        let dayCanChi = CanChiCalculator.canChiToString(CanChiCalculator.calculateDayCanChi(for: date))
        let availability = StarCalculator.dataAvailability(lunarMonth: lunar.month, dayCanChi: dayCanChi)

        if availability == .missingForDay {
            let verdict = ActivityVerdictCalculator.verdict(for: date, purpose: .travel, birthYear: nil)
            XCTAssertEqual(verdict.status, .incomplete)
            XCTAssertTrue(verdict.isStarDataIncomplete)
        }
    }

    func testBirthYearXungLowersVerdictForTravel() {
        var components = DateComponents()
        components.year = 2026
        components.month = 6
        components.day = 24
        components.timeZone = TimeZone(identifier: "Asia/Ho_Chi_Minh")
        let calendar = Calendar(identifier: .gregorian)
        guard let date = calendar.date(from: components) else {
            XCTFail("Could not build test date")
            return
        }

        let dayChi = CanChiCalculator.calculateDayCanChi(for: date).chi
        let birthYear = 1990
        let birthChi = TuoiHopXungCalculator.birthYearCanChi(for: birthYear).chi

        guard TuoiHopXungCalculator.conflictingChi(for: birthChi) == dayChi else {
            return // Skip when test date is not a clash day for 1990
        }

        let without = ActivityVerdictCalculator.verdict(for: date, purpose: .travel, birthYear: nil)
        let withXung = ActivityVerdictCalculator.verdict(for: date, purpose: .travel, birthYear: birthYear)

        XCTAssertTrue(withXung.isBirthYearXung)
        XCTAssertNotNil(withXung.nguHanhHint)
        XCTAssertNotEqual(without.status, withXung.status)
    }
}
