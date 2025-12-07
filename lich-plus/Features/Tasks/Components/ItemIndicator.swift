//
//  ItemIndicator.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 26/11/25.
//

import SwiftUI

/// A visual indicator component that displays different UI for tasks and events.
///
/// For tasks: Shows a checkbox (unchecked circle or checked circle with checkmark)
/// For events: Shows a calendar icon
///
/// This component provides interactive feedback with optional toggle callback for tasks.
struct ItemIndicator: View {
    let itemType: ItemType
    let isCompleted: Bool
    let onToggle: () -> Void

    var body: some View {
        switch itemType {
        case .task:
            taskIndicator
        case .event:
            eventIndicator
        }
    }

    // MARK: - Task Indicator (Checkbox)

    private var taskIndicator: some View {
        Button(action: onToggle) {
            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(AppColors.primary)
            } else {
                Circle()
                    .fill(AppColors.white)
                    .overlay(Circle().strokeBorder(AppColors.borderLight, lineWidth: 2))
                    .frame(width: 24, height: 24)
            }
        }
    }

    // MARK: - Event Indicator (Calendar Icon)

    private var eventIndicator: some View {
        Image(systemName: "calendar")
            .font(.system(size: 20, weight: .semibold))
            .foregroundColor(AppColors.primary)
    }
}

#Preview {
    VStack(spacing: AppTheme.spacing20) {
        // MARK: - Unchecked Task

        VStack(alignment: .leading, spacing: AppTheme.spacing8) {
            Text("Unchecked Task")
                .font(.system(size: AppTheme.fontSubheading, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)

            HStack(spacing: AppTheme.spacing12) {
                ItemIndicator(itemType: .task, isCompleted: false, onToggle: {})
                Text("Toggle to complete")
                    .font(.system(size: AppTheme.fontBody))
                    .foregroundColor(AppColors.textSecondary)
                Spacer()
            }
        }

        // MARK: - Checked Task

        VStack(alignment: .leading, spacing: AppTheme.spacing8) {
            Text("Completed Task")
                .font(.system(size: AppTheme.fontSubheading, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)

            HStack(spacing: AppTheme.spacing12) {
                ItemIndicator(itemType: .task, isCompleted: true, onToggle: {})
                Text("Click to mark incomplete")
                    .font(.system(size: AppTheme.fontBody))
                    .foregroundColor(AppColors.textSecondary)
                Spacer()
            }
        }

        // MARK: - Event Indicator

        VStack(alignment: .leading, spacing: AppTheme.spacing8) {
            Text("Event Indicator")
                .font(.system(size: AppTheme.fontSubheading, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)

            HStack(spacing: AppTheme.spacing12) {
                ItemIndicator(itemType: .event, isCompleted: false, onToggle: {})
                Text("Event items show calendar icon")
                    .font(.system(size: AppTheme.fontBody))
                    .foregroundColor(AppColors.textSecondary)
                Spacer()
            }
        }
    }
    .padding()
}
