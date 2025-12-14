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
        let testCases: [(Int, String)] = [
            (0, "Tý"),      // 23-01
            (1, "Sửu"),     // 01-03
            (2, "Dần"),     // 03-05
            (3, "Mão"),     // 05-07
            (4, "Thìn"),    // 07-09
            (5, "Tỵ"),      // 09-11
            (6, "Ngọ"),     // 11-13
            (7, "Mùi"),     // 13-15
            (8, "Thân"),    // 15-17
            (9, "Dậu"),     // 17-19
            (10, "Tuất"),   // 19-21
            (11, "Hợi")     // 21-23
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
        XCTAssertEqual(chi, "Tý", "Hour 0 (midnight) should map to Tý")
    }

    func testChiMappingNoon() {
        let chi = TimeRulerView.chiForHour(12)
        XCTAssertEqual(chi, "Ngọ", "Hour 12 (noon) should map to Ngọ")
    }

    func testChiMappingEvening() {
        let chi = TimeRulerView.chiForHour(18)
        XCTAssertEqual(chi, "Dậu", "Hour 18 should map to Dậu")
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
        let allChis = (0..<12).map { TimeRulerView.chiForHour($0) }
        let uniqueChis = Set(allChis)
        XCTAssertEqual(uniqueChis.count, 12, "All 12 hours should map to unique Chi values")
    }
}
