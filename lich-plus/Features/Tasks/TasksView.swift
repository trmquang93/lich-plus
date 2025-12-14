//
//  TasksView.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 23/11/25.
//

import SwiftUI
import SwiftData

enum TimelineViewMode: String, CaseIterable {
    case list = "List"
    case day = "Day"
}

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
    @State private var viewMode: TimelineViewMode = .list
    @State private var selectedDate: Date = Date()

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

    /// Events for the selected day (used in Day view mode)
    private var eventsForSelectedDay: [TaskItem] {
        let calendar = Calendar.current
        return tasks.filter { task in
            calendar.isDate(task.date, inSameDayAs: selectedDate)
        }.sorted { ($0.startTime ?? $0.date) < ($1.startTime ?? $1.date) }
    }

    /// Hoang Dao (auspicious) hours for the selected day
    private var hoangDaoHours: Set<Int> {
        // Get auspicious hours based on day's Chi
        // This is a simplified version - the full implementation uses HoangDaoCalculator
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: selectedDate) ?? 1
        // Cycle through different patterns based on day
        let patterns: [[Int]] = [
            [0, 1, 4, 5, 8, 9],      // Pattern 1
            [2, 3, 6, 7, 10, 11],    // Pattern 2
            [0, 1, 6, 7, 8, 9],      // Pattern 3
            [2, 3, 4, 5, 10, 11],    // Pattern 4
            [0, 1, 2, 3, 8, 9],      // Pattern 5
            [4, 5, 6, 7, 10, 11],    // Pattern 6
        ]
        let patternIndex = dayOfYear % 6
        return Set(patterns[patternIndex])
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Timeline Header with View Mode Picker
                HStack {
                    TimelineHeader(
                        searchText: $searchText,
                        isSearchActive: $isSearchActive,
                        onAddTapped: { showAddSheet = true }
                    )
                }

                // View Mode Picker
                Picker("View Mode", selection: $viewMode) {
                    ForEach(TimelineViewMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, AppTheme.spacing16)
                .padding(.bottom, AppTheme.spacing8)

                // Content based on view mode
                if viewMode == .list {
                    // Infinite Timeline View (List Mode)
                    InfiniteTimelineView(
                        tasks: filteredTasks,
                        onToggleCompletion: toggleTaskCompletion,
                        onDelete: deleteTask,
                        onEdit: startEditingTask,
                        onAddNew: { showAddSheet = true }
                    )
                    .id(refreshCounter)
                } else {
                    // Day Timeline View (Time Grid Mode)
                    DayTimelineView(
                        date: selectedDate,
                        events: eventsForSelectedDay,
                        hoangDaoHours: hoangDaoHours,
                        onEventTap: { task in
                            startEditingTask(task)
                        },
                        onAddEvent: { _ in
                            // Open add sheet
                            showAddSheet = true
                        },
                        onToggleCompletion: toggleTaskCompletion
                    )
                    .id(refreshCounter)
                }
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
