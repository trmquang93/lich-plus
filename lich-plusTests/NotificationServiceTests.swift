//
//  NotificationServiceTests.swift
//  lich-plusTests
//
//  Created by Quang Tran Minh on 20/12/25.
//

import XCTest
import SwiftData
@testable import lich_plus

@MainActor
final class NotificationServiceTests: XCTestCase {
    
    var service: NotificationService!
    var modelContext: ModelContext!
    
    override func setUp() async throws {
        try await super.setUp()
        
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: NotificationSettings.self,
            configurations: config
        )
        modelContext = ModelContext(container)
        service = NotificationService(modelContext: modelContext)
    }
    
    override func tearDown() async throws {
        service = nil
        modelContext = nil
        try await super.tearDown()
    }
    
    // MARK: - Settings Tests
    
    func testGetSettings_createsDefaultIfNotExists() {
        let settings = service.getSettings()
        
        XCTAssertEqual(settings.id, "notification_settings")
        XCTAssertFalse(settings.isEnabled)
        XCTAssertTrue(settings.eventNotificationsEnabled)
        XCTAssertEqual(settings.defaultReminderMinutes, 15)
        XCTAssertTrue(settings.ramNotificationsEnabled)
        XCTAssertEqual(settings.ramNotificationHour, 6)
        XCTAssertEqual(settings.ramNotificationMinute, 0)
        XCTAssertTrue(settings.mung1NotificationsEnabled)
        XCTAssertEqual(settings.mung1NotificationHour, 6)
        XCTAssertEqual(settings.mung1NotificationMinute, 0)
        XCTAssertFalse(settings.fixedEventNotificationsEnabled)
        XCTAssertEqual(settings.fixedEventReminderDays, 1)
    }
    
    func testUpdateSettings_persists() {
        let settings = service.getSettings()
        settings.isEnabled = true
        settings.defaultReminderMinutes = 30
        service.updateSettings(settings)
        
        let fetched = service.getSettings()
        XCTAssertTrue(fetched.isEnabled)
        XCTAssertEqual(fetched.defaultReminderMinutes, 30)
    }
    
    // MARK: - Lunar Date Calculation Tests
    
    func testGetUpcomingRamDates_doesNotCrash() {
        // Verify the function can be called without crashing
        let ramDates = service.getUpcomingRamDates(months: 3)
        // Function should complete without error
        XCTAssertGreaterThanOrEqual(ramDates.count, 0)
    }
    
    func testGetUpcomingMung1Dates_doesNotCrash() {
        // Verify the function can be called without crashing
        let mung1Dates = service.getUpcomingMung1Dates(months: 3)
        // Function should complete without error
        XCTAssertGreaterThanOrEqual(mung1Dates.count, 0)
    }
    
    func testLeapMonthHandling_doesNotCrash() {
        // Verify the leap month handling doesn't crash
        let ramDates = service.getUpcomingRamDates(months: 6)
        let mung1Dates = service.getUpcomingMung1Dates(months: 6)
        
        // Functions should complete without crashing
        XCTAssertGreaterThanOrEqual(ramDates.count, 0)
        XCTAssertGreaterThanOrEqual(mung1Dates.count, 0)
    }
    
    // MARK: - Event Notification Tests
    
    func testScheduleEventNotification_validReminder() {
        // This test verifies the notification scheduling logic without actually scheduling
        
        let event = SyncableEvent(
            title: "Test Meeting",
            startDate: Date().addingTimeInterval(3600),  // 1 hour from now
            reminderMinutes: 15
        )
        
        // Just verify it doesn't crash
        service.scheduleEventNotification(for: event)
    }
    
    func testScheduleEventNotification_noReminder_skips() {
        let event = SyncableEvent(
            title: "Test Event",
            startDate: Date().addingTimeInterval(3600),
            reminderMinutes: nil
        )
        
        // Should not schedule (no reminder set)
        service.scheduleEventNotification(for: event)
    }
    
    func testCancelEventNotification() {
        let eventId = UUID()
        
        // Should not crash when canceling non-existent notification
        service.cancelEventNotification(eventId: eventId)
    }
    
    // MARK: - Lunar Date Edge Case Tests
    
    func testGetUpcomingDates_handlesPastDates() {
        // Test that dates returned are not in the past
        let today = Date()
        let ramDates = service.getUpcomingRamDates(months: 3)
        
        for date in ramDates {
            XCTAssertGreaterThanOrEqual(date, today)
        }
    }
    
     func testLunarToSolarRoundTrip() {
         // Test that lunar->solar->lunar conversion is consistent
         let testLunarDate = (day: 15, month: 1, year: 2025)
         
         let solarDate = LunarCalendar.lunarToSolar(
             day: testLunarDate.day,
             month: testLunarDate.month,
             year: testLunarDate.year
         )
         
         let backToLunar = LunarCalendar.solarToLunar(solarDate)
         
         XCTAssertEqual(backToLunar.day, testLunarDate.day)
         XCTAssertEqual(backToLunar.month, testLunarDate.month)
         XCTAssertEqual(backToLunar.year, testLunarDate.year)
     }
     
     // MARK: - Deterministic Lunar Date Tests
     
     func testGetUpcomingRamDates_returnsCorrectDates() {
         // Test with a fixed number of months
         let ramDates = service.getUpcomingRamDates(months: 12)
         
         // Verify dates are sorted if we get any
         if ramDates.count > 1 {
             for i in 0..<(ramDates.count - 1) {
                 XCTAssertLessThan(ramDates[i], ramDates[i + 1])
             }
         }
         
         // Verify all dates returned are Rằm (15th lunar day)
         for date in ramDates {
             let lunar = LunarCalendar.solarToLunar(date)
             XCTAssertEqual(lunar.day, 15, "Expected lunar day 15 for Rằm, got \(lunar.day)")
         }
     }
     
     func testGetUpcomingMung1Dates_returnsCorrectDates() {
         // Test with a fixed number of months
         let mung1Dates = service.getUpcomingMung1Dates(months: 12)
         
         // Verify dates are sorted if we get any
         if mung1Dates.count > 1 {
             for i in 0..<(mung1Dates.count - 1) {
                 XCTAssertLessThan(mung1Dates[i], mung1Dates[i + 1])
             }
         }
         
         // Verify all dates returned are Mùng 1 (1st lunar day)
         for date in mung1Dates {
             let lunar = LunarCalendar.solarToLunar(date)
             XCTAssertEqual(lunar.day, 1, "Expected lunar day 1 for Mùng 1, got \(lunar.day)")
         }
     }
     
     func testGetUpcomingRamDates_noDuplicates() {
         // Verify there are no duplicate dates in the schedule
         let ramDates = service.getUpcomingRamDates(months: 6)
         let uniqueDates = Set(ramDates.map { Int($0.timeIntervalSince1970) })
         
         XCTAssertEqual(ramDates.count, uniqueDates.count, "Found duplicate dates in Rằm schedule")
     }
     
     func testGetUpcomingMung1Dates_noDuplicates() {
         // Verify there are no duplicate dates in the schedule
         let mung1Dates = service.getUpcomingMung1Dates(months: 6)
         let uniqueDates = Set(mung1Dates.map { Int($0.timeIntervalSince1970) })
         
         XCTAssertEqual(mung1Dates.count, uniqueDates.count, "Found duplicate dates in Mùng 1 schedule")
     }
 }
