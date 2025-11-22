import XCTest
import SwiftUI
@testable import lich_plus

// MARK: - Calendar Cell ViewModel Tests
final class CalendarCellViewModelTests: XCTestCase {

    // MARK: - Weekend Coloring Tests

    func testWeekendColoringSaturday() {
        // Create a Saturday date (August 3, 2024 is Saturday)
        let saturdayDate = createDate(year: 2024, month: 8, day: 3)
        let lunarInfo = LunarDateInfo(year: 2024, month: 6, day: 18)
        let auspiciousInfo = AuspiciousDayInfo(type: .neutral)

        let viewModel = CalendarCellViewModel(
            date: saturdayDate,
            lunarInfo: lunarInfo,
            auspiciousInfo: auspiciousInfo,
            isCurrentMonth: true,
            isToday: false
        )

        // Saturday should be cyan (#50E3C2)
        XCTAssertEqual(viewModel.solarDayColor, Color(hex: "#50E3C2") ?? .cyan)
    }

    func testWeekendColoringSunday() {
        // Create a Sunday date (August 4, 2024 is Sunday)
        let sundayDate = createDate(year: 2024, month: 8, day: 4)
        let lunarInfo = LunarDateInfo(year: 2024, month: 6, day: 19)
        let auspiciousInfo = AuspiciousDayInfo(type: .neutral)

        let viewModel = CalendarCellViewModel(
            date: sundayDate,
            lunarInfo: lunarInfo,
            auspiciousInfo: auspiciousInfo,
            isCurrentMonth: true,
            isToday: false
        )

        // Sunday should be orange (#F5A623)
        XCTAssertEqual(viewModel.solarDayColor, Color(hex: "#F5A623") ?? .orange)
    }

    func testWeekdayColoringDefault() {
        // Create a weekday date (August 6, 2024 is Tuesday)
        let tuesdayDate = createDate(year: 2024, month: 8, day: 6)
        let lunarInfo = LunarDateInfo(year: 2024, month: 6, day: 21)
        let auspiciousInfo = AuspiciousDayInfo(type: .neutral)

        let viewModel = CalendarCellViewModel(
            date: tuesdayDate,
            lunarInfo: lunarInfo,
            auspiciousInfo: auspiciousInfo,
            isCurrentMonth: true,
            isToday: false
        )

        // Weekday should be black
        XCTAssertEqual(viewModel.solarDayColor, .black)
    }

    // MARK: - Lunar Month Start Tests

    func testLunarMonthStartHighlight() {
        // Create date with lunar day 1 (Mùng 1)
        let date = createDate(year: 2024, month: 8, day: 16)
        let lunarInfo = LunarDateInfo(year: 2024, month: 7, day: 1)
        let auspiciousInfo = AuspiciousDayInfo(type: .neutral)

        let viewModel = CalendarCellViewModel(
            date: date,
            lunarInfo: lunarInfo,
            auspiciousInfo: auspiciousInfo,
            isCurrentMonth: true,
            isToday: false
        )

        // Mùng 1 should have red text (#D0021B)
        XCTAssertEqual(viewModel.lunarTextColor, Color(hex: "#D0021B") ?? .red)
        XCTAssertTrue(viewModel.isLunarMonthStart)
    }

    // MARK: - Auspicious Dot Visibility Tests

    func testAuspiciousDotVisibility() {
        // Create auspicious day
        let date = createDate(year: 2024, month: 8, day: 1)
        let lunarInfo = LunarDateInfo(year: 2024, month: 6, day: 16)
        let auspiciousInfo = AuspiciousDayInfo(type: .auspicious, reason: "Ngày hoàng đạo")

        let viewModel = CalendarCellViewModel(
            date: date,
            lunarInfo: lunarInfo,
            auspiciousInfo: auspiciousInfo,
            isCurrentMonth: true,
            isToday: false
        )

        // Auspicious day should show auspicious dot only
        XCTAssertTrue(viewModel.shouldShowAuspiciousDot)
        XCTAssertFalse(viewModel.shouldShowInauspiciousDot)
    }

    func testInauspiciousDotVisibility() {
        // Create inauspicious day
        let date = createDate(year: 2024, month: 8, day: 22)
        let lunarInfo = LunarDateInfo(year: 2024, month: 7, day: 7)
        let auspiciousInfo = AuspiciousDayInfo(type: .inauspicious, reason: "Ngày xấu")

        let viewModel = CalendarCellViewModel(
            date: date,
            lunarInfo: lunarInfo,
            auspiciousInfo: auspiciousInfo,
            isCurrentMonth: true,
            isToday: false
        )

        // Inauspicious day should show inauspicious dot only
        XCTAssertTrue(viewModel.shouldShowInauspiciousDot)
        XCTAssertFalse(viewModel.shouldShowAuspiciousDot)
    }

    func testNeutralDayNoDots() {
        // Create neutral day
        let date = createDate(year: 2024, month: 8, day: 17)
        let lunarInfo = LunarDateInfo(year: 2024, month: 7, day: 2)
        let auspiciousInfo = AuspiciousDayInfo(type: .neutral)

        let viewModel = CalendarCellViewModel(
            date: date,
            lunarInfo: lunarInfo,
            auspiciousInfo: auspiciousInfo,
            isCurrentMonth: true,
            isToday: false
        )

        // Neutral day should show no dots
        XCTAssertFalse(viewModel.shouldShowAuspiciousDot)
        XCTAssertFalse(viewModel.shouldShowInauspiciousDot)
    }

    // MARK: - Today Border Tests

    func testTodayBorderColor() {
        // Create viewModel for today
        let date = createDate(year: 2024, month: 8, day: 15)
        let lunarInfo = LunarDateInfo(year: 2024, month: 6, day: 30)
        let auspiciousInfo = AuspiciousDayInfo(type: .neutral)

        let viewModel = CalendarCellViewModel(
            date: date,
            lunarInfo: lunarInfo,
            auspiciousInfo: auspiciousInfo,
            isCurrentMonth: true,
            isToday: true
        )

        // Today should have green border (#5BC0A6)
        XCTAssertEqual(viewModel.todayBorderColor, Color(hex: "#5BC0A6") ?? .green)
    }

    func testNotTodayBorderColor() {
        // Create viewModel for not today
        let date = createDate(year: 2024, month: 8, day: 15)
        let lunarInfo = LunarDateInfo(year: 2024, month: 6, day: 30)
        let auspiciousInfo = AuspiciousDayInfo(type: .neutral)

        let viewModel = CalendarCellViewModel(
            date: date,
            lunarInfo: lunarInfo,
            auspiciousInfo: auspiciousInfo,
            isCurrentMonth: true,
            isToday: false
        )

        // Not today should have clear border
        XCTAssertEqual(viewModel.todayBorderColor, .clear)
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
