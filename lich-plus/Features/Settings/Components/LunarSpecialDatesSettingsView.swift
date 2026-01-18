//
//  LunarSpecialDatesSettingsView.swift
//  lich-plus
//
//  Created by Claude Code
//

import SwiftUI
import SwiftData

struct LunarSpecialDatesSettingsView: View {
    @State private var viewModel: LunarSpecialDatesViewModel

    init(viewModel: LunarSpecialDatesViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Form {
            Section {
                ForEach(LunarSpecialDate.allDates, id: \.id) { specialDate in
                    ToggleRow(
                        title: specialDate.title,
                        description: descriptionForSpecialDate(specialDate),
                        color: Color(hex: specialDate.colorHex) ?? AppColors.primary,
                        isOn: bindingForSpecialDate(specialDate)
                    )
                }
            } header: {
                Text(String(localized: "Special Dates"))
            } footer: {
                Text(String(localized: "Automatically add lunar calendar events for Mùng 1 and Rằm each month"))
            }
        }
        .navigationTitle(String(localized: "Lunar Special Dates"))
    }

    private func descriptionForSpecialDate(_ specialDate: LunarSpecialDate) -> String {
        if specialDate.lunarDay == 1 {
            return String(localized: "First day of lunar month - for ancestor worship")
        } else {
            return String(localized: "Full moon day (15th) - for temple visits")
        }
    }

    private func bindingForSpecialDate(_ specialDate: LunarSpecialDate) -> Binding<Bool> {
        Binding(
            get: { viewModel.isEnabled(specialDate) },
            set: { newValue in
                viewModel.toggle(specialDate, enabled: newValue)
            }
        )
    }
}

private struct ToggleRow: View {
    let title: String
    let description: String
    let color: Color
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: AppTheme.spacing12) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)

            VStack(alignment: .leading, spacing: AppTheme.spacing4) {
                Text(title)
                    .font(.body)
                    .foregroundStyle(AppColors.textPrimary)

                Text(description)
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()

            Toggle("", isOn: $isOn)
        }
        .padding(.vertical, AppTheme.spacing4)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: SyncableEvent.self, configurations: config)
    let modelContext = ModelContext(container)
    let service = LunarSpecialDateService(modelContext: modelContext)
    let viewModel = LunarSpecialDatesViewModel(service: service)

    return NavigationStack {
        LunarSpecialDatesSettingsView(viewModel: viewModel)
    }
}
