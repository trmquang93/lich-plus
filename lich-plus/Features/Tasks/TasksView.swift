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
    @EnvironmentObject var notificationService: NotificationService

    @Query(
        filter: #Predicate<SyncableEvent> { !$0.isDeleted },
        sort: \.startDate
    )
    private var syncableEvents: [SyncableEvent]

    @State private var searchText: String = ""
    @State private var isSearchActive: Bool = false
    @State private var showAddSheet: Bool = false
    @State private var addEventDate: Date? = nil
    @State private var editingEvent: SyncableEvent? = nil
    @State private var showEditSheet: Bool = false
    @State private var refreshCounter: Int = 0
    @State private var showEventNotFoundAlert: Bool = false
    @State private var navigateToDate: Date? = nil

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

    /// Events for a given date (used when navigating to Day view)
    private func eventsForDate(_ date: Date) -> [TaskItem] {
        let calendar = Calendar.current
        return tasks.filter { task in
            calendar.isDate(task.date, inSameDayAs: date)
        }.sorted { ($0.startTime ?? $0.date) < ($1.startTime ?? $1.date) }
    }

    /// Hoang Dao (auspicious) hours for a given date
    /// Uses HoangDaoCalculator service for consistent auspicious hour calculation
    /// based on traditional Vietnamese astrology (12 Trực system)
    private func hoangDaoHoursForDate(_ date: Date) -> Set<Int> {
        let hourlyZodiacs = HoangDaoCalculator.getHourlyZodiacs(for: date)
        let auspiciousIndices = hourlyZodiacs
            .filter { $0.isAuspicious }
            .map { $0.hour }
        return Set(auspiciousIndices)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Timeline Header
                HStack {
                    TimelineHeader(
                        searchText: $searchText,
                        isSearchActive: $isSearchActive,
                        onAddTapped: { showAddSheet = true }
                    )
                }

                // List View - Infinite Timeline
                InfiniteTimelineView(
                    tasks: filteredTasks,
                    onToggleCompletion: toggleTaskCompletion,
                    onDelete: deleteTask,
                    onEdit: startEditingTask,
                    onAddNew: { showAddSheet = true },
                    onDateTap: { date in
                        navigateToDate = date
                    }
                )
                .id(refreshCounter)
            }
            .background(AppColors.background)
            .navigationDestination(item: $navigateToDate) { date in
                DayTimelineView(
                    date: date,
                    events: eventsForDate(date),
                    hoangDaoHours: hoangDaoHoursForDate(date),
                    onEventTap: { task in
                        startEditingTask(task)
                    },
                    onAddEvent: { date in
                        addEventDate = date
                        showAddSheet = true
                    },
                    onToggleCompletion: toggleTaskCompletion
                )
            }
            .onReceive(NotificationCenter.default.publisher(for: .calendarDataDidChange)) { _ in
                refreshCounter += 1
            }
            .sheet(isPresented: $showAddSheet) {
                CreateItemSheet(
                    editingEvent: nil,
                    initialStartDate: addEventDate,
                    onSave: { _ in
                        addEventDate = nil
                        showAddSheet = false
                    }
                )
                .environmentObject(syncService)
                .environmentObject(notificationService)
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
                .environmentObject(notificationService)
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
