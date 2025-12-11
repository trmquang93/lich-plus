//
//  ContentView.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 23/11/25.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @Environment(\.modelContext) var modelContext
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
        // Auto-sync coordinator environment object
        .environmentObject(autoSyncCoordinator ?? createAutoSyncCoordinator())
        .tint(AppColors.primary)
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

    // MARK: - Auto-Sync Initialization

    /// Create AutoSyncCoordinator with proper dependencies
    private func createAutoSyncCoordinator() -> AutoSyncCoordinator {
        let sync = syncService ?? CalendarSyncService(eventKitService: eventKitService, modelContext: modelContext)
        return AutoSyncCoordinator(
            syncService: sync,
            eventKitService: eventKitService,
            modelContext: modelContext
        )
    }

    /// Initialize auto-sync coordinator on app appearance
    private func initializeAutoSync() {
        guard autoSyncCoordinator == nil else { return }

        autoSyncCoordinator = createAutoSyncCoordinator()
        autoSyncCoordinator?.startObserving()
    }
}

#Preview {
    MainTabView()
}
