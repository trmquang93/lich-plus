//
//  EmptyStateView.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 26/11/25.
//

import SwiftUI

struct EmptyStateView: View {
    let title: String
    let message: String
    let onAddNew: () -> Void

    var body: some View {
        VStack(spacing: AppTheme.spacing16) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 48))
                .foregroundStyle(AppColors.borderLight)

            Text(title)
                .font(.system(size: AppTheme.fontSubheading, weight: .semibold))
                .foregroundStyle(AppColors.textPrimary)

            Text(message)
                .font(.system(size: AppTheme.fontBody))
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)

            Button(action: onAddNew) {
                Text(String(localized: "empty.addButton"))
                    .font(.system(size: AppTheme.fontBody, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, AppTheme.spacing24)
                    .padding(.vertical, AppTheme.spacing12)
                    .background(AppColors.primary)
                    .cornerRadius(AppTheme.cornerRadiusMedium)
            }
        }
        .padding(AppTheme.spacing24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmptyStateView(
        title: "No tasks today",
        message: "Enjoy your day! Create a new task to get started.",
        onAddNew: {}
    )
    .background(AppColors.background)
}
