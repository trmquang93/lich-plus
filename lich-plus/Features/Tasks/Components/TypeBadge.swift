//
//  TypeBadge.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 26/11/25.
//

import SwiftUI

/// A pill-shaped badge displaying the item type (Task or Event).
///
/// This component shows a visual indicator of whether an item is a task or event.
/// It uses a capsule shape with the app's badge color scheme.
struct TypeBadge: View {
    let itemType: ItemType

    var body: some View {
        Text(itemType.displayName)
            .font(.system(size: AppTheme.fontCaption, weight: .medium))
            .foregroundColor(AppColors.badgeText)
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(AppColors.badgeBackground)
            .clipShape(Capsule())
    }
}

#Preview {
    VStack(spacing: AppTheme.spacing12) {
        HStack(spacing: AppTheme.spacing12) {
            TypeBadge(itemType: .task)
            TypeBadge(itemType: .event)
            Spacer()
        }

        HStack(spacing: AppTheme.spacing12) {
            VStack(alignment: .leading, spacing: AppTheme.spacing8) {
                Text("Task Badge")
                    .font(.system(size: AppTheme.fontBody, weight: .semibold))
                TypeBadge(itemType: .task)
            }

            VStack(alignment: .leading, spacing: AppTheme.spacing8) {
                Text("Event Badge")
                    .font(.system(size: AppTheme.fontBody, weight: .semibold))
                TypeBadge(itemType: .event)
            }

            Spacer()
        }
    }
    .padding()
}
