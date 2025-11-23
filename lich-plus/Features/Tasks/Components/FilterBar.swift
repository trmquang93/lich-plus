//
//  FilterBar.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 23/11/25.
//

import SwiftUI

enum TaskFilter {
    case all
    case today
    case thisWeek
    case thisMonth

    var label: String {
        switch self {
        case .all:
            return String(localized: "task.all")
        case .today:
            return String(localized: "task.today")
        case .thisWeek:
            return String(localized: "task.thisWeek")
        case .thisMonth:
            return String(localized: "task.thisMonth")
        }
    }
}

struct FilterBar: View {
    @Binding var selectedFilter: TaskFilter
    let filters: [TaskFilter] = [.all, .today, .thisWeek, .thisMonth]
    let taskCounts: [TaskFilter: Int]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.spacing8) {
                ForEach(filters, id: \.self) { filter in
                    FilterButton(
                        label: filter.label,
                        count: taskCounts[filter] ?? 0,
                        isSelected: selectedFilter == filter
                    )
                    .onTapGesture {
                        withAnimation {
                            selectedFilter = filter
                        }
                    }
                }
            }
            .padding(.horizontal, AppTheme.spacing16)
        }
        .padding(.vertical, AppTheme.spacing8)
    }
}

// MARK: - Filter Button

struct FilterButton: View {
    let label: String
    let count: Int
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 2) {
            HStack(spacing: AppTheme.spacing4) {
                Text(label)
                    .font(.system(size: AppTheme.fontBody, weight: isSelected ? .semibold : .regular))

                Text("(\(count))")
                    .font(.system(size: AppTheme.fontCaption, weight: .regular))
            }
            .foregroundStyle(isSelected ? .white : AppColors.textSecondary)
        }
        .padding(.horizontal, AppTheme.spacing12)
        .padding(.vertical, AppTheme.spacing8)
        .background(isSelected ? AppColors.primary : AppColors.backgroundLightGray)
        .cornerRadius(AppTheme.cornerRadiusMedium)
    }
}

// MARK: - Hashable Conformance

extension TaskFilter: Hashable {}

#Preview {
    FilterBar(
        selectedFilter: .constant(.all),
        taskCounts: [.all: 10, .today: 3, .thisWeek: 7, .thisMonth: 15]
    )
}
