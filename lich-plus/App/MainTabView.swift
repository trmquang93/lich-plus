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

    var body: some View {
        TabView(selection: $selectedTab) {
            CalendarView()
                .tabItem {
                    Label("tab.calendar", systemImage: "calendar")
                }
                .tag(0)

            TasksView()
                .tabItem {
                    Label("tab.tasks", systemImage: "list.bullet")
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
        }
        .task {
            // Configure tab bar appearance
            configureTabBarAppearance()
            // Restore previous Google sign-in session
            await googleAuthService.restorePreviousSignIn()
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
}

#Preview {
    MainTabView()
}
