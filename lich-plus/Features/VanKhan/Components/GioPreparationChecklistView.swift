//
//  GioPreparationChecklistView.swift
//  lich-plus
//
//  Light “chuẩn bị cúng” checklist for giỗ-style lunar events.
//

import SwiftUI

struct GioPreparationChecklistView: View {
    @AppStorage("gio_checklist_v1") private var checkedRaw: String = ""

    private let items: [String] = [
        String(localized: "Buy fruit and flowers"),
        String(localized: "Prepare offering tray"),
        String(localized: "Review văn khấn text"),
        String(localized: "Notify family members"),
        String(localized: "Clean altar area"),
    ]

    private var checkedIndices: Set<Int> {
        Set(checkedRaw.split(separator: ",").compactMap { Int($0) })
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing8) {
            Text(String(localized: "Giỗ preparation"))
                .font(.system(size: AppTheme.fontSubheading, weight: .semibold))
                .foregroundStyle(AppColors.textPrimary)

            Text(String(localized: "A simple checklist — resets each lunar year."))
                .font(.system(size: AppTheme.fontCaption))
                .foregroundStyle(AppColors.textSecondary)

            ForEach(Array(items.enumerated()), id: \.offset) { index, title in
                Button {
                    toggle(index)
                } label: {
                    HStack(spacing: AppTheme.spacing12) {
                        Image(systemName: checkedIndices.contains(index) ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(checkedIndices.contains(index) ? AppColors.accent : AppColors.textDisabled)
                        Text(title)
                            .font(.system(size: AppTheme.fontBody))
                            .foregroundStyle(AppColors.textPrimary)
                            .multilineTextAlignment(.leading)
                        Spacer(minLength: 0)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(AppTheme.spacing16)
        .background(AppColors.vkPaper)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge)
                .strokeBorder(AppColors.vkGoldSoft, lineWidth: 1)
        )
        .onAppear {
            AnalyticsService.shared.logFeatureUsed(.gio_reminder_preset)
        }
    }

    private func toggle(_ index: Int) {
        var set = checkedIndices
        if set.contains(index) {
            set.remove(index)
        } else {
            set.insert(index)
        }
        checkedRaw = set.sorted().map(String.init).joined(separator: ",")
    }
}

#Preview {
    GioPreparationChecklistView()
        .padding()
}
