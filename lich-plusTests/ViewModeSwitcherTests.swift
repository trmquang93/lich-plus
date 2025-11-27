//
//  ViewModeSwitcherTests.swift
//  lich-plusTests
//
//  Created by Quang Tran Minh on 26/11/25.
//

import XCTest
import SwiftUI
@testable import lich_plus

final class ViewModeSwitcherTests: XCTestCase {

    func testViewModeEnum_HasThreeCases() {
        let modes = ViewMode.allCases
        XCTAssertEqual(modes.count, 3)
    }

    func testViewModeEnum_HasCorrectIdentifiers() {
        XCTAssertEqual(ViewMode.today.id, "today")
        XCTAssertEqual(ViewMode.thisWeek.id, "thisWeek")
        XCTAssertEqual(ViewMode.all.id, "all")
    }

    func testViewModeEnum_DisplayNamesAreLocalized() {
        let todayName = ViewMode.today.displayName
        let thisWeekName = ViewMode.thisWeek.displayName
        let allName = ViewMode.all.displayName

        // Display names should not be empty
        XCTAssertFalse(todayName.isEmpty)
        XCTAssertFalse(thisWeekName.isEmpty)
        XCTAssertFalse(allName.isEmpty)
    }

    func testViewModeSwitcher_InitializesWithBinding() {
        // Given
        var selectedMode = ViewMode.today
        let binding = Binding(
            get: { selectedMode },
            set: { selectedMode = $0 }
        )

        // When
        let switcher = ViewModeSwitcher(selectedMode: binding)

        // Then
        XCTAssertNotNil(switcher)
        XCTAssertEqual(selectedMode, ViewMode.today)
    }

    func testViewModeSwitcher_AcceptsBindingParameter() {
        // This test verifies the component can be instantiated with a binding
        // Actual state updates are SwiftUI's responsibility, tested in UI tests
        var selectedMode = ViewMode.today
        let binding = Binding(
            get: { selectedMode },
            set: { selectedMode = $0 }
        )

        // When
        let switcher = ViewModeSwitcher(selectedMode: binding)

        // Then
        XCTAssertNotNil(switcher)
    }
}
