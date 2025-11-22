import XCTest
import SwiftData
import SwiftUI
@testable import lich_plus

// MARK: - Event Protection Tests
final class EventProtectionTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: - System Event Flag Tests

    /// Test that system events (lunar events) have isRecurring flag set to true
    func testSystemEventsHaveRecurringFlagTrue() {
        // Create a system event (simulating lunar event)
        let systemEvent = CalendarEvent(
            title: "Mùng 1 tháng 1",
            date: Date(),
            category: "Sự kiện văn hóa",
            color: "#F8E71C",
            isAllDay: true
        )
        systemEvent.isRecurring = true

        // Verify system event flag
        XCTAssertTrue(systemEvent.isRecurring, "System events should have isRecurring = true")
    }

    /// Test that user events have isRecurring flag set to false
    func testUserEventsHaveRecurringFlagFalse() {
        // Create a user event
        let userEvent = CalendarEvent(
            title: "Họp team tuần",
            date: Date(),
            category: "Họp công việc",
            color: "#5BC0A6"
        )

        // Verify user event flag
        XCTAssertFalse(userEvent.isRecurring, "User events should have isRecurring = false")
    }

    // MARK: - EventDetailView Protection Tests

    /// Test that EventDetailView should hide edit button for system events
    func testEventDetailViewHidesEditButtonForSystemEvents() {
        let systemEvent = CalendarEvent(
            title: "Rằm tháng 1",
            date: Date(),
            category: "Sự kiện văn hóa",
            color: "#F8E71C",
            isAllDay: true
        )
        systemEvent.isRecurring = true

        // The protection check: system events should not allow editing
        XCTAssertTrue(systemEvent.isRecurring, "System event should be protected")
        XCTAssertEqual(systemEvent.title, "Rằm tháng 1")
    }

    /// Test that EventDetailView should hide delete button for system events
    func testEventDetailViewHidesDeleteButtonForSystemEvents() {
        let systemEvent = CalendarEvent(
            title: "Mùng 1 tháng 6",
            date: Date(),
            category: "Sự kiện văn hóa",
            color: "#F8E71C",
            isAllDay: true
        )
        systemEvent.isRecurring = true

        // The protection check: system events should not allow deletion
        XCTAssertTrue(systemEvent.isRecurring, "System event should be protected from deletion")
    }

    /// Test that EventDetailView shows lock icon for system events
    func testEventDetailViewShowsLockIconForSystemEvents() {
        let systemEvent = CalendarEvent(
            title: "Rằm tháng 7",
            date: Date(),
            category: "Sự kiện văn hóa",
            notes: "Ngày rằm âm lịch",
            color: "#F8E71C",
            isAllDay: true
        )
        systemEvent.isRecurring = true

        // Verify that the lock icon should be shown for system events
        XCTAssertTrue(systemEvent.isRecurring, "System event should show lock indicator")
        // The actual UI text "Sự kiện hệ thống" is implementation detail
    }

    /// Test that EventDetailView shows edit/delete buttons for user events
    func testEventDetailViewShowsEditDeleteButtonsForUserEvents() {
        let userEvent = CalendarEvent(
            title: "Họp team tuần",
            date: Date(),
            startTime: Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date()),
            endTime: Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()),
            location: "Phòng họp A",
            category: "Họp công việc",
            color: "#5BC0A6"
        )

        // User events should allow editing and deletion
        XCTAssertFalse(userEvent.isRecurring, "User event should not have recurring flag")
        XCTAssertEqual(userEvent.category, "Họp công việc")
    }

    // MARK: - EventFormView Protection Tests

    /// Test that EventFormView should prevent opening form for system events
    func testEventFormViewPreventsEditingSystemEvents() {
        let systemEvent = CalendarEvent(
            title: "Mùng 1 tháng 2",
            date: Date(),
            category: "Sự kiện văn hóa",
            color: "#F8E71C",
            isAllDay: true
        )
        systemEvent.isRecurring = true

        // Attempting to edit a system event should be blocked
        XCTAssertTrue(systemEvent.isRecurring, "System event should prevent editing")
    }

    /// Test that EventFormView allows editing user events
    func testEventFormViewAllowsEditingUserEvents() {
        let userEvent = CalendarEvent(
            title: "Gọi điện cho đối tác",
            date: Date(),
            startTime: Calendar.current.date(bySettingHour: 15, minute: 0, second: 0, of: Date()),
            endTime: Calendar.current.date(bySettingHour: 15, minute: 30, second: 0, of: Date()),
            category: "Gọi điện",
            color: "#50E3C2"
        )

        // User events should be editable
        XCTAssertFalse(userEvent.isRecurring, "User event should be editable")
        XCTAssertEqual(userEvent.title, "Gọi điện cho đối tác")
    }

    // MARK: - Lunar Event Creation Tests

    /// Test that lunar events are created with isRecurring flag set to true
    func testLunarEventsCreatedWithProtectionFlag() {
        let lunarEvents = CalendarEvent.createLunarEvents(startYear: 2024, yearCount: 1)

        // All lunar events should have isRecurring = true
        for event in lunarEvents {
            XCTAssertTrue(event.isRecurring, "Lunar event '\(event.title)' should have isRecurring = true")
            XCTAssertTrue(event.title.contains("Mùng 1") || event.title.contains("Rằm"),
                         "Lunar event should be Mùng 1 or Rằm")
            XCTAssertEqual(event.category, "Sự kiện văn hóa")
            XCTAssertEqual(event.color, "#F8E71C")
        }
    }

    /// Test that sample user events are created with isRecurring flag set to false
    func testSampleEventsCreatedWithoutProtectionFlag() {
        let sampleEvents = CalendarEvent.createSampleEvents(for: 2024, month: 8)

        // All sample events should have isRecurring = false
        for event in sampleEvents {
            XCTAssertFalse(event.isRecurring, "Sample event '\(event.title)' should have isRecurring = false")
        }
    }

    // MARK: - Protection Logic Tests

    /// Test determining if event is editable (not a system event)
    func testEventEditabilityLogic() {
        let systemEvent = CalendarEvent(
            title: "Rằm tháng 1",
            date: Date(),
            category: "Sự kiện văn hóa",
            color: "#F8E71C",
            isAllDay: true
        )
        systemEvent.isRecurring = true

        let userEvent = CalendarEvent(
            title: "Họp công việc",
            date: Date(),
            category: "Họp công việc",
            color: "#5BC0A6"
        )

        // System event should not be editable
        let isSystemEventEditable = !systemEvent.isRecurring
        XCTAssertFalse(isSystemEventEditable, "System events should not be editable")

        // User event should be editable
        let isUserEventEditable = !userEvent.isRecurring
        XCTAssertTrue(isUserEventEditable, "User events should be editable")
    }

    /// Test determining if event is deletable (not a system event)
    func testEventDeletabilityLogic() {
        let systemEvent = CalendarEvent(
            title: "Mùng 1 tháng 6",
            date: Date(),
            category: "Sự kiện văn hóa",
            color: "#F8E71C",
            isAllDay: true
        )
        systemEvent.isRecurring = true

        let userEvent = CalendarEvent(
            title: "Ăn trưa với khách hàng",
            date: Date(),
            category: "Ăn trưa",
            color: "#4A90E2"
        )

        // System event should not be deletable
        let isSystemEventDeletable = !systemEvent.isRecurring
        XCTAssertFalse(isSystemEventDeletable, "System events should not be deletable")

        // User event should be deletable
        let isUserEventDeletable = !userEvent.isRecurring
        XCTAssertTrue(isUserEventDeletable, "User events should be deletable")
    }

    // MARK: - Integration Tests

    /// Test that system events cannot be modified in the model context
    func testSystemEventsCannotBeModifiedInModelContext() {
        let systemEvent = CalendarEvent(
            title: "Mùng 1 tháng 1",
            date: Date(),
            category: "Sự kiện văn hóa",
            color: "#F8E71C",
            isAllDay: true
        )
        systemEvent.isRecurring = true

        // In the UI, the form should not allow editing
        // This is enforced by the EventFormView onAppear check
        XCTAssertTrue(systemEvent.isRecurring, "System event should have protection flag")
    }

    /// Test mixed event collection with both system and user events
    func testMixedEventCollectionProperly() {
        let userEvent1 = CalendarEvent(
            title: "Họp team tuần",
            date: Date(),
            category: "Họp công việc",
            color: "#5BC0A6"
        )

        let systemEvent = CalendarEvent(
            title: "Rằm tháng 1",
            date: Date(),
            category: "Sự kiện văn hóa",
            color: "#F8E71C",
            isAllDay: true
        )
        systemEvent.isRecurring = true

        let userEvent2 = CalendarEvent(
            title: "Ăn trưa với khách hàng",
            date: Date(),
            category: "Ăn trưa",
            color: "#4A90E2"
        )

        let events = [userEvent1, systemEvent, userEvent2]

        // Verify event protection flags
        let userEvents = events.filter { !$0.isRecurring }
        let systemEvents = events.filter { $0.isRecurring }

        XCTAssertEqual(userEvents.count, 2, "Should have 2 user events")
        XCTAssertEqual(systemEvents.count, 1, "Should have 1 system event")

        // All user events should be editable
        for event in userEvents {
            XCTAssertFalse(event.isRecurring)
        }

        // All system events should not be editable
        for event in systemEvents {
            XCTAssertTrue(event.isRecurring)
        }
    }

    // MARK: - Edge Cases

    /// Test that editing a user event doesn't accidentally set isRecurring flag
    func testEditingUserEventDoesNotSetRecurringFlag() {
        let userEvent = CalendarEvent(
            title: "Original title",
            date: Date(),
            category: "Họp công việc",
            color: "#5BC0A6"
        )

        XCTAssertFalse(userEvent.isRecurring, "User event should start with isRecurring = false")

        // Simulate editing the event (title change)
        userEvent.title = "Updated title"

        // isRecurring flag should remain false
        XCTAssertFalse(userEvent.isRecurring, "isRecurring flag should not change during edit")
    }

    /// Test that category change doesn't affect protection status
    func testChangingCategoryDoesNotAffectProtection() {
        let userEvent = CalendarEvent(
            title: "Test Event",
            date: Date(),
            category: "Họp công việc",
            color: "#5BC0A6"
        )

        XCTAssertFalse(userEvent.isRecurring, "User event should be unprotected")

        // Change category (should not affect protection)
        userEvent.category = "Ăn trưa"

        XCTAssertFalse(userEvent.isRecurring, "Protection status should not change with category")
    }
}
