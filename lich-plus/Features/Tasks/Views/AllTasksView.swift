//
//  AllTasksView.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 26/11/25.
//

import SwiftUI

struct AllTasksView: View {
    let tasks: [TaskItem]
    let onToggleCompletion: (TaskItem) -> Void
    let onDelete: (TaskItem) -> Void
    let onEdit: (TaskItem) -> Void
    let onAddNew: () -> Void

    var calendar: Calendar = Calendar.current

    private var groupedTasks: [(date: Date, items: [TaskItem])] {
        var groupedByDate: [Date: [TaskItem]] = [:]

        for task in tasks {
            let dayStart = calendar.startOfDay(for: task.date)
            if groupedByDate[dayStart] != nil {
                groupedByDate[dayStart]?.append(task)
            } else {
                groupedByDate[dayStart] = [task]
            }
        }

        let sortedDates = groupedByDate.keys.sorted()
        return sortedDates.map { date in
            let dayTasks = (groupedByDate[date] ?? [])
                .sorted { ($0.startTime ?? $0.date) < ($1.startTime ?? $1.date) }
            return (date: date, items: dayTasks)
        }
    }

    var body: some View {
        ScrollView {
            if tasks.isEmpty {
                EmptyStateView(
                    title: String(localized: "all.empty.title"),
                    message: String(localized: "all.empty.message"),
                    onAddNew: onAddNew
                )
            } else {
                LazyVStack(spacing: AppTheme.spacing16, pinnedViews: [.sectionHeaders]) {
                    ForEach(Array(groupedTasks.enumerated()), id: \.element.date) { _, group in
                        Section {
                            VStack(spacing: AppTheme.spacing12) {
                                ForEach(group.items, id: \.id) { task in
                                    TimelineItemCard(
                                        task: task,
                                        onToggleCompletion: onToggleCompletion,
                                        onDelete: onDelete,
                                        onEdit: onEdit
                                    )
                                }
                            }
                            .padding(AppTheme.spacing16)
                        } header: {
                            DateSectionHeader(date: group.date)
                                .background(AppColors.backgroundLightGray)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
    }
}

#Preview {
    struct PreviewWrapper: View {
        var body: some View {
            let previewTasks: [TaskItem] = {
                var tasks: [TaskItem] = []
                let calendar = Calendar.current

                for dayOffset in 0..<10 {
                    if let date = calendar.date(byAdding: .day, value: dayOffset, to: Date()) {
                        tasks.append(
                            TaskItem(
                                title: "Task Day \(dayOffset + 1)",
                                date: date,
                                category: .work,
                                itemType: .task,
                                priority: .high
                            )
                        )
                    }
                }

                return tasks
            }()

            return AllTasksView(
                tasks: previewTasks,
                onToggleCompletion: { _ in },
                onDelete: { _ in },
                onEdit: { _ in },
                onAddNew: {}
            )
        }
    }

    return PreviewWrapper()
}
