//
//  InfiniteTimelineView.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 27/11/25.
//

import SwiftUI

struct InfiniteTimelineView: View {
    let tasks: [TaskItem]
    let onToggleCompletion: (TaskItem) -> Void
    let onDelete: (TaskItem) -> Void
    let onEdit: (TaskItem) -> Void
    let onAddNew: () -> Void

    @State private var hasInitialScrolled: Bool = false
    @State private var isAnchorSectionVisible: Bool = false

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

    // Anchor section: today if exists, else nearest future, else first
    private var anchorSectionID: String? {
        let today = calendar.startOfDay(for: Date())

        if let todayGroup = groupedTasks.first(where: { calendar.isDateInToday($0.date) }) {
            return dateID(todayGroup.date)
        } else if let futureGroup = groupedTasks.first(where: { $0.date > today }) {
            return dateID(futureGroup.date)
        } else if let firstGroup = groupedTasks.first {
            return dateID(firstGroup.date)
        }
        return nil
    }

    private func dateID(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter.string(from: date)
    }

    var body: some View {
        ScrollViewReader { scrollProxy in
            ZStack {
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
                                    DateSectionHeader(
                                        date: group.date,
                                        showTodayBadge: calendar.isDateInToday(group.date)
                                    )
                                    .background(AppColors.backgroundLightGray)
                                    .onAppear {
                                        if dateID(group.date) == anchorSectionID {
                                            isAnchorSectionVisible = true
                                        }
                                    }
                                    .onDisappear {
                                        if dateID(group.date) == anchorSectionID {
                                            isAnchorSectionVisible = false
                                        }
                                    }
                                }
                                .id(dateID(group.date))
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(AppColors.background)
                .opacity(hasInitialScrolled ? 1 : 0)
                .task {
                    if let anchorID = anchorSectionID {
                        scrollProxy.scrollTo(anchorID, anchor: .top)
                    }
                    hasInitialScrolled = true
                }

                // Today floating button - shows when anchor section is off-screen
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            if !isAnchorSectionVisible && anchorSectionID != nil {
                                TodayFloatingButton {
                                    if let anchorID = anchorSectionID {
                                        withAnimation {
                                            scrollProxy.scrollTo(anchorID, anchor: .top)
                                        }
                                    }
                                }
                                .padding(AppTheme.spacing16)
                            } else {
                                Spacer().frame(width: 44, height: 44)
                                    .allowsHitTesting(false)
                            }
                        }
                    }
                    .transition(.scale.combined(with: .opacity))
            }
            .animation(.easeInOut(duration: 0.2), value: isAnchorSectionVisible)
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        var body: some View {
            let previewTasks: [TaskItem] = {
                var tasks: [TaskItem] = []
                let calendar = Calendar.current

                for dayOffset in -5..<15 {
                    if let date = calendar.date(byAdding: .day, value: dayOffset, to: Date()) {
                        tasks.append(
                            TaskItem(
                                title: "Task Day \(dayOffset + 6)",
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

            return InfiniteTimelineView(
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
