//
//  CanChiCalculatorTests.swift
//  lich-plusTests
//
//  Tests for Can-Chi (Heavenly Stems & Earthly Branches) calculation
//  Verifies Vietnamese calendar zodiac year calculations
//

import XCTest
@testable import lich_plus

@MainActor
final class CanChiCalculatorTests: XCTestCase {

    // MARK: - Test: Year Can-Chi Calculation

    func testYearCanChiCalculation_BasicValidation() {
        // Test various lunar years to ensure non-empty output
        let testCases: [Int] = [2024, 2025, 2026, 2027]

        for lunarYear in testCases {
            let yearCanChi = CanChiCalculator.calculateYearCanChi(lunarYear: lunarYear)
            let displayName = yearCanChi.displayName

            // Should not be empty
            XCTAssertFalse(displayName.isEmpty)

            // Should contain both Can and Chi
            XCTAssertTrue(displayName.contains(yearCanChi.can.vietnameseName))
            XCTAssertTrue(displayName.contains(yearCanChi.chi.vietnameseName))
        }
    }

    func testYearCanChiCalculation_SpecificYears() {
        // Reference: 1900 = Canh Tý (issue #32 fix verification)
        let testCases: [(year: Int, expectedCan: String, expectedChi: String)] = [
            (1900, "Canh", "Tý"),    // Reference year
            (2024, "Giáp", "Thìn"),  // Year of Dragon
            (2025, "Ất", "Tỵ"),      // Year of Snake (bug fix verification)
            (2026, "Bính", "Ngọ"),   // Year of Horse
        ]

        for testCase in testCases {
            let yearCanChi = CanChiCalculator.calculateYearCanChi(lunarYear: testCase.year)
            XCTAssertEqual(yearCanChi.can.vietnameseName, testCase.expectedCan,
                "Year \(testCase.year) Can should be \(testCase.expectedCan)")
            XCTAssertEqual(yearCanChi.chi.vietnameseName, testCase.expectedChi,
                "Year \(testCase.year) Chi should be \(testCase.expectedChi)")
        }
    }

    func testYearCanChiCalculation_YearsBeforeReferenceYear() {
        // Test years before 1900 to verify negative modulo handling
        let testCases: [(year: Int, expectedCan: String, expectedChi: String)] = [
            (1899, "Kỷ", "Hợi"),     // Year before reference (tests negative modulo)
            (1850, "Canh", "Tuất"),  // 50 years before 1900
            (1800, "Canh", "Thân"),  // 100 years before 1900
        ]

        for testCase in testCases {
            let yearCanChi = CanChiCalculator.calculateYearCanChi(lunarYear: testCase.year)
            XCTAssertEqual(yearCanChi.can.vietnameseName, testCase.expectedCan,
                "Year \(testCase.year) Can should be \(testCase.expectedCan)")
            XCTAssertEqual(yearCanChi.chi.vietnameseName, testCase.expectedChi,
                "Year \(testCase.year) Chi should be \(testCase.expectedChi)")
        }
    }

    func testYearCanChiCalculation_60YearCycleVerification() {
        // The Can-Chi cycle repeats every 60 years (LCM of 10 and 12)
        // Years 60 apart should have identical Can-Chi
        let testCases: [(year: Int, expectedCan: String, expectedChi: String)] = [
            (1840, "Canh", "Tý"),    // 60 years before 1900
            (1900, "Canh", "Tý"),    // Reference year
            (1960, "Canh", "Tý"),    // 60 years after 1900
            (2020, "Canh", "Tý"),    // 120 years after 1900
        ]

        for testCase in testCases {
            let yearCanChi = CanChiCalculator.calculateYearCanChi(lunarYear: testCase.year)
            XCTAssertEqual(yearCanChi.can.vietnameseName, testCase.expectedCan,
                "Year \(testCase.year) Can should be \(testCase.expectedCan) (60-year cycle)")
            XCTAssertEqual(yearCanChi.chi.vietnameseName, testCase.expectedChi,
                "Year \(testCase.year) Chi should be \(testCase.expectedChi) (60-year cycle)")
        }
    }

    func testYearCanChiCalculation_BoundaryConditions() {
        // Test edge cases for input validation
        let testCases: [(year: Int, expectedCan: String, expectedChi: String, description: String)] = [
            (1, "Tân", "Dậu", "Year 1 (minimum valid year)"),
            (9999, "Kỷ", "Hợi", "Year 9999 (maximum valid year)"),
        ]

        for testCase in testCases {
            let yearCanChi = CanChiCalculator.calculateYearCanChi(lunarYear: testCase.year)
            XCTAssertEqual(yearCanChi.can.vietnameseName, testCase.expectedCan,
                "\(testCase.description): Can should be \(testCase.expectedCan)")
            XCTAssertEqual(yearCanChi.chi.vietnameseName, testCase.expectedChi,
                "\(testCase.description): Chi should be \(testCase.expectedChi)")
        }
    }

    func testYearCanChiCalculation_InvalidInputs() {
        // Test input validation for out-of-range years
        let invalidYears = [0, -1, -100, 10000, 99999]

        for invalidYear in invalidYears {
            let yearCanChi = CanChiCalculator.calculateYearCanChi(lunarYear: invalidYear)
            // Should return default Giáp Tý for invalid inputs
            XCTAssertEqual(yearCanChi.can.vietnameseName, "Giáp",
                "Invalid year \(invalidYear) should return default Can (Giáp)")
            XCTAssertEqual(yearCanChi.chi.vietnameseName, "Tý",
                "Invalid year \(invalidYear) should return default Chi (Tý)")
        }
    }
}
