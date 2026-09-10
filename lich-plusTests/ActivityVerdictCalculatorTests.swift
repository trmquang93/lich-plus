//
//  ActivityVerdictCalculatorTests.swift
//  lich-plusTests
//

import XCTest
@testable import lich_plus

final class ActivityVerdictCalculatorTests: XCTestCase {

    private var vietnamCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Ho_Chi_Minh") ?? .current
        return calendar
    }

    func testEmptyStarPlaceholdersAreNotComplete() {
        // WHY: Month 3 seeds 60 empty keys; an empty placeholder is missing data, not a confident empty day.
        let availability = StarCalculator.dataAvailability(lunarMonth: 3, dayCanChi: "Giáp Tý")
        XCTAssertEqual(
            availability,
            .missingForDay,
            "empty star placeholders must not count as complete"
        )

        let completeness = StarCalculator.monthCompleteness(lunarMonth: 3)
        XCTAssertLessThan(completeness.completed, completeness.total)
    }

    func testVerdictReturnsIncompleteWhenStarDataMissingForCanChi() throws {
        // WHY: xem ngày must not treat missing star tables as a finished verdict.
        let calendar = vietnamCalendar
        guard var date = calendar.date(from: DateComponents(year: 2026, month: 3, day: 15)) else {
            XCTFail("Could not build search start date")
            return
        }

        var missingDate: Date?
        for _ in 0..<70 {
            let lunar = LunarCalendar.solarToLunar(date)
            if lunar.month == 3 {
                let dayCanChi = CanChiCalculator.canChiToString(CanChiCalculator.calculateDayCanChi(for: date))
                if StarCalculator.dataAvailability(lunarMonth: lunar.month, dayCanChi: dayCanChi) == .missingForDay {
                    missingDate = date
                    break
                }
            }
            guard let next = calendar.date(byAdding: .day, value: 1, to: date) else { break }
            date = next
        }

        let dateWithMissingStars = try XCTUnwrap(
            missingDate,
            "lunar month 3 should include days whose star entry is only an empty placeholder"
        )

        let verdict = ActivityVerdictCalculator.verdict(for: dateWithMissingStars, purpose: .travel, birthYear: nil)
        XCTAssertEqual(verdict.status, .incomplete)
        XCTAssertTrue(verdict.isStarDataIncomplete)
    }

    func testBirthYearXungLowersVerdictForTravel() throws {
        // WHY: a real clash day must lower the travel verdict; skipping a non-clash date hid the bug.
        let birthYear = 1990
        let birthChi = TuoiHopXungCalculator.birthYearCanChi(for: birthYear).chi
        let conflicting = try XCTUnwrap(TuoiHopXungCalculator.conflictingChi(for: birthChi))

        let calendar = vietnamCalendar
        guard var cursor = calendar.date(from: DateComponents(year: 2026, month: 1, day: 1)),
              let end = calendar.date(from: DateComponents(year: 2026, month: 12, day: 31)) else {
            XCTFail("Could not build 2026 search range")
            return
        }

        var clashDate: Date?
        while cursor <= end {
            if CanChiCalculator.calculateDayCanChi(for: cursor).chi == conflicting {
                clashDate = cursor
                break
            }
            guard let next = calendar.date(byAdding: .day, value: 1, to: cursor) else { break }
            cursor = next
        }

        let date = try XCTUnwrap(
            clashDate,
            "expected a 2026 solar day whose chi xung with birth year \(birthYear)"
        )
        XCTAssertEqual(CanChiCalculator.calculateDayCanChi(for: date).chi, conflicting)

        let without = ActivityVerdictCalculator.verdict(for: date, purpose: .travel, birthYear: nil)
        let withXung = ActivityVerdictCalculator.verdict(for: date, purpose: .travel, birthYear: birthYear)

        XCTAssertTrue(withXung.isBirthYearXung)
        XCTAssertNotNil(withXung.nguHanhHint)
        XCTAssertNotEqual(without.status, withXung.status)
    }
}
