//
//  StarDataCompletenessTests.swift
//  lich-plusTests
//

import XCTest
@testable import lich_plus

final class StarDataCompletenessTests: XCTestCase {

    private let allCanChi = [
        "Giáp Tý", "Ất Sửu", "Bính Dần", "Đinh Mão", "Mậu Thìn", "Kỷ Tỵ",
        "Canh Ngọ", "Tân Mùi", "Nhâm Thân", "Quý Dậu", "Giáp Tuất", "Ất Hợi",
        "Bính Tý", "Đinh Sửu", "Mậu Dần", "Kỷ Mão", "Canh Thìn", "Tân Tỵ",
        "Nhâm Ngọ", "Quý Mùi", "Giáp Thân", "Ất Dậu", "Bính Tuất", "Đinh Hợi",
        "Mậu Tý", "Kỷ Sửu", "Canh Dần", "Tân Mão", "Nhâm Thìn", "Quý Tỵ",
        "Giáp Ngọ", "Ất Mùi", "Bính Thân", "Đinh Dậu", "Mậu Tuất", "Kỷ Hợi",
        "Canh Tý", "Tân Sửu", "Nhâm Dần", "Quý Mão", "Giáp Thìn", "Ất Tỵ",
        "Bính Ngọ", "Đinh Mùi", "Mậu Thân", "Kỷ Dậu", "Canh Tuất", "Tân Hợi",
        "Nhâm Tý", "Quý Sửu", "Giáp Dần", "Ất Mão", "Bính Thìn", "Đinh Tỵ",
        "Mậu Ngọ", "Kỷ Mùi", "Canh Thân", "Tân Dậu", "Nhâm Tuất", "Quý Hợi"
    ]

    func testMonth3HasFullCanChiCoverage() {
        // WHY: xem ngày must not show partial-data banners for lunar month 3
        let completeness = StarCalculator.monthCompleteness(lunarMonth: 3)
        XCTAssertEqual(completeness.completed, 60)
        XCTAssertEqual(completeness.total, 60)

        for canChi in allCanChi {
            XCTAssertEqual(
                StarCalculator.dataAvailability(lunarMonth: 3, dayCanChi: canChi),
                .complete,
                "\(canChi) should have complete star data in month 3"
            )
        }
    }

    func testMonth7HasDocumentedResidualGapsOnly() {
        // WHY: month 7 book rows Giáp Thân / Bính Thân list only non-enum stars (Thổ phủ, Lục bất thành)
        let completeness = StarCalculator.monthCompleteness(lunarMonth: 7)
        XCTAssertEqual(completeness.completed, 58)
        XCTAssertEqual(completeness.total, 60)

        let gapDays = ["Giáp Thân", "Bính Thân"]
        for canChi in allCanChi {
            let availability = StarCalculator.dataAvailability(lunarMonth: 7, dayCanChi: canChi)
            if gapDays.contains(canChi) {
                XCTAssertEqual(availability, .missingForDay, "\(canChi) is an honest residual gap")
            } else {
                XCTAssertEqual(availability, .complete, "\(canChi) should be complete in month 7")
            }
        }
    }

    func testMonth3VerdictIsNoLongerIncompleteForPopulatedDay() {
        // WHY: filling month 3 removes the incomplete banner for days that now have catalog stars
        guard let date = firstLunarMonthDate(year: 2026, lunarMonth: 3, dayCanChi: "Giáp Tý") else {
            XCTFail("Need a lunar month 3 date for Giáp Tý")
            return
        }

        let verdict = ActivityVerdictCalculator.verdict(for: date, purpose: .travel, birthYear: nil)
        XCTAssertFalse(verdict.isStarDataIncomplete)
        XCTAssertNotEqual(verdict.status, .incomplete)
    }

    func testMonth7VerdictStillIncompleteOnlyOnDocumentedGapDays() {
        guard let gapDate = firstLunarMonthDate(year: 2026, lunarMonth: 7, dayCanChi: "Giáp Thân"),
              let completeDate = firstLunarMonthDate(year: 2026, lunarMonth: 7, dayCanChi: "Ất Dậu") else {
            XCTFail("Need lunar month 7 dates for gap and complete Can-Chi rows")
            return
        }

        let gapVerdict = ActivityVerdictCalculator.verdict(for: gapDate, purpose: .travel, birthYear: nil)
        XCTAssertTrue(gapVerdict.isStarDataIncomplete)

        let completeVerdict = ActivityVerdictCalculator.verdict(for: completeDate, purpose: .travel, birthYear: nil)
        XCTAssertFalse(completeVerdict.isStarDataIncomplete)
    }

    private func firstLunarMonthDate(year: Int, lunarMonth: Int, dayCanChi: String) -> Date? {
        var components = DateComponents()
        components.year = year
        components.timeZone = TimeZone(identifier: "Asia/Ho_Chi_Minh")
        let calendar = Calendar(identifier: .gregorian)
        for month in 1...12 {
            components.month = month
            for day in 1...31 {
                components.day = day
                guard let date = calendar.date(from: components) else { continue }
                let lunar = LunarCalendar.solarToLunar(date)
                guard lunar.month == lunarMonth else { continue }
                let canChi = CanChiCalculator.canChiToString(
                    CanChiCalculator.calculateDayCanChi(for: date)
                )
                if canChi == dayCanChi { return date }
            }
        }
        return nil
    }
}
