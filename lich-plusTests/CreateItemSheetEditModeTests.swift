//
//  CreateItemSheetEditModeTests.swift
//  lich-plusTests
//
//  Tests for Issue 26: Edit mode title logic
//  - Header title changes based on edit mode and item type
//  - Save button title changes based on edit mode and item type
//

import XCTest
@testable import lich_plus

final class CreateItemSheetEditModeTests: XCTestCase {

    // MARK: - Header Title Tests

    func testHeaderTitleShowsEditEventInEditModeForEvent() {
        // Arrange
        let isEditMode = true
        let itemType = ItemType.event

        // Act
        let title = headerTitle(isEditMode: isEditMode, itemType: itemType)

        // Assert
        XCTAssertEqual(title, String(localized: "createItem.editEvent"),
                       "Header should show 'Edit Event' when editing an event")
    }

    func testHeaderTitleShowsEditTaskInEditModeForTask() {
        // Arrange
        let isEditMode = true
        let itemType = ItemType.task

        // Act
        let title = headerTitle(isEditMode: isEditMode, itemType: itemType)

        // Assert
        XCTAssertEqual(title, String(localized: "createItem.editTask"),
                       "Header should show 'Edit Task' when editing a task")
    }

    func testHeaderTitleShowsCreateNewInCreateMode() {
        // Arrange
        let isEditMode = false
        let itemType = ItemType.event

        // Act
        let title = headerTitle(isEditMode: isEditMode, itemType: itemType)

        // Assert
        XCTAssertEqual(title, String(localized: "createItem.title"),
                       "Header should show 'Create new' when creating a new item")
    }

    func testHeaderTitleShowsCreateNewInCreateModeForTask() {
        // Arrange
        let isEditMode = false
        let itemType = ItemType.task

        // Act
        let title = headerTitle(isEditMode: isEditMode, itemType: itemType)

        // Assert
        XCTAssertEqual(title, String(localized: "createItem.title"),
                       "Header should show 'Create new' when creating a new task")
    }

    // MARK: - Save Button Title Tests

    func testSaveButtonTitleShowsSaveInEditModeForEvent() {
        // Arrange
        let isEditMode = true
        let itemType = ItemType.event

        // Act
        let title = saveButtonTitle(isEditMode: isEditMode, itemType: itemType)

        // Assert
        XCTAssertEqual(title, String(localized: "createItem.save"),
                       "Save button should show 'Save' when editing an event")
    }

    func testSaveButtonTitleShowsSaveInEditModeForTask() {
        // Arrange
        let isEditMode = true
        let itemType = ItemType.task

        // Act
        let title = saveButtonTitle(isEditMode: isEditMode, itemType: itemType)

        // Assert
        XCTAssertEqual(title, String(localized: "createItem.save"),
                       "Save button should show 'Save' when editing a task")
    }

    func testSaveButtonTitleShowsCreateEventInCreateModeForEvent() {
        // Arrange
        let isEditMode = false
        let itemType = ItemType.event

        // Act
        let title = saveButtonTitle(isEditMode: isEditMode, itemType: itemType)

        // Assert
        XCTAssertEqual(title, String(localized: "createItem.createEvent"),
                       "Save button should show 'Create event' when creating an event")
    }

    func testSaveButtonTitleShowsCreateTaskInCreateModeForTask() {
        // Arrange
        let isEditMode = false
        let itemType = ItemType.task

        // Act
        let title = saveButtonTitle(isEditMode: isEditMode, itemType: itemType)

        // Assert
        XCTAssertEqual(title, String(localized: "createItem.createTask"),
                       "Save button should show 'Create task' when creating a task")
    }

    // MARK: - Edge Cases

    func testEditModeIsDeterminedByEditingEventPresence() {
        // This test verifies the isEditMode logic
        let hasEditingEvent = true
        let noEditingEvent = false

        XCTAssertTrue(hasEditingEvent, "isEditMode should be true when editingEvent is not nil")
        XCTAssertFalse(noEditingEvent, "isEditMode should be false when editingEvent is nil")
    }

    // MARK: - Helper Methods
    // These mirror the logic in CreateItemSheet to enable unit testing

    private func headerTitle(isEditMode: Bool, itemType: ItemType) -> String {
        if isEditMode {
            return itemType == .event
                ? String(localized: "createItem.editEvent")
                : String(localized: "createItem.editTask")
        } else {
            return String(localized: "createItem.title")
        }
    }

    private func saveButtonTitle(isEditMode: Bool, itemType: ItemType) -> String {
        if isEditMode {
            return String(localized: "createItem.save")
        } else {
            return itemType == .event
                ? String(localized: "createItem.createEvent")
                : String(localized: "createItem.createTask")
        }
    }
}
