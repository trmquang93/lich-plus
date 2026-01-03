//
//  View+DeleteConfirmation.swift
//  lich-plus
//
//  Reusable delete confirmation alert for events and tasks
//

import SwiftUI

extension View {
    /// Shows a delete confirmation alert with appropriate messaging for events, tasks, and recurring items
    ///
    /// - Parameters:
    ///   - isPresented: Binding to control alert visibility
    ///   - isRecurring: Whether the item is recurring (shows special warning)
    ///   - itemType: Type of item being deleted (event or task)
    ///   - onConfirm: Action to perform when user confirms deletion
    /// - Returns: Modified view with delete confirmation alert
    func deleteConfirmationAlert(
        isPresented: Binding<Bool>,
        isRecurring: Bool,
        itemType: ItemType,
        onConfirm: @escaping () -> Void
    ) -> some View {
        self.alert(
            isRecurring
                ? String(localized: "delete.recurring.title")
                : String(localized: "delete.confirm"),
            isPresented: isPresented
        ) {
            Button(String(localized: "delete.confirm"), role: .destructive, action: onConfirm)
            Button(String(localized: "delete.cancel"), role: .cancel) { }
        } message: {
            Text(deleteConfirmationMessage(isRecurring: isRecurring, itemType: itemType))
        }
    }

    /// Returns the appropriate confirmation message based on item type and recurrence
    private func deleteConfirmationMessage(isRecurring: Bool, itemType: ItemType) -> String {
        if isRecurring {
            return String(localized: "delete.recurring.message")
        }
        return itemType == .event
            ? String(localized: "delete.event.message")
            : String(localized: "delete.task.message")
    }
}
