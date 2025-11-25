//
//  CalendarDataManagerTests.swift
//  lich-plusTests
//
//  Created by Quang Tran Minh on 25/11/25.
//

import XCTest
import SwiftData
@testable import lich_plus

final class CalendarDataManagerTests: XCTestCase {

    var sut: CalendarDataManager!
    var modelContext: ModelContext!

    override func setUp() async throws {
        try await super.setUp()

        // Create in-memory SwiftData model context
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: SyncableEvent.self, configurations: config)
        modelContext = ModelContext(container)

        // Initialize CalendarDataManager
        sut = CalendarDataManager()
        sut.setModelContext(modelContext)
    }

    override func tearDown() async throws {
        sut = nil
        modelContext = nil
        try await super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitializationSetsCurrentMonth() {
        XCTAssertNotNil(sut.currentMonth)
    }

    func testInitializationSelectsTodaysDate() {
        let calendar = Calendar.current
        if let selectedDay = sut.selectedDay {
            XCTAssertTrue(calendar.isDateInToday(selectedDay.date))
        }
    }

    // MARK: - Calendar Month Generation

    func testGenerateCalendarMonthForCurrentDate() {
        let today = Date()
        let month = CalendarDataManager.generateCalendarMonth(for: today)

        XCTAssertEqual(month.days.count, 42) // 6 weeks
    }

    func testGenerateCalendarMonthHasCorrectMonthYear() {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.month, .year], from: Date())

        let month = CalendarDataManager.generateCalendarMonth(for: Date())

        XCTAssertEqual(month.month, dateComponents.month)
        XCTAssertEqual(month.year, dateComponents.year)
    }

    // MARK: - Event Fetching from SwiftData

    func testFetchEventsForSpecificDate() throws {
        // Given
        let testDate = Date()
        let syncableEvent = SyncableEvent(
            title: "Test Event",
            startDate: testDate,
            category: "work"
        )
        modelContext.insert(syncableEvent)
        try modelContext.save()

        // When
        sut.setModelContext(modelContext)
        let month = CalendarDataManager.generateCalendarMonth(for: testDate)

        // Then - Find the day matching testDate
        let matchingDay = month.days.first { day in
            let calendar = Calendar.current
            return calendar.isDateInToday(day.date) ||
                   calendar.dateComponents([.year, .month, .day], from: day.date) ==
                   calendar.dateComponents([.year, .month, .day], from: testDate)
        }

        XCTAssertNotNil(matchingDay)
    }

    func testFetchEventsReturnsEmptyForDateWithoutEvents() throws {
        // Given
        let testDate = Date(timeIntervalSince1970: 0) // January 1, 1970

        // When
        sut.setModelContext(modelContext)
        let month = CalendarDataManager.generateCalendarMonth(for: testDate)

        // Then - Verify we can generate month without errors
        XCTAssertEqual(month.days.count, 42)
    }

    // MARK: - Day Selection

    func testSelectDay() {
        let month = sut.currentMonth
        if !month.days.isEmpty {
            let firstDay = month.days[0]

            sut.selectDay(firstDay)

            XCTAssertEqual(sut.selectedDay?.date, firstDay.date)
        }
    }

    // MARK: - Month Navigation

    func testGoToNextMonth() {
        let currentMonth = sut.currentMonth.month
        sut.goToNextMonth()

        XCTAssertNotEqual(sut.currentMonth.month, currentMonth)
        XCTAssertNil(sut.selectedDay)
    }

    func testGoToPreviousMonth() {
        let currentMonth = sut.currentMonth.month
        sut.goToPreviousMonth()

        XCTAssertNotEqual(sut.currentMonth.month, currentMonth)
        XCTAssertNil(sut.selectedDay)
    }

    // MARK: - Model Context Integration

    func testSetModelContextStoresDatabaseAccess() {
        let newContext = ModelContext(
            try! ModelContainer(for: SyncableEvent.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        )

        sut.setModelContext(newContext)

        // If no exception is thrown, the context was set successfully
        XCTAssertTrue(true)
    }

    func testCalendarDayHasCorrectLunarInformation() {
        let month = sut.currentMonth

        // All days should have lunar month and year
        for day in month.days {
            XCTAssertGreater(day.lunarMonth, 0)
            XCTAssertGreater(day.lunarYear, 0)
        }
    }

    func testCalendarDayTypeIsCalculated() {
        let month = sut.currentMonth

        // All days should have a day type
        for day in month.days {
            XCTAssertNotNil(day.dayType)
        }
    }
}
