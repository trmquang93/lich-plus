//
//  EventCard.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 26/11/25.
//

import SwiftUI

struct EventCard: View {
    let task: TaskItem
    let onDelete: (TaskItem) -> Void
    let onEdit: (TaskItem) -> Void

    @State private var showDeleteConfirmation = false

    var body: some View {
        HStack(spacing: AppTheme.spacing12) {
            // Time Badge
            if let timeDisplay = task.timeDisplay {
                VStack {
                    Text(timeDisplay)
                        .font(.system(size: AppTheme.fontCaption, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, AppTheme.spacing8)
                        .padding(.vertical, AppTheme.spacing4)
                        .background(AppColors.primary)
                        .cornerRadius(AppTheme.cornerRadiusSmall)
                }
                .frame(width: 50)
            }

            // Event Content
            VStack(alignment: .leading, spacing: AppTheme.spacing4) {
                HStack(spacing: AppTheme.spacing8) {
                    Text(task.title)
                        .font(.system(size: AppTheme.fontBody, weight: .semibold))
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(1)

                    Spacer()

                    // Category Badge
                    Text(task.category.displayName)
                        .font(.system(size: AppTheme.fontCaption, weight: .medium))
                        .foregroundStyle(.white)
                        .padding(.horizontal, AppTheme.spacing8)
                        .padding(.vertical, AppTheme.spacing2)
                        .background(task.category.colorValue)
                        .cornerRadius(AppTheme.cornerRadiusSmall)
                }

                // Location and Duration
                VStack(alignment: .leading, spacing: AppTheme.spacing4) {
                    if let location = task.location {
                        HStack(spacing: AppTheme.spacing4) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 12))
                            Text(location)
                                .font(.system(size: AppTheme.fontCaption))
                                .lineLimit(1)
                        }
                        .foregroundStyle(AppColors.textSecondary)
                    }

                    if let timeRange = task.timeRangeDisplay {
                        HStack(spacing: AppTheme.spacing4) {
                            Image(systemName: "clock")
                                .font(.system(size: 12))
                            Text(timeRange)
                                .font(.system(size: AppTheme.fontCaption))
                        }
                        .foregroundStyle(AppColors.textSecondary)
                    }
                }
            }

            // Actions
            VStack(spacing: AppTheme.spacing8) {
                Button(action: {
                    onEdit(task)
                }, label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 14))
                        .foregroundStyle(AppColors.primary)
                })

                Button(action: {
                    showDeleteConfirmation = true
                }, label: {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                        .foregroundStyle(AppColors.primary)
                })
            }
        }
        .padding(AppTheme.spacing12)
        .background(AppColors.background)
        .cornerRadius(AppTheme.cornerRadiusMedium)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                .stroke(AppColors.borderLight, lineWidth: 1)
        )
        .contentShape(Rectangle())
        .confirmationDialog(
            "task.delete",
            isPresented: $showDeleteConfirmation,
            presenting: task,
            actions: { _ in
                Button("task.delete", role: .destructive) {
                    onDelete(task)
                }
            },
            message: { _ in
                Text(String(localized: "event.deleteConfirmMessage"))
            }
        )
    }
}

#Preview {
    EventCard(
        task: TaskItem(
            title: "Team Meeting",
            date: Date(),
            startTime: Date(),
            endTime: Date(timeIntervalSinceNow: 3600),
            category: .meeting,
            itemType: .event,
            location: "Conference Room 123"
        ),
        onDelete: { _ in },
        onEdit: { _ in }
    )
    .padding()
}
