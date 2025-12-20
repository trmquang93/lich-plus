//
//  BackgroundSyncManager.swift
//  lich-plus
//
//  Created by Claude on December 20, 2025.
//

import Foundation
import BackgroundTasks
import SwiftData
import Combine

/// Manages background sync operations for all calendar sources
///
/// Coordinates periodic synchronization of all enabled calendar sources:
/// - Apple Calendar
/// - Google Calendar
/// - Microsoft Calendar
/// - ICS Subscriptions
///
/// Default sync interval: 15 minutes
@MainActor
final class BackgroundSyncManager: ObservableObject {
    
    // Dependencies
    private let appleSyncService: CalendarSyncService?
    private let googleSyncService: GoogleCalendarSyncService?
    private let microsoftSyncService: MicrosoftCalendarSyncService?
    private let icsSyncService: ICSCalendarSyncService?
    
    // Configuration
    private let taskIdentifier = "com.lichplus.sync.background"
    private let defaultSyncInterval: TimeInterval = 15 * 60  // 15 minutes
    
    @Published var isScheduled = false
    @Published var lastBackgroundSyncDate: Date?
    
    init(
        appleSyncService: CalendarSyncService? = nil,
        googleSyncService: GoogleCalendarSyncService? = nil,
        microsoftSyncService: MicrosoftCalendarSyncService? = nil,
        icsSyncService: ICSCalendarSyncService? = nil
    ) {
        self.appleSyncService = appleSyncService
        self.googleSyncService = googleSyncService
        self.microsoftSyncService = microsoftSyncService
        self.icsSyncService = icsSyncService
        
        // Register background task handler
        BGTaskScheduler.shared.register(forTaskWithIdentifier: taskIdentifier, using: nil) { [weak self] task in
            Task { [weak self] in
                guard let appRefreshTask = task as? BGAppRefreshTask else {
                    print("[BackgroundSync] Error: Received task of unexpected type.")
                    task.setTaskCompleted(success: false)
                    return
                }
                await self?.handleBackgroundSync(task: appRefreshTask)
            }
        }
    }
    
    // MARK: - Scheduling
    
    /// Start scheduling background sync tasks
    func startScheduling() {
        let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: defaultSyncInterval)
        
        do {
            try BGTaskScheduler.shared.submit(request)
            isScheduled = true
            print("[BackgroundSync] Scheduled background sync in \(Int(defaultSyncInterval / 60)) minutes")
        } catch {
            print("[BackgroundSync] Failed to schedule background sync: \(error)")
            isScheduled = false
        }
    }
    
    /// Stop scheduling background sync tasks
    func stopScheduling() {
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: taskIdentifier)
        isScheduled = false
        print("[BackgroundSync] Cancelled background sync scheduling")
    }
    
    // MARK: - Background Sync Handler
    
    /// Handle background sync task
    private func handleBackgroundSync(task: BGAppRefreshTask) {
        print("[BackgroundSync] Starting background sync task")
        
        let startTime = Date()
        
        // Create a task that will complete when sync finishes or timeout occurs
        let syncTask = Task { [weak self] in
            do {
                try await self?.performBackgroundSync()
                task.setTaskCompleted(success: true)
                print("[BackgroundSync] Background sync completed successfully")
            } catch {
                task.setTaskCompleted(success: false)
                print("[BackgroundSync] Background sync failed: \(error)")
            }
            
            // Reschedule for next interval
            await MainActor.run {
                self?.startScheduling()
            }
        }
        
        // Set expiration handler - called when OS wants to terminate the task
        task.expirationHandler = {
            print("[BackgroundSync] Background sync task expired by system")
            syncTask.cancel()
        }
    }
    
    /// Perform actual sync across all sources
    private func performBackgroundSync() async throws {
        print("[BackgroundSync] Syncing all enabled sources...")
        
        var syncErrors: [Error] = []
        
        // Sync Apple Calendar
        if let appleSyncService = appleSyncService {
            do {
                print("[BackgroundSync] Syncing Apple Calendar...")
                try await appleSyncService.performFullSync()
                lastBackgroundSyncDate = Date()
                print("[BackgroundSync] Apple Calendar synced successfully")
            } catch {
                print("[BackgroundSync] Apple Calendar sync failed: \(error)")
                syncErrors.append(error)
            }
        }
        
        // Sync Google Calendar
        if let googleSyncService = googleSyncService {
            do {
                print("[BackgroundSync] Syncing Google Calendar...")
                try await googleSyncService.pullRemoteChanges()
                try await googleSyncService.pushLocalChanges()
                print("[BackgroundSync] Google Calendar synced successfully")
            } catch {
                print("[BackgroundSync] Google Calendar sync failed: \(error)")
                syncErrors.append(error)
            }
        }
        
        // Sync Microsoft Calendar
        if let microsoftSyncService = microsoftSyncService {
            do {
                print("[BackgroundSync] Syncing Microsoft Calendar...")
                try await microsoftSyncService.pullRemoteChanges()
                try await microsoftSyncService.pushLocalChanges()
                print("[BackgroundSync] Microsoft Calendar synced successfully")
            } catch {
                print("[BackgroundSync] Microsoft Calendar sync failed: \(error)")
                syncErrors.append(error)
            }
        }
        
        // Sync ICS Subscriptions
        if let icsSyncService = icsSyncService {
            do {
                print("[BackgroundSync] Syncing ICS subscriptions...")
                try await icsSyncService.pullRemoteChanges()
                print("[BackgroundSync] ICS subscriptions synced successfully")
            } catch {
                print("[BackgroundSync] ICS sync failed: \(error)")
                syncErrors.append(error)
            }
        }
        
        lastBackgroundSyncDate = Date()
        
        // If any syncs failed, throw the first error
        if let firstError = syncErrors.first {
            throw firstError
        }
        
        print("[BackgroundSync] All sources synced successfully")
    }
}
