import XCTest
@testable import lich_plus

// MARK: - Calendar Event Tests
final class CalendarEventTests: XCTestCase {

    // MARK: - Test Event Creation
    func testEventCreation() {
        let title = "Họp team"
        let date = Date()
        let location = "Phòng họp A"
        let category = "Họp công việc"
        let color = "#5BC0A6"

        let event = CalendarEvent(
            title: title,
            date: date,
            location: location,
            category: category,
            color: color
        )

        XCTAssertEqual(event.title, title)
        XCTAssertEqual(event.location, location)
        XCTAssertEqual(event.category, category)
        XCTAssertEqual(event.color, color)
        XCTAssertEqual(event.isAllDay, false)
    }

    // MARK: - Test All Day Event
    func testAllDayEvent() {
        let event = CalendarEvent(
            title: "Lễ Vu Lan",
            date: Date(),
            isAllDay: true
        )

        XCTAssertTrue(event.isAllDay)
        XCTAssertNil(event.startTime)
        XCTAssertNil(event.endTime)
    }

    // MARK: - Test Event with Time Range
    func testEventWithTimeRange() {
        let calendar = Calendar.current
        let date = Date()
        let startTime = calendar.date(bySettingHour: 7, minute: 0, second: 0, of: date)
        let endTime = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: date)

        let event = CalendarEvent(
            title: "Họp team",
            date: date,
            startTime: startTime,
            endTime: endTime
        )

        XCTAssertNotNil(event.startTime)
        XCTAssertNotNil(event.endTime)
        XCTAssertNotNil(event.timeRangeString)
    }

    // MARK: - Test Event String Formats
    func testEventStringFormats() {
        let date = Date()
        let event = CalendarEvent(
            title: "Test Event",
            date: date
        )

        XCTAssertFalse(event.dateString.isEmpty)
        XCTAssertFalse(event.dateWithDayString.isEmpty)
    }

    // MARK: - Test Sample Events Creation
    func testSampleEventsCreation() {
        let sampleEvents = CalendarEvent.createSampleEvents(for: 2024, month: 8)

        XCTAssertGreaterThan(sampleEvents.count, 0)
        XCTAssertEqual(sampleEvents.count, 10)
    }

    // MARK: - Test Sample Event Properties
    func testSampleEventProperties() {
        let sampleEvents = CalendarEvent.createSampleEvents(for: 2024, month: 8)

        // Check first event
        let firstEvent = sampleEvents.first
        XCTAssertEqual(firstEvent?.title, "Họp team tuần")
        XCTAssertEqual(firstEvent?.category, "Họp công việc")
        XCTAssertEqual(firstEvent?.color, "#5BC0A6")

        // Check all day event
        let allDayEvent = sampleEvents.first { $0.isAllDay }
        XCTAssertNotNil(allDayEvent)
    }

    // MARK: - Test Event with Location
    func testEventWithLocation() {
        let location = "Nhà hàng Việt Thắng"
        let event = CalendarEvent(
            title: "Ăn trưa",
            date: Date(),
            location: location
        )

        XCTAssertEqual(event.location, location)
    }

    // MARK: - Test Event without Optional Fields
    func testEventWithoutOptionalFields() {
        let event = CalendarEvent(
            title: "Simple Event",
            date: Date()
        )

        XCTAssertNil(event.location)
        XCTAssertNil(event.notes)
        XCTAssertNil(event.startTime)
        XCTAssertNil(event.endTime)
    }
}
