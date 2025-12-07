//
//  CategoryPill.swift
//  lich-plus
//
//  Category selection pill with icon and color
//

import SwiftUI

struct CategoryPill: View {
    let category: TaskCategory
    let isSelected: Bool
    let action: () -> Void

    private var backgroundColor: Color {
        switch category {
        case .work:
            return AppColors.categoryWorkBackground
        case .personal:
            return AppColors.categoryPersonalBackground
        case .meeting:
            return AppColors.categoryMeetingBackground
        case .birthday:
            return AppColors.categoryBirthdayBackground
        case .holiday:
            return AppColors.categoryHolidayBackground
        case .other:
            return AppColors.categoryOtherBackground
        }
    }

    private var textColor: Color {
        switch category {
        case .work:
            return AppColors.categoryWorkText
        case .personal:
            return AppColors.categoryPersonalText
        case .meeting:
            return AppColors.categoryMeetingText
        case .birthday:
            return AppColors.categoryBirthdayText
        case .holiday:
            return AppColors.categoryHolidayText
        case .other:
            return AppColors.categoryOtherText
        }
    }

    private var iconName: String {
        switch category {
        case .work:
            return "briefcase.fill"
        case .personal:
            return "heart.fill"
        case .meeting:
            return "person.2.fill"
        case .birthday:
            return "gift.fill"
        case .holiday:
            return "sun.max.fill"
        case .other:
            return "tag.fill"
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.spacing4) {
                Image(systemName: iconName)
                    .font(.system(size: 12))

                Text(category.displayName)
                    .font(.system(size: AppTheme.fontBody, weight: .medium))
            }
            .foregroundStyle(textColor)
            .padding(.horizontal, AppTheme.spacing12)
            .padding(.vertical, AppTheme.spacing8)
            .background(backgroundColor)
            .cornerRadius(AppTheme.cornerRadiusLarge)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge)
                    .strokeBorder(isSelected ? textColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}
