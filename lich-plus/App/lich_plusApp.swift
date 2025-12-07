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
    init() {
        AppColors.configureSegmentedControlAppearance()
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(.light)
                .modelContainer(PersistenceController.shared.container)
        }
    }
}
