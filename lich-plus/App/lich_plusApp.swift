//
//  lich_plusApp.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 22/11/25.
//

import SwiftUI
import SwiftData

@main
struct lich_plusApp: App {
    // Set up AppDelegate for notification handling
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    // Create notification service
    @StateObject private var notificationService: NotificationService
    
    init() {
        AppColors.configureSegmentedControlAppearance()
        
        // Initialize notification service with container's main context for data consistency
        let persistenceController = PersistenceController.shared
        _notificationService = StateObject(
            wrappedValue: NotificationService(modelContext: persistenceController.container.mainContext)
        )
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(.light)
                .modelContainer(PersistenceController.shared.container)
                .environmentObject(notificationService)
                .onAppear {
                    // Reschedule notifications on app launch
                    Task {
                        await notificationService.rescheduleAllNotifications()
                    }
                }
        }
    }
}
