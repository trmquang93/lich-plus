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
    @State private var editingEvent: SyncableEvent? = nil
    @State private var showEditSheet: Bool = false
    @State private var refreshCounter: Int = 0
    @State private var showEventNotFoundAlert: Bool = false

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
                .id(refreshCounter)
            }
            .background(AppColors.background)
            .onReceive(NotificationCenter.default.publisher(for: .calendarDataDidChange)) { _ in
                refreshCounter += 1
            }
            .sheet(isPresented: $showAddSheet) {
                CreateItemSheet(
                    editingEvent: nil,
                    onSave: { _ in
                        showAddSheet = false
                    }
                )
                .environmentObject(syncService)
                .modelContext(modelContext)
            }
            .sheet(isPresented: $showEditSheet) {
                CreateItemSheet(
                    editingEvent: editingEvent,
                    onSave: { _ in
                        editingEvent = nil
                        showEditSheet = false
                    }
                )
                .environmentObject(syncService)
                .modelContext(modelContext)
            }
            .alert(String(localized: "Event not found"), isPresented: $showEventNotFoundAlert) {
                Button(String(localized: "OK"), role: .cancel) { }
            }
        }
    }

    // MARK: - Methods

    private func toggleTaskCompletion(_ task: TaskItem) {
        // Prevent toggling completion for ICS subscription events (read-only)
        guard task.isEditable else { return }

        // Resolve to master event ID (occurrence or master)
        let targetId = task.masterEventId ?? task.id

        if let syncableEvent = syncableEvents.first(where: { $0.id == targetId }) {
            syncableEvent.isCompleted.toggle()
            syncableEvent.setSyncStatus(.pending)
            try? modelContext.save()

            NotificationCenter.default.post(name: .calendarDataDidChange, object: nil)
        }
    }

    private func deleteTask(_ task: TaskItem) {
        // Prevent deleting ICS subscription events (read-only)
        guard task.isEditable else { return }

        // Resolve to master event ID (occurrence or master)
        let targetId = task.masterEventId ?? task.id

        if let syncableEvent = syncableEvents.first(where: { $0.id == targetId }) {
            syncableEvent.isDeleted = true
            syncableEvent.setSyncStatus(.pending)
            try? modelContext.save()

            NotificationCenter.default.post(name: .calendarDataDidChange, object: nil)
        }
    }

    private func startEditingTask(_ task: TaskItem) {
        // Prevent editing ICS subscription events (read-only)
        guard task.isEditable else { return }

        // Resolve to master event (occurrence or master)
        let targetId = task.masterEventId ?? task.id
        editingEvent = syncableEvents.first(where: { $0.id == targetId })

        if editingEvent != nil {
            showEditSheet = true
        } else {
            showEventNotFoundAlert = true
        }
    }
}

#Preview {
    TasksView()
}
