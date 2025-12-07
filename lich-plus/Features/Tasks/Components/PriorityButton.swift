//
//  PriorityButton.swift
//  lich-plus
//
//  Priority selection button component
//

import SwiftUI

struct PriorityButton: View {
    let priority: Priority
    let isSelected: Bool
    let action: () -> Void

    private var borderColor: Color {
        switch priority {
        case .high:
            return AppColors.primary
        case .medium:
            return AppColors.eventOrange
        case .low, .none:
            return AppColors.borderLight
        }
    }

    private var textColor: Color {
        switch priority {
        case .high:
            return AppColors.primary
        case .medium:
            return AppColors.eventOrange
        case .low, .none:
            return AppColors.textSecondary
        }
    }

    private var backgroundColor: Color {
        guard isSelected else { return AppColors.background }
        switch priority {
        case .high:
            return AppColors.priorityHighBackground
        case .medium:
            return AppColors.priorityMediumBackground
        case .low, .none:
            return AppColors.background
        }
    }

    var body: some View {
        Button(action: action) {
            Text(priority.displayName)
                .font(.system(size: AppTheme.fontBody, weight: .medium))
                .foregroundStyle(textColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppTheme.spacing12)
                .background(backgroundColor)
                .cornerRadius(AppTheme.cornerRadiusLarge)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge)
                        .stroke(borderColor, lineWidth: isSelected ? 2 : 1)
                )
        }
        .buttonStyle(.plain)
    }
}
