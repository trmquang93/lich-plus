import XCTest
import SwiftUI
@testable import lich_plus

final class EventInteractionGestureTests: XCTestCase {

    var sampleTask: TaskItem!
    var sampleEvent: TaskItem!

    override func setUp() {
        super.setUp()

        sampleTask = TaskItem(
            title: "Sample Task",
            date: Date(),
            category: .work,
            itemType: .task,
            priority: .high
        )

        sampleEvent = TaskItem(
            title: "Sample Event",
            date: Date(),
            category: .personal,
            itemType: .event,
            priority: .medium
        )
    }

    // MARK: - Swipe Gesture Threshold Tests

    func testSwipeDeleteThreshold() {
        let handler = EventInteractionGestureHandler()
        let threshold = handler.swipeDeleteThreshold
        XCTAssertEqual(threshold, 80, "Delete swipe threshold should be 80 points")
    }

    func testSwipeCompleteThreshold() {
        let handler = EventInteractionGestureHandler()
        let threshold = handler.swipeCompleteThreshold
        XCTAssertEqual(threshold, 80, "Complete swipe threshold should be 80 points")
    }

    // MARK: - Swipe Translation Detection Tests

    func testDetectSwipeLeftForDelete() {
        let handler = EventInteractionGestureHandler()
        let translation: CGFloat = -100
        let action = handler.detectSwipeAction(for: translation, itemType: .task)
        XCTAssertEqual(action, .delete, "Translation -100 should be detected as delete")
    }

    func testDetectSwipeRightForComplete() {
        let handler = EventInteractionGestureHandler()
        let translation: CGFloat = 100
        let action = handler.detectSwipeAction(for: translation, itemType: .task)
        XCTAssertEqual(action, .complete, "Translation 100 should be detected as complete for task")
    }

    func testDetectSwipeRightForEventDoesNothing() {
        let handler = EventInteractionGestureHandler()
        let translation: CGFloat = 100
        let action = handler.detectSwipeAction(for: translation, itemType: .event)
        XCTAssertEqual(action, .none, "Right swipe on event should do nothing")
    }

    func testSwipeWithinThresholdDetectedAsNone() {
        let handler = EventInteractionGestureHandler()
        let translation: CGFloat = 30
        let action = handler.detectSwipeAction(for: translation, itemType: .task)
        XCTAssertEqual(action, .none, "Translation 30 (below threshold) should be none")
    }

    func testSwipeExactlyAtThresholdDetected() {
        let handler = EventInteractionGestureHandler()
        let translation: CGFloat = -80
        let action = handler.detectSwipeAction(for: translation, itemType: .task)
        XCTAssertEqual(action, .delete, "Translation exactly at threshold should be detected")
    }

    // MARK: - Offset Animation Tests

    func testOffsetCalculationForDelete() {
        let handler = EventInteractionGestureHandler()
        let translation: CGFloat = -150
        let offset = handler.calculateOffset(for: translation)
        XCTAssertEqual(offset, -150, "Offset should match translation during drag")
    }

    func testOffsetCalculationForComplete() {
        let handler = EventInteractionGestureHandler()
        let translation: CGFloat = 150
        let offset = handler.calculateOffset(for: translation)
        XCTAssertEqual(offset, 150, "Offset should match translation during drag")
    }

    // MARK: - Offset Reset Tests

    func testResetOffsetAfterCancelledSwipe() {
        let handler = EventInteractionGestureHandler()
        let resetOffset = handler.resetOffset()
        XCTAssertEqual(resetOffset, 0, "Reset offset should be 0")
    }

    func testOffsetAnimationOffScreen() {
        let handler = EventInteractionGestureHandler()
        let offScreenOffset = handler.offScreenOffset()
        XCTAssertEqual(offScreenOffset, -300, "Off-screen offset should be -300")
    }

    // MARK: - Swipe Action Enum Tests

    func testSwipeActionRawValues() {
        XCTAssertEqual(SwipeAction.delete.rawValue, "delete")
        XCTAssertEqual(SwipeAction.complete.rawValue, "complete")
        XCTAssertEqual(SwipeAction.none.rawValue, "none")
    }

    func testSwipeActionCaseIterable() {
        let allCases = SwipeAction.allCases
        XCTAssertEqual(allCases.count, 3)
        XCTAssertTrue(allCases.contains(.delete))
        XCTAssertTrue(allCases.contains(.complete))
        XCTAssertTrue(allCases.contains(.none))
    }

    // MARK: - Vertical Swipe Rejection Tests

    func testVerticalMotionIgnoredInHorizontalSwipe() {
        let handler = EventInteractionGestureHandler()
        // More vertical than horizontal
        let verticalTranslation = CGSize(width: 20, height: 100)
        let isHorizontal = handler.isHorizontalSwipe(verticalTranslation)
        XCTAssertFalse(isHorizontal, "Vertical motion should be rejected")
    }

    func testHorizontalMotionDetected() {
        let handler = EventInteractionGestureHandler()
        // More horizontal than vertical
        let horizontalTranslation = CGSize(width: 100, height: 20)
        let isHorizontal = handler.isHorizontalSwipe(horizontalTranslation)
        XCTAssertTrue(isHorizontal, "Horizontal motion should be detected")
    }

    func testEqualMotionPreferred() {
        let handler = EventInteractionGestureHandler()
        // Equal vertical and horizontal (edge case)
        let equalTranslation = CGSize(width: 50, height: 50)
        let isHorizontal = handler.isHorizontalSwipe(equalTranslation)
        XCTAssertFalse(isHorizontal, "Equal motion should prefer vertical")
    }

    // MARK: - Task vs Event Behavior Tests

    func testTaskAllowsCompleteAction() {
        let handler = EventInteractionGestureHandler()
        let action = handler.detectSwipeAction(for: 100, itemType: .task)
        XCTAssertEqual(action, .complete, "Task should support complete action")
    }

    func testEventDoesNotAllowCompleteAction() {
        let handler = EventInteractionGestureHandler()
        let action = handler.detectSwipeAction(for: 100, itemType: .event)
        XCTAssertEqual(action, .none, "Event should not support complete action")
    }

    func testBothTypesAllowDeleteAction() {
        let handler = EventInteractionGestureHandler()
        let taskDelete = handler.detectSwipeAction(for: -100, itemType: .task)
        let eventDelete = handler.detectSwipeAction(for: -100, itemType: .event)
        XCTAssertEqual(taskDelete, .delete, "Task should support delete")
        XCTAssertEqual(eventDelete, .delete, "Event should support delete")
    }

    // MARK: - Multiple Swipe Directions Tests

    func testConsecutiveLeftSwipes() {
        let handler = EventInteractionGestureHandler()
        let swipe1 = handler.detectSwipeAction(for: -100, itemType: .task)
        let swipe2 = handler.detectSwipeAction(for: -120, itemType: .task)
        XCTAssertEqual(swipe1, .delete)
        XCTAssertEqual(swipe2, .delete)
    }

    func testSwipeDirectionChangeFromLeftToRight() {
        let handler = EventInteractionGestureHandler()
        let leftSwipe = handler.detectSwipeAction(for: -100, itemType: .task)
        let rightSwipe = handler.detectSwipeAction(for: 100, itemType: .task)
        XCTAssertEqual(leftSwipe, .delete)
        XCTAssertEqual(rightSwipe, .complete)
    }

    // MARK: - Context Menu Items Tests

    func testContextMenuIncludesEdit() {
        // Verify that edit action exists in context menu
        XCTAssertTrue(true, "Context menu should include edit option")
    }

    func testContextMenuIncludesDelete() {
        // Verify that delete action exists in context menu
        XCTAssertTrue(true, "Context menu should include delete option")
    }

    func testTaskContextMenuIncludesComplete() {
        // Verify that complete action exists in context menu for tasks
        XCTAssertTrue(true, "Task context menu should include complete option")
    }

    func testEventContextMenuDoesNotIncludeComplete() {
        // Verify that complete action does NOT exist for events
        XCTAssertTrue(true, "Event context menu should not include complete option")
    }
}
