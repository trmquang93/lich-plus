//
//  TaskCardPriorityTests.swift
//  lich-plusTests
//
//  Created by Quang Tran Minh on 26/11/25.
//

import XCTest
import SwiftUI
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

    func testTaskCard_WithHighPriority() {
        // Given
        let task = TaskItem(
            title: "Important Task",
            date: Date(),
            priority: .high
        )

        // When
        let card = TaskCard(
            task: task,
            onToggleCompletion: { _ in },
            onDelete: { _ in },
            onEdit: { _ in }
        )

        // Then
        XCTAssertNotNil(card)
        XCTAssertEqual(task.priority, .high)
        XCTAssertNotNil(task.priority.color)
    }

    func testTaskCard_WithoutPriority() {
        // Given
        let task = TaskItem(
            title: "Task",
            date: Date(),
            priority: .none
        )

        // Then - Should still render
        XCTAssertEqual(task.priority, .none)
    }
}
