//
//  ContentView.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 23/11/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            CalendarView()
                .tabItem {
                    Label("Lịch", systemImage: "calendar")
                }
                .tag(0)

            TasksView()
                .tabItem {
                    Label("Việc", systemImage: "checkmark.circle")
                }
                .tag(1)

            AIView()
                .tabItem {
                    Label("AI", systemImage: "sparkles")
                }
                .tag(2)

            SettingsView()
                .tabItem {
                    Label("Cài đặt", systemImage: "gear")
                }
                .tag(3)
        }
    }
}

#Preview {
    ContentView()
}
