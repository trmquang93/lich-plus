//
//  TaskCardPriorityTests.swift
//  lich-plusTests
//
//  Created by Quang Tran Minh on 26/11/25.
//

import XCTest
@testable import lich_plus

final class TaskCardPriorityTests: XCTestCase {

    func testTaskItem_HasPriorityProperty() {
        // Given
        let task = TaskItem(
            title: "Task",
            date: Date(),
            priority: .high
        )

        // Then
        XCTAssertEqual(task.priority, .high)
    }

    func testPriority_HasCorrectColor() {
        XCTAssertEqual(Priority.none.color, AppColors.textSecondary)
        XCTAssertEqual(Priority.low.color, AppColors.eventBlue)
        XCTAssertEqual(Priority.medium.color, AppColors.eventYellow)
        XCTAssertEqual(Priority.high.color, AppColors.primary)
    }

    func testPriority_HasDisplayName() {
        XCTAssertFalse(Priority.none.displayName.isEmpty)
        XCTAssertFalse(Priority.low.displayName.isEmpty)
        XCTAssertFalse(Priority.medium.displayName.isEmpty)
        XCTAssertFalse(Priority.high.displayName.isEmpty)
    }

    func testTaskItem_WithoutPriority() {
        // Given
        let task = TaskItem(
            title: "Task",
            date: Date(),
            priority: .none
        )

        // Then
        XCTAssertEqual(task.priority, .none)
    }
}
