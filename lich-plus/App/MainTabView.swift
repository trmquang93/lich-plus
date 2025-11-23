//
//  ContentView.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 23/11/25.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            CalendarView()
                .tabItem {
                    Label("tab.calendar", systemImage: "calendar")
                }
                .tag(0)

            TasksView()
                .tabItem {
                    Label("tab.tasks", systemImage: "checkmark.circle")
                }
                .tag(1)

            AIView()
                .tabItem {
                    Label("tab.ai", systemImage: "sparkles")
                }
                .tag(2)

            SettingsView()
                .tabItem {
                    Label("tab.settings", systemImage: "gear")
                }
                .tag(3)
        }
        .tint(AppColors.primary)
        .task {
            configureTabBarAppearance()
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
