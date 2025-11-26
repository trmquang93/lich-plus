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
    @State private var viewMode: ViewMode = .today
    @State private var showAddSheet: Bool = false
    @State private var editingEventId: UUID? = nil
    @State private var showEditSheet: Bool = false

    // MARK: - Computed Properties

    private var tasks: [TaskItem] {
        syncableEvents.map { TaskItem(from: $0) }
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

    private var todayTasks: [TaskItem] {
        filteredTasks.filter { $0.isToday }
            .sorted { ($0.startTime ?? $0.date) < ($1.startTime ?? $1.date) }
    }

    private var weekTasks: [TaskItem] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let weekEnd = calendar.date(byAdding: .day, value: 7, to: today) else { return [] }
        return filteredTasks.filter { $0.date >= today && $0.date < weekEnd }
            .sorted { $0.date < $1.date }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header with Search
                TaskListHeader(
                    searchText: $searchText,
                    showAddSheet: $showAddSheet
                )

                // View Mode Switcher (replaces FilterBar)
                ViewModeSwitcher(selectedMode: $viewMode)
                    .padding(.vertical, AppTheme.spacing8)
                    .padding(.horizontal, AppTheme.spacing16)

                // Content based on view mode
                switch viewMode {
                case .today:
                    TodayView(
                        tasks: todayTasks,
                        onToggleCompletion: toggleTaskCompletion,
                        onDelete: deleteTask,
                        onEdit: startEditingTask,
                        onAddNew: { showAddSheet = true }
                    )

                case .thisWeek:
                    WeekView(
                        tasks: weekTasks,
                        onToggleCompletion: toggleTaskCompletion,
                        onDelete: deleteTask,
                        onEdit: startEditingTask,
                        onAddNew: { showAddSheet = true }
                    )

                case .all:
                    AllTasksView(
                        tasks: filteredTasks,
                        onToggleCompletion: toggleTaskCompletion,
                        onDelete: deleteTask,
                        onEdit: startEditingTask,
                        onAddNew: { showAddSheet = true }
                    )
                }
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

    // MARK: - Methods

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
