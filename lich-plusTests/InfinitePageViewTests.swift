//
//  InfinitePageViewTests.swift
//  lich-plusTests
//
//  Created by Quang Tran Minh on 02/12/25.
//

import XCTest
import SwiftUI
@testable import lich_plus

final class InfinitePageViewTests: XCTestCase {

    var sut: InfinitePageView<Int, Text>!
    var coordinator: InfinitePageView<Int, Text>.Coordinator!
    var pageChangedValues: [Int] = []

    override func setUp() {
        super.setUp()
        pageChangedValues = []

        // Create InfinitePageView with minimal setup
        sut = InfinitePageView(
            initialIndex: 0,
            currentValue: 0,
            content: { index in Text("Page \(index)") },
            onPageChanged: { [weak self] index in
                self?.pageChangedValues.append(index)
            }
        )

        // Create coordinator
        coordinator = sut.makeCoordinator()
    }

    override func tearDown() {
        sut = nil
        coordinator = nil
        pageChangedValues = []
        super.tearDown()
    }

    // MARK: - IndexedHostingController Tests

    func testIndexedHostingController_DefaultPageIndexIsZero() {
        // Given
        let hostingController = IndexedHostingController<Int, Text>(rootView: Text("Test"))

        // When
        hostingController.pageIndex = 0

        // Then
        XCTAssertEqual(hostingController.pageIndex, 0)
    }

    func testIndexedHostingController_PageIndexCanBeSet() {
        // Given
        let hostingController = IndexedHostingController<Int, Text>(rootView: Text("Test"))

        // When
        hostingController.pageIndex = 5

        // Then
        XCTAssertEqual(hostingController.pageIndex, 5)
    }

    func testIndexedHostingController_PageIndexCanBeSetToNegative() {
        // Given
        let hostingController = IndexedHostingController<Int, Text>(rootView: Text("Test"))

        // When
        hostingController.pageIndex = -10

        // Then
        XCTAssertEqual(hostingController.pageIndex, -10)
    }

    func testIndexedHostingController_PageIndexCanBeLarge() {
        // Given
        let hostingController = IndexedHostingController<Int, Text>(rootView: Text("Test"))

        // When
        hostingController.pageIndex = 1000

        // Then
        XCTAssertEqual(hostingController.pageIndex, 1000)
    }

    // MARK: - Coordinator makeHostingController Tests

    func testCoordinator_MakeHostingController_SetsCorrectPageIndex() {
        // Given
        let index = 5

        // When
        let controller = coordinator.makeHostingController(for: index)

        // Then
        XCTAssertEqual(controller.pageIndex, index)
    }

    func testCoordinator_MakeHostingController_WithZeroIndex() {
        // Given
        let index = 0

        // When
        let controller = coordinator.makeHostingController(for: index)

        // Then
        XCTAssertEqual(controller.pageIndex, index)
    }

    func testCoordinator_MakeHostingController_WithNegativeIndex() {
        // Given
        let index = -5

        // When
        let controller = coordinator.makeHostingController(for: index)

        // Then
        XCTAssertEqual(controller.pageIndex, index)
    }

    func testCoordinator_MakeHostingController_WithLargeIndex() {
        // Given
        let index = 999

        // When
        let controller = coordinator.makeHostingController(for: index)

        // Then
        XCTAssertEqual(controller.pageIndex, index)
    }

    // MARK: - Page Index Arithmetic: Next Page Tests

    func testPageViewController_ViewControllerAfter_IncrementsByOne() {
        // Given
        let currentController = coordinator.makeHostingController(for: 5)

        // When
        let nextController = coordinator.pageViewController(
            UIPageViewController(),
            viewControllerAfter: currentController
        ) as? IndexedHostingController<Int, Text>

        // Then
        XCTAssertNotNil(nextController)
        XCTAssertEqual(nextController?.pageIndex, 6)
    }

    func testPageViewController_ViewControllerAfter_FromZero() {
        // Given
        let currentController = coordinator.makeHostingController(for: 0)

        // When
        let nextController = coordinator.pageViewController(
            UIPageViewController(),
            viewControllerAfter: currentController
        ) as? IndexedHostingController<Int, Text>

        // Then
        XCTAssertNotNil(nextController)
        XCTAssertEqual(nextController?.pageIndex, 1)
    }

    func testPageViewController_ViewControllerAfter_FromNegativeIndex() {
        // Given
        let currentController = coordinator.makeHostingController(for: -5)

        // When
        let nextController = coordinator.pageViewController(
            UIPageViewController(),
            viewControllerAfter: currentController
        ) as? IndexedHostingController<Int, Text>

        // Then
        XCTAssertNotNil(nextController)
        XCTAssertEqual(nextController?.pageIndex, -4)
    }

    func testPageViewController_ViewControllerAfter_ChainedCalls() {
        // Given
        let initialController = coordinator.makeHostingController(for: 0)

        // When
        let next1 = coordinator.pageViewController(
            UIPageViewController(),
            viewControllerAfter: initialController
        ) as? IndexedHostingController<Int, Text>

        let next2 = coordinator.pageViewController(
            UIPageViewController(),
            viewControllerAfter: next1!
        ) as? IndexedHostingController<Int, Text>

        let next3 = coordinator.pageViewController(
            UIPageViewController(),
            viewControllerAfter: next2!
        ) as? IndexedHostingController<Int, Text>

        // Then
        XCTAssertEqual(next1?.pageIndex, 1)
        XCTAssertEqual(next2?.pageIndex, 2)
        XCTAssertEqual(next3?.pageIndex, 3)
    }

    // MARK: - Page Index Arithmetic: Previous Page Tests

    func testPageViewController_ViewControllerBefore_DecrementsByOne() {
        // Given
        let currentController = coordinator.makeHostingController(for: 5)

        // When
        let prevController = coordinator.pageViewController(
            UIPageViewController(),
            viewControllerBefore: currentController
        ) as? IndexedHostingController<Int, Text>

        // Then
        XCTAssertNotNil(prevController)
        XCTAssertEqual(prevController?.pageIndex, 4)
    }

    func testPageViewController_ViewControllerBefore_FromZero() {
        // Given
        let currentController = coordinator.makeHostingController(for: 0)

        // When
        let prevController = coordinator.pageViewController(
            UIPageViewController(),
            viewControllerBefore: currentController
        ) as? IndexedHostingController<Int, Text>

        // Then
        XCTAssertNotNil(prevController)
        XCTAssertEqual(prevController?.pageIndex, -1)
    }

    func testPageViewController_ViewControllerBefore_FromNegativeIndex() {
        // Given
        let currentController = coordinator.makeHostingController(for: -5)

        // When
        let prevController = coordinator.pageViewController(
            UIPageViewController(),
            viewControllerBefore: currentController
        ) as? IndexedHostingController<Int, Text>

        // Then
        XCTAssertNotNil(prevController)
        XCTAssertEqual(prevController?.pageIndex, -6)
    }

    func testPageViewController_ViewControllerBefore_ChainedCalls() {
        // Given
        let initialController = coordinator.makeHostingController(for: 3)

        // When
        let prev1 = coordinator.pageViewController(
            UIPageViewController(),
            viewControllerBefore: initialController
        ) as? IndexedHostingController<Int, Text>

        let prev2 = coordinator.pageViewController(
            UIPageViewController(),
            viewControllerBefore: prev1!
        ) as? IndexedHostingController<Int, Text>

        let prev3 = coordinator.pageViewController(
            UIPageViewController(),
            viewControllerBefore: prev2!
        ) as? IndexedHostingController<Int, Text>

        // Then
        XCTAssertEqual(prev1?.pageIndex, 2)
        XCTAssertEqual(prev2?.pageIndex, 1)
        XCTAssertEqual(prev3?.pageIndex, 0)
    }

    // MARK: - Edge Cases: Large Index Values

    func testPageViewController_ViewControllerAfter_LargeIndex() {
        // Given
        let largeIndex = 10000
        let currentController = coordinator.makeHostingController(for: largeIndex)

        // When
        let nextController = coordinator.pageViewController(
            UIPageViewController(),
            viewControllerAfter: currentController
        ) as? IndexedHostingController<Int, Text>

        // Then
        XCTAssertNotNil(nextController)
        XCTAssertEqual(nextController?.pageIndex, 10001)
    }

    func testPageViewController_ViewControllerBefore_LargeNegativeIndex() {
        // Given
        let largeNegativeIndex = -10000
        let currentController = coordinator.makeHostingController(for: largeNegativeIndex)

        // When
        let prevController = coordinator.pageViewController(
            UIPageViewController(),
            viewControllerBefore: currentController
        ) as? IndexedHostingController<Int, Text>

        // Then
        XCTAssertNotNil(prevController)
        XCTAssertEqual(prevController?.pageIndex, -10001)
    }

    // MARK: - Edge Cases: Integer Boundaries

    func testPageViewController_ViewControllerAfter_NearMaxInt() {
        // Given - use a large but safe value
        let nearMaxIndex = Int.max - 2
        let currentController = coordinator.makeHostingController(for: nearMaxIndex)

        // When
        let nextController = coordinator.pageViewController(
            UIPageViewController(),
            viewControllerAfter: currentController
        ) as? IndexedHostingController<Int, Text>

        // Then
        XCTAssertNotNil(nextController)
        XCTAssertEqual(nextController?.pageIndex, Int.max - 1)
    }

    func testPageViewController_ViewControllerBefore_NearMinInt() {
        // Given - use a large negative value but safe
        let nearMinIndex = Int.min + 2
        let currentController = coordinator.makeHostingController(for: nearMinIndex)

        // When
        let prevController = coordinator.pageViewController(
            UIPageViewController(),
            viewControllerBefore: currentController
        ) as? IndexedHostingController<Int, Text>

        // Then
        XCTAssertNotNil(prevController)
        XCTAssertEqual(prevController?.pageIndex, Int.min + 1)
    }

    // MARK: - Error Handling: Invalid Input

    func testPageViewController_ViewControllerAfter_InvalidController() {
        // Given
        let invalidController = UIViewController()

        // When
        let result = coordinator.pageViewController(
            UIPageViewController(),
            viewControllerAfter: invalidController
        )

        // Then
        XCTAssertNil(result)
    }

    func testPageViewController_ViewControllerBefore_InvalidController() {
        // Given
        let invalidController = UIViewController()

        // When
        let result = coordinator.pageViewController(
            UIPageViewController(),
            viewControllerBefore: invalidController
        )

        // Then
        XCTAssertNil(result)
    }

    // MARK: - Bidirectional Navigation Tests

    func testPageViewController_NavigateForwardThenBackward() {
        // Given
        let startIndex = 5
        let startController = coordinator.makeHostingController(for: startIndex)

        // When
        let nextController = coordinator.pageViewController(
            UIPageViewController(),
            viewControllerAfter: startController
        ) as? IndexedHostingController<Int, Text>

        let backController = coordinator.pageViewController(
            UIPageViewController(),
            viewControllerBefore: nextController!
        ) as? IndexedHostingController<Int, Text>

        // Then
        XCTAssertEqual(backController?.pageIndex, startIndex)
    }

    func testPageViewController_NavigateBackwardThenForward() {
        // Given
        let startIndex = 5
        let startController = coordinator.makeHostingController(for: startIndex)

        // When
        let prevController = coordinator.pageViewController(
            UIPageViewController(),
            viewControllerBefore: startController
        ) as? IndexedHostingController<Int, Text>

        let nextController = coordinator.pageViewController(
            UIPageViewController(),
            viewControllerAfter: prevController!
        ) as? IndexedHostingController<Int, Text>

        // Then
        XCTAssertEqual(nextController?.pageIndex, startIndex)
    }

    // MARK: - Infinity Tests

    func testPageViewController_CanNavigateInfinitelyForward() {
        // Given
        var currentController = coordinator.makeHostingController(for: 0)

        // When & Then - iterate multiple times
        for expectedIndex in 1...100 {
            let nextController = coordinator.pageViewController(
                UIPageViewController(),
                viewControllerAfter: currentController
            ) as? IndexedHostingController<Int, Text>

            XCTAssertNotNil(nextController)
            XCTAssertEqual(nextController?.pageIndex, expectedIndex)

            currentController = nextController!
        }
    }

    func testPageViewController_CanNavigateInfinitelyBackward() {
        // Given
        var currentController = coordinator.makeHostingController(for: 0)

        // When & Then - iterate multiple times
        for expectedIndex in (-1)...(-100) {
            let prevController = coordinator.pageViewController(
                UIPageViewController(),
                viewControllerBefore: currentController
            ) as? IndexedHostingController<Int, Text>

            XCTAssertNotNil(prevController)
            XCTAssertEqual(prevController?.pageIndex, expectedIndex)

            currentController = prevController!
        }
    }

    // MARK: - Coordinator Initialization Tests

    func testCoordinator_InitializationWithCurrentValue() {
        // Given
        let initialValue = 0

        // When
        let testCoordinator = sut.makeCoordinator()

        // Then
        XCTAssertEqual(testCoordinator.lastIndex, initialValue)
    }

    func testCoordinator_ParentReferenceIsSet() {
        // Given
        // When
        let testCoordinator = sut.makeCoordinator()

        // Then
        XCTAssertNotNil(testCoordinator.parent)
    }
}
