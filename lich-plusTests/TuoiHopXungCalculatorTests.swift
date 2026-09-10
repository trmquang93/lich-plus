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

    func testNguHanhHintForXungDay() {
        let hint = TuoiHopXungCalculator.nguHanhHint(
            birthYear: 1990,
            dayCan: .binh,
            isXung: true
        )
        XCTAssertFalse(hint.isEmpty)
    }
}
