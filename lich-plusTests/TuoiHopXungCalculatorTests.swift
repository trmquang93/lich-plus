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
        XCTAssertEqual(xung?.birthYearChi, .ty)
        XCTAssertEqual(xung?.dayChi, .ngo)
    }

    func testXungReasonUsesBirthYearChiAgainstDayChi() throws {
        // WHY: conflictingChi == dayChi on a clash, so naming both as dayChi prints "Ngọ xung Ngọ".
        let xung = try XCTUnwrap(TuoiHopXungCalculator.isXungDay(birthYear: 1996, dayChi: .ngo))
        let birthName = ChiEnum.ty.vietnameseName
        let dayName = ChiEnum.ngo.vietnameseName
        XCTAssertTrue(xung.reason.contains(birthName), "reason should name birth-year chi, got \(xung.reason)")
        XCTAssertTrue(xung.reason.contains(dayName), "reason should name day chi, got \(xung.reason)")
        XCTAssertFalse(
            xung.reason.contains("\(dayName) xung \(dayName)"),
            "reason must not repeat the day chi as both sides of xung"
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
