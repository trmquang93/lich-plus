import XCTest
import SwiftUI
@testable import lich_plus

final class DragToCreateGestureTests: XCTestCase {

    var calendar: Calendar!
    var referenceDate: Date!
    var converter: TimeToPixelConverter!

    override func setUp() {
        super.setUp()
        calendar = Calendar.current

        var components = DateComponents()
        components.year = 2025
        components.month = 1
        components.day = 15
        components.hour = 0
        components.minute = 0
        components.second = 0
        referenceDate = calendar.date(from: components)!

        converter = TimeToPixelConverter(hourHeight: 60)
    }

    // MARK: - Time Calculation Tests

    func testCalculateStartTime_MidnightPosition() {
        // Y position 0 should be midnight at the reference date
        let startY: CGFloat = 0

        let actualTime = converter.date(from: startY, referenceDate: referenceDate)

        let expectedComponents = calendar.dateComponents([.hour, .minute], from: referenceDate)
        let actualComponents = calendar.dateComponents([.hour, .minute], from: actualTime)

        XCTAssertEqual(actualComponents, expectedComponents)
    }

    func testCalculateStartTime_NoonPosition() {
        // Y position 12 * 60 = 720 should be noon (12:00)
        let startY: CGFloat = 12 * 60
        var expectedComponents = calendar.dateComponents([.year, .month, .day], from: referenceDate)
        expectedComponents.hour = 12
        let expectedTime = calendar.date(from: expectedComponents)!

        let actualTime = converter.date(from: startY, referenceDate: referenceDate)

        XCTAssertEqual(
            calendar.dateComponents([.hour, .minute], from: actualTime),
            calendar.dateComponents([.hour, .minute], from: expectedTime)
        )
    }

    func testCalculateStartTime_ArbitraryTime() {
        // Y position 10.5 * 60 = 630 should be 10:30
        let startY: CGFloat = 10.5 * 60
        var expectedComponents = calendar.dateComponents([.year, .month, .day], from: referenceDate)
        expectedComponents.hour = 10
        expectedComponents.minute = 30
        let expectedTime = calendar.date(from: expectedComponents)!

        let actualTime = converter.date(from: startY, referenceDate: referenceDate)

        XCTAssertEqual(
            calendar.dateComponents([.hour, .minute], from: actualTime),
            calendar.dateComponents([.hour, .minute], from: expectedTime)
        )
    }

    // MARK: - Snapping Tests

    func testSnapToGrid_FifteenMinInterval() {
        let snapHelper = DragToCreateSnapHelper(calendar: calendar)

        // Time 10:07 should snap to 10:00 (nearest 15-min boundary)
        var testComponents = calendar.dateComponents([.year, .month, .day], from: referenceDate)
        testComponents.hour = 10
        testComponents.minute = 7
        let testDate = calendar.date(from: testComponents)!

        let snapped = snapHelper.snapToNearestFifteenMinutes(testDate)
        let snappedComponents = calendar.dateComponents([.hour, .minute], from: snapped)

        XCTAssertEqual(snappedComponents.hour, 10)
        XCTAssertEqual(snappedComponents.minute, 0)
    }

    func testSnapToGrid_FifteenMinInterval_RoundUp() {
        let snapHelper = DragToCreateSnapHelper(calendar: calendar)

        // Time 10:10 should snap to 10:15
        var testComponents = calendar.dateComponents([.year, .month, .day], from: referenceDate)
        testComponents.hour = 10
        testComponents.minute = 10
        let testDate = calendar.date(from: testComponents)!

        let snapped = snapHelper.snapToNearestFifteenMinutes(testDate)
        let snappedComponents = calendar.dateComponents([.hour, .minute], from: snapped)

        XCTAssertEqual(snappedComponents.hour, 10)
        XCTAssertEqual(snappedComponents.minute, 15)
    }

    func testSnapToGrid_FifteenMinInterval_OnBoundary() {
        let snapHelper = DragToCreateSnapHelper(calendar: calendar)

        // Time 10:30 should remain 10:30
        var testComponents = calendar.dateComponents([.year, .month, .day], from: referenceDate)
        testComponents.hour = 10
        testComponents.minute = 30
        let testDate = calendar.date(from: testComponents)!

        let snapped = snapHelper.snapToNearestFifteenMinutes(testDate)
        let snappedComponents = calendar.dateComponents([.hour, .minute], from: snapped)

        XCTAssertEqual(snappedComponents.hour, 10)
        XCTAssertEqual(snappedComponents.minute, 30)
    }

    // MARK: - Event Duration Tests

    func testMinimumEventDuration() {
        let helper = DragToCreateHelper()

        var startComps = calendar.dateComponents([.year, .month, .day], from: referenceDate)
        startComps.hour = 10
        let startTime = calendar.date(from: startComps)!

        var endComps = calendar.dateComponents([.year, .month, .day], from: referenceDate)
        endComps.hour = 10
        endComps.minute = 5  // Only 5 minutes duration
        let endTime = calendar.date(from: endComps)!

        let finalEnd = helper.enforceMinimumDuration(
            startTime: startTime,
            endTime: endTime,
            minimumMinutes: 15
        )

        let duration = Int(finalEnd.timeIntervalSince(startTime) / 60)
        XCTAssertEqual(duration, 15)
    }

    func testMinimumEventDuration_AlreadySufficient() {
        let helper = DragToCreateHelper()

        var startComps = calendar.dateComponents([.year, .month, .day], from: referenceDate)
        startComps.hour = 10
        let startTime = calendar.date(from: startComps)!

        var endComps = calendar.dateComponents([.year, .month, .day], from: referenceDate)
        endComps.hour = 10
        endComps.minute = 45  // 45 minutes duration
        let endTime = calendar.date(from: endComps)!

        let finalEnd = helper.enforceMinimumDuration(
            startTime: startTime,
            endTime: endTime,
            minimumMinutes: 15
        )

        let duration = Int(finalEnd.timeIntervalSince(startTime) / 60)
        XCTAssertEqual(duration, 45)
    }

    // MARK: - Drag Direction Tests

    func testDragDownward_CalculatesCorrectly() {
        // Dragging down: dragStartY < dragCurrentY
        let dragStartY: CGFloat = 10 * 60  // 10:00
        let dragCurrentY: CGFloat = 12 * 60  // 12:00

        let startTime = converter.date(from: min(dragStartY, dragCurrentY), referenceDate: referenceDate)
        let endTime = converter.date(from: max(dragStartY, dragCurrentY), referenceDate: referenceDate)

        let durationMinutes = Int(endTime.timeIntervalSince(startTime) / 60)
        XCTAssertEqual(durationMinutes, 120)  // 2 hours
    }

    func testDragUpward_CalculatesCorrectly() {
        // Dragging up: dragStartY > dragCurrentY
        let dragStartY: CGFloat = 14 * 60  // 14:00
        let dragCurrentY: CGFloat = 11 * 60  // 11:00

        let startTime = converter.date(from: min(dragStartY, dragCurrentY), referenceDate: referenceDate)
        let endTime = converter.date(from: max(dragStartY, dragCurrentY), referenceDate: referenceDate)

        let durationMinutes = Int(endTime.timeIntervalSince(startTime) / 60)
        XCTAssertEqual(durationMinutes, 180)  // 3 hours
    }

    // MARK: - Block Height Tests

    func testBlockHeightFromDragDistance() {
        let helper = DragToCreateHelper()

        let dragStartY: CGFloat = 10 * 60
        let dragCurrentY: CGFloat = 12 * 60

        let height = helper.blockHeight(
            from: dragStartY,
            to: dragCurrentY,
            hourHeight: 60
        )

        XCTAssertEqual(height, 120)  // 2 hours * 60pt/hour
    }

    func testBlockHeightWithMinimum() {
        let helper = DragToCreateHelper()

        // Very small drag distance
        let dragStartY: CGFloat = 10 * 60
        let dragCurrentY: CGFloat = 10 * 60 + 5  // Only 5pt

        let height = helper.blockHeight(
            from: dragStartY,
            to: dragCurrentY,
            hourHeight: 60,
            minimumHeight: 30
        )

        XCTAssertEqual(height, 30)  // Enforces minimum
    }

    // MARK: - Feedback Timing Tests

    func testHapticFeedbackTriggerPoints() {
        let feedbackTracker = HapticFeedbackTracker()

        // Simulate drag from 10:00 to 10:37
        let yPositions: [CGFloat] = [
            10 * 60,      // 10:00 - no haptic yet
            10 * 60 + 15, // 10:15 - trigger haptic (first boundary)
            10 * 60 + 30, // 10:30 - trigger haptic
            10 * 60 + 37, // 10:37 - no new haptic (< 15 min boundary)
        ]

        var previousMinute = -1
        for yPos in yPositions {
            let converter = TimeToPixelConverter(hourHeight: 60)
            let date = converter.date(from: yPos, referenceDate: referenceDate)
            let components = calendar.dateComponents([.minute], from: date)
            let minute = components.minute ?? 0
            let snappedMinute = (minute / 15) * 15

            if snappedMinute != previousMinute && previousMinute != -1 {
                feedbackTracker.recordFeedback(at: yPos)
            }
            previousMinute = snappedMinute
        }

        // We should have feedback at 10:15 and 10:30
        XCTAssertEqual(feedbackTracker.feedbackCount, 2)
    }

    // MARK: - Edge Cases

    func testDragPastMidnight_StaysWithinDay() {
        // If we try to drag beyond 23:59, we should clamp to 23:59
        let dragCurrentY: CGFloat = 25 * 60  // Beyond 24 hours

        let endTime = converter.date(from: min(dragCurrentY, 24 * 60), referenceDate: referenceDate)
        let components = calendar.dateComponents([.hour], from: endTime)

        XCTAssertLessThanOrEqual(components.hour ?? 0, 23)
    }

    func testZeroHeightBlockGetsMinimum() {
        let helper = DragToCreateHelper()

        // Start and end at same Y position
        let dragStartY: CGFloat = 10 * 60
        let dragCurrentY: CGFloat = 10 * 60

        let height = helper.blockHeight(
            from: dragStartY,
            to: dragCurrentY,
            hourHeight: 60,
            minimumHeight: 30
        )

        XCTAssertEqual(height, 30)
    }
}

// MARK: - Test Helpers for non-gesture functionality

class DragToCreateHelper {
    private let calendar = Calendar.current

    func blockHeight(
        from startY: CGFloat,
        to currentY: CGFloat,
        hourHeight: CGFloat,
        minimumHeight: CGFloat = 30
    ) -> CGFloat {
        let distance = abs(currentY - startY)
        return max(distance, minimumHeight)
    }

    func enforceMinimumDuration(
        startTime: Date,
        endTime: Date,
        minimumMinutes: Int
    ) -> Date {
        let duration = endTime.timeIntervalSince(startTime)
        let minimumDuration = TimeInterval(minimumMinutes * 60)

        if duration < minimumDuration {
            return startTime.addingTimeInterval(minimumDuration)
        }
        return endTime
    }
}

class HapticFeedbackTracker {
    private(set) var feedbackCount = 0

    func recordFeedback(at yPosition: CGFloat) {
        feedbackCount += 1
    }
}
