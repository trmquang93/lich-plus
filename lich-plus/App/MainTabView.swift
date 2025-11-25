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
    @StateObject private var eventKitService = EventKitService()
    @State private var syncService: CalendarSyncService?

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

            AIView()
                .tabItem {
                    Label {
                        Text("tab.ai")
                    } icon: {
                        Image("ai.tab")
                            .renderingMode(.template)
                    }
                }
                .tag(2)

            SettingsView()
                .tabItem {
                    Label("tab.settings", systemImage: "gear")
                }
                .tag(3)
        }
        .environmentObject(eventKitService)
        .environmentObject(syncService ?? CalendarSyncService(eventKitService: eventKitService, modelContext: modelContext))
        .tint(AppColors.primary)
        .task {
            configureTabBarAppearance()
        }
        .onAppear {
            // Initialize sync service
            if syncService == nil {
                syncService = CalendarSyncService(eventKitService: eventKitService, modelContext: modelContext)
            }
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
}

#Preview {
    MainTabView()
}
