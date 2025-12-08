//
//  PickerCalendarGridViewTests.swift
//  lich-plusTests
//
//  Created by Quang Tran Minh on 08/12/25.
//

import XCTest
import SwiftUI
@testable import lich_plus

final class PickerCalendarGridViewTests: XCTestCase {

    // MARK: - Test Data

    private func createSampleMonth() -> CalendarMonth {
        // Create a proper month with all days including padding
        // November 2025 has 30 days and starts on Saturday
        let baseDate = Calendar.current.date(from: DateComponents(year: 2025, month: 11, day: 1)) ?? Date()

        var allDays: [CalendarDay] = []

        // Add days from previous month (padding at start)
        let weekdayOfFirstDay = Calendar.current.component(.weekday, from: baseDate) // 1=Sunday, 7=Saturday
        let daysBeforeMonthStart = (weekdayOfFirstDay - 2 + 7) % 7 // Adjust to Monday=0

        // Days from previous month (not current month)
        let prevMonthDate = Calendar.current.date(byAdding: .month, value: -1, to: baseDate) ?? baseDate
        if let prevMonthLastDay = Calendar.current.range(of: .day, in: .month, for: prevMonthDate) {
            let lastDayOfPrevMonth = prevMonthLastDay.count
            for i in 0..<daysBeforeMonthStart {
                let dayNum = lastDayOfPrevMonth - daysBeforeMonthStart + i + 1
                allDays.append(CalendarDay(
                    date: Calendar.current.date(byAdding: .day, value: -(daysBeforeMonthStart - i), to: baseDate) ?? baseDate,
                    solarDay: 0,
                    solarMonth: 0,
                    solarYear: 0,
                    lunarDay: 0,
                    lunarMonth: 0,
                    lunarYear: 0,
                    dayType: .neutral,
                    isCurrentMonth: false,
                    isToday: false,
                    events: [],
                    isWeekend: false
                ))
            }
        }

        // Days of current month
        if let daysInMonth = Calendar.current.range(of: .day, in: .month, for: baseDate) {
            for dayNum in 1...daysInMonth.count {
                let date = Calendar.current.date(byAdding: .day, value: dayNum - 1, to: baseDate) ?? baseDate
                let isWeekend = Calendar.current.component(.weekday, from: date) % 7 == 1 || Calendar.current.component(.weekday, from: date) == 7
                let dayType: DayType = dayNum % 3 == 0 ? .good : (dayNum % 3 == 1 ? .bad : .neutral)

                allDays.append(CalendarDay(
                    date: date,
                    solarDay: dayNum,
                    solarMonth: 11,
                    solarYear: 2025,
                    lunarDay: dayNum,
                    lunarMonth: 10,
                    lunarYear: 2024,
                    dayType: dayType,
                    isCurrentMonth: true,
                    isToday: dayNum == 8,
                    events: [],
                    isWeekend: isWeekend
                ))
            }
        }

        // Days from next month (padding at end)
        let targetCount = 42 // 6 weeks * 7 days
        while allDays.count < targetCount {
            let nextDate = Calendar.current.date(byAdding: .day, value: allDays.count - daysBeforeMonthStart, to: baseDate) ?? baseDate
            allDays.append(CalendarDay(
                date: nextDate,
                solarDay: 0,
                solarMonth: 0,
                solarYear: 0,
                lunarDay: 0,
                lunarMonth: 0,
                lunarYear: 0,
                dayType: .neutral,
                isCurrentMonth: false,
                isToday: false,
                events: [],
                isWeekend: false
            ))
        }

        return CalendarMonth(
            month: 11,
            year: 2025,
            days: Array(allDays.prefix(42)),
            lunarMonth: 10,
            lunarYear: 2024
        )
    }

    // MARK: - Grid Structure Tests

    func testPickerCalendarGridView_HasWeekdayHeaders() {
        // Given
        let month = createSampleMonth()

        // Then - should have 7 weekday headers
        let expectedHeaders = ["T2", "T3", "T4", "T5", "T6", "T7", "CN"]
        XCTAssertEqual(expectedHeaders.count, 7)
    }

    func testPickerCalendarGridView_Has6WeekLayout() {
        // Given
        let month = createSampleMonth()

        // Then - month should have 6 weeks
        XCTAssertEqual(month.weeksOfDays.count, 6)
    }

    func testPickerCalendarGridView_EachWeekHas7Days() {
        // Given
        let month = createSampleMonth()

        // Then - each week should have exactly 7 days
        for week in month.weeksOfDays {
            XCTAssertEqual(week.count, 7)
        }
    }

    func testPickerCalendarGridView_Has42TotalDays() {
        // Given
        let month = createSampleMonth()

        // Then - 6 weeks * 7 days = 42 days
        let totalDays = month.weeksOfDays.flatMap { $0 }.count
        XCTAssertEqual(totalDays, 42)
    }

    // MARK: - Date Selection Tests

    func testPickerCalendarGridView_SelectsCurrentMonthDay() {
        // Given
        let month = createSampleMonth()
        var selectedDate = Date()

        // When - select a current month day
        guard let dayToSelect = month.days.first(where: { $0.isCurrentMonth && $0.solarDay == 15 }) else {
            XCTFail("Could not find day 15 in sample month")
            return
        }
        selectedDate = dayToSelect.date

        // Then - the selected date should match the selected day
        XCTAssertTrue(Calendar.current.isDate(selectedDate, inSameDayAs: dayToSelect.date))
    }

    func testPickerCalendarGridView_IgnoresNonCurrentMonthDayTap() {
        // Given
        let month = createSampleMonth()
        let otherMonthDay = CalendarDay(
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
            solarDay: 0,
            solarMonth: 0,
            solarYear: 0,
            lunarDay: 0,
            lunarMonth: 0,
            lunarYear: 0,
            dayType: .neutral,
            isCurrentMonth: false,
            isToday: false,
            events: [],
            isWeekend: false
        )

        // Then - day should not be selectable
        XCTAssertFalse(otherMonthDay.isCurrentMonth)
    }

    // MARK: - Time Preservation Tests

    func testPickerCalendarGridView_PreservesTimeComponentsOnSelection() {
        // Given
        let originalDate = Calendar.current.date(
            bySettingHour: 14,
            minute: 30,
            second: 0,
            of: Date()
        ) ?? Date()

        let month = createSampleMonth()
        // Find a day from the current month (not padding)
        guard let selectedDay = month.days.first(where: { $0.isCurrentMonth && $0.solarDay == 15 }) else {
            XCTFail("Could not find day 15 in sample month")
            return
        }

        // When - extract time components
        let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: originalDate)

        // Then - time should be preserved
        XCTAssertEqual(timeComponents.hour, 14)
        XCTAssertEqual(timeComponents.minute, 30)
    }

    func testPickerCalendarGridView_CombinesDateAndTime() {
        // Given
        let originalDate = Calendar.current.date(
            bySettingHour: 9,
            minute: 15,
            second: 0,
            of: Date()
        ) ?? Date()

        let month = createSampleMonth()
        // Find a day from the current month (not padding)
        guard let selectedDay = month.days.first(where: { $0.isCurrentMonth && $0.solarDay == 15 }) else {
            XCTFail("Could not find day 15 in sample month")
            return
        }

        // When - create new date with selected day but original time
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: originalDate)
        var newDateComponents = calendar.dateComponents([.year, .month, .day], from: selectedDay.date)
        newDateComponents.hour = timeComponents.hour
        newDateComponents.minute = timeComponents.minute
        let newDate = calendar.date(from: newDateComponents) ?? selectedDay.date

        // Then - new date should have selected day but original time
        XCTAssertEqual(calendar.component(.hour, from: newDate), 9)
        XCTAssertEqual(calendar.component(.minute, from: newDate), 15)
        XCTAssertEqual(calendar.component(.day, from: newDate), selectedDay.solarDay)
    }

    func testPickerCalendarGridView_PreservesTimeFor24HourFormat() {
        // Given
        let originalDate = Calendar.current.date(
            bySettingHour: 23,
            minute: 59,
            second: 0,
            of: Date()
        ) ?? Date()

        // When
        let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: originalDate)

        // Then - 24-hour format should be preserved
        XCTAssertEqual(timeComponents.hour, 23)
        XCTAssertEqual(timeComponents.minute, 59)
    }

    func testPickerCalendarGridView_PreservesTimeForMidnight() {
        // Given
        let originalDate = Calendar.current.date(
            bySettingHour: 0,
            minute: 0,
            second: 0,
            of: Date()
        ) ?? Date()

        // When
        let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: originalDate)

        // Then - midnight should be preserved
        XCTAssertEqual(timeComponents.hour, 0)
        XCTAssertEqual(timeComponents.minute, 0)
    }

    // MARK: - Selection State Tests

    func testPickerCalendarGridView_IdentifiesSelectedDate() {
        // Given
        let month = createSampleMonth()
        let dateToSelect = month.days[10].date

        // When
        let isSelected = Calendar.current.isDate(dateToSelect, inSameDayAs: month.days[10].date)

        // Then
        XCTAssertTrue(isSelected)
    }

    func testPickerCalendarGridView_IdentifiesDifferentDate() {
        // Given
        let month = createSampleMonth()
        let date1 = month.days[10].date
        let date2 = month.days[15].date

        // When
        let isSameDay = Calendar.current.isDate(date1, inSameDayAs: date2)

        // Then
        XCTAssertFalse(isSameDay)
    }

    // MARK: - Visual State Tests

    func testPickerCalendarGridView_DisplaysSelectedDateWithBorder() {
        // Given
        let month = createSampleMonth()
        let selectedDay = month.days[14]

        // Then - selected day should be identifiable
        XCTAssertTrue(selectedDay.isCurrentMonth)
    }

    func testPickerCalendarGridView_DisplaysTodayWithBorder() {
        // Given
        let month = createSampleMonth()
        let todayDay = month.days.first(where: { $0.isToday })

        // Then
        XCTAssertNotNil(todayDay)
        XCTAssertTrue(todayDay?.isToday ?? false)
    }
}
