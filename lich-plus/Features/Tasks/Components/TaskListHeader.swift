//
//  TaskListHeader.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 23/11/25.
//

import SwiftUI

struct TaskListHeader: View {
    @Binding var searchText: String
    @Binding var showAddSheet: Bool
    @Binding var isAISearchMode: Bool

    var body: some View {
        VStack(spacing: AppTheme.spacing12) {
            HStack {
                Text("task.myTasks")
                    .font(.system(size: AppTheme.fontTitle2, weight: .bold))
                    .foregroundStyle(AppColors.textPrimary)

                Spacer()

                Button(action: { showAddSheet = true }) {
                    HStack(spacing: AppTheme.spacing4) {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .semibold))
                        Text("task.add")
                            .font(.system(size: AppTheme.fontBody, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, AppTheme.spacing12)
                    .padding(.vertical, AppTheme.spacing8)
                    .background(AppColors.primary)
                    .cornerRadius(AppTheme.cornerRadiusMedium)
                }
            }

            HStack(spacing: AppTheme.spacing8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(AppColors.textSecondary)

                TextField("task.search", text: $searchText)
                    .textContentType(.none)
                    .font(.system(size: AppTheme.fontBody))
                    .foregroundStyle(AppColors.textPrimary)

                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }

                Divider()
                    .frame(height: 24)

                SearchModeToggle(isAIMode: $isAISearchMode)
            }
            .padding(.horizontal, AppTheme.spacing12)
            .padding(.vertical, AppTheme.spacing8)
            .background(AppColors.backgroundLightGray)
            .cornerRadius(AppTheme.cornerRadiusMedium)
        }
        .padding(AppTheme.spacing16)
        .background(AppColors.background)
    }
}

#Preview {
    TaskListHeader(
        searchText: .constant(""),
        showAddSheet: .constant(false),
        isAISearchMode: .constant(false)
    )
}
