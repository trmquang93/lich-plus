//
//  TodayView.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 26/11/25.
//

import SwiftUI

struct TodayView: View {
    let tasks: [TaskItem]
    let onToggleCompletion: (TaskItem) -> Void
    let onDelete: (TaskItem) -> Void
    let onEdit: (TaskItem) -> Void
    let onAddNew: () -> Void

    var body: some View {
        ScrollView {
            if tasks.isEmpty {
                EmptyStateView(
                    title: String(localized: "today.empty.title"),
                    message: String(localized: "today.empty.message"),
                    onAddNew: onAddNew
                )
            } else {
                VStack(spacing: 0) {
                    DateSectionHeader(date: Date())
                        .background(AppColors.backgroundLightGray)

                    VStack(spacing: AppTheme.spacing12) {
                        ForEach(tasks, id: \.id) { task in
                            TimelineItemCard(
                                task: task,
                                onToggleCompletion: onToggleCompletion,
                                onDelete: onDelete,
                                onEdit: onEdit
                            )
                        }
                    }
                    .padding(AppTheme.spacing16)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
    }
}

#Preview {
    TodayView(
        tasks: [
            TaskItem(
                title: "Team Meeting",
                date: Date(),
                startTime: Date(),
                endTime: Date(timeIntervalSinceNow: 3600),
                category: .meeting,
                itemType: .event
            ),
            TaskItem(
                title: "Complete report",
                date: Date(),
                category: .work,
                itemType: .task,
                priority: .high
            ),
        ],
        onToggleCompletion: { _ in },
        onDelete: { _ in },
        onEdit: { _ in },
        onAddNew: {}
    )
}
