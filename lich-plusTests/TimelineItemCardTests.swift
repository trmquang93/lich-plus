//
//  TimelineItemCardTests.swift
//  lich-plusTests
//
//  Created by Quang Tran Minh on 26/11/25.
//

import XCTest
import SwiftUI
@testable import lich_plus

final class TimelineItemCardTests: XCTestCase {

    func testTimelineItemCard_RendersTaskCard_ForTaskItem() {
        // Given
        let task = TaskItem(
            title: "Task",
            date: Date(),
            itemType: .task
        )

        // When
        let card = TimelineItemCard(
            task: task,
            onToggleCompletion: { _ in },
            onDelete: { _ in },
            onEdit: { _ in }
        )

        // Then - Should create successfully
        XCTAssertNotNil(card)
    }

    func testTimelineItemCard_RendersEventCard_ForEventItem() {
        // Given
        let event = TaskItem(
            title: "Event",
            date: Date(),
            startTime: Date(),
            itemType: .event
        )

        // When
        let card = TimelineItemCard(
            task: event,
            onToggleCompletion: { _ in },
            onDelete: { _ in },
            onEdit: { _ in }
        )

        // Then - Should create successfully
        XCTAssertNotNil(card)
    }

    func testTimelineItemCard_HasCompletionCallback() {
        // Given
        let task = TaskItem(
            title: "Task",
            date: Date(),
            itemType: .task
        )
        var completionCalled = false

        // When
        let _ = TimelineItemCard(
            task: task,
            onToggleCompletion: { _ in completionCalled = true },
            onDelete: { _ in },
            onEdit: { _ in }
        )

        // Then
        XCTAssertFalse(completionCalled)
    }

    func testTimelineItemCard_HasDeleteCallback() {
        // Given
        let task = TaskItem(
            title: "Task",
            date: Date(),
            itemType: .task
        )
        var deletedItem: TaskItem?

        // When
        let _ = TimelineItemCard(
            task: task,
            onToggleCompletion: { _ in },
            onDelete: { deletedItem = $0 },
            onEdit: { _ in }
        )

        // Then
        XCTAssertNil(deletedItem)
    }

    func testTimelineItemCard_HasEditCallback() {
        // Given
        let task = TaskItem(
            title: "Task",
            date: Date(),
            itemType: .task
        )
        var editedItem: TaskItem?

        // When
        let _ = TimelineItemCard(
            task: task,
            onToggleCompletion: { _ in },
            onDelete: { _ in },
            onEdit: { editedItem = $0 }
        )

        // Then
        XCTAssertNil(editedItem)
    }
}
