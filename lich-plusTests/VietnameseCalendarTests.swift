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

        // Test Case 3: November 15, 2025 - Thiên Lao Hắc Đạo
        // Reference: xemngay.com - CORRECTED LUNAR DATE
        // Solar: 15/11/2025
        // Lunar: 26/09 Ất Tỵ (CORRECTED from 17/09)
        // Trực: Trừ (very auspicious)
        // Unlucky Day: Thiên Lao (severity 4)
        // Quality: Bad (2.0 (tru) - 2.5 (thienlao) = -0.5)
        TestDate(
            name: "Nov 15, 2025 - Thiên Lao Hắc Đạo (severity 4)",
            solarDate: VietnameseCalendarTests.createDate(year: 2025, month: 11, day: 15),
            lunarDay: 26,
            lunarMonth: 9,
            lunarYear: 2025,
            expectedDayCanChi: "Mậu Tý",
            expectedDayChiIndex: 0,  // Tý
            expectedMonthCanChi: "Bính Tuất",
            expectedYearCanChi: "Ất Tỵ",
            expectedTruc: .tru,  // Trừ is very auspicious
            expectedUnluckyDay: "Thiên Lao",
            expectedFinalQuality: .bad,  // Score: 2.0 (tru) - 2.5 (thienlao) = -0.5 = bad
            expectedLuckyHourChis: [.ty, .suu, .mao, .ngo, .than, .dau]  // From xemngay.com
        ),

        // Test Case 4: November 20, 2025 - Câu Trần Hắc Đạo + Phá
        // Reference: xemngay.com
        // Solar: 20/11/2025
        // Lunar: 01/10 Ất Tỵ (new lunar month)
        // Trực: Phá (inauspicious)
        // Unlucky Day: Câu Trần (severity 3)
        // Quality: Bad (score -4.0)
        TestDate(
            name: "Nov 20, 2025 - Câu Trần Hắc Đạo (severity 3) + Phá",
            solarDate: VietnameseCalendarTests.createDate(year: 2025, month: 11, day: 20),
            lunarDay: 1,
            lunarMonth: 10,
            lunarYear: 2025,
            expectedDayCanChi: "Quý Tỵ",
            expectedDayChiIndex: 5,  // Tỵ
            expectedMonthCanChi: "Đinh Hợi",
            expectedYearCanChi: "Ất Tỵ",
            expectedTruc: .pha,  // Phá is inauspicious
            expectedUnluckyDay: "Câu Trần",  // Now correctly detected with the fix
            expectedFinalQuality: .bad,  // Score: -2.0 (pha) - 2.0 (cautran) = -4.0 = bad
            expectedLuckyHourChis: [.suu, .thin, .ngo, .mui, .tuat, .hoi]  // From xemngay.com
        ),

        // Test Case 5: December 1, 2025 - Chấp (Hoàng Đạo/Good Trực, no unlucky day)
        // Reference: xemngay.com - https://xemngay.com/Default.aspx?blog=xngay&d=01122025
        // Solar: 01/12/2025
        // Lunar: 12/10 Ất Tỵ
        // Trực: Chấp (Hoàng Đạo - Good per Lịch Vạn Niên 2005-2009, Page 48)
        // Unlucky Day: None
        // xemngay rating: [5/5] "Ngày hoàn hảo" (Perfect day)
        // Quality: Good (2.0 score from Chấp Hoàng Đạo, confirmed by xemngay [5/5])
        TestDate(
            name: "Dec 1, 2025 - Chấp (Hoàng Đạo, perfect day)",
            solarDate: VietnameseCalendarTests.createDate(year: 2025, month: 12, day: 1),
            lunarDay: 12,
            lunarMonth: 10,
            lunarYear: 2025,
            expectedDayCanChi: "Giáp Thìn",
            expectedDayChiIndex: 4,  // Thìn
            expectedMonthCanChi: "Đinh Hợi",
            expectedYearCanChi: "Ất Tỵ",
            expectedTruc: .chap,  // Chấp is Hoàng Đạo (Good)
            expectedUnluckyDay: nil,
            expectedFinalQuality: .good,  // Score: 2.0 (Chấp Hoàng Đạo) = good, xemngay [5/5]
            expectedLuckyHourChis: [.dan, .thin, .ty2, .than, .dau, .hoi]  // From xemngay.com
        ),

        // Test Case 6: November 3, 2025 - Mãn (Hắc Đạo) + Thiên Lao
        // Reference: xemngay.com - https://xemngay.com/Default.aspx?blog=xngay&d=03112025
        // Solar: 03/11/2025
        // Lunar: 14/09 Ất Tỵ
        // Trực: Mãn (Hắc Đạo per Lịch Vạn Niên 2005-2009, Page 48)
        // Unlucky Day: Thiên Lao (Month 9 + Chi Tý, severity 4)
        // xemngay rating: [3] "Khá tốt" - Rating doesn't always correlate with Lục Hắc Đạo
        // Quality: Bad (0.0 base from Mãn + -2.5 Thiên Lao = -2.5 = bad, severity >= 4 rule)
        TestDate(
            name: "Nov 3, 2025 - Mãn (Hắc Đạo) + Thiên Lao [severity 4]",
            solarDate: VietnameseCalendarTests.createDate(year: 2025, month: 11, day: 3),
            lunarDay: 14,
            lunarMonth: 9,
            lunarYear: 2025,
            expectedDayCanChi: "Bính Tý",
            expectedDayChiIndex: 0,  // Tý
            expectedMonthCanChi: "Bính Tuất",
            expectedYearCanChi: "Ất Tỵ",
            expectedTruc: .man,  // Mãn is Hắc Đạo
            expectedUnluckyDay: "Thiên Lao",  // Month 9 + Chi Tý (LucHacDaoCalculator.swift:120)
            expectedFinalQuality: .bad,  // Score: 0.0 (Mãn) - 2.5 (Thiên Lao severity 4) = bad
            expectedLuckyHourChis: [.ty, .suu, .mao, .ngo, .than, .dau]  // From xemngay.com
        ),

        // Test Case 7: November 28, 2025 - Mãn (Hắc Đạo) + Thiên Lao
        // Reference: xemngay.com - https://xemngay.com/Default.aspx?blog=xngay&d=28112025
        // Solar: 28/11/2025
        // Lunar: 09/10 Ất Tỵ
        // Trực: Mãn (Hắc Đạo per Lịch Vạn Niên 2005-2009, Page 48)
        // Unlucky Day: Thiên Lao (Month 10 + Chi Sửu, severity 4)
        // xemngay rating: [3] "Khá tốt" + Ngọc Đường - Rating doesn't correlate with Lục Hắc Đạo
        // Quality: Bad (0.0 base from Mãn + -2.5 Thiên Lao = -2.5 = bad, severity >= 4 rule)
        TestDate(
            name: "Nov 28, 2025 - Mãn (Hắc Đạo) + Thiên Lao [severity 4]",
            solarDate: VietnameseCalendarTests.createDate(year: 2025, month: 11, day: 28),
            lunarDay: 9,
            lunarMonth: 10,
            lunarYear: 2025,
            expectedDayCanChi: "Tân Sửu",
            expectedDayChiIndex: 1,  // Sửu
            expectedMonthCanChi: "Đinh Hợi",
            expectedYearCanChi: "Ất Tỵ",
            expectedTruc: .man,  // Mãn is Hắc Đạo
            expectedUnluckyDay: "Thiên Lao",  // Month 10 + Chi Sửu (LucHacDaoCalculator.swift:122-123)
            expectedFinalQuality: .bad,  // Score: 0.0 (Mãn) - 2.5 (Thiên Lao severity 4) = bad
            expectedLuckyHourChis: [.dan, .mao, .ty2, .than, .tuat, .hoi]  // [2, 3, 5, 8, 10, 11]
        ),

        // Test Case 8: December 8, 2025 - Bế (Close) + Bảo Quang Hoàng Đạo
        // Reference: xemngay.com - CORRECTED DAY CAN-CHI
        // Solar: 08/12/2025
        // Lunar: 19/10 Ất Tỵ
        // Trực: Bế (inauspicious)
        // Unlucky Day: None
        // Quality: Bad (rating 0.5 - very inauspicious)
        TestDate(
            name: "Dec 8, 2025 - Bế (Close) + Bảo Quang Hoàng Đạo (rating 0.5 - very inauspicious)",
            solarDate: VietnameseCalendarTests.createDate(year: 2025, month: 12, day: 8),
            lunarDay: 19,
            lunarMonth: 10,
            lunarYear: 2025,
            expectedDayCanChi: "Tân Hợi",
            expectedDayChiIndex: 11,  // Hợi (CORRECTED from Sửu)
            expectedMonthCanChi: "Đinh Hợi",
            expectedYearCanChi: "Ất Tỵ",
            expectedTruc: .be,  // Bế (inauspicious)
            expectedUnluckyDay: nil,
            expectedFinalQuality: .bad,  // Website rating 0.5
            expectedLuckyHourChis: [.suu, .thin, .ngo, .mui, .tuat, .hoi]  // [1, 4, 6, 7, 10, 11] - for Hợi day
        ),

        // Test Case 9: December 12, 2025 - Bình (Balance) + somewhat auspicious
        // Reference: xemlicham.com, licham.vn
        // Solar: 12/12/2025
        // Lunar: 23/10 Ất Tỵ
        // Trực: Bình (inauspicious in 3-tier, but website says somewhat auspicious)
        // Unlucky Day: None
        // Quality: Neutral (rating 2.5/5 = neutral)
        TestDate(
            name: "Dec 12, 2025 - Bình (Balance) (rating 2.5/5 - somewhat auspicious)",
            solarDate: VietnameseCalendarTests.createDate(year: 2025, month: 12, day: 12),
            lunarDay: 23,
            lunarMonth: 10,
            lunarYear: 2025,
            expectedDayCanChi: "Ất Mão",
            expectedDayChiIndex: 3,  // Mão
            expectedMonthCanChi: "Đinh Hợi",
            expectedYearCanChi: "Ất Tỵ",
            expectedTruc: .binh,  // Bình (inauspicious in 3-tier, but website says somewhat auspicious)
            expectedUnluckyDay: nil,
            expectedFinalQuality: .neutral,  // Website rating 2.5/5 = neutral
            expectedLuckyHourChis: [.ty, .dan, .mao, .ngo, .mui, .dau]  // [0, 2, 3, 6, 7, 9]
        ),

        // Test Case 10: December 15, 2025 - Phá (Break) + Thanh Long Hoàng Đạo
        // Reference: xemlicham.com, licham.vn
        // Solar: 15/12/2025
        // Lunar: 26/10 Ất Tỵ
        // Trực: Phá (inauspicious)
        // Unlucky Day: None
        // Quality: Bad (rating 1 - quite bad)
        TestDate(
            name: "Dec 15, 2025 - Phá (Break) + Thanh Long Hoàng Đạo (rating 1 - quite bad)",
            solarDate: VietnameseCalendarTests.createDate(year: 2025, month: 12, day: 15),
            lunarDay: 26,
            lunarMonth: 10,
            lunarYear: 2025,
            expectedDayCanChi: "Mậu Ngọ",
            expectedDayChiIndex: 6,  // Ngọ
            expectedMonthCanChi: "Đinh Hợi",
            expectedYearCanChi: "Ất Tỵ",
            expectedTruc: .pha,  // Phá (inauspicious)
            expectedUnluckyDay: nil,
            expectedFinalQuality: .bad,  // Website rating [1] = quite bad
            expectedLuckyHourChis: [.ty, .suu, .mao, .ngo, .than, .dau]  // [0, 1, 3, 6, 8, 9]
        ),

        // Test Case 11: January 1, 2026 - Bế (Close) + somewhat inauspicious
        // Reference: xemlicham.com, licham.vn
        // Solar: 01/01/2026
        // Lunar: 13/11 Ất Tỵ
        // Trực: Bế (inauspicious)
        // Unlucky Day: None
        // Quality: Bad (rating 1.5/10 - somewhat inauspicious)
        TestDate(
            name: "Jan 1, 2026 - Bế (Close) (rating 1.5/10 - somewhat inauspicious)",
            solarDate: VietnameseCalendarTests.createDate(year: 2026, month: 1, day: 1),
            lunarDay: 13,
            lunarMonth: 11,
            lunarYear: 2025,
            expectedDayCanChi: "Ất Hợi",
            expectedDayChiIndex: 11,  // Hợi
            expectedMonthCanChi: "Mậu Tý",
            expectedYearCanChi: "Ất Tỵ",
            expectedTruc: .be,  // Bế (inauspicious, but rating 1.5/10 vs Dec 8's 0.5)
            expectedUnluckyDay: nil,
            expectedFinalQuality: .bad,  // Website rating 1.5/10
            expectedLuckyHourChis: [.suu, .thin, .ngo, .mui, .tuat, .hoi]  // [1, 4, 6, 7, 10, 11]
        ),

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
            // Use the Chi-based calculation method (traditional Vietnamese astrology)
            let calculatedTruc = HoangDaoCalculator.calculateZodiacHourChiBased(
                solarDate: testCase.solarDate,
                lunarMonth: testCase.lunarMonth
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

                Calculation: Chi-based formula (dayChi - monthChi) % 12
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
                solarDate: testCase.solarDate,
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
