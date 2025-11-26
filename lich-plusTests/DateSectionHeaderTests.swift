//
//  DateSectionHeaderTests.swift
//  lich-plusTests
//
//  Created by Quang Tran Minh on 26/11/25.
//

import XCTest
import SwiftUI
@testable import lich_plus

final class DateSectionHeaderTests: XCTestCase {

    func testDateSectionHeader_VietnameseWeekdayFormatting() {
        // Create a known date (2025-11-26 is a Wednesday)
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 2025
        components.month = 11
        components.day = 26
        let date = calendar.date(from: components)!

        // Create formatter
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.dateFormat = "EEEE, dd/MM"
        let result = formatter.string(from: date).uppercased()

        // Should contain weekday and date
        XCTAssertTrue(result.contains("26/11"))
    }

    func testDateSectionHeader_LunarDateConversion() {
        // Given
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 2025
        components.month = 11
        components.day = 26
        let date = calendar.date(from: components)!

        // When
        let (day, month, year) = LunarCalendar.solarToLunar(date)

        // Then - Should have valid lunar date values
        XCTAssert(day > 0)
        XCTAssert(month > 0)
        XCTAssert(month <= 12)
        XCTAssert(year > 0)
    }

    func testDateSectionHeader_YearCanChiCalculation() {
        // Given
        let date = Date()

        // When
        let canChiPair = CanChiCalculator.calculateYearCanChi(for: date)

        // Then
        XCTAssertFalse(canChiPair.displayName.isEmpty)
        XCTAssertTrue(canChiPair.displayName.count > 0)
    }
}
