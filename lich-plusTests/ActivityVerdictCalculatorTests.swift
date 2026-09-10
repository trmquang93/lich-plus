//
//  ActivityVerdictCalculatorTests.swift
//  lich-plusTests
//

import XCTest
@testable import lich_plus

final class ActivityVerdictCalculatorTests: XCTestCase {

    private let timeZone = TimeZone(identifier: "Asia/Ho_Chi_Minh")!

    func testVerdictReturnsIncompleteWhenStarDataMissingForCanChi() {
        // WHY: empty padded catalog rows must not produce a confident good/bad verdict
        guard let date = firstDate(
            year: 2026,
            month: 4,
            matching: { date in
                let lunar = LunarCalendar.solarToLunar(date)
                guard lunar.month == 3 else { return false }
                let canChi = CanChiCalculator.canChiToString(
                    CanChiCalculator.calculateDayCanChi(for: date)
                )
                return StarCalculator.dataAvailability(lunarMonth: 3, dayCanChi: canChi) == .missingForDay
            }
        ) else {
            XCTFail("Need a lunar month 3 date whose star row is an empty placeholder")
            return
        }

        let lunar = LunarCalendar.solarToLunar(date)
        XCTAssertEqual(lunar.month, 3, "Test date should fall in lunar month 3")

        let verdict = ActivityVerdictCalculator.verdict(for: date, purpose: .travel, birthYear: nil)
        XCTAssertEqual(verdict.status, .incomplete)
        XCTAssertTrue(verdict.isStarDataIncomplete)
    }

    func testBirthYearXungLowersVerdictForTravel() {
        // WHY: natal Tam Xung must change the travel verdict; skipping hides the clash
        guard let date = firstDate(
            year: 2026,
            month: 7,
            matching: { date in
                let lunar = LunarCalendar.solarToLunar(date)
                guard lunar.month == 6 else { return false }
                let canChi = CanChiCalculator.canChiToString(
                    CanChiCalculator.calculateDayCanChi(for: date)
                )
                return StarCalculator.dataAvailability(lunarMonth: 6, dayCanChi: canChi) == .complete
            }
        ) else {
            XCTFail("Need a lunar month 6 date with complete star data")
            return
        }

        let dayChi = CanChiCalculator.calculateDayCanChi(for: date).chi
        guard let natalChi = TuoiHopXungCalculator.conflictingChi(for: dayChi) else {
            XCTFail("Every earthly branch has a Tam Xung pair")
            return
        }
        guard let birthYear = (1920...2100).first(where: {
            TuoiHopXungCalculator.birthYearCanChi(for: $0).chi == natalChi
        }) else {
            XCTFail("Need a birth year whose chi clashes with \(dayChi.vietnameseName)")
            return
        }

        let without = ActivityVerdictCalculator.verdict(for: date, purpose: .travel, birthYear: nil)
        let withXung = ActivityVerdictCalculator.verdict(for: date, purpose: .travel, birthYear: birthYear)

        XCTAssertNotEqual(without.status, .incomplete, "Clash test needs a complete star day")
        XCTAssertTrue(withXung.isBirthYearXung)
        XCTAssertNotNil(withXung.nguHanhHint)
        XCTAssertTrue(
            withXung.reasons.contains { $0.contains(natalChi.vietnameseName) && $0.contains(dayChi.vietnameseName) },
            "xung reason must name natal \(natalChi.vietnameseName) and day \(dayChi.vietnameseName); got \(withXung.reasons)"
        )

        if without.status == .bad {
            XCTAssertEqual(withXung.status, .bad)
        } else {
            XCTAssertNotEqual(
                without.status,
                withXung.status,
                "Tuổi xung should lower the travel verdict from \(without.status)"
            )
        }
    }

    func testEmptyPaddedStarRowsAreNotTreatedAsComplete() {
        // WHY: empty padded days must not get confident .good/.bad as if the catalog was full
        XCTAssertEqual(
            StarCalculator.dataAvailability(lunarMonth: 3, dayCanChi: "Giáp Tý"),
            .missingForDay
        )
        XCTAssertEqual(
            StarCalculator.dataAvailability(lunarMonth: 7, dayCanChi: "Giáp Tý"),
            .missingForDay
        )

        let month3 = StarCalculator.monthCompleteness(lunarMonth: 3)
        XCTAssertLessThan(month3.completed, month3.total)

        XCTAssertEqual(
            StarCalculator.dataAvailability(lunarMonth: 3, dayCanChi: "Ất Dậu"),
            .monthPartial
        )
        XCTAssertEqual(
            StarCalculator.dataAvailability(lunarMonth: 6, dayCanChi: "Giáp Tý"),
            .complete
        )
    }

    private func firstDate(
        year: Int,
        month: Int,
        matching: (Date) -> Bool
    ) -> Date? {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.timeZone = timeZone
        let calendar = Calendar(identifier: .gregorian)
        for day in 1...31 {
            components.day = day
            guard let date = calendar.date(from: components) else { continue }
            if matching(date) { return date }
        }
        return nil
    }
}
