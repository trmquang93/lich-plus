//
//  WeekView.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 26/11/25.
//

import SwiftUI

struct WeekView: View {
    let tasks: [TaskItem]
    let onToggleCompletion: (TaskItem) -> Void
    let onDelete: (TaskItem) -> Void
    let onEdit: (TaskItem) -> Void
    let onAddNew: () -> Void

    var calendar: Calendar = Calendar.current

    private var groupedTasks: [(date: Date, items: [TaskItem])] {
        let today = calendar.startOfDay(for: Date())
        var result: [(date: Date, items: [TaskItem])] = []

        for dayOffset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: today) else { continue }

            let dayTasks = tasks.filter { calendar.isDate($0.date, inSameDayAs: date) }
                .sorted { ($0.startTime ?? $0.date) < ($1.startTime ?? $1.date) }

            if !dayTasks.isEmpty {
                result.append((date: date, items: dayTasks))
            }
        }

        if result.isEmpty {
            // Still show all 7 days even if empty
            for dayOffset in 0..<7 {
                guard let date = calendar.date(byAdding: .day, value: dayOffset, to: today) else { continue }
                result.append((date: date, items: []))
            }
        }

        return result
    }

    var body: some View {
        ScrollView {
            if tasks.isEmpty {
                EmptyStateView(
                    title: String(localized: "week.empty.title"),
                    message: String(localized: "week.empty.message"),
                    onAddNew: onAddNew
                )
            } else {
                LazyVStack(spacing: AppTheme.spacing16, pinnedViews: [.sectionHeaders]) {
                    ForEach(Array(groupedTasks.enumerated()), id: \.element.date) { _, group in
                        Section {
                            VStack(spacing: AppTheme.spacing12) {
                                if group.items.isEmpty {
                                    Text(String(localized: "week.noItems"))
                                        .font(.system(size: AppTheme.fontBody))
                                        .foregroundStyle(AppColors.textSecondary)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding(AppTheme.spacing16)
                                } else {
                                    ForEach(group.items, id: \.id) { task in
                                        TimelineItemCard(
                                            task: task,
                                            onToggleCompletion: onToggleCompletion,
                                            onDelete: onDelete,
                                            onEdit: onEdit
                                        )
                                    }
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

                for dayOffset in 0..<3 {
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

            return WeekView(
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
