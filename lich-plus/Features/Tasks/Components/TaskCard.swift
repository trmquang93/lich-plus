//
//  TaskCard.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 23/11/25.
//

import SwiftUI

struct TaskCard: View {
    let task: TaskItem
    let onToggleCompletion: (TaskItem) -> Void
    let onDelete: (TaskItem) -> Void
    let onEdit: (TaskItem) -> Void

    @State private var showDeleteConfirmation = false

    var body: some View {
        HStack(spacing: AppTheme.spacing12) {
            // Checkbox
            Button(action: { onToggleCompletion(task) }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundStyle(task.isCompleted ? AppColors.primary : AppColors.borderLight)
            }

            // Task Content
            VStack(alignment: .leading, spacing: AppTheme.spacing4) {
                HStack(spacing: AppTheme.spacing8) {
                    Text(task.title)
                        .font(.system(size: AppTheme.fontBody, weight: .semibold))
                        .foregroundStyle(AppColors.textPrimary)
                        .strikethrough(task.isCompleted, color: AppColors.textSecondary)
                        .lineLimit(1)

                    Spacer()

                    // Category Badge
                    Text(task.category.displayName)
                        .font(.system(size: AppTheme.fontCaption, weight: .medium))
                        .foregroundStyle(.white)
                        .padding(.horizontal, AppTheme.spacing8)
                        .padding(.vertical, AppTheme.spacing2)
                        .background(getCategoryColor(task.category))
                        .cornerRadius(AppTheme.cornerRadiusSmall)
                }

                // Time and Details
                HStack(spacing: AppTheme.spacing12) {
                    if let timeRange = task.timeRangeDisplay {
                        HStack(spacing: AppTheme.spacing4) {
                            Image(systemName: "clock")
                                .font(.system(size: 12))
                            Text(timeRange)
                                .font(.system(size: AppTheme.fontCaption))
                        }
                        .foregroundStyle(AppColors.textSecondary)
                    }

                    if let reminder = task.reminderDisplay {
                        HStack(spacing: AppTheme.spacing4) {
                            Image(systemName: "bell")
                                .font(.system(size: 12))
                            Text(reminder)
                                .font(.system(size: AppTheme.fontCaption))
                        }
                        .foregroundStyle(AppColors.textSecondary)
                    }

                    Spacer()
                }
            }

            // Actions
            VStack(spacing: AppTheme.spacing8) {
                Button(action: { onEdit(task) }) {
                    Image(systemName: "pencil")
                        .font(.system(size: 14))
                        .foregroundStyle(AppColors.primary)
                }

                Button(action: { showDeleteConfirmation = true }) {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                        .foregroundStyle(AppColors.primary)
                }
            }
        }
        .padding(AppTheme.spacing12)
        .background(AppColors.background)
        .border(AppColors.borderLight, width: 1)
        .cornerRadius(AppTheme.cornerRadiusMedium)
        .contentShape(Rectangle())
        .confirmationDialog(
            "task.delete",
            isPresented: $showDeleteConfirmation,
            presenting: task
        ) { _ in
            Button("task.delete", role: .destructive) {
                onDelete(task)
            }
        } message: { _ in
            Text("Are you sure you want to delete this task?")
        }
    }

    private func getCategoryColor(_ category: TaskCategory) -> Color {
        switch category {
        case .work:
            return AppColors.eventBlue
        case .personal:
            return AppColors.primary
        case .birthday:
            return AppColors.eventPink
        case .holiday:
            return AppColors.eventOrange
        case .meeting:
            return AppColors.eventYellow
        case .other:
            return AppColors.secondary
        }
    }
}

#Preview {
    TaskCard(
        task: TaskItem(
            title: "Sample Task",
            date: Date(),
            startTime: Date(),
            endTime: Date(timeIntervalSinceNow: 3600),
            category: .work,
            reminderMinutes: 15
        ),
        onToggleCompletion: { _ in },
        onDelete: { _ in },
        onEdit: { _ in }
    )
    .padding()
}
