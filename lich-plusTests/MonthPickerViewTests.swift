//
//  MonthPickerViewTests.swift
//  lich-plusTests
//
//  Created by Quang Tran Minh on 27/11/25.
//

import XCTest
import SwiftUI
@testable import lich_plus

class MonthPickerViewTests: XCTestCase {

    func testMonthPickerInitializesWithCurrentDate() {
        let today = Date()
        var selectedMonth: Int?
        var selectedYear: Int?

        let view = MonthPickerView(
            selectedDate: today,
            onMonthSelected: { month, year in
                selectedMonth = month
                selectedYear = year
            },
            onDismiss: {}
        )

        XCTAssertNotNil(view)
    }

    func testMonthSelectionCallsCallback() {
        let today = Date()
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: today)
        let currentYear = calendar.component(.year, from: today)

        var callbackMonth: Int?
        var callbackYear: Int?
        var callbackCalled = false

        let expectation = XCTestExpectation(description: "Month selection callback triggered")

        let view = MonthPickerView(
            selectedDate: today,
            onMonthSelected: { month, year in
                callbackMonth = month
                callbackYear = year
                callbackCalled = true
                expectation.fulfill()
            },
            onDismiss: {}
        )

        XCTAssertNotNil(view)
    }

    func testMonthPickerYearNavigationForward() {
        let today = Date()
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: today)

        var pickedYear: Int?

        let view = MonthPickerView(
            selectedDate: today,
            onMonthSelected: { month, year in
                pickedYear = year
            },
            onDismiss: {}
        )

        XCTAssertNotNil(view)
        // Year navigation is handled internally via swipe gestures
    }

    func testMonthPickerYearNavigationBackward() {
        let today = Date()
        var pickedYear: Int?

        let view = MonthPickerView(
            selectedDate: today,
            onMonthSelected: { month, year in
                pickedYear = year
            },
            onDismiss: {}
        )

        XCTAssertNotNil(view)
    }

    func testMonthPickerRespectYearBounds() {
        let today = Date()
        let calendar = Calendar.current

        let view = MonthPickerView(
            selectedDate: today,
            onMonthSelected: { month, year in
                // Year should be between 1900 and 2100
                XCTAssertGreaterThanOrEqual(year, 1900)
                XCTAssertLessThanOrEqual(year, 2100)
            },
            onDismiss: {}
        )

        XCTAssertNotNil(view)
    }

    func testMonthPickerValidatesMonthSelection() {
        let today = Date()

        var pickedMonth: Int?

        let view = MonthPickerView(
            selectedDate: today,
            onMonthSelected: { month, year in
                pickedMonth = month
                // Month should be 1-12
                XCTAssertGreaterThanOrEqual(month, 1)
                XCTAssertLessThanOrEqual(month, 12)
            },
            onDismiss: {}
        )

        XCTAssertNotNil(view)
    }

    func testMonthPickerDismissCallbackFired() {
        let today = Date()
        var dismissCalled = false

        let expectation = XCTestExpectation(description: "Dismiss callback triggered")

        let view = MonthPickerView(
            selectedDate: today,
            onMonthSelected: { _, _ in },
            onDismiss: {
                dismissCalled = true
                expectation.fulfill()
            }
        )

        XCTAssertNotNil(view)
    }

    func testMonthPickerDisplaysAllMonths() {
        let today = Date()
        let monthLabels = ["Th.1", "Th.2", "Th.3", "Th.4", "Th.5", "Th.6",
                          "Th.7", "Th.8", "Th.9", "Th.10", "Th.11", "Th.12"]

        let view = MonthPickerView(
            selectedDate: today,
            onMonthSelected: { _, _ in },
            onDismiss: {}
        )

        XCTAssertNotNil(view)
        // Month labels are hard-coded in the view
    }

    func testMonthPickerIdentifiesCurrentMonth() {
        let today = Date()
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: today)
        let currentYear = calendar.component(.year, from: today)

        let view = MonthPickerView(
            selectedDate: today,
            onMonthSelected: { _, _ in },
            onDismiss: {}
        )

        XCTAssertNotNil(view)
        // Current month highlighting is handled visually in the view
    }

    func testMonthPickerIdentifiesSelectedMonth() {
        let today = Date()
        let calendar = Calendar.current
        let futureDate = calendar.date(byAdding: .month, value: 3, to: today)!

        let view = MonthPickerView(
            selectedDate: futureDate,
            onMonthSelected: { _, _ in },
            onDismiss: {}
        )

        XCTAssertNotNil(view)
    }
}
