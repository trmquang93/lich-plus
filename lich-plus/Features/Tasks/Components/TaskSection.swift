//
//  TaskSection.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 23/11/25.
//

import SwiftUI

struct TaskSection: View {
    let title: String
    let tasks: [Task]
    let onToggleCompletion: (Task) -> Void
    let onDelete: (Task) -> Void
    let onEdit: (Task) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing12) {
            // Section Header
            HStack {
                Text(title)
                    .font(.system(size: AppTheme.fontSubheading, weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)

                Spacer()

                Text("(\(tasks.count))")
                    .font(.system(size: AppTheme.fontCaption))
                    .foregroundStyle(AppColors.textSecondary)
            }
            .padding(.horizontal, AppTheme.spacing16)

            // Tasks
            if tasks.isEmpty {
                VStack {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 32))
                        .foregroundStyle(AppColors.borderLight)

                    Text("No tasks")
                        .font(.system(size: AppTheme.fontBody))
                        .foregroundStyle(AppColors.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(AppTheme.spacing16)
            } else {
                VStack(spacing: AppTheme.spacing12) {
                    ForEach(tasks, id: \.id) { task in
                        TaskCard(
                            task: task,
                            onToggleCompletion: onToggleCompletion,
                            onDelete: onDelete,
                            onEdit: onEdit
                        )
                    }
                }
                .padding(.horizontal, AppTheme.spacing16)
            }
        }
        .padding(.vertical, AppTheme.spacing12)
    }
}

#Preview {
    TaskSection(
        title: "Today",
        tasks: [
            Task(
                title: "Team Meeting",
                date: Date(),
                startTime: Date(),
                category: .meeting
            ),
            Task(
                title: "Finish Report",
                date: Date(),
                startTime: Date(timeIntervalSinceNow: 7200),
                category: .work,
                isCompleted: false
            )
        ],
        onToggleCompletion: { _ in },
        onDelete: { _ in },
        onEdit: { _ in }
    )
}
