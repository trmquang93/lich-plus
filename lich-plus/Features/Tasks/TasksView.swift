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
    @State private var showEventNotFoundAlert: Bool = false
    @State private var navigateToDate: Date? = nil
    @State private var tasks: [TaskItem] = []

    // MARK: - Computed Properties

    private var eventsFingerprint: String {
        // Sum (not max) of timestamps so an edit to any event invalidates the
        // fingerprint, not only edits that bump the maximum. Background-sync
        // writes can arrive with timestamps older than an existing local edit;
        // a max-only fingerprint would silently skip the rebuild in that case.
        let count = syncableEvents.count
        let sum = syncableEvents.reduce(0.0) { $0 + $1.lastModifiedLocal.timeIntervalSince1970 }
        return "\(count)-\(sum)"
    }

    private var filteredTasks: [TaskItem] {
        guard !searchText.isEmpty else { return tasks }
        return tasks.filter { task in
            task.title.localizedCaseInsensitiveContains(searchText) ||
                (task.notes?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
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
            .task(id: eventsFingerprint) {
                tasks = RecurringEventExpander.expandRecurringEvents(syncableEvents)
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
            .sheet(item: $editingEvent) { event in
                CreateItemSheet(
                    editingEvent: event,
                    onSave: { _ in
                        editingEvent = nil
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
            // Prevent double-delete
            guard !syncableEvent.isDeleted else { return }

            do {
                try modelContext.deleteEvent(syncableEvent, notificationService: notificationService)
            } catch {
                print("Error deleting task: \(error)")
                // TODO: Show error alert to user or revert in-memory changes
            }
        }
    }

    private func startEditingTask(_ task: TaskItem) {
        // Prevent editing ICS subscription events (read-only)
        guard task.isEditable else { return }

        // Resolve to master event (occurrence or master)
        let targetId = task.masterEventId ?? task.id
        let foundEvent = syncableEvents.first(where: { $0.id == targetId })

        if foundEvent != nil {
            editingEvent = foundEvent
        } else {
            showEventNotFoundAlert = true
        }
    }
}

#Preview {
    TasksView()
}
