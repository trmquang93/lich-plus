import XCTest
@testable import lich_plus

// MARK: - Can Chi Calculator Tests
final class CanChiCalculatorTests: XCTestCase {

    // MARK: - Test Can Chi for Known Date
    func testCanChiForKnownDate() {
        // January 1, 2000 should be Giáp Tý (JDN = 2451545.0)
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 2000
        components.month = 1
        components.day = 1
        components.hour = 12

        guard let date = calendar.date(from: components) else {
            XCTFail("Failed to create date")
            return
        }

        let canChi = CanChiCalculator.calculateCanChi(for: date)

        XCTAssertEqual(canChi.can, "Giáp", "Expected Can to be Giáp")
        XCTAssertEqual(canChi.chi, "Tý", "Expected Chi to be Tý")
        XCTAssertEqual(canChi.displayName, "Giáp Tý", "Expected display name to be Giáp Tý")
    }

    // MARK: - Test 60-Day Cycle
    func testCanChi60DayCycle() {
        // Can Chi repeats every 60 days (10 Can × 6 = 60, 12 Chi × 5 = 60)
        let calendar = Calendar.current

        // Date 1: January 1, 2000
        var components1 = DateComponents()
        components1.year = 2000
        components1.month = 1
        components1.day = 1
        components1.hour = 12

        guard let date1 = calendar.date(from: components1) else {
            XCTFail("Failed to create date1")
            return
        }

        // Date 2: 60 days later (March 1, 2000)
        guard let date2 = calendar.date(byAdding: .day, value: 60, to: date1) else {
            XCTFail("Failed to create date2")
            return
        }

        let canChi1 = CanChiCalculator.calculateCanChi(for: date1)
        let canChi2 = CanChiCalculator.calculateCanChi(for: date2)

        XCTAssertEqual(canChi1.displayName, canChi2.displayName, "Can Chi should repeat after 60 days")
        XCTAssertEqual(canChi1.can, canChi2.can, "Can should be the same after 60 days")
        XCTAssertEqual(canChi1.chi, canChi2.chi, "Chi should be the same after 60 days")
    }

    // MARK: - Test Array Bounds
    func testCanChiArrayBounds() {
        // Test multiple dates to ensure no index out of bounds
        let calendar = Calendar.current
        let testYears = [1990, 2000, 2010, 2020, 2030]

        for year in testYears {
            for month in 1...12 {
                var components = DateComponents()
                components.year = year
                components.month = month
                components.day = 15
                components.hour = 12

                guard let date = calendar.date(from: components) else {
                    XCTFail("Failed to create date for \(year)/\(month)")
                    continue
                }

                let canChi = CanChiCalculator.calculateCanChi(for: date)

                XCTAssertFalse(canChi.displayName.isEmpty, "Display name should not be empty for \(year)/\(month)")
                XCTAssertFalse(canChi.can.isEmpty, "Can should not be empty for \(year)/\(month)")
                XCTAssertFalse(canChi.chi.isEmpty, "Chi should not be empty for \(year)/\(month)")
            }
        }
    }

    // MARK: - Test JDN Conversion
    func testJDNConversion() {
        // Test dateToJDN conversion accuracy
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 2000
        components.month = 1
        components.day = 1
        components.hour = 12

        guard let date = calendar.date(from: components) else {
            XCTFail("Failed to create date")
            return
        }

        let jdn = LunarCalendarConverter.dateToJDN(date)

        // January 1, 2000 at noon should be approximately JDN 2451545.0
        // Allow for some tolerance due to time zone and hour differences
        XCTAssertEqual(jdn, 2451545.0, accuracy: 1.0, "JDN should be approximately 2451545.0 for January 1, 2000")
    }
}
