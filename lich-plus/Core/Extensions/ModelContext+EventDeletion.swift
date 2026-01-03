//
//  ModelContext+EventDeletion.swift
//  lich-plus
//
//  Extension for handling event deletion with notification cancellation and sync coordination
//

import SwiftData
import Foundation

@MainActor
extension ModelContext {
    /// Deletes an event with proper notification cleanup and sync coordination
    ///
    /// This method performs the complete deletion workflow:
    /// 1. Cancels any scheduled notifications for the event
    /// 2. Marks the event as deleted (soft delete)
    /// 3. Sets sync status to pending for external calendar sync
    /// 4. Saves changes to database
    /// 5. Posts calendar change notification for UI refresh
    ///
    /// - Parameters:
    ///   - event: The event to delete
    ///   - notificationService: Service for cancelling scheduled notifications
    /// - Throws: Database save errors
    /// - Note: Notification cancellation is fire-and-forget and always succeeds (no errors thrown)
    func deleteEvent(
        _ event: SyncableEvent,
        notificationService: NotificationService
    ) throws {
        // Cancel scheduled notification (fire-and-forget, no errors)
        // UNUserNotificationCenter.removePendingNotificationRequests silently succeeds
        // even if the notification doesn't exist
        notificationService.cancelEventNotification(eventId: event.id)

        // Soft delete
        event.isDeleted = true
        event.setSyncStatus(.pending)

        // Save and notify
        try self.save()
        NotificationCenter.default.post(name: .calendarDataDidChange, object: nil)
    }
}
