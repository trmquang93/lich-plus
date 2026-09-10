//
//  TuoiHopXungCalculatorTests.swift
//  lich-plusTests
//

import XCTest
@testable import lich_plus

final class TuoiHopXungCalculatorTests: XCTestCase {

    func testTamXungPairs() {
        XCTAssertEqual(TuoiHopXungCalculator.conflictingChi(for: .ty), .ngo)
        XCTAssertEqual(TuoiHopXungCalculator.conflictingChi(for: .ngo), .ty)
        XCTAssertEqual(TuoiHopXungCalculator.conflictingChi(for: .dan), .than)
        XCTAssertEqual(TuoiHopXungCalculator.conflictingChi(for: .hoi), .ty2)
    }

    func testIsXungDayDetectsClash() {
        let birthYear = 1996 // Bính Tý
        let birthChi = TuoiHopXungCalculator.birthYearCanChi(for: birthYear).chi
        XCTAssertEqual(birthChi, .ty)

        let xung = TuoiHopXungCalculator.isXungDay(birthYear: birthYear, dayChi: .ngo)
        XCTAssertNotNil(xung)
        XCTAssertEqual(xung?.conflictingChi, .ngo)
    }

    func testXungReasonNamesBirthYearChiAndDayChi() throws {
        // WHY: user must see which natal branch clashes with the day (not "Ngọ xung Ngọ")
        let xung = TuoiHopXungCalculator.isXungDay(birthYear: 1996, dayChi: .ngo)
        let reason = try XCTUnwrap(xung?.reason)

        XCTAssertEqual(xung?.birthYearChi, .ty)
        XCTAssertEqual(xung?.dayChi, .ngo)
        XCTAssertTrue(reason.contains("Tý"), "reason must name natal chi, got \(reason)")
        XCTAssertTrue(reason.contains("Ngọ"), "reason must name day chi, got \(reason)")
        XCTAssertFalse(
            reason.contains("Ngọ xung Ngọ"),
            "clash copy must not repeat the day chi as both sides, got \(reason)"
        )
    }

    func testNguHanhHintForXungDay() {
        let hint = TuoiHopXungCalculator.nguHanhHint(
            birthYear: 1990,
            dayCan: .binh,
            isXung: true
        )
        XCTAssertFalse(hint.isEmpty)
    }
}
