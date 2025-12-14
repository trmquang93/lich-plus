import XCTest
import SwiftUI
@testable import lich_plus

final class TimeScaleGestureTests: XCTestCase {

    // MARK: - Scale Clamping Tests

    func testScaleClampingToMinimum() {
        let gesture = TimeScaleGestureHandler()
        let clampedHeight = gesture.clampHeight(30)
        XCTAssertEqual(clampedHeight, 40, "Height below minimum should clamp to 40")
    }

    func testScaleClampingToMaximum() {
        let gesture = TimeScaleGestureHandler()
        let clampedHeight = gesture.clampHeight(130)
        XCTAssertEqual(clampedHeight, 120, "Height above maximum should clamp to 120")
    }

    func testScaleClampingWithinRange() {
        let gesture = TimeScaleGestureHandler()
        let clampedHeight = gesture.clampHeight(60)
        XCTAssertEqual(clampedHeight, 60, "Height within range should remain unchanged")
    }

    // MARK: - Scale Snapping Tests

    func testSnapToNearestScaleFifteenMin() {
        let gesture = TimeScaleGestureHandler()
        let nearestScale = gesture.nearestScale(for: 100)
        XCTAssertEqual(nearestScale, .fifteenMin, "Height 100 should snap to fifteenMin (120)")
    }

    func testSnapToNearestScaleThirtyMin() {
        let gesture = TimeScaleGestureHandler()
        let nearestScale = gesture.nearestScale(for: 60)
        XCTAssertEqual(nearestScale, .thirtyMin, "Height 60 should snap to thirtyMin (60)")
    }

    func testSnapToNearestScaleOneHour() {
        let gesture = TimeScaleGestureHandler()
        let nearestScale = gesture.nearestScale(for: 35)
        XCTAssertEqual(nearestScale, .oneHour, "Height 35 should snap to oneHour (40)")
    }

    func testSnapToNearestScaleMidpoint() {
        let gesture = TimeScaleGestureHandler()
        // 90 is equidistant between 60 (thirtyMin) and 120 (fifteenMin)
        // Should snap to fifteenMin as it's the higher value
        let nearestScale = gesture.nearestScale(for: 90)
        XCTAssertTrue(
            nearestScale == .fifteenMin || nearestScale == .thirtyMin,
            "Equidistant should snap to one of the adjacent scales"
        )
    }

    // MARK: - Scale Calculation Tests

    func testScaleForHeightFifteenMin() {
        let gesture = TimeScaleGestureHandler()
        let scale = gesture.scaleForHeight(120)
        XCTAssertEqual(scale, .fifteenMin)
    }

    func testScaleForHeightThirtyMin() {
        let gesture = TimeScaleGestureHandler()
        let scale = gesture.scaleForHeight(60)
        XCTAssertEqual(scale, .thirtyMin)
    }

    func testScaleForHeightOneHour() {
        let gesture = TimeScaleGestureHandler()
        let scale = gesture.scaleForHeight(40)
        XCTAssertEqual(scale, .oneHour)
    }

    // MARK: - Scale Change Delta Tests

    func testScaleDeltaCalculation() {
        let gesture = TimeScaleGestureHandler()
        let currentHeight = 60.0
        let newHeight = 90.0
        let delta = gesture.calculateScaleDelta(from: currentHeight, to: newHeight)
        XCTAssertEqual(delta, 1.5, accuracy: 0.01, "Delta from 60 to 90 should be 1.5")
    }

    func testScaleDeltaWithZoomIn() {
        let gesture = TimeScaleGestureHandler()
        let currentHeight = 60.0
        let newHeight = 120.0
        let delta = gesture.calculateScaleDelta(from: currentHeight, to: newHeight)
        XCTAssertEqual(delta, 2.0, accuracy: 0.01, "Doubling height should have delta of 2.0")
    }

    func testScaleDeltaWithZoomOut() {
        let gesture = TimeScaleGestureHandler()
        let currentHeight = 120.0
        let newHeight = 60.0
        let delta = gesture.calculateScaleDelta(from: currentHeight, to: newHeight)
        XCTAssertEqual(delta, 0.5, accuracy: 0.01, "Halving height should have delta of 0.5")
    }

    // MARK: - Configuration Update Tests

    func testConfigurationUpdateOnScaleChange() {
        var config = TimelineConfiguration()
        config.currentScale = .thirtyMin

        let gesture = TimeScaleGestureHandler()
        let newHeight = gesture.clampHeight(120)
        let newScale = gesture.nearestScale(for: newHeight)

        config.currentScale = newScale

        XCTAssertEqual(config.currentScale, .fifteenMin)
        XCTAssertEqual(config.hourHeight, 120)
    }

    func testConfigurationMultipleScaleTransitions() {
        var config = TimelineConfiguration()
        config.currentScale = .thirtyMin

        let gesture = TimeScaleGestureHandler()

        // Transition 1: thirtyMin (60) -> fifteenMin (120)
        config.currentScale = gesture.nearestScale(for: 120)
        XCTAssertEqual(config.currentScale, .fifteenMin)

        // Transition 2: fifteenMin (120) -> oneHour (40)
        config.currentScale = gesture.nearestScale(for: 40)
        XCTAssertEqual(config.currentScale, .oneHour)

        // Transition 3: oneHour (40) -> thirtyMin (60)
        config.currentScale = gesture.nearestScale(for: 60)
        XCTAssertEqual(config.currentScale, .thirtyMin)
    }

    // MARK: - Edge Cases

    func testScaleWithExtremelySmallHeight() {
        let gesture = TimeScaleGestureHandler()
        let clampedHeight = gesture.clampHeight(0.1)
        XCTAssertEqual(clampedHeight, 40)
    }

    func testScaleWithExtremelyLargeHeight() {
        let gesture = TimeScaleGestureHandler()
        let clampedHeight = gesture.clampHeight(1000)
        XCTAssertEqual(clampedHeight, 120)
    }

    func testNegativeHeightClamping() {
        let gesture = TimeScaleGestureHandler()
        let clampedHeight = gesture.clampHeight(-50)
        XCTAssertEqual(clampedHeight, 40)
    }

    // MARK: - All Scales Available

    func testAllTimeScalesAreAccessible() {
        let scales = TimelineConfiguration.TimeScale.allCases
        XCTAssertEqual(scales.count, 3, "Should have exactly 3 time scales")
        XCTAssertTrue(scales.contains(.fifteenMin))
        XCTAssertTrue(scales.contains(.thirtyMin))
        XCTAssertTrue(scales.contains(.oneHour))
    }
}
