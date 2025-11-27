//
//  TasksView.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 23/11/25.
//

import SwiftUI
import SwiftData
import Foundation

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
    @State private var isAISearchMode: Bool = false
    @State private var aiSearchFilter: SearchFilter? = nil
    @State private var isSearching: Bool = false

    // MARK: - Services

    private let nlpService: NLPService = MockNLPService()

    // MARK: - Computed Properties

    private var tasks: [TaskItem] {
        syncableEvents.map { TaskItem(from: $0) }
    }

    private var filteredTasks: [TaskItem] {
        var filtered = tasks

        // Apply AI search filter if in AI mode
        if isAISearchMode, let aiFilter = aiSearchFilter {
            filtered = applyAIFilter(filtered, filter: aiFilter)
        } else if !searchText.isEmpty {
            // Apply standard text search filter
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
                    showAddSheet: $showAddSheet,
                    isAISearchMode: $isAISearchMode
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
            .onChange(of: searchText) { oldValue, newValue in
                if isAISearchMode && !newValue.isEmpty {
                    performAISearchDebounced()
                } else if newValue.isEmpty {
                    aiSearchFilter = nil
                }
            }
            .onChange(of: isAISearchMode) { _, _ in
                if isAISearchMode && !searchText.isEmpty {
                    performAISearchDebounced()
                } else {
                    aiSearchFilter = nil
                }
            }
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

    // MARK: - AI Search Methods

    private func performAISearchDebounced() {
        Task {
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 second debounce
            await performAISearch()
        }
    }

    @MainActor
    private func performAISearch() async {
        guard !searchText.isEmpty else {
            aiSearchFilter = nil
            return
        }

        isSearching = true
        do {
            let filter = try await nlpService.parseSearchQuery(searchText, currentDate: Date())
            aiSearchFilter = filter
        } catch {
            // Fall back to no filter on error
            aiSearchFilter = nil
        }
        isSearching = false
    }

    private func applyAIFilter(_ tasks: [TaskItem], filter: SearchFilter) -> [TaskItem] {
        var filtered = tasks

        // Apply keywords
        if !filter.keywords.isEmpty {
            filtered = filtered.filter { task in
                filter.keywords.contains { keyword in
                    task.title.localizedCaseInsensitiveContains(keyword) ||
                    (task.notes?.localizedCaseInsensitiveContains(keyword) ?? false)
                }
            }
        }

        // Apply date range
        if let dateRange = filter.dateRange {
            filtered = filtered.filter { task in
                task.date >= dateRange.start && task.date <= dateRange.end
            }
        }

        // Apply categories
        if let categories = filter.categories, !categories.isEmpty {
            filtered = filtered.filter { task in
                categories.contains(task.category.rawValue.lowercased())
            }
        }

        // Apply completion filter
        if !filter.includeCompleted {
            filtered = filtered.filter { !$0.isCompleted }
        }

        return filtered
    }
}

#Preview {
    TasksView()
}
