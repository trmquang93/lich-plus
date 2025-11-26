//
//  TimelineItemCard.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 26/11/25.
//

import SwiftUI

struct TimelineItemCard: View {
    let task: TaskItem
    let onToggleCompletion: (TaskItem) -> Void
    let onDelete: (TaskItem) -> Void
    let onEdit: (TaskItem) -> Void

    var body: some View {
        if task.itemType == .event {
            EventCard(task: task, onDelete: onDelete, onEdit: onEdit)
        } else {
            TaskCard(
                task: task,
                onToggleCompletion: onToggleCompletion,
                onDelete: onDelete,
                onEdit: onEdit
            )
        }
    }
}

#Preview {
    VStack(spacing: AppTheme.spacing16) {
        TimelineItemCard(
            task: TaskItem(
                title: "Team Meeting",
                date: Date(),
                startTime: Date(),
                endTime: Date(timeIntervalSinceNow: 3600),
                category: .meeting,
                itemType: .event
            ),
            onToggleCompletion: { _ in },
            onDelete: { _ in },
            onEdit: { _ in }
        )

        TimelineItemCard(
            task: TaskItem(
                title: "Complete project",
                date: Date(),
                category: .work,
                itemType: .task,
                priority: .high
            ),
            onToggleCompletion: { _ in },
            onDelete: { _ in },
            onEdit: { _ in }
        )
    }
    .padding()
}
