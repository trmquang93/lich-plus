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
}
