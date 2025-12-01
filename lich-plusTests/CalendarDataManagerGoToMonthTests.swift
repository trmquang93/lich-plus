//
//  CalendarDataManagerGoToMonthTests.swift
//  lich-plusTests
//
//  Created by Quang Tran Minh on 27/11/25.
//

import XCTest
@testable import lich_plus

class CalendarDataManagerGoToMonthTests: XCTestCase {

    var manager: CalendarDataManager!

    override func setUp() {
        super.setUp()
        manager = CalendarDataManager()
        // Initialize calendar with current month to populate days array
        let components = Calendar.current.dateComponents([.month, .year], from: Date())
        manager.goToMonth(components.month ?? 1, year: components.year ?? 2025)
    }

    override func tearDown() {
        manager = nil
        super.tearDown()
    }

    func testGoToMonthUpdatesCurrentMonth() {
        manager.goToMonth(3, year: 2025)

        XCTAssertEqual(manager.currentMonth.month, 3)
        XCTAssertEqual(manager.currentMonth.year, 2025)
    }

    func testGoToMonthPreservesSelectedDate() {
        // First select a day
        guard let firstDay = manager.currentMonth.days.first(where: { $0.isCurrentMonth }) else {
            XCTFail("No day with isCurrentMonth found")
            return
        }
        manager.selectDay(firstDay)

        let selectedDateBeforeNavigation = manager.selectedDate

        // Then go to a different month
        manager.goToMonth(6, year: 2025)

        // Selected date should persist after month navigation
        XCTAssertEqual(manager.selectedDate, selectedDateBeforeNavigation)
    }

    func testGoToMonthGeneratesValidCalendar() {
        manager.goToMonth(5, year: 2025)

        let calendar = manager.currentMonth
        XCTAssertEqual(calendar.month, 5)
        XCTAssertEqual(calendar.year, 2025)
        XCTAssertGreaterThan(calendar.days.count, 0)
        XCTAssertEqual(calendar.days.count, 42) // 6 weeks * 7 days
    }

    func testGoToMonthWithValidate() {
        let validMonths = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]

        for month in validMonths {
            manager.goToMonth(month, year: 2025)
            XCTAssertEqual(manager.currentMonth.month, month)
        }
    }

    func testGoToMonthWithDifferentYears() {
        let testYears = [2000, 2010, 2020, 2025, 2030, 2099]

        for year in testYears {
            manager.goToMonth(6, year: year)
            XCTAssertEqual(manager.currentMonth.year, year)
        }
    }

    func testGoToMonthCalculatesLunarDates() {
        manager.goToMonth(1, year: 2025)

        let calendar = manager.currentMonth
        XCTAssertGreaterThan(calendar.lunarMonth, 0)
        XCTAssertGreaterThan(calendar.lunarYear, 0)
    }

    func testGoToMonthMultipleCallsSequential() {
        manager.goToMonth(1, year: 2025)
        XCTAssertEqual(manager.currentMonth.month, 1)

        manager.goToMonth(6, year: 2025)
        XCTAssertEqual(manager.currentMonth.month, 6)

        manager.goToMonth(12, year: 2024)
        XCTAssertEqual(manager.currentMonth.month, 12)
        XCTAssertEqual(manager.currentMonth.year, 2024)
    }

    func testGoToMonthPreservesCalendarProperties() {
        manager.goToMonth(7, year: 2025)

        let calendar = manager.currentMonth
        XCTAssertNotNil(calendar.days)
        XCTAssertTrue(calendar.days.count > 0)

        // Verify all days have proper initialization
        for day in calendar.days {
            XCTAssertNotNil(day.date)
            XCTAssertGreaterThanOrEqual(day.solarDay, 0)
            XCTAssertGreaterThanOrEqual(day.solarMonth, 0)
        }
    }

    func testGoToMonthHandlesYearTransition() {
        manager.goToMonth(12, year: 2024)
        XCTAssertEqual(manager.currentMonth.year, 2024)

        manager.goToMonth(1, year: 2025)
        XCTAssertEqual(manager.currentMonth.year, 2025)
    }
}
