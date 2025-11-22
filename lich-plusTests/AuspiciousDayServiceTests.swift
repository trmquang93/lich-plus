import XCTest
@testable import lich_plus

// MARK: - Auspicious Day Service Tests
final class AuspiciousDayServiceTests: XCTestCase {

    var service: AuspiciousDayServiceProtocol!

    override func setUp() {
        super.setUp()
        // Reset factory to default before each test
        AuspiciousDayServiceFactory.resetToDefault()
        service = StaticAuspiciousDayService()
    }

    override func tearDown() {
        service = nil
        // Reset factory after each test to avoid state leakage
        AuspiciousDayServiceFactory.resetToDefault()
        super.tearDown()
    }

    // MARK: - Auspicious Day Detection Tests

    func testAuspiciousDayDetection() {
        // Test that lunar days 1, 15, 16 return .auspicious type

        // August 1, 2024 = Lunar 6/16 (auspicious)
        let date1 = createDate(year: 2024, month: 8, day: 1)
        let info1 = service.getAuspiciousInfo(for: date1)
        XCTAssertEqual(info1.type, .auspicious, "Lunar day 16 should be auspicious")
        XCTAssertNotNil(info1.reason, "Auspicious day should have a reason")

        // August 16, 2024 = Lunar 7/1 (auspicious - mùng 1)
        let date2 = createDate(year: 2024, month: 8, day: 16)
        let info2 = service.getAuspiciousInfo(for: date2)
        XCTAssertEqual(info2.type, .auspicious, "Lunar day 1 (mùng 1) should be auspicious")
        XCTAssertNotNil(info2.reason, "Auspicious day should have a reason")

        // August 30, 2024 = Lunar 7/15 (auspicious)
        let date3 = createDate(year: 2024, month: 8, day: 30)
        let info3 = service.getAuspiciousInfo(for: date3)
        XCTAssertEqual(info3.type, .auspicious, "Lunar day 15 should be auspicious")
        XCTAssertNotNil(info3.reason, "Auspicious day should have a reason")
    }

    // MARK: - Inauspicious Day Detection Tests

    func testInauspiciousDayDetection() {
        // Test that lunar days 7, 14, 23 return .inauspicious type
        // Using August 2024 dates: Aug 1 = Lunar 6/16
        // So: Lunar day N = Aug (N - 15) for days 16-30, Aug (N + 15) for days 1-15 of lunar month 7

        // August 22, 2024 = Lunar 7/7 (22 + 15 = 37, 37 - 30 = 7) - inauspicious
        let date1 = createDate(year: 2024, month: 8, day: 22)
        let info1 = service.getAuspiciousInfo(for: date1)
        XCTAssertEqual(info1.type, .inauspicious, "Lunar day 7 should be inauspicious")
        XCTAssertNotNil(info1.reason, "Inauspicious day should have a reason")

        // August 29, 2024 = Lunar 7/14 (29 + 15 = 44, 44 - 30 = 14) - inauspicious
        let date2 = createDate(year: 2024, month: 8, day: 29)
        let info2 = service.getAuspiciousInfo(for: date2)
        XCTAssertEqual(info2.type, .inauspicious, "Lunar day 14 should be inauspicious")
        XCTAssertNotNil(info2.reason, "Inauspicious day should have a reason")

        // For lunar day 23, we need Aug (23 + 15) = Aug 38 which is out of range
        // So we test with a date that maps to lunar 23 using the general converter
        // Or we can test August 7, 2024 which should map to lunar 6/22 (neutral)
        // Instead, let's test August 8 which should be lunar 6/23
        let date3 = createDate(year: 2024, month: 8, day: 8)
        let info3 = service.getAuspiciousInfo(for: date3)
        // August 8 = Lunar 6/23 (8 + 15 = 23)
        XCTAssertEqual(info3.type, .inauspicious, "Lunar day 23 should be inauspicious")
        XCTAssertNotNil(info3.reason, "Inauspicious day should have a reason")
    }

    // MARK: - Neutral Day Detection Tests

    func testNeutralDayDetection() {
        // Test that other days (e.g., 2, 8, 10) return .neutral type

        // August 17, 2024 = Lunar 7/2 (neutral)
        let date1 = createDate(year: 2024, month: 8, day: 17)
        let info1 = service.getAuspiciousInfo(for: date1)
        XCTAssertEqual(info1.type, .neutral, "Lunar day 2 should be neutral")

        // August 23, 2024 = Lunar 7/8 (neutral)
        let date2 = createDate(year: 2024, month: 8, day: 23)
        let info2 = service.getAuspiciousInfo(for: date2)
        XCTAssertEqual(info2.type, .neutral, "Lunar day 8 should be neutral")

        // August 25, 2024 = Lunar 7/10 (neutral)
        let date3 = createDate(year: 2024, month: 8, day: 25)
        let info3 = service.getAuspiciousInfo(for: date3)
        XCTAssertEqual(info3.type, .neutral, "Lunar day 10 should be neutral")
    }

    // MARK: - Service Factory Tests

    func testServiceSwapping() {
        // Test that the factory can swap services

        // Test date for verification
        let testDate = createDate(year: 2024, month: 8, day: 1)

        // First, verify default service works
        let defaultInfo = AuspiciousDayServiceFactory.shared.getAuspiciousInfo(for: testDate)
        // August 1, 2024 = Lunar 6/16 (auspicious)
        XCTAssertEqual(defaultInfo.type, .auspicious, "Default service should return auspicious for lunar day 16")

        // Create and set mock service
        let mockService = MockAuspiciousDayService()
        AuspiciousDayServiceFactory.setService(mockService)

        // Verify that the mock service is now being used
        let mockInfo = AuspiciousDayServiceFactory.shared.getAuspiciousInfo(for: testDate)
        XCTAssertEqual(mockInfo.type, .neutral, "Factory should return mock service result type")
        XCTAssertEqual(mockInfo.reason, "Mock service", "Factory should return mock service reason")

        // Reset to default service
        AuspiciousDayServiceFactory.resetToDefault()

        // Verify the default service is restored
        let restoredInfo = AuspiciousDayServiceFactory.shared.getAuspiciousInfo(for: testDate)
        XCTAssertEqual(restoredInfo.type, .auspicious, "Factory should restore default service")
    }

    // MARK: - Helper Methods

    private func createDate(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = 12
        components.minute = 0
        components.second = 0

        let calendar = Calendar.current
        return calendar.date(from: components) ?? Date()
    }
}

// MARK: - Mock Service for Testing

class MockAuspiciousDayService: AuspiciousDayServiceProtocol {
    func getAuspiciousInfo(for date: Date) -> AuspiciousDayInfo {
        return AuspiciousDayInfo(type: .neutral, reason: "Mock service")
    }
}
