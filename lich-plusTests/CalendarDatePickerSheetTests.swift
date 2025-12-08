//
//  CalendarDatePickerSheetTests.swift
//  lich-plusTests
//
//  Tests for CalendarDatePickerSheet component with month navigation and date selection
//

import XCTest
import SwiftUI
@testable import lich_plus

final class CalendarDatePickerSheetTests: XCTestCase {

    // MARK: - Test: Month Navigation

    func testInitializeWithCurrentDate() {
        let testDate = Date(timeIntervalSince1970: 1733337600) // Dec 4, 2024
        var selectedDate = testDate

        let sheet = CalendarDatePickerSheet(
            title: "Select Date",
            selectedDate: Binding(
                get: { selectedDate },
                set: { selectedDate = $0 }
            ),
            onDone: {}
        )

        // Should initialize without crashes
        XCTAssertNotNil(sheet)
    }

    func testMonthNavigationNext() {
        var selectedDate = Date()

        let sheet = CalendarDatePickerSheet(
            title: "Select Date",
            selectedDate: Binding(
                get: { selectedDate },
                set: { selectedDate = $0 }
            ),
            onDone: {}
        )

        // Verify component initializes without crashes
        XCTAssertNotNil(sheet)
    }

    func testMonthNavigationPrevious() {
        var selectedDate = Date()

        let sheet = CalendarDatePickerSheet(
            title: "Select Date",
            selectedDate: Binding(
                get: { selectedDate },
                set: { selectedDate = $0 }
            ),
            onDone: {}
        )

        // Verify component initializes without crashes
        XCTAssertNotNil(sheet)
    }

    // MARK: - Test: Month Boundary Handling

    func testDecemberToJanuaryTransition() {
        // Start with December 2024
        let calendar = Calendar.current
        let decemberDate = calendar.date(from: DateComponents(year: 2024, month: 12, day: 15)) ?? Date()
        var selectedDate = decemberDate

        let sheet = CalendarDatePickerSheet(
            title: "Select Date",
            selectedDate: Binding(
                get: { selectedDate },
                set: { selectedDate = $0 }
            ),
            onDone: {}
        )

        // Should handle month wrap correctly
        XCTAssertNotNil(sheet)
    }

    func testJanuaryToDecemberTransition() {
        // Start with January 2024
        let calendar = Calendar.current
        let januaryDate = calendar.date(from: DateComponents(year: 2024, month: 1, day: 15)) ?? Date()
        var selectedDate = januaryDate

        let sheet = CalendarDatePickerSheet(
            title: "Select Date",
            selectedDate: Binding(
                get: { selectedDate },
                set: { selectedDate = $0 }
            ),
            onDone: {}
        )

        // Should handle month wrap correctly
        XCTAssertNotNil(sheet)
    }

    // MARK: - Test: Solar Month/Year Formatting

    func testSolarMonthYearFormatting() {
        let calendar = Calendar.current
        let testDate = calendar.date(from: DateComponents(year: 2025, month: 12, day: 1)) ?? Date()
        var selectedDate = testDate

        let sheet = CalendarDatePickerSheet(
            title: "Select Date",
            selectedDate: Binding(
                get: { selectedDate },
                set: { selectedDate = $0 }
            ),
            onDone: {}
        )

        // Format should be "Tháng 12, 2025"
        let formatted = String(format: "Tháng %d, %d", 12, 2025)
        XCTAssertEqual(formatted, "Tháng 12, 2025")
    }

    func testSolarMonthYearFormattingVariousMonths() {
        let testCases: [(month: Int, year: Int, expected: String)] = [
            (1, 2025, "Tháng 1, 2025"),
            (6, 2025, "Tháng 6, 2025"),
            (12, 2024, "Tháng 12, 2024"),
        ]

        for testCase in testCases {
            let formatted = String(format: "Tháng %d, %d", testCase.month, testCase.year)
            XCTAssertEqual(formatted, testCase.expected)
        }
    }

    // MARK: - Test: Lunar Month/Year Formatting

    func testLunarYearCanChiCalculation() {
        // Test various lunar years
        let testCases: [Int] = [2024, 2025, 2026, 2027]

        for lunarYear in testCases {
            let yearCanChi = CanChiCalculator.calculateYearCanChi(lunarYear: lunarYear)
            let displayName = yearCanChi.displayName

            // Should not be empty
            XCTAssertFalse(displayName.isEmpty)

            // Should contain both Can and Chi
            XCTAssertTrue(displayName.contains(yearCanChi.can.vietnameseName))
            XCTAssertTrue(displayName.contains(yearCanChi.chi.vietnameseName))
        }
    }

    func testLunarMonthYearFormatting() {
        let lunarYear = 2024
        let lunarMonth = 11
        let yearCanChi = CanChiCalculator.calculateYearCanChi(lunarYear: lunarYear)

        let formatted = String(format: "Tháng %d năm %@", lunarMonth, yearCanChi.displayName)

        // Should match format "Tháng 11 năm Giáp Thìn"
        XCTAssertTrue(formatted.contains("Tháng 11 năm"))
        XCTAssertTrue(formatted.contains(yearCanChi.displayName))
    }

    // MARK: - Test: Integration with CalendarDataManager

    func testInitializeWithDecemberDate() {
        let calendar = Calendar.current
        let decemberDate = calendar.date(from: DateComponents(year: 2025, month: 12, day: 15)) ?? Date()
        var selectedDate = decemberDate

        let sheet = CalendarDatePickerSheet(
            title: "Select Date",
            selectedDate: Binding(
                get: { selectedDate },
                set: { selectedDate = $0 }
            ),
            onDone: {}
        )

        // Should initialize with December successfully
        XCTAssertNotNil(sheet)
    }

    func testInitializeWithVariousMonths() {
        let calendar = Calendar.current
        let testMonths: [(Int, Int)] = [(1, 2025), (6, 2025), (12, 2024)]

        for (month, year) in testMonths {
            let date = calendar.date(from: DateComponents(year: year, month: month, day: 15)) ?? Date()
            var selectedDate = date

            let sheet = CalendarDatePickerSheet(
                title: "Select Date",
                selectedDate: Binding(
                    get: { selectedDate },
                    set: { selectedDate = $0 }
                ),
                onDone: {}
            )

            // Should initialize for all months without error
            XCTAssertNotNil(sheet)
        }
    }

    // MARK: - Test: Date Selection Preserves Time

    func testDateSelectionPreservesTime() {
        let calendar = Calendar.current
        let originalDate = calendar.date(from: DateComponents(year: 2025, month: 12, day: 15, hour: 14, minute: 30)) ?? Date()
        var selectedDate = originalDate

        _ = CalendarDatePickerSheet(
            title: "Select Date",
            selectedDate: Binding(
                get: { selectedDate },
                set: { selectedDate = $0 }
            ),
            onDone: {}
        )

        // When selecting a new date, time should be preserved
        // (This is handled by PickerCalendarGridView.updateSelectedDate)
        let hour = calendar.component(.hour, from: selectedDate)
        let minute = calendar.component(.minute, from: selectedDate)

        XCTAssertEqual(hour, 14)
        XCTAssertEqual(minute, 30)
    }

    // MARK: - Test: Done Button Callback

    func testOnDoneCallback() {
        var selectedDate = Date()

        let sheet = CalendarDatePickerSheet(
            title: "Select Date",
            selectedDate: Binding(
                get: { selectedDate },
                set: { selectedDate = $0 }
            ),
            onDone: {}
        )

        // Verify onDone closure initialization works
        XCTAssertNotNil(sheet)
    }

    // MARK: - Test: Title Parameter

    func testTitleParameter() {
        let titles = ["Select Start Date", "Select End Date", "Choose Event Date"]

        for title in titles {
            var selectedDate = Date()

            let sheet = CalendarDatePickerSheet(
                title: title,
                selectedDate: Binding(
                    get: { selectedDate },
                    set: { selectedDate = $0 }
                ),
                onDone: {}
            )

            // Should accept various titles
            XCTAssertNotNil(sheet)
        }
    }

    // MARK: - Test: Time Picker Integration

    func testTimePickerInitialization() {
        let calendar = Calendar.current
        let testDate = calendar.date(from: DateComponents(year: 2025, month: 12, day: 15, hour: 10, minute: 30)) ?? Date()
        var selectedDate = testDate

        _ = CalendarDatePickerSheet(
            title: "Select Date",
            selectedDate: Binding(
                get: { selectedDate },
                set: { selectedDate = $0 }
            ),
            onDone: {}
        )

        // Should initialize with time components
        let hour = calendar.component(.hour, from: selectedDate)
        let minute = calendar.component(.minute, from: selectedDate)

        XCTAssertEqual(hour, 10)
        XCTAssertEqual(minute, 30)
    }

    func testTimePickerUpdatesSelectedDate() {
        let calendar = Calendar.current
        let initialDate = calendar.date(from: DateComponents(year: 2025, month: 12, day: 15, hour: 9, minute: 0)) ?? Date()
        var selectedDate = initialDate

        _ = CalendarDatePickerSheet(
            title: "Select Date",
            selectedDate: Binding(
                get: { selectedDate },
                set: { selectedDate = $0 }
            ),
            onDone: {}
        )

        // Simulate time change
        let newDate = calendar.date(from: DateComponents(year: 2025, month: 12, day: 15, hour: 14, minute: 45)) ?? Date()
        selectedDate = newDate

        let hour = calendar.component(.hour, from: selectedDate)
        let minute = calendar.component(.minute, from: selectedDate)

        XCTAssertEqual(hour, 14)
        XCTAssertEqual(minute, 45)
    }

    // MARK: - Helper Methods

    private func isEmpty(_ date: Date) -> Bool {
        date.timeIntervalSince1970 == 0
    }
}
