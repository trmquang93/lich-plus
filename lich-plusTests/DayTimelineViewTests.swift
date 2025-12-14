import XCTest
import SwiftUI
@testable import lich_plus

final class DayTimelineViewTests: XCTestCase {

    // MARK: - Setup

    let testDate = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date())!
    let hoangDaoHours: Set<Int> = [0, 1, 4, 5, 7, 10]

    // MARK: - Event Positioning Tests

    func testPositionedEventsIncludesOnlyTimedEvents() {
        // Given: Mix of timed and all-day events
        let timedEvent = TaskItem(
            title: "Team Meeting",
            date: testDate,
            startTime: Calendar.current.date(byAdding: .hour, value: 2, to: testDate),
            endTime: Calendar.current.date(byAdding: .hour, value: 3, to: testDate),
            category: .meeting,
            itemType: .event
        )

        let allDayEvent = TaskItem(
            title: "Holiday",
            date: testDate,
            category: .holiday,
            itemType: .event
        )

        let events = [timedEvent, allDayEvent]
        let resolver = ConcurrentEventResolver(converter: TimeToPixelConverter(hourHeight: 60))

        // When: Resolving positions
        let positioned = resolver.resolvePositions(events: events)

        // Then: Only timed event is included
        XCTAssertEqual(positioned.count, 1)
        XCTAssertEqual(positioned[0].event.id, timedEvent.id)
    }

    func testSingleEventPositioning() {
        // Given: Single event
        let event = TaskItem(
            title: "Meeting",
            date: testDate,
            startTime: Calendar.current.date(byAdding: .hour, value: 14, to: testDate),
            endTime: Calendar.current.date(byAdding: .hour, value: 15, to: testDate),
            category: .meeting,
            itemType: .event
        )

        let resolver = ConcurrentEventResolver(converter: TimeToPixelConverter(hourHeight: 60))

        // When: Resolving position
        let positioned = resolver.resolvePositions(events: [event])

        // Then: Event has full width
        XCTAssertEqual(positioned.count, 1)
        XCTAssertEqual(positioned[0].widthFraction, 1.0)
        XCTAssertEqual(positioned[0].xOffset, 0.0)
        XCTAssertEqual(positioned[0].column, 0)
        XCTAssertEqual(positioned[0].totalColumns, 1)
    }

    func testOverlappingEventsPositioning() {
        // Given: Two overlapping events
        let startTime = Calendar.current.date(byAdding: .hour, value: 14, to: testDate)!
        let event1 = TaskItem(
            title: "Event 1",
            date: testDate,
            startTime: startTime,
            endTime: Calendar.current.date(byAdding: .hour, value: 1, to: startTime)!,
            category: .work,
            itemType: .event
        )

        let event2 = TaskItem(
            title: "Event 2",
            date: testDate,
            startTime: Calendar.current.date(byAdding: .minute, value: 30, to: startTime)!,
            endTime: Calendar.current.date(byAdding: .hour, value: 1, to: startTime)!,
            category: .personal,
            itemType: .event
        )

        let resolver = ConcurrentEventResolver(converter: TimeToPixelConverter(hourHeight: 60))

        // When: Resolving positions
        let positioned = resolver.resolvePositions(events: [event1, event2])

        // Then: Both events have half width, side-by-side
        XCTAssertEqual(positioned.count, 2)
        XCTAssertEqual(positioned[0].widthFraction, 0.5)
        XCTAssertEqual(positioned[1].widthFraction, 0.5)
        XCTAssertEqual(positioned[0].xOffset, 0.0)
        XCTAssertEqual(positioned[1].xOffset, 0.5)
    }

    // MARK: - Event State Tests

    func testEventIsPastWhenBeforeCurrent() {
        // Given: Event that ended 1 hour ago
        let pastStartTime = Calendar.current.date(byAdding: .hour, value: -2, to: Date())!
        let pastEndTime = Calendar.current.date(byAdding: .hour, value: -1, to: Date())!

        let event = TaskItem(
            title: "Past Event",
            date: pastStartTime,
            startTime: pastStartTime,
            endTime: pastEndTime,
            category: .work,
            itemType: .event
        )

        // When: Check if event is in past
        let currentTime = Date()
        let isPast = (event.endTime ?? event.startTime ?? event.date) < currentTime

        // Then: Event is marked as past
        XCTAssertTrue(isPast)
    }

    func testEventIsCurrentWhenContainsNow() {
        // Given: Event that runs through current time
        let startTime = Calendar.current.date(byAdding: .hour, value: -1, to: Date())!
        let endTime = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!

        let event = TaskItem(
            title: "Current Event",
            date: startTime,
            startTime: startTime,
            endTime: endTime,
            category: .work,
            itemType: .event
        )

        // When: Check if event is current
        let currentTime = Date()
        let isCurrent = (event.startTime ?? event.date) <= currentTime && currentTime < (event.endTime ?? event.date)

        // Then: Event is marked as current
        XCTAssertTrue(isCurrent)
    }

    // MARK: - Configuration Tests

    func testDefaultConfigurationScale() {
        let config = TimelineConfiguration()
        XCTAssertEqual(config.currentScale, .thirtyMin)
        XCTAssertEqual(config.hourHeight, 60)
    }

    func testConfigurationTotalHeight() {
        let config = TimelineConfiguration()
        // 24 hours * 60 points/hour = 1440
        XCTAssertEqual(config.totalHeight, 1440)
    }

    // MARK: - Time Position Tests

    func testNowIndicatorYPosition() {
        // Given: Current time
        let now = Date()
        let converter = TimeToPixelConverter(hourHeight: 60)

        // When: Calculate Y position for now
        let yPosition = converter.yPosition(for: now)

        // Then: Y position is non-negative
        XCTAssertGreaterThanOrEqual(yPosition, 0)
        // And less than total timeline height
        XCTAssertLessThanOrEqual(yPosition, 24 * 60)
    }

    func testMidnightYPosition() {
        // Given: Midnight
        let midnight = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
        let converter = TimeToPixelConverter(hourHeight: 60)

        // When: Calculate Y position for midnight
        let yPosition = converter.yPosition(for: midnight)

        // Then: Y position is 0
        XCTAssertEqual(yPosition, 0)
    }

    func testNoonYPosition() {
        // Given: Noon (12:00)
        let noon = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date())!
        let converter = TimeToPixelConverter(hourHeight: 60)

        // When: Calculate Y position for noon
        let yPosition = converter.yPosition(for: noon)

        // Then: Y position is 12 * 60 = 720
        XCTAssertEqual(yPosition, 720)
    }

    // MARK: - Helper Methods

    private func createTestEvent(
        startHour: Int,
        durationHours: Int,
        on date: Date
    ) -> TaskItem {
        let startTime = Calendar.current.date(byAdding: .hour, value: startHour, to: Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: date)!)!
        let endTime = Calendar.current.date(byAdding: .hour, value: durationHours, to: startTime)!

        return TaskItem(
            title: "Test Event",
            date: date,
            startTime: startTime,
            endTime: endTime,
            category: .work,
            itemType: .event
        )
    }
}
