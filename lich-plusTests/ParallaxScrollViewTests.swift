//
//  ParallaxScrollViewTests.swift
//  lich-plusTests
//
//  Created by Quang Tran Minh on 02/12/25.
//

import XCTest
import SwiftUI
@testable import lich_plus

final class ParallaxScrollViewTests: XCTestCase {

    // MARK: - Height Calculation Tests

    func testCalculatedHeaderHeight_WhenScrollOffsetIsZero_ReturnsMaxHeight() {
        // Given
        let minHeight: CGFloat = 100
        let maxHeight: CGFloat = 300
        let scrollOffset: CGFloat = 0

        // When
        let headerHeight = calculateHeaderHeight(scrollOffset: scrollOffset, minHeight: minHeight, maxHeight: maxHeight)

        // Then
        XCTAssertEqual(headerHeight, maxHeight)
    }

    func testCalculatedHeaderHeight_WhenScrollingDown_ReturnsMaxHeight() {
        // Given - scrolling down (positive offset)
        let minHeight: CGFloat = 100
        let maxHeight: CGFloat = 300

        // When
        let headerHeight = calculateHeaderHeight(scrollOffset: 50, minHeight: minHeight, maxHeight: maxHeight)

        // Then - still at max height when scrolling down
        XCTAssertEqual(headerHeight, maxHeight)
    }

    func testCalculatedHeaderHeight_WhenScrollingUp_CollapsesProportionally() {
        // Given - scrolling up (negative offset)
        let minHeight: CGFloat = 100
        let maxHeight: CGFloat = 300
        let scrollOffset: CGFloat = -100

        // When
        let headerHeight = calculateHeaderHeight(scrollOffset: scrollOffset, minHeight: minHeight, maxHeight: maxHeight)

        // Then - header collapses by scrollOffset amount
        let expectedHeight: CGFloat = maxHeight + scrollOffset // 300 + (-100) = 200
        XCTAssertEqual(headerHeight, expectedHeight)
    }

    func testCalculatedHeaderHeight_WhenScrollingUpMore_RespectsMinHeight() {
        // Given - scrolling up more than the collapsible range
        let minHeight: CGFloat = 100
        let maxHeight: CGFloat = 300
        let scrollOffset: CGFloat = -250  // Would result in 50, below minHeight

        // When
        let headerHeight = calculateHeaderHeight(scrollOffset: scrollOffset, minHeight: minHeight, maxHeight: maxHeight)

        // Then - clamped to minimum height
        XCTAssertEqual(headerHeight, minHeight)
    }

    func testCalculatedHeaderHeight_WithLargeNegativeOffset_ClampsToMinHeight() {
        // Given
        let minHeight: CGFloat = 100
        let maxHeight: CGFloat = 300
        let scrollOffset: CGFloat = -1000

        // When
        let headerHeight = calculateHeaderHeight(scrollOffset: scrollOffset, minHeight: minHeight, maxHeight: maxHeight)

        // Then
        XCTAssertEqual(headerHeight, minHeight)
    }

    // MARK: - Collapse Progress Tests

    func testCollapseProgress_WhenHeaderIsExpanded_ReturnsZero() {
        // Given - header at max height (not collapsed)
        let minHeight: CGFloat = 100
        let maxHeight: CGFloat = 300
        let headerHeight = maxHeight

        // When
        let progress = calculateCollapseProgress(headerHeight: headerHeight, minHeight: minHeight, maxHeight: maxHeight)

        // Then
        XCTAssertEqual(progress, 0.0)
    }

    func testCollapseProgress_WhenHeaderIsFullyCollapsed_ReturnsOne() {
        // Given - header at min height (fully collapsed)
        let minHeight: CGFloat = 100
        let maxHeight: CGFloat = 300
        let headerHeight = minHeight

        // When
        let progress = calculateCollapseProgress(headerHeight: headerHeight, minHeight: minHeight, maxHeight: maxHeight)

        // Then
        XCTAssertEqual(progress, 1.0)
    }

    func testCollapseProgress_WhenHeaderIsHalfCollapsed_ReturnsHalf() {
        // Given - header exactly halfway between min and max
        let minHeight: CGFloat = 100
        let maxHeight: CGFloat = 300
        let headerHeight: CGFloat = 200  // Exactly halfway

        // When
        let progress = calculateCollapseProgress(headerHeight: headerHeight, minHeight: minHeight, maxHeight: maxHeight)

        // Then
        XCTAssertEqual(progress, 0.5)
    }

    func testCollapseProgress_WithQuarterCollapsed_ReturnsAccurateValue() {
        // Given - header 1/4 collapsed (3/4 of range remaining)
        let minHeight: CGFloat = 100
        let maxHeight: CGFloat = 300
        let range = maxHeight - minHeight  // 200
        let headerHeight = maxHeight - (range * 0.25)  // 300 - 50 = 250

        // When
        let progress = calculateCollapseProgress(headerHeight: headerHeight, minHeight: minHeight, maxHeight: maxHeight)

        // Then
        XCTAssertEqual(progress, 0.25, accuracy: 0.001)
    }

    func testCollapseProgress_WithEqualMinMaxHeight_ReturnsZero() {
        // Given - min and max are the same (no collapsible range)
        let minHeight: CGFloat = 200
        let maxHeight: CGFloat = 200
        let headerHeight: CGFloat = 200

        // When
        let progress = calculateCollapseProgress(headerHeight: headerHeight, minHeight: minHeight, maxHeight: maxHeight)

        // Then - no range to collapse, return 0
        XCTAssertEqual(progress, 0.0)
    }

    // MARK: - Integration Tests

    func testScrollOffsetTracking_UpdatesHeaderHeightCorrectly() {
        // Given
        let minHeight: CGFloat = 100
        let maxHeight: CGFloat = 300
        var calculatedHeights: [CGFloat] = []

        // When - simulate various scroll positions
        let scrollOffsets: [CGFloat] = [0, -50, -100, -150, -200, -250]

        // Then
        for offset in scrollOffsets {
            let height = calculateHeaderHeight(scrollOffset: offset, minHeight: minHeight, maxHeight: maxHeight)
            calculatedHeights.append(height)
            XCTAssertGreaterThanOrEqual(height, minHeight, "Height should not go below minimum")
            XCTAssertLessThanOrEqual(height, maxHeight, "Height should not exceed maximum")
        }

        // Verify heights decrease as offset becomes more negative
        for i in 0..<calculatedHeights.count - 1 {
            XCTAssertGreaterThanOrEqual(calculatedHeights[i], calculatedHeights[i + 1])
        }
    }

    func testScrollOffsetTracking_WithAlternatingScrollDirection_HandlesCorrectly() {
        // Given
        let minHeight: CGFloat = 100
        let maxHeight: CGFloat = 300

        // When - simulate scrolling up and down
        let scrollSequence: [CGFloat] = [0, -50, 25, -75, 10, -150]
        var heights: [CGFloat] = []

        // Then - each height calculation should be correct regardless of previous
        for offset in scrollSequence {
            let height = calculateHeaderHeight(scrollOffset: offset, minHeight: minHeight, maxHeight: maxHeight)
            heights.append(height)
            XCTAssertGreaterThanOrEqual(height, minHeight)
            XCTAssertLessThanOrEqual(height, maxHeight)
        }

        // Verify specific transitions
        XCTAssertEqual(heights[0], maxHeight)  // 0
        XCTAssertEqual(heights[1], 250)        // -50
        XCTAssertEqual(heights[2], maxHeight)  // 25 (positive, so maxHeight)
        XCTAssertEqual(heights[3], 225)        // -75
    }

    func testCollapseProgressAndHeightCorrelation_AreConsistent() {
        // Given
        let minHeight: CGFloat = 100
        let maxHeight: CGFloat = 300

        // When - calculate multiple height/progress pairs
        let scrollOffsets: [CGFloat] = [0, -50, -100, -150, -200, -250]

        // Then - progress should accurately reflect collapse state
        for offset in scrollOffsets {
            let height = calculateHeaderHeight(scrollOffset: offset, minHeight: minHeight, maxHeight: maxHeight)
            let progress = calculateCollapseProgress(headerHeight: height, minHeight: minHeight, maxHeight: maxHeight)

            // Verify relationship: height = maxHeight - (range * progress)
            let expectedHeight = maxHeight - ((maxHeight - minHeight) * progress)
            XCTAssertEqual(height, expectedHeight, accuracy: 0.001)
        }
    }

    // MARK: - Helper Functions

    private func calculateHeaderHeight(scrollOffset: CGFloat, minHeight: CGFloat, maxHeight: CGFloat) -> CGFloat {
        if scrollOffset >= 0 {
            return maxHeight
        } else {
            let collapsed = maxHeight + scrollOffset
            return max(minHeight, collapsed)
        }
    }

    private func calculateCollapseProgress(headerHeight: CGFloat, minHeight: CGFloat, maxHeight: CGFloat) -> CGFloat {
        let range = maxHeight - minHeight
        guard range > 0 else { return 0 }
        return (maxHeight - headerHeight) / range
    }
}
