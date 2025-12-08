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
    @State private var isSearchActive: Bool = false
    @State private var showAddSheet: Bool = false
    @State private var editingEventId: UUID? = nil
    @State private var showEditSheet: Bool = false

    // MARK: - Computed Properties

    private var tasks: [TaskItem] {
        RecurringEventExpander.expandRecurringEvents(syncableEvents)
    }

    private var filteredTasks: [TaskItem] {
        var filtered = tasks

        if !searchText.isEmpty {
            filtered = filtered.filter { task in
                task.title.localizedCaseInsensitiveContains(searchText) ||
                    (task.notes?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }

        return filtered.sorted { $0.date < $1.date }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Timeline Header
                TimelineHeader(
                    searchText: $searchText,
                    isSearchActive: $isSearchActive,
                    onAddTapped: { showAddSheet = true }
                )

                // Infinite Timeline View
                InfiniteTimelineView(
                    tasks: filteredTasks,
                    onToggleCompletion: toggleTaskCompletion,
                    onDelete: deleteTask,
                    onEdit: startEditingTask,
                    onAddNew: { showAddSheet = true }
                )
            }
            .background(AppColors.background)
            .sheet(isPresented: $showAddSheet) {
                CreateItemSheet(
                    editingEventId: nil,
                    onSave: { _ in
                        showAddSheet = false
                    }
                )
                .environmentObject(syncService)
            }
            .sheet(isPresented: $showEditSheet) {
                if let editingEventId = editingEventId {
                    CreateItemSheet(
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
        // Resolve to master event ID (occurrence or master)
        let targetId = task.masterEventId ?? task.id

        if let syncableEvent = syncableEvents.first(where: { $0.id == targetId }) {
            syncableEvent.isCompleted.toggle()
            syncableEvent.setSyncStatus(.pending)
        }
    }

    private func deleteTask(_ task: TaskItem) {
        // Resolve to master event ID (occurrence or master)
        let targetId = task.masterEventId ?? task.id

        if let syncableEvent = syncableEvents.first(where: { $0.id == targetId }) {
            syncableEvent.isDeleted = true
            syncableEvent.setSyncStatus(.pending)
        }
    }

    private func startEditingTask(_ task: TaskItem) {
        // Resolve to master event ID (occurrence or master)
        editingEventId = task.masterEventId ?? task.id
        showEditSheet = true
    }
}

#Preview {
    TasksView()
}
