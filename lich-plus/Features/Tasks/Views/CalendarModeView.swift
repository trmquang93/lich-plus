//
//  CalendarModeView.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 26/11/25.
//

import SwiftUI

struct CalendarModeView: View {
    let tasks: [TaskItem]
    @Binding var selectedDate: Date
    let onToggleCompletion: (TaskItem) -> Void
    let onDelete: (TaskItem) -> Void
    let onEdit: (TaskItem) -> Void
    let onAddNew: () -> Void

    var calendar: Calendar = Calendar.current

    private var selectedDateTasks: [TaskItem] {
        tasks.filter { calendar.isDate($0.date, inSameDayAs: selectedDate) }
            .sorted { ($0.startTime ?? $0.date) < ($1.startTime ?? $1.date) }
    }

    private var daysWithItems: Set<DateComponents> {
        var days = Set<DateComponents>()
        for task in tasks {
            let components = calendar.dateComponents([.year, .month, .day], from: task.date)
            days.insert(components)
        }
        return days
    }

    var body: some View {
        VStack(spacing: 0) {
            CompactCalendarView(
                selectedDate: $selectedDate,
                daysWithItems: daysWithItems
            )
            .padding(AppTheme.spacing16)

            ScrollView {
                if selectedDateTasks.isEmpty {
                    EmptyStateView(
                        title: String(localized: "calendar.empty.title"),
                        message: String(localized: "calendar.empty.message"),
                        onAddNew: onAddNew
                    )
                } else {
                    VStack(spacing: 0) {
                        DateSectionHeader(date: selectedDate)
                            .background(AppColors.backgroundLightGray)

                        VStack(spacing: AppTheme.spacing12) {
                            ForEach(selectedDateTasks, id: \.id) { task in
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
        }
        .background(AppColors.background)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var selectedDate = Date()

        var body: some View {
            let previewTasks: [TaskItem] = {
                var tasks: [TaskItem] = []
                let calendar = Calendar.current

                for dayOffset in 0..<5 {
                    if let date = calendar.date(byAdding: .day, value: dayOffset, to: Date()) {
                        tasks.append(
                            TaskItem(
                                title: "Task \(dayOffset + 1)",
                                date: date,
                                category: .work,
                                itemType: .task,
                                priority: dayOffset % 2 == 0 ? .high : .none
                            )
                        )
                    }
                }

                return tasks
            }()

            return CalendarModeView(
                tasks: previewTasks,
                selectedDate: $selectedDate,
                onToggleCompletion: { _ in },
                onDelete: { _ in },
                onEdit: { _ in },
                onAddNew: {}
            )
        }
    }

    return PreviewWrapper()
}
