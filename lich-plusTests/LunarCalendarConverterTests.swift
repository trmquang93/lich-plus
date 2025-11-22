import XCTest
@testable import lich_plus

// MARK: - Lunar Calendar Converter Tests
final class LunarCalendarConverterTests: XCTestCase {

    // MARK: - Test Lunar Date Conversion
    func testSolarToLunarConversion() {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 2024
        components.month = 8
        components.day = 1

        let solarDate = calendar.date(from: components)!
        let lunarDate = LunarCalendarConverter.solarToLunar(date: solarDate)

        XCTAssertEqual(lunarDate.year, 2024)
    }

    // MARK: - Test Get Lunar Date
    func testGetLunarDate() {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 2024
        components.month = 8
        components.day = 15

        let solarDate = calendar.date(from: components)!
        let lunarDate = LunarCalendarConverter.getLunarDate(for: solarDate)

        XCTAssertEqual(lunarDate.year, 2024)
        XCTAssertGreaterThan(lunarDate.month, 0)
        XCTAssertGreaterThan(lunarDate.day, 0)
    }

    // MARK: - Test Lunar Date Info
    func testLunarDateInfo() {
        let lunarDate = LunarDateInfo(year: 2024, month: 6, day: 15)

        XCTAssertEqual(lunarDate.year, 2024)
        XCTAssertEqual(lunarDate.month, 6)
        XCTAssertEqual(lunarDate.day, 15)
        XCTAssertFalse(lunarDate.isLeapMonth)
    }

    // MARK: - Test Leap Month
    func testLeapMonth() {
        let lunarDate = LunarDateInfo(year: 2024, month: 6, day: 15, isLeapMonth: true)

        XCTAssertTrue(lunarDate.isLeapMonth)
    }

    // MARK: - Test Display String
    func testDisplayString() {
        let lunarDate = LunarDateInfo(year: 2024, month: 6, day: 15)
        let displayString = lunarDate.displayString

        XCTAssertTrue(displayString.contains("6"))
        XCTAssertTrue(displayString.contains("15"))
    }

    // MARK: - Test Leap Month Display String
    func testLeapMonthDisplayString() {
        let lunarDate = LunarDateInfo(year: 2024, month: 6, day: 15, isLeapMonth: true)
        let displayString = lunarDate.displayString

        XCTAssertTrue(displayString.contains("N6"))
    }

    // MARK: - Test Hashable
    func testLunarDateHashable() {
        let lunarDate1 = LunarDateInfo(year: 2024, month: 6, day: 15)
        let lunarDate2 = LunarDateInfo(year: 2024, month: 6, day: 15)
        let lunarDate3 = LunarDateInfo(year: 2024, month: 6, day: 16)

        XCTAssertEqual(lunarDate1, lunarDate2)
        XCTAssertNotEqual(lunarDate1, lunarDate3)
    }

    // MARK: - Test Codable
    func testLunarDateCodable() {
        let lunarDate = LunarDateInfo(year: 2024, month: 6, day: 15)

        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        do {
            let data = try encoder.encode(lunarDate)
            let decodedDate = try decoder.decode(LunarDateInfo.self, from: data)

            XCTAssertEqual(decodedDate.year, lunarDate.year)
            XCTAssertEqual(decodedDate.month, lunarDate.month)
            XCTAssertEqual(decodedDate.day, lunarDate.day)
        } catch {
            XCTFail("Failed to encode/decode: \(error)")
        }
    }

    // MARK: - Test Lunar to Solar Conversion
    /// Test verified Vietnamese lunar dates for accuracy
    func testLunarToSolarTet2024() {
        // Tết 2024 = Lunar 1/1/2024 = Solar Feb 10, 2024
        let date = LunarCalendarConverter.lunarToSolar(year: 2024, month: 1, day: 1)

        XCTAssertNotNil(date)

        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date!)

        XCTAssertEqual(components.year, 2024)
        XCTAssertEqual(components.month, 2)
        XCTAssertEqual(components.day, 10)
    }

    /// Test verified Vietnamese lunar dates for mid-autumn festival
    func testLunarToSolarMidAutumn2024() {
        // Rằm Tháng 8/2024 = Lunar 8/15/2024 = Solar Sep 18, 2024
        let date = LunarCalendarConverter.lunarToSolar(year: 2024, month: 8, day: 15)

        XCTAssertNotNil(date)

        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date!)

        XCTAssertEqual(components.year, 2024)
        XCTAssertEqual(components.month, 9)
        XCTAssertEqual(components.day, 18)
    }

    /// Test Tết 2025
    func testLunarToSolarTet2025() {
        // Tết 2025 = Lunar 1/1/2025 = Solar Jan 29, 2025
        let date = LunarCalendarConverter.lunarToSolar(year: 2025, month: 1, day: 1)

        XCTAssertNotNil(date)

        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date!)

        XCTAssertEqual(components.year, 2025)
        XCTAssertEqual(components.month, 1)
        XCTAssertEqual(components.day, 29)
    }

    /// Test Tết 2026
    func testLunarToSolarTet2026() {
        // Tết 2026 = Lunar 1/1/2026 = Solar Feb 17, 2026
        let date = LunarCalendarConverter.lunarToSolar(year: 2026, month: 1, day: 1)

        XCTAssertNotNil(date)

        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date!)

        XCTAssertEqual(components.year, 2026)
        XCTAssertEqual(components.month, 2)
        XCTAssertEqual(components.day, 17)
    }

    /// Test Tết 2027
    func testLunarToSolarTet2027() {
        // Tết 2027 = Lunar 1/1/2027 = Solar Feb 6, 2027
        let date = LunarCalendarConverter.lunarToSolar(year: 2027, month: 1, day: 1)

        XCTAssertNotNil(date)

        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date!)

        XCTAssertEqual(components.year, 2027)
        XCTAssertEqual(components.month, 2)
        XCTAssertEqual(components.day, 6)
    }

    /// Test Tết 2028
    func testLunarToSolarTet2028() {
        // Tết 2028 = Lunar 1/1/2028 = Solar Jan 26, 2028
        let date = LunarCalendarConverter.lunarToSolar(year: 2028, month: 1, day: 1)

        XCTAssertNotNil(date)

        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date!)

        XCTAssertEqual(components.year, 2028)
        XCTAssertEqual(components.month, 1)
        XCTAssertEqual(components.day, 26)
    }

    /// Test Tết 2029
    func testLunarToSolarTet2029() {
        // Tết 2029 = Lunar 1/1/2029 = Solar Feb 13, 2029
        let date = LunarCalendarConverter.lunarToSolar(year: 2029, month: 1, day: 1)

        XCTAssertNotNil(date)

        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date!)

        XCTAssertEqual(components.year, 2029)
        XCTAssertEqual(components.month, 2)
        XCTAssertEqual(components.day, 13)
    }

    /// Test mid-range dates for interpolation
    func testLunarToSolarMidMonth() {
        // Test a day in the middle of a month for interpolation accuracy
        let date = LunarCalendarConverter.lunarToSolar(year: 2024, month: 6, day: 8)

        XCTAssertNotNil(date)

        // Should be approximately 7 days after Lunar 6/1 (Solar July 7)
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date!)

        XCTAssertEqual(components.year, 2024)
        XCTAssertEqual(components.month, 7)
    }

    /// Test end of month dates
    func testLunarToSolarEndOfMonth() {
        // Test last day of a 30-day lunar month
        let date = LunarCalendarConverter.lunarToSolar(year: 2024, month: 1, day: 30)

        XCTAssertNotNil(date)

        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date!)

        XCTAssertEqual(components.year, 2024)
    }

    // MARK: - Test Leap Month Detection
    func testLeapMonthDetection2023() {
        // 2023 has leap month 2
        XCTAssertTrue(LunarCalendarConverter.isLeapMonth(year: 2023, month: 2))
        XCTAssertFalse(LunarCalendarConverter.isLeapMonth(year: 2023, month: 1))
        XCTAssertFalse(LunarCalendarConverter.isLeapMonth(year: 2023, month: 3))
    }

    func testLeapMonthDetection2024() {
        // 2024 has no leap month
        for month in 1...12 {
            XCTAssertFalse(LunarCalendarConverter.isLeapMonth(year: 2024, month: month))
        }
    }

    func testLeapMonthDetection2025() {
        // 2025 has leap month 6
        XCTAssertTrue(LunarCalendarConverter.isLeapMonth(year: 2025, month: 6))
        XCTAssertFalse(LunarCalendarConverter.isLeapMonth(year: 2025, month: 1))
        XCTAssertFalse(LunarCalendarConverter.isLeapMonth(year: 2025, month: 5))
        XCTAssertFalse(LunarCalendarConverter.isLeapMonth(year: 2025, month: 7))
    }

    func testLeapMonthDetection2028() {
        // 2028 has leap month 5
        XCTAssertTrue(LunarCalendarConverter.isLeapMonth(year: 2028, month: 5))
        XCTAssertFalse(LunarCalendarConverter.isLeapMonth(year: 2028, month: 4))
        XCTAssertFalse(LunarCalendarConverter.isLeapMonth(year: 2028, month: 6))
    }

    // MARK: - Test Leap Month Conversion
    func testLeapMonthConversion2025() {
        // Test leap month 6 in 2025
        let date = LunarCalendarConverter.lunarToSolar(
            year: 2025,
            month: 6,
            day: 1,
            isLeapMonth: true
        )

        XCTAssertNotNil(date)

        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date!)

        XCTAssertEqual(components.year, 2025)
        XCTAssertEqual(components.month, 6)
    }

    func testLeapMonthConversion2028() {
        // Test leap month 5 in 2028
        let date = LunarCalendarConverter.lunarToSolar(
            year: 2028,
            month: 5,
            day: 15,
            isLeapMonth: true
        )

        XCTAssertNotNil(date)

        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date!)

        XCTAssertEqual(components.year, 2028)
        XCTAssertEqual(components.month, 7)
    }

    // MARK: - Test Invalid Lunar Dates
    func testInvalidLunarYearOutOfRange() {
        // Year outside supported range should return nil
        let invalidYear1 = LunarCalendarConverter.lunarToSolar(year: 2023, month: 1, day: 1)
        XCTAssertNil(invalidYear1)

        let invalidYear2 = LunarCalendarConverter.lunarToSolar(year: 2030, month: 1, day: 1)
        XCTAssertNil(invalidYear2)
    }

    func testInvalidLunarMonth() {
        // Month 0 and month 13 (without leap) should return nil
        let invalidMonth1 = LunarCalendarConverter.lunarToSolar(year: 2024, month: 0, day: 1)
        XCTAssertNil(invalidMonth1)

        let invalidMonth2 = LunarCalendarConverter.lunarToSolar(year: 2024, month: 13, day: 1)
        XCTAssertNil(invalidMonth2)
    }

    func testInvalidLunarDay() {
        // Day 0 and day 31 should return nil
        let invalidDay1 = LunarCalendarConverter.lunarToSolar(year: 2024, month: 1, day: 0)
        XCTAssertNil(invalidDay1)

        let invalidDay2 = LunarCalendarConverter.lunarToSolar(year: 2024, month: 1, day: 31)
        XCTAssertNil(invalidDay2)
    }

    func testInvalidLeapMonthInNonLeapYear() {
        // Requesting leap month 6 in 2024 (non-leap year) should return nil
        let invalidLeapMonth = LunarCalendarConverter.lunarToSolar(
            year: 2024,
            month: 6,
            day: 15,
            isLeapMonth: true
        )
        XCTAssertNil(invalidLeapMonth)
    }

    func testInvalidDayInMonth() {
        // Some lunar months have only 29 days
        // Test with a 29-day month (month 2)
        let validDay29 = LunarCalendarConverter.lunarToSolar(year: 2024, month: 2, day: 29)
        // May or may not exist depending on that specific year, but 30 should be invalid

        let invalidDay30 = LunarCalendarConverter.lunarToSolar(year: 2024, month: 2, day: 30)
        XCTAssertNil(invalidDay30)
    }

    // MARK: - Test Edge Cases
    func testFirstDayOfYear() {
        // First day of lunar year should work
        let date = LunarCalendarConverter.lunarToSolar(year: 2024, month: 1, day: 1)
        XCTAssertNotNil(date)
    }

    func testLastDayOfYear() {
        // Last day of lunar year should work
        let date = LunarCalendarConverter.lunarToSolar(year: 2024, month: 12, day: 29)
        XCTAssertNotNil(date)
    }

    func testFullMoonDates() {
        // Full moon (15th day) dates should all work
        for month in 1...12 {
            let date = LunarCalendarConverter.lunarToSolar(year: 2024, month: month, day: 15)
            XCTAssertNotNil(date, "Full moon date 15/\(month)/2024 should be valid")
        }
    }

    func testAllMonthsOfYear() {
        // Test that we can convert dates from all 12 months
        for month in 1...12 {
            let date = LunarCalendarConverter.lunarToSolar(year: 2024, month: month, day: 1)
            XCTAssertNotNil(date, "Month \(month) should be convertible")
        }
    }

    // MARK: - Test Year Range Coverage
    func testSupportedYears() {
        // Test that all supported years work
        let years = [2024, 2025, 2026, 2027, 2028, 2029]

        for year in years {
            let date = LunarCalendarConverter.lunarToSolar(year: year, month: 1, day: 1)
            XCTAssertNotNil(date, "Year \(year) should be supported")
        }
    }

    // MARK: - Test Consistency
    func testConsistentResultsForSameLunarDate() {
        // Calling the same conversion multiple times should return the same result
        let date1 = LunarCalendarConverter.lunarToSolar(year: 2024, month: 6, day: 15)
        let date2 = LunarCalendarConverter.lunarToSolar(year: 2024, month: 6, day: 15)

        XCTAssertEqual(date1, date2)
    }

    func testLeapMonthConsistency() {
        // isLeapMonth should return consistent results
        let result1 = LunarCalendarConverter.isLeapMonth(year: 2025, month: 6)
        let result2 = LunarCalendarConverter.isLeapMonth(year: 2025, month: 6)

        XCTAssertEqual(result1, result2)
        XCTAssertTrue(result1)
    }
}
