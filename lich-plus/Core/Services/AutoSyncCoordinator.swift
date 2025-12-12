//
//  AutoSyncCoordinator.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 11/12/25.
//

import Foundation
import SwiftData
import Combine
import EventKit

/// Orchestrates automatic sync to Apple Calendar by observing data changes
///
/// Listens for `.calendarDataDidChange` notifications and triggers sync to Apple Calendar
/// with debouncing to prevent sync storms during rapid event creation/updates.
///
/// Example usage:
/// ```swift
/// let coordinator = AutoSyncCoordinator(
///     syncService: syncService,
///     eventKitService: eventKitService,
///     modelContext: modelContext
/// )
/// coordinator.startObserving()
/// ```
@MainActor
final class AutoSyncCoordinator: ObservableObject {
    private let syncService: CalendarSyncService
    private let eventKitService: EventKitService
    private let modelContext: ModelContext

    @Published var isSyncing: Bool = false
    @Published var lastSyncError: Error?

    private var notificationObserver: NSObjectProtocol?
    private var syncTask: Task<Void, Never>?
    private let debounceInterval: TimeInterval = 0.3

    init(syncService: CalendarSyncService, eventKitService: EventKitService, modelContext: ModelContext) {
        self.syncService = syncService
        self.eventKitService = eventKitService
        self.modelContext = modelContext
    }

    deinit {
        // Clean up observer in a nonisolated context
        if let observer = notificationObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        syncTask?.cancel()
    }

    // MARK: - Observation

    /// Start observing calendar data changes
    ///
    /// Registers a notification observer for `.calendarDataDidChange` notifications.
    /// When changes are detected, schedules a debounced sync operation.
    func startObserving() {
        notificationObserver = NotificationCenter.default.addObserver(
            forName: .calendarDataDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            // The closure runs on main queue, so we can safely call MainActor-isolated methods
            MainActor.assumeIsolated {
                self?.scheduleSync()
            }
        }
    }

    /// Stop observing calendar data changes
    ///
    /// Removes the notification observer and cancels any pending sync tasks.
    func stopObserving() {
        if let observer = notificationObserver {
            NotificationCenter.default.removeObserver(observer)
            notificationObserver = nil
        }
        syncTask?.cancel()
    }

    // MARK: - Sync Orchestration

    /// Schedule a debounced sync operation
    ///
    /// Cancels any pending sync and schedules a new one after the debounce interval.
    /// This prevents rapid sync operations when multiple changes occur quickly.
    private func scheduleSync() {
        syncTask?.cancel()

        syncTask = Task { [weak self] in
            guard let self = self else { return }
            let interval = self.debounceInterval

            try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))

            guard !Task.isCancelled else { return }
            await self.performSync()
        }
    }

    /// Perform the actual sync operation
    ///
    /// Ensures permissions are granted and a calendar is enabled before
    /// pushing local changes to Apple Calendar.
    func performSync() async {
        guard !isSyncing else { return }

        isSyncing = true
        lastSyncError = nil

        defer {
            isSyncing = false
        }

        do {
            guard try await ensurePermissions() else { return }
            guard try await ensureCalendarEnabled() else { return }
            try await syncService.pushLocalChanges()
        } catch {
            lastSyncError = error
            print("Auto-sync failed: \(error)")
        }
    }

    // MARK: - Permission Handling

    /// Ensure calendar permissions are granted
    ///
    /// Checks if full access is already granted, otherwise requests it.
    ///
    /// - Returns: `true` if permissions are granted, `false` otherwise
    private func ensurePermissions() async throws -> Bool {
        if eventKitService.hasFullAccess() {
            return true
        }
        return await eventKitService.requestFullAccess()
    }

    // MARK: - Calendar Setup

    /// Ensure at least one calendar is enabled for sync
    ///
    /// If no calendars are enabled, automatically enables the default calendar.
    ///
    /// - Returns: `true` if a calendar is enabled, `false` otherwise
    private func ensureCalendarEnabled() async throws -> Bool {
        if try syncService.hasEnabledCalendars() {
            return true
        }

        let calendars = eventKitService.fetchAllCalendars()
        guard let defaultCalendar = calendars.first else {
            return false
        }

        let syncedCalendar = SyncedCalendar(
            calendarIdentifier: defaultCalendar.calendarIdentifier,
            title: defaultCalendar.title,
            colorHex: defaultCalendar.cgColor?.toHexString() ?? "#FF0000",
            isEnabled: true,
            accountName: defaultCalendar.source.title
        )

        modelContext.insert(syncedCalendar)
        try modelContext.save()

        return true
    }
}

// MARK: - CGColor Extension

private extension CGColor {
    /// Convert CGColor to hex string
    ///
    /// - Returns: Hex color string in format "#RRGGBB"
    func toHexString() -> String {
        guard let components = self.components, components.count >= 3 else {
            return "#FF0000"
        }
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
