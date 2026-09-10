//
//  ElderModeSettingsView.swift
//  lich-plus
//

import SwiftUI

struct ElderModeSettingsView: View {
    @ObservedObject private var elderMode = ElderModeStore.shared

    var body: some View {
        List {
            Section {
                Toggle(String(localized: "Large text mode"), isOn: Binding(
                    get: { elderMode.isEnabled },
                    set: { elderMode.setEnabled($0) }
                ))
            } footer: {
                Text(String(localized: "Enlarges text and spacing across the app. Respects system Dynamic Type where possible."))
            }

            Section(String(localized: "Preview")) {
                VStack(alignment: .leading, spacing: AppTheme.spacing12) {
                    Text(String(localized: "Today"))
                        .elderModeFont(size: AppTheme.fontTitle2, weight: .bold)
                        .foregroundStyle(AppColors.textPrimary)
                    Text(String(localized: "Lunar 15/8/2026 · Giáp Thìn"))
                        .elderModeFont(size: AppTheme.fontBody)
                        .foregroundStyle(AppColors.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .elderModePadding(.vertical, AppTheme.spacing8)
            }
        }
        .navigationTitle(String(localized: "Large text mode"))
        .trackAnalyticsScreen(.elder_mode_settings)
    }
}

#Preview {
    NavigationStack {
        ElderModeSettingsView()
    }
}
