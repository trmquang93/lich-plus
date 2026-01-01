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

    // Outbound sync (local changes → Apple Calendar)
    private var notificationObserver: NSObjectProtocol?
    private var syncTask: Task<Void, Never>?
    
    // Inbound sync (Apple Calendar changes → local)
    private var externalChangeObserver: NSObjectProtocol?
    private var pullSyncTask: Task<Void, Never>?
    
    private let debounceInterval: TimeInterval = 0.3

    init(syncService: CalendarSyncService, eventKitService: EventKitService, modelContext: ModelContext) {
        self.syncService = syncService
        self.eventKitService = eventKitService
        self.modelContext = modelContext
    }

    deinit {
        // Clean up observers in a nonisolated context
        if let observer = notificationObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = externalChangeObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        syncTask?.cancel()
        pullSyncTask?.cancel()
    }

    // MARK: - Observation (Outbound: Local Changes → Apple Calendar)

    /// Start observing local calendar data changes
    ///
    /// Registers a notification observer for `.calendarDataDidChange` notifications.
    /// When changes are detected, schedules a debounced sync operation to push
    /// local changes to Apple Calendar.
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

    /// Stop observing local calendar data changes
    ///
    /// Removes the notification observer and cancels any pending sync tasks.
    func stopObserving() {
        if let observer = notificationObserver {
            NotificationCenter.default.removeObserver(observer)
            notificationObserver = nil
        }
        syncTask?.cancel()
    }

    // MARK: - Observation (Inbound: Apple Calendar Changes → Local)

    /// Start observing Apple Calendar external changes
    ///
    /// Registers a notification observer for `.EKEventStoreChanged` notifications.
    /// When Apple Calendar changes externally (e.g., synced from iCloud, edited on another device),
    /// schedules a debounced pull operation to fetch the changes.
    func startObservingExternalChanges() {
        externalChangeObserver = NotificationCenter.default.addObserver(
            forName: .EKEventStoreChanged,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.schedulePullRemoteChanges()
            }
        }
    }

    /// Stop observing Apple Calendar external changes
    ///
    /// Removes the external change observer and cancels any pending pull sync tasks.
    func stopObservingExternalChanges() {
        if let observer = externalChangeObserver {
            NotificationCenter.default.removeObserver(observer)
            externalChangeObserver = nil
        }
        pullSyncTask?.cancel()
    }

    // MARK: - Sync Orchestration

    /// Schedule a debounced outbound sync operation
    ///
    /// Cancels any pending sync and schedules a new one after the debounce interval.
    /// This prevents rapid sync operations when multiple local changes occur quickly.
    /// Used for pushing local changes to Apple Calendar.
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

    /// Schedule a debounced inbound sync operation
    ///
    /// Cancels any pending pull and schedules a new one after the debounce interval.
    /// This prevents rapid sync operations when multiple external changes occur quickly.
    /// Used for pulling remote changes from Apple Calendar.
    private func schedulePullRemoteChanges() {
        pullSyncTask?.cancel()

        pullSyncTask = Task { [weak self] in
            guard let self = self else { return }
            let interval = self.debounceInterval

            try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))

            guard !Task.isCancelled else { return }
            await self.performPullSync()
        }
    }

    /// Perform the actual outbound sync operation
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

    /// Perform the actual inbound sync operation
    ///
    /// Pulls remote changes from Apple Calendar into local storage.
    /// Called when external changes are detected via EKEventStoreChanged notification.
    private func performPullSync() async {
        guard !isSyncing else { return }

        isSyncing = true
        lastSyncError = nil

        defer {
            isSyncing = false
        }

        do {
            guard try await ensurePermissions() else { return }
            try await syncService.pullRemoteChanges()
        } catch {
            lastSyncError = error
            print("Pull sync failed: \(error)")
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
