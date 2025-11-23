//
//  VietnameseCalendarTests.swift
//  lich-plusTests
//
//  Vietnamese Calendar Calculation Tests
//  Tests based on real Vietnamese calendar reference data
//

import XCTest
@testable import lich_plus

class VietnameseCalendarTests: XCTestCase {

    // MARK: - Test Data Structure

    struct TestDate {
        let name: String
        let solarDate: Date
        let lunarDay: Int
        let lunarMonth: Int
        let lunarYear: Int
        let expectedDayCanChi: String
        let expectedDayChiIndex: Int  // For Chi enum rawValue
        let expectedMonthCanChi: String
        let expectedYearCanChi: String
        let expectedTruc: ZodiacHourType
        let expectedUnluckyDay: String?
        let expectedFinalQuality: DayType
        let expectedLuckyHourChis: [ChiEnum]
    }

    // MARK: - Reference Test Data from Vietnamese Calendars

    lazy var testCases: [TestDate] = [
        // Test Case 1: November 24, 2025 - CRITICAL TEST
        // Reference: xemlicham.com, licham.vn
        // Solar: 24/11/2025
        // Lunar: 05/10 Ất Tỵ
        TestDate(
            name: "Nov 24, 2025 - Chu Tước Hắc Đạo",
            solarDate: VietnameseCalendarTests.createDate(year: 2025, month: 11, day: 24),
            lunarDay: 5,
            lunarMonth: 10,
            lunarYear: 2025,
            expectedDayCanChi: "Đinh Dậu",
            expectedDayChiIndex: 9,  // Dậu = index 9
            expectedMonthCanChi: "Đinh Hợi",
            expectedYearCanChi: "Ất Tỵ",
            expectedTruc: .khai,
            expectedUnluckyDay: "Chu Tước Hắc Đạo",
            expectedFinalQuality: .bad,
            expectedLuckyHourChis: [.ty, .dan, .mao, .ngo, .mui, .dau]  // Tý, Dần, Mão, Ngọ, Mùi, Dậu
        ),

        // Test Case 2: November 2, 2025 - Ngọc Đường Hoàng Đạo (Jade Path - Auspicious)
        // Reference: xemlicham.com, licham.vn
        // Solar: 02/11/2025
        // Lunar: 13/09 Ất Tỵ - NO UNLUCKY DAY
        // Trực: Trừ (very auspicious - one of Tứ Hộ Thần)
        // Quality: Slightly good (2.5/5)
        TestDate(
            name: "Nov 2, 2025 - Ngọc Đường Hoàng Đạo",
            solarDate: VietnameseCalendarTests.createDate(year: 2025, month: 11, day: 2),
            lunarDay: 13,
            lunarMonth: 9,
            lunarYear: 2025,
            expectedDayCanChi: "Ất Hợi",
            expectedDayChiIndex: 11,  // Hợi = index 11
            expectedMonthCanChi: "Bính Tuất",
            expectedYearCanChi: "Ất Tỵ",
            expectedTruc: .tru,  // Trừ = very auspicious
            expectedUnluckyDay: nil,  // No unlucky day
            expectedFinalQuality: .good,  // Trừ is very auspicious
            expectedLuckyHourChis: [.suu, .thin, .ngo, .mui, .tuat, .hoi]  // Sửu, Thìn, Ngọ, Mùi, Tuất, Hợi
        ),

        // Test Case 3: TODO - Different unlucky day type
        // TODO: Get actual data with Bạch Hổ Hắc Đạo or other unlucky type

        // Test Case 4: TODO - Inauspicious Trực type
        // TODO: Get actual data with Phá, Nguy, etc.
    ]

    // MARK: - Setup & Helpers

    override func setUp() {
        super.setUp()
    }

    static func createDate(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.timeZone = TimeZone.current
        let date = Calendar.current.date(from: components)!
        return date
    }

    // MARK: - Test 12 Trực Calculation

    /// Test that 12 Trực is calculated correctly for each lunar date
    func testTrucCalculation() {
        for testCase in testCases {
            let calculatedTruc = HoangDaoCalculator.calculateZodiacHour(
                for: (
                    day: testCase.lunarDay,
                    month: testCase.lunarMonth,
                    year: testCase.lunarYear
                )
            )

            XCTAssertEqual(
                calculatedTruc,
                testCase.expectedTruc,
                """
                FAILED: \(testCase.name)

                Expected Trực: \(testCase.expectedTruc.vietnameseName) (\(testCase.expectedTruc.displayName))
                Got:           \(calculatedTruc.vietnameseName) (\(calculatedTruc.displayName))

                Lunar Date: \(testCase.lunarDay)/\(testCase.lunarMonth)/\(testCase.lunarYear)
                Solar Date: \(testCase.solarDate.formatted(date: .abbreviated, time: .omitted))

                Calculation: Need to verify formula for 12 Trực
                """
            )
        }
    }

    // MARK: - Test Day Can-Chi Calculation

    /// Test that day Can-Chi is calculated correctly from solar date
    func testDayCanChiCalculation() {
        for testCase in testCases {
            let calculatedCanChi = CanChiCalculator.calculateDayCanChi(
                for: testCase.solarDate
            )

            XCTAssertEqual(
                calculatedCanChi.displayName,
                testCase.expectedDayCanChi,
                """
                FAILED: \(testCase.name) - Day Can-Chi

                Expected: \(testCase.expectedDayCanChi)
                Got:      \(calculatedCanChi.displayName)

                Solar Date: \(testCase.solarDate.formatted(date: .abbreviated, time: .omitted))
                Lunar Date: \(testCase.lunarDay)/\(testCase.lunarMonth)/\(testCase.lunarYear)
                """
            )
        }
    }

    /// Test that day Chi (Earthly Branch) is correct
    func testDayChiExtraction() {
        for testCase in testCases {
            let calculatedCanChi = CanChiCalculator.calculateDayCanChi(
                for: testCase.solarDate
            )

            XCTAssertEqual(
                calculatedCanChi.chi.rawValue,
                testCase.expectedDayChiIndex,
                """
                FAILED: \(testCase.name) - Day Chi

                Expected Chi Index: \(testCase.expectedDayChiIndex) (\(calculateChiName(for: testCase.expectedDayChiIndex)))
                Got Chi Index:      \(calculatedCanChi.chi.rawValue) (\(calculatedCanChi.chi.vietnameseName))

                Solar Date: \(testCase.solarDate.formatted(date: .abbreviated, time: .omitted))
                """
            )
        }
    }

    // MARK: - Test Month Can-Chi Calculation

    /// Test that month Can-Chi is calculated correctly
    func testMonthCanChiCalculation() {
        for testCase in testCases {
            let yearCanChi = CanChiCalculator.calculateYearCanChi(
                for: testCase.solarDate
            )
            let calculatedMonthCanChi = CanChiCalculator.calculateMonthCanChi(
                lunarMonth: testCase.lunarMonth,
                yearCan: yearCanChi.can
            )

            XCTAssertEqual(
                calculatedMonthCanChi.displayName,
                testCase.expectedMonthCanChi,
                """
                FAILED: \(testCase.name) - Month Can-Chi

                Expected: \(testCase.expectedMonthCanChi)
                Got:      \(calculatedMonthCanChi.displayName)

                Lunar Month: \(testCase.lunarMonth)
                Year Can: \(yearCanChi.can.vietnameseName)
                """
            )
        }
    }

    // MARK: - Test Year Can-Chi Calculation

    /// Test that year Can-Chi is calculated correctly
    func testYearCanChiCalculation() {
        for testCase in testCases {
            let calculatedYearCanChi = CanChiCalculator.calculateYearCanChi(
                for: testCase.solarDate
            )

            XCTAssertEqual(
                calculatedYearCanChi.displayName,
                testCase.expectedYearCanChi,
                """
                FAILED: \(testCase.name) - Year Can-Chi

                Expected: \(testCase.expectedYearCanChi)
                Got:      \(calculatedYearCanChi.displayName)

                Lunar Year: \(testCase.lunarYear)
                """
            )
        }
    }

    // MARK: - Test Lục Hắc Đạo (Unlucky Days)

    /// Test that Lục Hắc Đạo unlucky days are correctly detected
    func testLucHacDaoDetection() {
        for testCase in testCases {
            // Skip if no unlucky day expected for this test case
            guard testCase.expectedUnluckyDay != nil else {
                continue
            }

            let dayCanChi = CanChiCalculator.calculateDayCanChi(
                for: testCase.solarDate
            )

            let unluckyDay = LucHacDaoCalculator.calculateUnluckyDay(
                lunarMonth: testCase.lunarMonth,
                dayChi: dayCanChi.chi
            )

            XCTAssertNotNil(
                unluckyDay,
                """
                FAILED: \(testCase.name) - Lục Hắc Đạo Not Detected

                Expected Unlucky Day: \(testCase.expectedUnluckyDay ?? "None")
                Got: None

                Lunar Month: \(testCase.lunarMonth)
                Day Chi: \(dayCanChi.chi.vietnameseName) (index: \(dayCanChi.chi.rawValue))
                """
            )

            if let unluckyDay = unluckyDay {
                XCTAssertEqual(
                    unluckyDay.vietnameseName,
                    testCase.expectedUnluckyDay,
                    """
                    FAILED: \(testCase.name) - Wrong Unlucky Day Type

                    Expected: \(testCase.expectedUnluckyDay ?? "None")
                    Got: \(unluckyDay.vietnameseName)

                    Lunar: \(testCase.lunarDay)/\(testCase.lunarMonth)/\(testCase.lunarYear)
                    Day Chi: \(dayCanChi.chi.vietnameseName)
                    """
                )
            }
        }
    }

    // MARK: - Test Composite Day Quality

    /// Test that final day quality correctly combines all systems
    func testCompositeDayQuality() {
        for testCase in testCases {
            let dayQuality = HoangDaoCalculator.determineDayQuality(
                lunarDay: testCase.lunarDay,
                lunarMonth: testCase.lunarMonth,
                lunarYear: testCase.lunarYear,
                dayCanChi: testCase.expectedDayCanChi
            )

            let finalQuality = dayQuality.finalQuality

            XCTAssertEqual(
                finalQuality,
                testCase.expectedFinalQuality,
                """
                FAILED: \(testCase.name) - Composite Day Quality

                Expected Final Quality: \(testCase.expectedFinalQuality)
                Got: \(finalQuality)

                Trực: \(dayQuality.zodiacHour.vietnameseName) (\(dayQuality.zodiacHour.quality))
                Unlucky Day: \(dayQuality.unluckyDayType?.vietnameseName ?? "None")

                Details:
                - Solar: \(testCase.solarDate.formatted(date: .abbreviated, time: .omitted))
                - Lunar: \(testCase.lunarDay)/\(testCase.lunarMonth)/\(testCase.lunarYear)
                - Day Can-Chi: \(testCase.expectedDayCanChi)
                """
            )
        }
    }

    // MARK: - Test Lucky Hours

    /// Test that lucky hours are correctly calculated
    func testLuckyHours() {
        for testCase in testCases {
            let luckyHours = DayTypeCalculator.getLuckyHours(for: testCase.solarDate)

            // Extract Chi from lucky hours based on time ranges
            let luckyChis = luckyHours.compactMap { hour -> ChiEnum? in
                extractChiFromTimeRange(hour.timeRange)
            }

            XCTAssertEqual(
                Set(luckyChis),
                Set(testCase.expectedLuckyHourChis),
                """
                FAILED: \(testCase.name) - Lucky Hours

                Expected Lucky Hour Chis: \(testCase.expectedLuckyHourChis.map { $0.vietnameseName }.joined(separator: ", "))
                Got: \(luckyChis.map { $0.vietnameseName }.joined(separator: ", "))

                Solar Date: \(testCase.solarDate.formatted(date: .abbreviated, time: .omitted))
                Lunar Date: \(testCase.lunarDay)/\(testCase.lunarMonth)/\(testCase.lunarYear)

                Lucky Hours Details:
                \(luckyHours.map { "  \($0.timeRange): \($0.luckyActivities.joined(separator: ", "))" }.joined(separator: "\n"))
                """
            )
        }
    }

    // MARK: - Helper Functions

    private func extractChiFromTimeRange(_ timeRange: String) -> ChiEnum? {
        // Parse "23:00 - 01:00" format to Chi
        let components = timeRange.split(separator: " ")
        guard let startTimeStr = components.first,
              let startHour = Int(startTimeStr.split(separator: ":").first ?? "") else {
            return nil
        }

        // Map hour ranges to Chi
        switch startHour {
        case 23: return .ty      // 23:00-01:00
        case 1: return .suu      // 01:00-03:00
        case 3: return .dan      // 03:00-05:00
        case 5: return .mao      // 05:00-07:00
        case 7: return .thin     // 07:00-09:00
        case 9: return .ty2      // 09:00-11:00
        case 11: return .ngo     // 11:00-13:00
        case 13: return .mui     // 13:00-15:00
        case 15: return .than    // 15:00-17:00
        case 17: return .dau     // 17:00-19:00
        case 19: return .tuat    // 19:00-21:00
        case 21: return .hoi     // 21:00-23:00
        default: return nil
        }
    }

    private func calculateChiName(for index: Int) -> String {
        guard let chi = ChiEnum(rawValue: index) else { return "Unknown" }
        return chi.vietnameseName
    }
}
