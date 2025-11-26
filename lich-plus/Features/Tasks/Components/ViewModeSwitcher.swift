//
//  ViewModeSwitcher.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 26/11/25.
//

import SwiftUI

// MARK: - View Mode Enum

enum ViewMode: String, CaseIterable, Identifiable {
    case today
    case thisWeek
    case all

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .today:
            return String(localized: "viewMode.today")
        case .thisWeek:
            return String(localized: "viewMode.thisWeek")
        case .all:
            return String(localized: "viewMode.all")
        }
    }
}

// MARK: - View Mode Switcher Component

struct ViewModeSwitcher: View {
    @Binding var selectedMode: ViewMode

    var body: some View {
        Picker("", selection: $selectedMode) {
            ForEach(ViewMode.allCases) { mode in
                Text(mode.displayName).tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, AppTheme.spacing16)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var selectedMode = ViewMode.today

        var body: some View {
            ViewModeSwitcher(selectedMode: $selectedMode)
                .padding()
        }
    }

    return PreviewWrapper()
}
