//
//  ContentView.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 23/11/25.
//

import SwiftUI
import SwiftData
import EventKit

struct MainTabView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.scenePhase) var scenePhase
    @State private var selectedTab: Int = 0

    // Apple Calendar services
    @StateObject private var eventKitService = EventKitService()
    @State private var syncService: CalendarSyncService?

    // Google Calendar services
    @StateObject private var googleAuthService = GoogleAuthService()
    @State private var googleCalendarService: GoogleCalendarService?
    @State private var googleSyncService: GoogleCalendarSyncService?

    // Microsoft Calendar services
    @StateObject private var microsoftAuthService = MicrosoftAuthService()
    @State private var microsoftCalendarService: MicrosoftCalendarService?
    @State private var microsoftSyncService: MicrosoftCalendarSyncService?

    // ICS Calendar services
    @State private var icsSyncService: ICSCalendarSyncService?

    // Built-in Calendar services
    @State private var builtInCalendarManager: BuiltInCalendarManager?

    // Auto-sync coordinator for Apple Calendar
    @State private var autoSyncCoordinator: AutoSyncCoordinator?
    
    // Background sync manager for periodic sync
    @State private var backgroundSyncManager: BackgroundSyncManager?

    var body: some View {
        TabView(selection: $selectedTab) {
            CalendarView()
                .tabItem {
                    Label("tab.calendar", systemImage: "calendar")
                }
                .tag(0)

            TasksView()
                .tabItem {
                    Label("tab.timeline", systemImage: "list.bullet")
                }
                .tag(1)

            SettingsView()
                .tabItem {
                    Label("tab.settings", systemImage: "gear")
                }
                .tag(2)
        }
        // Apple Calendar environment objects
        .environmentObject(eventKitService)
        .environmentObject(syncService ?? CalendarSyncService(eventKitService: eventKitService, modelContext: modelContext))
        // Google Calendar environment objects
        .environmentObject(googleAuthService)
        .environmentObject(googleSyncService ?? createGoogleSyncService())
        // Microsoft Calendar environment objects
        .environmentObject(microsoftAuthService)
        .environmentObject(microsoftSyncService ?? createMicrosoftSyncService())
        // ICS Calendar environment objects
        .environmentObject(icsSyncService ?? createICSSyncService())
        .tint(AppColors.primary)
        // Handle app lifecycle for sync management
        .onChange(of: scenePhase) { oldPhase, newPhase in
            handleScenePhaseChange(from: oldPhase, to: newPhase)
        }
        // Handle Google Sign-In URL callback
        .onOpenURL { url in
            _ = googleAuthService.handle(url)
        }
        .onAppear {
            // Initialize Apple Calendar sync service
            if syncService == nil {
                syncService = CalendarSyncService(eventKitService: eventKitService, modelContext: modelContext)
            }
            // Initialize Google Calendar services
            initializeGoogleServices()
            // Initialize Microsoft Calendar services
            initializeMicrosoftServices()
            // Initialize ICS Calendar services
            initializeICSServices()
            // Initialize built-in calendars (first launch only)
            initializeBuiltInCalendars()
            // Initialize auto-sync coordinator
            initializeAutoSync()
            // Initialize background sync manager
            initializeBackgroundSync()
        }
        .task {
            // Configure tab bar appearance
            configureTabBarAppearance()
            // Restore previous Google sign-in session
            await googleAuthService.restorePreviousSignIn()
            // Restore previous Microsoft sign-in session
            await microsoftAuthService.restorePreviousSignIn()
        }
    }

    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = AppColors.background.uiColor

        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.titleTextAttributes = [
            .foregroundColor: AppColors.secondary.uiColor,
            .font: UIFont.systemFont(ofSize: AppTheme.fontCaption),
        ]
        itemAppearance.selected.titleTextAttributes = [
            .foregroundColor: AppColors.primary.uiColor,
            .font: UIFont.systemFont(ofSize: AppTheme.fontCaption, weight: .semibold),
        ]
        itemAppearance.normal.iconColor = AppColors.secondary.uiColor
        itemAppearance.selected.iconColor = AppColors.primary.uiColor

        appearance.stackedLayoutAppearance = itemAppearance
        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance

        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }

    // MARK: - Google Services Initialization

    /// Create GoogleSyncService with proper dependencies
    private func createGoogleSyncService() -> GoogleCalendarSyncService {
        let calService = googleCalendarService ?? GoogleCalendarService(authService: googleAuthService)
        return GoogleCalendarSyncService(
            authService: googleAuthService,
            calendarService: calService,
            modelContext: modelContext
        )
    }

    /// Initialize Google Calendar services on app appearance
    private func initializeGoogleServices() {
        if googleCalendarService == nil {
            googleCalendarService = GoogleCalendarService(authService: googleAuthService)
        }
        if googleSyncService == nil {
            googleSyncService = GoogleCalendarSyncService(
                authService: googleAuthService,
                calendarService: googleCalendarService!,
                modelContext: modelContext
            )
        }
    }

    // MARK: - Microsoft Services Initialization

    /// Create MicrosoftSyncService with proper dependencies
    private func createMicrosoftSyncService() -> MicrosoftCalendarSyncService {
        let calService = microsoftCalendarService ?? MicrosoftCalendarService(authService: microsoftAuthService)
        return MicrosoftCalendarSyncService(
            authService: microsoftAuthService,
            calendarService: calService,
            modelContext: modelContext
        )
    }

    /// Initialize Microsoft Calendar services on app appearance
    private func initializeMicrosoftServices() {
        if microsoftCalendarService == nil {
            microsoftCalendarService = MicrosoftCalendarService(authService: microsoftAuthService)
        }
        if microsoftSyncService == nil {
            microsoftSyncService = MicrosoftCalendarSyncService(
                authService: microsoftAuthService,
                calendarService: microsoftCalendarService!,
                modelContext: modelContext
            )
        }
    }

    // MARK: - ICS Services Initialization

    /// Create ICSCalendarSyncService with proper dependencies
    private func createICSSyncService() -> ICSCalendarSyncService {
        return ICSCalendarSyncService(modelContext: modelContext)
    }

    /// Initialize ICS Calendar services on app appearance
    private func initializeICSServices() {
        if icsSyncService == nil {
            icsSyncService = ICSCalendarSyncService(modelContext: modelContext)
        }
    }

    // MARK: - Built-in Calendars Initialization

    /// Initialize built-in calendars on first app launch
    private func initializeBuiltInCalendars() {
        let manager = BuiltInCalendarManager()
        if !manager.isInitialized() {
            Task {
                do {
                    try await manager.initializeBuiltInCalendars(modelContext: modelContext)
                    // Trigger sync to fetch events from built-in calendars
                    try await icsSyncService?.pullRemoteChanges()
                } catch {
                    print("Failed to initialize built-in calendars: \(error)")
                }
            }
        }
        builtInCalendarManager = manager
    }

    // MARK: - Scene Phase Management

    /// Handle app lifecycle transitions for sync coordination
    private func handleScenePhaseChange(from oldPhase: ScenePhase, to newPhase: ScenePhase) {
        switch newPhase {
        case .active:
            // App became active - resume observing changes
            autoSyncCoordinator?.startObserving()
            autoSyncCoordinator?.startObservingExternalChanges()
            // Start background sync scheduling when app is active
            backgroundSyncManager?.startScheduling()
        case .inactive:
            // App transitioning to background - nothing special needed
            break
        case .background:
            // App went to background - stop observing to save resources
            // Changes will be synced on next foreground activation
            autoSyncCoordinator?.stopObserving()
            autoSyncCoordinator?.stopObservingExternalChanges()
            // Stop background sync scheduling in background (will resume on active)
            backgroundSyncManager?.stopScheduling()
        @unknown default:
            break
        }
    }

    // MARK: - Auto-Sync Initialization

    /// Initialize auto-sync coordinator on app appearance
    ///
    /// Must be called after syncService is initialized.
    /// Sets up:
    /// - Outbound sync (local changes → Apple Calendar)
    /// - Inbound sync (Apple Calendar changes → local)
    /// - Initial full sync on app launch
    private func initializeAutoSync() {
        guard autoSyncCoordinator == nil, let sync = syncService else { return }

        autoSyncCoordinator = AutoSyncCoordinator(
            syncService: sync,
            eventKitService: eventKitService,
            modelContext: modelContext
        )
        
        // Start observing local changes (outbound)
        autoSyncCoordinator?.startObserving()
        
        // Start observing external changes (inbound from Apple Calendar)
        autoSyncCoordinator?.startObservingExternalChanges()
        
        // Trigger initial full sync on app launch
        Task {
            await autoSyncCoordinator?.performSync()
        }
    }
    
    // MARK: - Background Sync Initialization
    
    /// Initialize background sync manager
    ///
    /// Sets up periodic background sync for all enabled calendar sources.
    /// Sync interval: 15 minutes
    private func initializeBackgroundSync() {
        guard backgroundSyncManager == nil else { return }
        
        backgroundSyncManager = BackgroundSyncManager(
            appleSyncService: syncService,
            googleSyncService: googleSyncService,
            microsoftSyncService: microsoftSyncService,
            icsSyncService: icsSyncService
        )
        
        // Start scheduling background sync
        backgroundSyncManager?.startScheduling()
    }
}

#Preview {
    MainTabView()
}
