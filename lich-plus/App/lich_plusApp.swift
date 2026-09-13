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
    @StateObject private var elderMode = ElderModeStore.shared
    @AppStorage(OnboardingStore.completionKey) private var hasCompletedOnboarding = false
    
    init() {
        // Initialize language manager BEFORE other services
        LanguageManager.shared.initialize()

        AppColors.configureSegmentedControlAppearance()

        // Initialize notification service with container's main context for data consistency
        let persistenceController = PersistenceController.shared
        _notificationService = StateObject(
            wrappedValue: NotificationService(modelContext: persistenceController.container.mainContext)
        )
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    MainTabView()
                } else {
                    OnboardingView {
                        hasCompletedOnboarding = true
                    }
                }
            }
            .preferredColorScheme(.light)
            .modelContainer(PersistenceController.shared.container)
            .environmentObject(notificationService)
            .environment(\.elderModeEnabled, elderMode.isEnabled)
            .onAppear {
                guard hasCompletedOnboarding else { return }
                // Reschedule notifications on app launch
                Task {
                    await notificationService.rescheduleAllNotifications()
                    await WidgetInstallTracker.trackInstalledWidgetsIfNeeded()
                }
                WidgetSnapshotCoordinator.shared.refresh(
                    modelContext: PersistenceController.shared.container.mainContext
                )
            }
            .onChange(of: hasCompletedOnboarding) { _, completed in
                guard completed else { return }
                Task {
                    await notificationService.rescheduleAllNotifications()
                    await WidgetInstallTracker.trackInstalledWidgetsIfNeeded()
                }
                WidgetSnapshotCoordinator.shared.refresh(
                    modelContext: PersistenceController.shared.container.mainContext
                )
            }
        }
    }
}
