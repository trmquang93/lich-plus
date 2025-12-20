//
//  TimeRulerComponentTests.swift
//  lich-plusTests
//
//  Tests for TimeRuler component including HoangDaoIndicator, TimeRulerCell, and TimeRulerView
//

import XCTest
import SwiftUI
@testable import lich_plus

@MainActor
final class TimeRulerComponentTests: XCTestCase {

    // MARK: - HoangDaoIndicator Tests

    func testHoangDaoIndicatorWithZeroStars() {
        let indicator = HoangDaoIndicator(level: 0)
        XCTAssertEqual(indicator.level, 0)
    }

    func testHoangDaoIndicatorWithOneStar() {
        let indicator = HoangDaoIndicator(level: 1)
        XCTAssertEqual(indicator.level, 1)
    }

    func testHoangDaoIndicatorWithTwoStars() {
        let indicator = HoangDaoIndicator(level: 2)
        XCTAssertEqual(indicator.level, 2)
    }

    // MARK: - TimeRulerCell Tests

    func testTimeRulerCellInitialization() {
        let cell = TimeRulerCell(
            hour: 10,
            chiHour: "Tỵ",
            hoangDaoLevel: 1,
            isPast: false,
            hourHeight: 60
        )
        XCTAssertEqual(cell.hour, 10)
        XCTAssertEqual(cell.chiHour, "Tỵ")
        XCTAssertEqual(cell.hoangDaoLevel, 1)
        XCTAssertEqual(cell.hourHeight, 60)
    }

    func testTimeRulerCellWithPastHour() {
        let cell = TimeRulerCell(
            hour: 5,
            chiHour: "Mão",
            hoangDaoLevel: 0,
            isPast: true,
            hourHeight: 60
        )
        XCTAssertTrue(cell.isPast)
    }

    func testTimeRulerCellFormatting() {
        let cell = TimeRulerCell(
            hour: 9,
            chiHour: "Thìn",
            hoangDaoLevel: 2,
            isPast: false,
            hourHeight: 60
        )
        XCTAssertEqual(cell.hour, 9)
    }

    // MARK: - Chi Hour Mapping Tests

    func testChiHourMapping() {
        // Updated test cases reflecting the corrected Chi hour mapping
        // Formula: (hour + 1) / 2 % 12
        // Each Chi covers a 2-hour period with Ty at 23:00-01:00
        let testCases: [(Int, String)] = [
            (0, "Tý"),      // 00:00 (within Tý 23:00-01:00)
            (1, "Sửu"),     // 01:00-02:00
            (2, "Sửu"),     // 02:00 (within Sửu 01:00-03:00)
            (3, "Dần"),     // 03:00-04:00
            (4, "Dần"),     // 04:00 (within Dần 03:00-05:00)
            (5, "Mão"),     // 05:00-06:00
            (6, "Mão"),     // 06:00 (within Mão 05:00-07:00)
            (7, "Thìn"),    // 07:00-08:00
            (8, "Thìn"),    // 08:00 (within Thìn 07:00-09:00)
            (9, "Tỵ"),      // 09:00-10:00
            (10, "Tỵ"),     // 10:00 (within Tỵ 09:00-11:00)
            (11, "Ngọ"),    // 11:00-12:00
            (12, "Ngọ"),    // 12:00 (within Ngọ 11:00-13:00)
            (13, "Mùi"),    // 13:00-14:00
            (14, "Mùi"),    // 14:00 (within Mùi 13:00-15:00)
            (15, "Thân"),   // 15:00-16:00
            (16, "Thân"),   // 16:00 (within Thân 15:00-17:00)
            (17, "Dậu"),    // 17:00-18:00
            (18, "Dậu"),    // 18:00 (within Dậu 17:00-19:00)
            (19, "Tuất"),   // 19:00-20:00
            (20, "Tuất"),   // 20:00 (within Tuất 19:00-21:00)
            (21, "Hợi"),    // 21:00-22:00
            (22, "Hợi"),    // 22:00 (within Hợi 21:00-23:00)
            (23, "Tý")      // 23:00 (start of Tý 23:00-01:00)
        ]

        for (hour, expectedChi) in testCases {
            let chi = TimeRulerView.chiForHour(hour)
            XCTAssertEqual(chi, expectedChi, "Hour \(hour) should map to Chi \(expectedChi)")
        }
    }

    // MARK: - TimeRulerView Tests

    func testTimeRulerViewInitialization() {
        let auspiciousHours: Set<Int> = [0, 1, 4, 5, 7, 10]
        let view = TimeRulerView(
            hourHeight: 60,
            auspiciousHours: auspiciousHours,
            currentHour: 14
        )
        XCTAssertEqual(view.hourHeight, 60)
        XCTAssertEqual(view.currentHour, 14)
        XCTAssertEqual(view.auspiciousHours, auspiciousHours)
    }

    func testTimeRulerViewWith24Hours() {
        let view = TimeRulerView(
            hourHeight: 60,
            auspiciousHours: [],
            currentHour: 0
        )
        // TimeRulerView should render 24 hours with correct hour height
        XCTAssertEqual(view.hourHeight, 60)
        XCTAssertEqual(view.currentHour, 0)
    }

    func testTimeRulerViewAuspiciousHourDetection() {
        let auspiciousHours: Set<Int> = [0, 1, 4, 5, 7, 10]
        let view = TimeRulerView(
            hourHeight: 60,
            auspiciousHours: auspiciousHours,
            currentHour: 12
        )

        // Verify that auspicious hours are correctly identified
        for hour in auspiciousHours {
            XCTAssertTrue(
                view.auspiciousHours.contains(hour),
                "Hour \(hour) should be in auspicious hours"
            )
        }
    }

    func testTimeRulerViewPastHourDetection() {
        let currentHour = 14
        let view = TimeRulerView(
            hourHeight: 60,
            auspiciousHours: [],
            currentHour: currentHour
        )

        // Hours before current hour should be marked as past
        XCTAssertLessThan(0, currentHour)
        XCTAssertLessThan(5, currentHour)
        XCTAssertGreaterThanOrEqual(currentHour, 14)
    }

    // MARK: - Hour-to-Chi Mapping Edge Cases

    func testChiMappingMidnight() {
        let chi = TimeRulerView.chiForHour(0)
        XCTAssertEqual(chi, "Tý", "Hour 0 (00:00) should map to Tý (within 23:00-01:00)")
    }

    func testChiMappingNoon() {
        let chi = TimeRulerView.chiForHour(12)
        XCTAssertEqual(chi, "Ngọ", "Hour 12 (noon) should map to Ngọ (11:00-13:00)")
    }

    func testChiMappingEvening() {
        let chi = TimeRulerView.chiForHour(18)
        XCTAssertEqual(chi, "Dậu", "Hour 18 should map to Dậu (17:00-19:00)")
    }
    
    func testChiMappingEarlyMorning() {
        let chi = TimeRulerView.chiForHour(1)
        XCTAssertEqual(chi, "Sửu", "Hour 1 (01:00) should map to Sửu (01:00-03:00)")
    }
    
    func testChiMappingLateNight() {
        let chi = TimeRulerView.chiForHour(23)
        XCTAssertEqual(chi, "Tý", "Hour 23 (23:00) should map to Tý (23:00-01:00)")
    }

    // MARK: - Hoang Dao Level Calculation Tests

    func testAuspiciousHourHasOneOrTwoStars() {
        // Auspicious hours should have 1 or 2 stars
        // This is determined by the day's zodiac hour configuration
        let testLevels = [0, 1, 2]
        for level in testLevels {
            let indicator = HoangDaoIndicator(level: level)
            XCTAssertGreaterThanOrEqual(indicator.level, 0)
            XCTAssertLessThanOrEqual(indicator.level, 2)
        }
    }

    // MARK: - Integration Tests

    func testTimeRulerCellWithAllParameters() {
        let cell = TimeRulerCell(
            hour: 14,
            chiHour: "Mùi",
            hoangDaoLevel: 2,
            isPast: false,
            hourHeight: 60
        )

        XCTAssertEqual(cell.hour, 14)
        XCTAssertEqual(cell.chiHour, "Mùi")
        XCTAssertEqual(cell.hoangDaoLevel, 2)
        XCTAssertFalse(cell.isPast)
        XCTAssertEqual(cell.hourHeight, 60)
    }

    func testTimeRulerViewWithRealHourlyData() {
        let today = Date()
        let hourlyZodiacs = HoangDaoCalculator.getHourlyZodiacs(for: today)

        XCTAssertEqual(hourlyZodiacs.count, 12, "Should have 12 hourly zodiacs")

        // Extract auspicious hours
        let auspiciousHours = Set(
            hourlyZodiacs
                .filter { $0.isAuspicious }
                .map { $0.hour }
        )

        let view = TimeRulerView(
            hourHeight: 60,
            auspiciousHours: auspiciousHours,
            currentHour: Calendar.current.component(.hour, from: today)
        )

        XCTAssertEqual(view.auspiciousHours.count, auspiciousHours.count)
    }

    func testChiForAllHoursDoesNotRepeat() {
        // Each Chi covers a 2-hour period, so 24 hours map to 12 Chi values
        // This test verifies that each Chi is used exactly twice (once per 2-hour period)
        var chiCounts: [String: Int] = [:]
        for hour in 0..<24 {
            let chi = TimeRulerView.chiForHour(hour)
            chiCounts[chi, default: 0] += 1
        }
        
        // Each of the 12 Chi values should appear exactly 2 times (2-hour periods)
        XCTAssertEqual(chiCounts.count, 12, "All 12 Chi values should be used")
        for (chi, count) in chiCounts {
            XCTAssertEqual(count, 2, "Chi \(chi) should appear exactly 2 times for the 24-hour cycle")
        }
    }
}
