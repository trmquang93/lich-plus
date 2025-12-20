import XCTest
import Foundation
@testable import lich_plus

final class TimelineConfigurationTests: XCTestCase {

    func testDefaultScaleIsTirtyMin() {
        let config = TimelineConfiguration()
        XCTAssertEqual(config.currentScale, .thirtyMin)
    }

    func testFifteenMinScaleHasCorrectHeight() {
        var config = TimelineConfiguration()
        config.currentScale = .fifteenMin
        XCTAssertEqual(config.hourHeight, 120)
    }

    func testThirtyMinScaleHasCorrectHeight() {
        var config = TimelineConfiguration()
        config.currentScale = .thirtyMin
        XCTAssertEqual(config.hourHeight, 60)
    }

    func testOneHourScaleHasCorrectHeight() {
        var config = TimelineConfiguration()
        config.currentScale = .oneHour
        XCTAssertEqual(config.hourHeight, 40)
    }

    func testTotalHeightCalculation() {
        var config = TimelineConfiguration()

        config.currentScale = .fifteenMin
        XCTAssertEqual(config.totalHeight, 120 * 24)

        config.currentScale = .thirtyMin
        XCTAssertEqual(config.totalHeight, 60 * 24)

        config.currentScale = .oneHour
        XCTAssertEqual(config.totalHeight, 40 * 24)
    }

    func testRulerWidthConstant() {
        XCTAssertEqual(TimelineConfiguration.rulerWidth, 50)
    }

    func testAllDayHeightConstant() {
        XCTAssertEqual(TimelineConfiguration.allDayHeight, 60)
    }

    func testHeaderHeightConstant() {
        XCTAssertEqual(TimelineConfiguration.headerHeight, 100)
    }

    func testNowIndicatorHeightConstant() {
        XCTAssertEqual(TimelineConfiguration.nowIndicatorHeight, 20)
    }
}

final class TimeToPixelConverterTests: XCTestCase {

    var converter: TimeToPixelConverter!
    var calendar: Calendar!
    var referenceDate: Date!

    override func setUp() {
        super.setUp()
        calendar = Calendar.current
        converter = TimeToPixelConverter(hourHeight: 60)

        var components = DateComponents()
        components.year = 2025
        components.month = 1
        components.day = 15
        components.hour = 0
        components.minute = 0
        components.second = 0
        referenceDate = calendar.date(from: components)!
    }

    func testMidnightPositionIsZero() {
        let yPosition = converter.yPosition(for: referenceDate)
        XCTAssertEqual(yPosition, 0, accuracy: 0.1)
    }

    func testNoonPositionIs12HoursDown() {
        var components = calendar.dateComponents([.year, .month, .day], from: referenceDate)
        components.hour = 12
        let noonDate = calendar.date(from: components)!

        let yPosition = converter.yPosition(for: noonDate)
        XCTAssertEqual(yPosition, 12 * 60, accuracy: 0.1)
    }

    func testThreeAMPositionIsCorrect() {
        var components = calendar.dateComponents([.year, .month, .day], from: referenceDate)
        components.hour = 3
        let threeAMDate = calendar.date(from: components)!

        let yPosition = converter.yPosition(for: threeAMDate)
        XCTAssertEqual(yPosition, 3 * 60, accuracy: 0.1)
    }

    func testBlockHeightForOneHourEvent() {
        var startComponents = calendar.dateComponents([.year, .month, .day], from: referenceDate)
        startComponents.hour = 10
        let startDate = calendar.date(from: startComponents)!

        var endComponents = calendar.dateComponents([.year, .month, .day], from: referenceDate)
        endComponents.hour = 11
        let endDate = calendar.date(from: endComponents)!

        let height = converter.blockHeight(start: startDate, end: endDate)
        XCTAssertEqual(height, 60, accuracy: 0.1)
    }

    func testCurrentTimeYReturnsValidPosition() {
        let currentY = converter.currentTimeY()
        XCTAssertGreaterThan(currentY, 0)
        XCTAssertLessThan(currentY, 24 * 60)
    }

    func testSnapToGridFifteenMinSnapsCorrectly() {
        let baseY: CGFloat = 10 * 60
        let offsetY: CGFloat = 7 * 60 / 60.0
        let unsnappedY = baseY + offsetY

        let snappedY = converter.snapToGrid(unsnappedY, scale: .fifteenMin)

        let possibleSnapPoints: [CGFloat] = [baseY, baseY + 15 * 60.0 / 60.0]
        let isSnapped = possibleSnapPoints.contains { abs(snappedY - $0) < 1 }
        XCTAssertTrue(isSnapped)
    }
}

final class ConcurrentEventResolverTests: XCTestCase {

    var resolver: ConcurrentEventResolver!
    var converter: TimeToPixelConverter!
    var calendar: Calendar!
    var referenceDate: Date!

    override func setUp() {
        super.setUp()
        calendar = Calendar.current
        converter = TimeToPixelConverter(hourHeight: 60)
        resolver = ConcurrentEventResolver(converter: converter)

        var components = DateComponents()
        components.year = 2025
        components.month = 1
        components.day = 15
        components.hour = 0
        referenceDate = calendar.date(from: components)!
    }

    func testSingleEventReturnsOnePosition() {
        let event = createEvent(title: "Meeting", startHour: 10, endHour: 11)
        let positioned = resolver.resolvePositions(events: [event])

        XCTAssertEqual(positioned.count, 1)
        XCTAssertEqual(positioned[0].column, 0)
        XCTAssertEqual(positioned[0].totalColumns, 1)
        XCTAssertEqual(positioned[0].widthFraction, 1.0)
        XCTAssertEqual(positioned[0].xOffset, 0.0)
    }

    func testAllDayEventIsIgnored() {
        let allDayEvent = createAllDayEvent(title: "Birthday")
        let timedEvent = createEvent(title: "Meeting", startHour: 10, endHour: 11)

        let positioned = resolver.resolvePositions(events: [allDayEvent, timedEvent])

        XCTAssertEqual(positioned.count, 1)
        XCTAssertEqual(positioned[0].event.title, "Meeting")
    }

    func testTwoCompletelyOverlappingEventsAreSideBySide() {
        let event1 = createEvent(title: "Event A", startHour: 10, endHour: 11)
        let event2 = createEvent(title: "Event B", startHour: 10, endHour: 11)

        let positioned = resolver.resolvePositions(events: [event1, event2])

        XCTAssertEqual(positioned.count, 2)
        XCTAssertTrue(positioned.allSatisfy { $0.totalColumns == 2 })
        XCTAssertTrue(positioned.allSatisfy { $0.widthFraction == 0.5 })

        let columns = Set(positioned.map { $0.column })
        XCTAssertEqual(columns, Set([0, 1]))
    }

    private func createEvent(
        title: String,
        startHour: Int,
        startMinute: Int = 0,
        endHour: Int,
        endMinute: Int = 0
    ) -> TaskItem {
        var startComps = calendar.dateComponents([.year, .month, .day], from: referenceDate)
        startComps.hour = startHour
        startComps.minute = startMinute
        let startTime = calendar.date(from: startComps)!

        var endComps = calendar.dateComponents([.year, .month, .day], from: referenceDate)
        endComps.hour = endHour
        endComps.minute = endMinute
        let endTime = calendar.date(from: endComps)!

        return TaskItem(
            title: title,
            date: referenceDate,
            startTime: startTime,
            endTime: endTime,
            itemType: .event
        )
    }

    private func createAllDayEvent(title: String) -> TaskItem {
        return TaskItem(
            title: title,
            date: referenceDate,
            startTime: nil,
            endTime: nil,
            itemType: .event
        )
    }
}
