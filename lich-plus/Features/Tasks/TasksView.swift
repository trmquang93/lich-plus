//
//  TasksView.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 23/11/25.
//

import SwiftUI
import SwiftData

struct TasksView: View {
    // MARK: - Environment & State

    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var syncService: CalendarSyncService

    @Query(
        filter: #Predicate<SyncableEvent> { !$0.isDeleted },
        sort: \.startDate
    )
    private var syncableEvents: [SyncableEvent]

    @State private var searchText: String = ""
    @State private var selectedFilter: TaskFilter = .all
    @State private var showAddSheet: Bool = false
    @State private var editingEventId: UUID? = nil
    @State private var showEditSheet: Bool = false

    // MARK: - Computed Properties

    private var tasks: [TaskItem] {
        syncableEvents.map { TaskItem(from: $0) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header with Search
                TaskListHeader(
                    searchText: $searchText,
                    showAddSheet: $showAddSheet
                )

                // Filter Bar
                FilterBar(
                    selectedFilter: $selectedFilter,
                    taskCounts: calculateTaskCounts()
                )

                // Task Sections
                ScrollView {
                    if filteredAndGroupedTasks.isEmpty {
                        VStack(spacing: AppTheme.spacing16) {
                            Image(systemName: "checkmark.circle")
                                .font(.system(size: 48))
                                .foregroundStyle(AppColors.borderLight)

                            Text("No tasks found")
                                .font(.system(size: AppTheme.fontBody))
                                .foregroundStyle(AppColors.textSecondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(AppTheme.spacing24)
                    } else {
                        VStack(spacing: AppTheme.spacing24) {
                            ForEach(filteredAndGroupedTasks, id: \.title) { section in
                                TaskSection(
                                    title: section.title,
                                    tasks: section.tasks,
                                    onToggleCompletion: toggleTaskCompletion,
                                    onDelete: deleteTask,
                                    onEdit: startEditingTask
                                )
                            }
                        }
                        .padding(.vertical, AppTheme.spacing16)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .background(AppColors.background)
            .sheet(isPresented: $showAddSheet) {
                AddEditTaskSheet(
                    editingEventId: nil,
                    onSave: { _ in
                        showAddSheet = false
                    }
                )
                .environmentObject(syncService)
            }
            .sheet(isPresented: $showEditSheet) {
                if let editingEventId = editingEventId {
                    AddEditTaskSheet(
                        editingEventId: editingEventId,
                        onSave: { _ in
                            showEditSheet = false
                        }
                    )
                    .environmentObject(syncService)
                }
            }
        }
    }

    private var filteredTasks: [TaskItem] {
        var filtered = tasks

        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { task in
                task.title.localizedCaseInsensitiveContains(searchText) ||
                    (task.notes?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }

        // Apply date filter
        switch selectedFilter {
        case .all:
            break
        case .today:
            filtered = filtered.filter { $0.isToday }
        case .thisWeek:
            filtered = filtered.filter { $0.isThisWeek }
        case .thisMonth:
            filtered = filtered.filter { $0.isThisMonth }
        }

        return filtered.sorted { $0.date < $1.date }
    }

    private var filteredAndGroupedTasks: [(title: String, tasks: [TaskItem])] {
        let filtered = filteredTasks

        var today: [TaskItem] = []
        var tomorrow: [TaskItem] = []
        var upcoming: [TaskItem] = []

        for task in filtered {
            if task.isToday {
                today.append(task)
            } else if task.isTomorrow {
                tomorrow.append(task)
            } else {
                upcoming.append(task)
            }
        }

        var sections: [(String, [TaskItem])] = []

        if !today.isEmpty {
            sections.append((String(localized: "task.today"), today))
        }

        if !tomorrow.isEmpty {
            sections.append((String(localized: "task.tomorrow"), tomorrow))
        }

        if !upcoming.isEmpty {
            sections.append((String(localized: "task.upcoming"), upcoming))
        }

        return sections
    }

    // MARK: - Methods

    private func calculateTaskCounts() -> [TaskFilter: Int] {
        var counts: [TaskFilter: Int] = [:]

        counts[.all] = tasks.count
        counts[.today] = tasks.filter { $0.isToday }.count
        counts[.thisWeek] = tasks.filter { $0.isThisWeek }.count
        counts[.thisMonth] = tasks.filter { $0.isThisMonth }.count

        return counts
    }

    private func toggleTaskCompletion(_ task: TaskItem) {
        if let syncableEvent = syncableEvents.first(where: { $0.id == task.id }) {
            syncableEvent.isCompleted.toggle()
            syncableEvent.setSyncStatus(.pending)
        }
    }

    private func deleteTask(_ task: TaskItem) {
        if let syncableEvent = syncableEvents.first(where: { $0.id == task.id }) {
            syncableEvent.isDeleted = true
            syncableEvent.setSyncStatus(.pending)
        }
    }

    private func startEditingTask(_ task: TaskItem) {
        editingEventId = task.id
        showEditSheet = true
    }
}

#Preview {
    TasksView()
}
