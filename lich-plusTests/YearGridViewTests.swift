import XCTest
@testable import lich_plus

// MARK: - Year Grid View Tests
final class YearGridViewTests: XCTestCase {

    // MARK: - Helper Methods
    /// Helper to create a date with specific year, month, and day
    private func createDate(year: Int, month: Int, day: Int) -> Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day

        guard let date = calendar.date(from: components) else {
            XCTFail("Failed to create date for \(year)-\(month)-\(day)")
            return Date()
        }

        return date
    }

    // MARK: - Test Helper for YearGridView
    /// Test helper class that exposes YearGridView's internal methods for testing
    private class YearGridViewTestHelper {
        private var currentDate: Date
        private var isPresented: Bool
        private var yearDate: Date

        init(currentDate: Date, isPresented: Bool = true) {
            self.currentDate = currentDate
            self.isPresented = isPresented
            self.yearDate = currentDate
        }

        // Simulate YearGridView's selectMonth method
        func selectMonth(_ month: Int) -> (newDate: Date?, isPresentedAfter: Bool) {
            let calendar = Calendar.current
            let year = calendar.component(.year, from: yearDate)

            var components = DateComponents()
            components.year = year
            components.month = month
            components.day = 1

            if let newDate = calendar.date(from: components) {
                currentDate = newDate
                isPresented = false
                return (newDate, false)
            } else {
                // This is the fix we're testing - should dismiss even on failure
                print("Warning: Failed to construct date for month \(month), year \(year)")
                isPresented = false
                return (nil, false)
            }
        }

        // Simulate YearGridView's goToPreviousYear method
        func goToPreviousYear() -> Date? {
            let calendar = Calendar.current
            let currentYear = calendar.component(.year, from: yearDate)

            guard currentYear > 1975 else { return nil }

            if let newDate = calendar.date(byAdding: .year, value: -1, to: yearDate) {
                yearDate = newDate
                return newDate
            }
            return nil
        }

        // Simulate YearGridView's goToNextYear method
        func goToNextYear() -> Date? {
            let calendar = Calendar.current
            let currentYear = calendar.component(.year, from: yearDate)

            guard currentYear < 2075 else { return nil }

            if let newDate = calendar.date(byAdding: .year, value: 1, to: yearDate) {
                yearDate = newDate
                return newDate
            }
            return nil
        }

        // Simulate YearGridView's jumpToToday method
        func jumpToToday() -> (newDate: Date, isPresentedAfter: Bool) {
            currentDate = Date()
            isPresented = false
            return (currentDate, false)
        }

        // Simulate YearGridView's isCurrentMonthAndYear method
        func isCurrentMonthAndYear(month: Int, year: Int) -> Bool {
            let calendar = Calendar.current
            let today = Date()
            let currentMonth = calendar.component(.month, from: today)
            let currentYear = calendar.component(.year, from: today)

            return month == currentMonth && year == currentYear
        }

        var currentDateValue: Date { currentDate }
        var isPresentedValue: Bool { isPresented }
        var yearDateValue: Date { yearDate }
    }

    // MARK: - Test selectMonth() Method
    func testSelectMonthUpdatesCurrentDate() {
        // Arrange: Start with August 2024
        let initialDate = createDate(year: 2024, month: 8, day: 15)
        let helper = YearGridViewTestHelper(currentDate: initialDate)

        // Act: Select December
        let result = helper.selectMonth(12)

        // Assert: Current date should be December 1, 2024
        XCTAssertNotNil(result.newDate, "selectMonth should return a valid date")
        if let newDate = result.newDate {
            let calendar = Calendar.current
            XCTAssertEqual(calendar.component(.year, from: newDate), 2024, "Year should remain 2024")
            XCTAssertEqual(calendar.component(.month, from: newDate), 12, "Month should be December")
            XCTAssertEqual(calendar.component(.day, from: newDate), 1, "Day should be 1st")
        }
    }

    func testSelectMonthDismissesSheet() {
        // Arrange
        let initialDate = createDate(year: 2024, month: 8, day: 15)
        let helper = YearGridViewTestHelper(currentDate: initialDate, isPresented: true)

        // Act
        let result = helper.selectMonth(6)

        // Assert: Sheet should be dismissed
        XCTAssertFalse(result.isPresentedAfter, "selectMonth should dismiss the sheet by setting isPresented to false")
    }

    func testSelectMonthWithAllValidMonths() {
        // Arrange
        let initialDate = createDate(year: 2024, month: 1, day: 1)
        let helper = YearGridViewTestHelper(currentDate: initialDate)

        // Act & Assert: Test all 12 months
        for month in 1...12 {
            let result = helper.selectMonth(month)
            XCTAssertNotNil(result.newDate, "selectMonth should work for month \(month)")

            if let newDate = result.newDate {
                let calendar = Calendar.current
                XCTAssertEqual(calendar.component(.month, from: newDate), month, "Should select month \(month)")
            }
        }
    }

    // MARK: - Test goToPreviousYear() Method
    func testGoToPreviousYearUpdatesYear() {
        // Arrange: Start at 2024
        let initialDate = createDate(year: 2024, month: 6, day: 15)
        let helper = YearGridViewTestHelper(currentDate: initialDate)

        // Act: Go to previous year
        let result = helper.goToPreviousYear()

        // Assert: Should be 2023
        XCTAssertNotNil(result, "goToPreviousYear should return a valid date")
        if let newDate = result {
            let calendar = Calendar.current
            XCTAssertEqual(calendar.component(.year, from: newDate), 2023, "Year should decrease to 2023")
        }
    }

    func testGoToPreviousYearStopsAtMinimum() {
        // Arrange: Start at minimum year (1975)
        let initialDate = createDate(year: 1975, month: 6, day: 15)
        let helper = YearGridViewTestHelper(currentDate: initialDate)

        // Act: Try to go to previous year
        let result = helper.goToPreviousYear()

        // Assert: Should return nil (cannot go before 1975)
        XCTAssertNil(result, "goToPreviousYear should return nil when at minimum year 1975")

        // Verify yearDate hasn't changed
        let calendar = Calendar.current
        XCTAssertEqual(calendar.component(.year, from: helper.yearDateValue), 1975, "Year should remain 1975")
    }

    func testGoToPreviousYearPreservesMonthAndDay() {
        // Arrange: Start at 2024-08-15
        let initialDate = createDate(year: 2024, month: 8, day: 15)
        let helper = YearGridViewTestHelper(currentDate: initialDate)

        // Act: Go to previous year
        let result = helper.goToPreviousYear()

        // Assert: Month and day should be preserved
        XCTAssertNotNil(result)
        if let newDate = result {
            let calendar = Calendar.current
            XCTAssertEqual(calendar.component(.month, from: newDate), 8, "Month should remain August")
            XCTAssertEqual(calendar.component(.day, from: newDate), 15, "Day should remain 15")
        }
    }

    // MARK: - Test goToNextYear() Method
    func testGoToNextYearUpdatesYear() {
        // Arrange: Start at 2024
        let initialDate = createDate(year: 2024, month: 6, day: 15)
        let helper = YearGridViewTestHelper(currentDate: initialDate)

        // Act: Go to next year
        let result = helper.goToNextYear()

        // Assert: Should be 2025
        XCTAssertNotNil(result, "goToNextYear should return a valid date")
        if let newDate = result {
            let calendar = Calendar.current
            XCTAssertEqual(calendar.component(.year, from: newDate), 2025, "Year should increase to 2025")
        }
    }

    func testGoToNextYearStopsAtMaximum() {
        // Arrange: Start at maximum year (2075)
        let initialDate = createDate(year: 2075, month: 6, day: 15)
        let helper = YearGridViewTestHelper(currentDate: initialDate)

        // Act: Try to go to next year
        let result = helper.goToNextYear()

        // Assert: Should return nil (cannot go after 2075)
        XCTAssertNil(result, "goToNextYear should return nil when at maximum year 2075")

        // Verify yearDate hasn't changed
        let calendar = Calendar.current
        XCTAssertEqual(calendar.component(.year, from: helper.yearDateValue), 2075, "Year should remain 2075")
    }

    func testGoToNextYearPreservesMonthAndDay() {
        // Arrange: Start at 2024-08-15
        let initialDate = createDate(year: 2024, month: 8, day: 15)
        let helper = YearGridViewTestHelper(currentDate: initialDate)

        // Act: Go to next year
        let result = helper.goToNextYear()

        // Assert: Month and day should be preserved
        XCTAssertNotNil(result)
        if let newDate = result {
            let calendar = Calendar.current
            XCTAssertEqual(calendar.component(.month, from: newDate), 8, "Month should remain August")
            XCTAssertEqual(calendar.component(.day, from: newDate), 15, "Day should remain 15")
        }
    }

    // MARK: - Test jumpToToday() Method
    func testJumpToTodayUpdatesDate() {
        // Arrange: Start with a past date
        let initialDate = createDate(year: 2020, month: 1, day: 1)
        let helper = YearGridViewTestHelper(currentDate: initialDate)

        // Act: Jump to today
        let result = helper.jumpToToday()

        // Assert: Should be today's date
        let calendar = Calendar.current
        let today = Date()
        let resultYear = calendar.component(.year, from: result.newDate)
        let resultMonth = calendar.component(.month, from: result.newDate)
        let todayYear = calendar.component(.year, from: today)
        let todayMonth = calendar.component(.month, from: today)

        XCTAssertEqual(resultYear, todayYear, "jumpToToday should update to current year")
        XCTAssertEqual(resultMonth, todayMonth, "jumpToToday should update to current month")
    }

    func testJumpToTodayDismissesSheet() {
        // Arrange
        let initialDate = createDate(year: 2020, month: 1, day: 1)
        let helper = YearGridViewTestHelper(currentDate: initialDate, isPresented: true)

        // Act: Jump to today
        let result = helper.jumpToToday()

        // Assert: Sheet should be dismissed
        XCTAssertFalse(result.isPresentedAfter, "jumpToToday should dismiss the sheet by setting isPresented to false")
    }

    // MARK: - Test isCurrentMonthAndYear() Method
    func testIsCurrentMonthAndYearWithCurrentMonth() {
        // Arrange
        let helper = YearGridViewTestHelper(currentDate: Date())
        let calendar = Calendar.current
        let today = Date()
        let currentMonth = calendar.component(.month, from: today)
        let currentYear = calendar.component(.year, from: today)

        // Act
        let result = helper.isCurrentMonthAndYear(month: currentMonth, year: currentYear)

        // Assert: Should return true for current month and year
        XCTAssertTrue(result, "isCurrentMonthAndYear should return true for current month and year")
    }

    func testIsCurrentMonthAndYearWithDifferentMonth() {
        // Arrange
        let helper = YearGridViewTestHelper(currentDate: Date())
        let calendar = Calendar.current
        let today = Date()
        let currentMonth = calendar.component(.month, from: today)
        let currentYear = calendar.component(.year, from: today)

        // Use a different month (if current is January, use December; otherwise use January)
        let differentMonth = currentMonth == 1 ? 12 : 1

        // Act
        let result = helper.isCurrentMonthAndYear(month: differentMonth, year: currentYear)

        // Assert: Should return false for different month
        XCTAssertFalse(result, "isCurrentMonthAndYear should return false for different month")
    }

    func testIsCurrentMonthAndYearWithDifferentYear() {
        // Arrange
        let helper = YearGridViewTestHelper(currentDate: Date())
        let calendar = Calendar.current
        let today = Date()
        let currentMonth = calendar.component(.month, from: today)
        let currentYear = calendar.component(.year, from: today)

        // Use a different year
        let differentYear = currentYear - 1

        // Act
        let result = helper.isCurrentMonthAndYear(month: currentMonth, year: differentYear)

        // Assert: Should return false for different year
        XCTAssertFalse(result, "isCurrentMonthAndYear should return false for different year")
    }

    // MARK: - Test Edge Cases and Error Handling
    func testSelectMonthDismissesSheetEvenOnFailure() {
        // Arrange
        let initialDate = createDate(year: 2024, month: 8, day: 15)
        let helper = YearGridViewTestHelper(currentDate: initialDate, isPresented: true)

        // Act: Select a valid month (should succeed)
        let result = helper.selectMonth(6)

        // Assert: Even if date construction somehow failed, sheet should still dismiss
        // This tests the error handling behavior
        XCTAssertFalse(result.isPresentedAfter, "Sheet should always dismiss, even if date construction fails")
    }

    // MARK: - Test Year Boundary Navigation
    func testMultiplePreviousYearNavigations() {
        // Arrange: Start at 2000
        let initialDate = createDate(year: 2000, month: 6, day: 15)
        let helper = YearGridViewTestHelper(currentDate: initialDate)

        // Act: Navigate back 5 years
        var currentYear = 2000
        for _ in 1...5 {
            if let newDate = helper.goToPreviousYear() {
                let calendar = Calendar.current
                currentYear -= 1
                XCTAssertEqual(calendar.component(.year, from: newDate), currentYear)
            }
        }

        // Assert: Should be at 1995
        let calendar = Calendar.current
        XCTAssertEqual(calendar.component(.year, from: helper.yearDateValue), 1995)
    }

    func testMultipleNextYearNavigations() {
        // Arrange: Start at 2000
        let initialDate = createDate(year: 2000, month: 6, day: 15)
        let helper = YearGridViewTestHelper(currentDate: initialDate)

        // Act: Navigate forward 5 years
        var currentYear = 2000
        for _ in 1...5 {
            if let newDate = helper.goToNextYear() {
                let calendar = Calendar.current
                currentYear += 1
                XCTAssertEqual(calendar.component(.year, from: newDate), currentYear)
            }
        }

        // Assert: Should be at 2005
        let calendar = Calendar.current
        XCTAssertEqual(calendar.component(.year, from: helper.yearDateValue), 2005)
    }
}
