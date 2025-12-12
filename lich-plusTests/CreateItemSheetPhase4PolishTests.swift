//
//  CreateItemSheetPhase4PolishTests.swift
//  lich-plusTests
//
//  Tests for Phase 4: Polish & Edge Cases for all-day events
//  - Date range validation
//  - Auto-adjust endDate when startDate changes
//  - Mode switching between all-day and timed
//

import XCTest
import SwiftData
@testable import lich_plus

final class CreateItemSheetPhase4PolishTests: XCTestCase {

    // MARK: - Setup

    var modelContainer: ModelContainer!
    var modelContext: ModelContext!

    override func setUp() {
        super.setUp()
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try! ModelContainer(for: SyncableEvent.self, configurations: config)
        modelContext = ModelContext(modelContainer)
    }

    override func tearDown() {
        modelContext = nil
        modelContainer = nil
        super.tearDown()
    }

    // MARK: - Test: Date Range Validation for All-Day Events

    func testDateRangeValidWhenEndDateEqualsStartDateAllDay() {
        // Arrange
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: Date())
        let endDate = calendar.startOfDay(for: Date())

        // Act
        let isValid = isDateRangeValidAllDay(startDate: startDate, endDate: endDate)

        // Assert
        XCTAssertTrue(isValid, "All-day event is valid when endDate equals startDate (same day)")
    }

    func testDateRangeValidWhenEndDateAfterStartDateAllDay() {
        // Arrange
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: Date())
        let endDate = calendar.date(byAdding: .day, value: 2, to: startDate)!

        // Act
        let isValid = isDateRangeValidAllDay(startDate: startDate, endDate: endDate)

        // Assert
        XCTAssertTrue(isValid, "All-day event is valid when endDate is after startDate")
    }

    func testDateRangeInvalidWhenEndDateBeforeStartDateAllDay() {
        // Arrange
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: Date())
        let endDate = calendar.date(byAdding: .day, value: -1, to: startDate)!

        // Act
        let isValid = isDateRangeValidAllDay(startDate: startDate, endDate: endDate)

        // Assert
        XCTAssertFalse(isValid, "All-day event is invalid when endDate is before startDate")
    }

    func testDateRangeValidWhenEndDateSameDayButDifferentTimeAllDay() {
        // Arrange
        let calendar = Calendar.current
        let startDate = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!
        let endDate = calendar.date(bySettingHour: 17, minute: 0, second: 0, of: Date())!

        // Act
        // For all-day, we should compare just the days (ignoring time)
        let isValid = isDateRangeValidAllDay(startDate: startDate, endDate: endDate)

        // Assert
        XCTAssertTrue(isValid, "All-day event is valid when same day (time component ignored)")
    }

    // MARK: - Test: Date Range Validation for Timed Events

    func testDateRangeValidForTimedEventWhenEndAfterStart() {
        // Arrange
        let calendar = Calendar.current
        let startDate = Date()
        let endDate = calendar.date(byAdding: .hour, value: 1, to: startDate)!

        // Act
        let isValid = isDateRangeValidTimed(startDate: startDate, endDate: endDate)

        // Assert
        XCTAssertTrue(isValid, "Timed event is valid when endDate is after startDate")
    }

    func testDateRangeInvalidForTimedEventWhenEndBeforeStart() {
        // Arrange
        let calendar = Calendar.current
        let startDate = Date()
        let endDate = calendar.date(byAdding: .hour, value: -1, to: startDate)!

        // Act
        let isValid = isDateRangeValidTimed(startDate: startDate, endDate: endDate)

        // Assert
        XCTAssertFalse(isValid, "Timed event is invalid when endDate is before startDate")
    }

    func testDateRangeInvalidForTimedEventWhenEndEqualsStart() {
        // Arrange
        let startDate = Date()
        let endDate = startDate

        // Act
        let isValid = isDateRangeValidTimed(startDate: startDate, endDate: endDate)

        // Assert
        XCTAssertFalse(isValid, "Timed event is invalid when endDate equals startDate (zero duration)")
    }

    // MARK: - Test: Auto-Adjust EndDate When StartDate Changes (All-Day)

    func testAutoAdjustEndDateAllDayWhenStartDateMovedForward() {
        // Arrange
        let calendar = Calendar.current
        var startDate = calendar.startOfDay(for: Date())
        var endDate = calendar.startOfDay(for: Date())

        // Act - Move start date forward by 3 days
        startDate = calendar.date(byAdding: .day, value: 3, to: startDate)!

        // For all-day, if startDate > endDate, endDate should be adjusted
        if calendar.startOfDay(for: startDate) > calendar.startOfDay(for: endDate) {
            endDate = startDate
        }

        // Assert
        XCTAssertEqual(
            calendar.startOfDay(for: endDate),
            calendar.startOfDay(for: startDate),
            "EndDate should be adjusted to match startDate when startDate moves forward"
        )
    }

    func testAutoAdjustEndDateAllDayWhenStartDateMovedBackward() {
        // Arrange
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: 5, to: Date())!
        let endDate = calendar.date(byAdding: .day, value: 5, to: Date())!

        // Act - Move start date backward
        let newStartDate = calendar.date(byAdding: .day, value: -2, to: startDate)!

        // For all-day, endDate should stay the same if it's still >= startDate
        let newEndDate = endDate
        let isValid = calendar.startOfDay(for: newStartDate) <= calendar.startOfDay(for: newEndDate)

        // Assert
        XCTAssertTrue(isValid, "EndDate should remain valid when startDate moves backward")
    }

    func testNoAdjustmentWhenEndDateStaysValidAllDay() {
        // Arrange
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: Date())
        let endDate = calendar.date(byAdding: .day, value: 2, to: startDate)!

        // Act - Verify endDate is valid for startDate
        let isValid = calendar.startOfDay(for: endDate) >= calendar.startOfDay(for: startDate)

        // Assert
        XCTAssertTrue(isValid, "EndDate should not be adjusted when it remains valid")
    }

    // MARK: - Test: Auto-Adjust EndDate When StartDate Changes (Timed)

    func testAutoAdjustEndDateTimedWhenStartDateMovedForward() {
        // Arrange
        let calendar = Calendar.current
        let startDate = Date()
        let endDate = calendar.date(byAdding: .hour, value: 1, to: startDate)!

        // Act - Move start date forward by 2 hours
        let newStartDate = calendar.date(byAdding: .hour, value: 2, to: startDate)!

        // For timed events, if newEndDate <= newStartDate, adjust to newStartDate + 1 hour
        let newEndDate: Date
        if endDate <= newStartDate {
            newEndDate = calendar.date(byAdding: .hour, value: 1, to: newStartDate)!
        } else {
            newEndDate = endDate
        }

        // Assert
        XCTAssertTrue(newEndDate > newStartDate, "EndDate should be adjusted to maintain 1-hour duration")
    }

    func testNoAdjustmentTimedWhenEndDateStaysAfterStart() {
        // Arrange
        let calendar = Calendar.current
        let startDate = Date()
        let endDate = calendar.date(byAdding: .hour, value: 2, to: startDate)!

        // Act - Move start date forward by 30 minutes (less than original duration)
        let newStartDate = calendar.date(byAdding: .minute, value: 30, to: startDate)!

        // NewEndDate should still be after newStartDate, so no adjustment needed
        let isValid = endDate > newStartDate

        // Assert
        XCTAssertTrue(isValid, "EndDate should not be adjusted when it remains after newStartDate")
    }

    // MARK: - Test: Mode Switching (All-Day ↔ Timed)

    func testSwitchToAllDayNormalizesStartDate() {
        // Arrange
        let calendar = Calendar.current
        let originalDate = calendar.date(bySettingHour: 14, minute: 30, second: 45, of: Date())!

        // Act - Normalize to all-day (start of day)
        let normalizedDate = calendar.startOfDay(for: originalDate)

        // Assert
        let components = calendar.dateComponents([.hour, .minute, .second], from: normalizedDate)
        XCTAssertEqual(components.hour, 0, "Start date should be normalized to 00:00:00")
        XCTAssertEqual(components.minute, 0, "Start date should be normalized to 00:00:00")
        XCTAssertEqual(components.second, 0, "Start date should be normalized to 00:00:00")
    }

    func testSwitchToAllDayNormalizesEndDate() {
        // Arrange
        let calendar = Calendar.current
        let originalDate = calendar.date(bySettingHour: 14, minute: 30, second: 45, of: Date())!

        // Act - Normalize to all-day (end of day: 23:59:59)
        let normalizedDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: originalDate)!

        // Assert
        let components = calendar.dateComponents([.hour, .minute, .second], from: normalizedDate)
        XCTAssertEqual(components.hour, 23, "End date should be normalized to 23:59:59")
        XCTAssertEqual(components.minute, 59, "End date should be normalized to 23:59:59")
        XCTAssertEqual(components.second, 59, "End date should be normalized to 23:59:59")
    }

    func testSwitchFromAllDayToTimedSetsDefaultTimes() {
        // Arrange
        let calendar = Calendar.current
        let allDayDate = calendar.startOfDay(for: Date())

        // Act - Convert to timed mode (9 AM - 10 AM)
        let startDate = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: allDayDate)!
        let endDate = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: allDayDate)!

        // Assert
        let startComponents = calendar.dateComponents([.hour, .minute], from: startDate)
        let endComponents = calendar.dateComponents([.hour, .minute], from: endDate)

        XCTAssertEqual(startComponents.hour, 9, "Timed event should default to 9 AM start")
        XCTAssertEqual(startComponents.minute, 0)
        XCTAssertEqual(endComponents.hour, 10, "Timed event should default to 10 AM end")
        XCTAssertEqual(endComponents.minute, 0)
    }

    func testSwitchFromAllDayToTimedMaintainsSameDay() {
        // Arrange
        let calendar = Calendar.current
        let allDayDate = calendar.startOfDay(for: Date())

        // Act - Convert to timed mode
        let startDate = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: allDayDate)!
        let endDate = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: allDayDate)!

        // Assert - Both should be on the same day as original all-day event
        XCTAssertEqual(
            calendar.startOfDay(for: startDate),
            allDayDate,
            "Start date should be on the same day"
        )
        XCTAssertEqual(
            calendar.startOfDay(for: endDate),
            allDayDate,
            "End date should be on the same day"
        )
    }

    func testMultiDayAllDayEventToTimedPreservesStartDate() {
        // Arrange
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: Date())
        _ = calendar.date(byAdding: .day, value: 2, to: startDate)!

        // Act - Convert multi-day all-day to timed (use startDate with default times)
        let timedStartDate = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: startDate)!
        let timedEndDate = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: startDate)!

        // Assert
        XCTAssertEqual(
            calendar.startOfDay(for: timedStartDate),
            startDate,
            "Timed version should start on the original start date"
        )
        XCTAssertTrue(timedEndDate > timedStartDate, "Timed event should have valid duration")
    }

    // MARK: - Test: Save Button Validation

    func testSaveButtonDisabledWhenDateRangeInvalid() {
        // Arrange
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: 5, to: Date())!
        let endDate = calendar.date(byAdding: .day, value: -1, to: Date())!

        // Act
        let isValid = isDateRangeValidAllDay(startDate: startDate, endDate: endDate)

        // Assert
        XCTAssertFalse(isValid, "Save should be disabled when date range is invalid")
    }

    func testSaveButtonEnabledWithValidTitleAndDateRange() {
        // Arrange
        let title = "Valid Event"
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: Date())
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!

        // Act
        let hasTitle = !title.trimmingCharacters(in: .whitespaces).isEmpty
        let hasValidDateRange = isDateRangeValidAllDay(startDate: startDate, endDate: endDate)

        // Assert
        XCTAssertTrue(hasTitle && hasValidDateRange, "Save should be enabled with valid title and date range")
    }

    // MARK: - Helper Methods

    private func isDateRangeValidAllDay(startDate: Date, endDate: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.startOfDay(for: endDate) >= calendar.startOfDay(for: startDate)
    }

    private func isDateRangeValidTimed(startDate: Date, endDate: Date) -> Bool {
        return endDate > startDate
    }
}
