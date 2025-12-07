//
//  TimelineItemCard.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 26/11/25.
//

import SwiftUI

/// A unified card component displaying both tasks and events in the timeline view.
///
/// This component uses a consistent design for both item types:
/// - ItemIndicator on the left (checkbox for tasks, calendar icon for events)
/// - Title text in the center
/// - TypeBadge on the right ("Task" or "Event" label)
/// - MetadataLine below with date, time (if available), and category
///
/// Supports interactions:
/// - Tap to edit item
/// - Swipe left to delete item
/// - For tasks: Toggle completion via the ItemIndicator
struct TimelineItemCard: View {
    let task: TaskItem
    let onToggleCompletion: (TaskItem) -> Void
    let onDelete: (TaskItem) -> Void
    let onEdit: (TaskItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing8) {
            // MARK: - Header: Indicator + Title + Badge

            HStack(spacing: AppTheme.spacing12) {
                // Item indicator (checkbox for tasks, calendar for events)
                ItemIndicator(
                    itemType: task.itemType,
                    isCompleted: task.isCompleted,
                    onToggle: {
                        onToggleCompletion(task)
                    }
                )
                .frame(width: 24, height: 24)

                // Title text
                Text(task.title)
                    .font(.system(size: AppTheme.fontBody, weight: .semibold))
                    .foregroundColor(
                        task.isCompleted ? AppColors.textSecondary : AppColors.textPrimary
                    )
                    .strikethrough(task.isCompleted)
                    .opacity(task.isCompleted ? AppTheme.opacityDisabled : 1.0)
                    .lineLimit(2)

                Spacer()

                // Type badge
                TypeBadge(itemType: task.itemType)
            }

            // MARK: - Metadata Line

            MetadataLine(item: task, isCompleted: task.isCompleted)
        }
        .padding(AppTheme.spacing16)
        .background(AppColors.background)
        .cornerRadius(AppTheme.cornerRadiusMedium)
        .shadow(color: Color.black.opacity(0.08), radius: 2, x: 0, y: 1)
        .onTapGesture {
            onEdit(task)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                onDelete(task)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

#Preview {
    VStack(spacing: AppTheme.spacing16) {
        // MARK: - Unchecked Task

        VStack(alignment: .leading, spacing: AppTheme.spacing8) {
            Text("Unchecked Task")
                .font(.system(size: AppTheme.fontSubheading, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)

            TimelineItemCard(
                task: TaskItem(
                    title: "Complete project proposal",
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

        // MARK: - Checked Task

        VStack(alignment: .leading, spacing: AppTheme.spacing8) {
            Text("Completed Task")
                .font(.system(size: AppTheme.fontSubheading, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)

            TimelineItemCard(
                task: TaskItem(
                    title: "Review presentation",
                    date: Date(),
                    category: .work,
                    isCompleted: true,
                    itemType: .task
                ),
                onToggleCompletion: { _ in },
                onDelete: { _ in },
                onEdit: { _ in }
            )
        }

        // MARK: - Event with Time

        VStack(alignment: .leading, spacing: AppTheme.spacing8) {
            Text("Event with Time")
                .font(.system(size: AppTheme.fontSubheading, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)

            TimelineItemCard(
                task: TaskItem(
                    title: "Team Meeting",
                    date: Date(),
                    startTime: Calendar.current.date(bySettingHour: 14, minute: 30, second: 0, of: Date())!,
                    endTime: Calendar.current.date(bySettingHour: 15, minute: 30, second: 0, of: Date())!,
                    category: .meeting,
                    itemType: .event
                ),
                onToggleCompletion: { _ in },
                onDelete: { _ in },
                onEdit: { _ in }
            )
        }

        // MARK: - Event without Time

        VStack(alignment: .leading, spacing: AppTheme.spacing8) {
            Text("Event without Time")
                .font(.system(size: AppTheme.fontSubheading, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)

            TimelineItemCard(
                task: TaskItem(
                    title: "Sarah's Birthday",
                    date: Date(timeIntervalSinceNow: 86400),
                    category: .birthday,
                    itemType: .event
                ),
                onToggleCompletion: { _ in },
                onDelete: { _ in },
                onEdit: { _ in }
            )
        }

        // MARK: - Personal Task with Different Category

        VStack(alignment: .leading, spacing: AppTheme.spacing8) {
            Text("Personal Task")
                .font(.system(size: AppTheme.fontSubheading, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)

            TimelineItemCard(
                task: TaskItem(
                    title: "Buy groceries",
                    date: Date(),
                    category: .personal,
                    itemType: .task
                ),
                onToggleCompletion: { _ in },
                onDelete: { _ in },
                onEdit: { _ in }
            )
        }

        Spacer()
    }
    .padding()
    .background(AppColors.backgroundLight)
}
