//
//  AddEditTaskSheet.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 23/11/25.
//

import SwiftUI
import SwiftData

struct AddEditTaskSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var syncService: CalendarSyncService

    @State private var title: String = ""
    @State private var date: Date = Date()
    @State private var hasTime: Bool = false
    @State private var startTime: Date = Date()
    @State private var endTime: Date = Date(timeIntervalSinceNow: 3600)
    @State private var selectedCategory: TaskCategory = .personal
    @State private var selectedReminder: Int? = nil
    @State private var selectedRecurrence: RecurrenceType = .none
    @State private var notes: String = ""

    // New fields for Phase 4
    @State private var selectedItemType: ItemType = .task
    @State private var selectedPriority: Priority = .none
    @State private var location: String = ""

    // SwiftData support
    @Query private var allEvents: [SyncableEvent]

    // AI Input state
    @State private var aiInputText: String = ""
    @State private var isAIParsing: Bool = false
    @State private var aiError: String? = nil

    let editingEventId: UUID?
    let initialItemType: ItemType?
    let onSave: (SyncableEvent) -> Void
    let nlpService: NLPService = MockNLPService()

    var isEditMode: Bool {
        editingEventId != nil
    }

    var editingEvent: SyncableEvent? {
        allEvents.first { $0.id == editingEventId }
    }

    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var navigationTitle: String {
        if isEditMode {
            return selectedItemType == .task ? "task.edit" : "event.edit"
        } else {
            return selectedItemType == .task ? "task.addNew" : "event.addNew"
        }
    }

    init(
        editingEventId: UUID? = nil,
        initialItemType: ItemType? = nil,
        onSave: @escaping (SyncableEvent) -> Void
    ) {
        self.editingEventId = editingEventId
        self.initialItemType = initialItemType
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                // Item Type Selector Section
                Section {
                    HStack(spacing: AppTheme.spacing12) {
                        // Task Button
                        Button(action: { selectedItemType = .task }) {
                            VStack(spacing: AppTheme.spacing4) {
                                Image(systemName: "checkmark.circle")
                                    .font(.system(size: 24))
                                Text(String(localized: "addSheet.typeTask"))
                                    .font(.system(size: AppTheme.fontCaption))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppTheme.spacing12)
                            .background(selectedItemType == .task ? AppColors.primary.opacity(0.1) : AppColors.backgroundLightGray)
                            .foregroundStyle(selectedItemType == .task ? AppColors.primary : AppColors.textSecondary)
                            .cornerRadius(AppTheme.cornerRadiusMedium)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                                    .stroke(selectedItemType == .task ? AppColors.primary : Color.clear, lineWidth: 2)
                            )
                        }
                        .buttonStyle(.plain)

                        // Event Button
                        Button(action: { selectedItemType = .event }) {
                            VStack(spacing: AppTheme.spacing4) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 24))
                                Text(String(localized: "addSheet.typeEvent"))
                                    .font(.system(size: AppTheme.fontCaption))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppTheme.spacing12)
                            .background(selectedItemType == .event ? AppColors.primary.opacity(0.1) : AppColors.backgroundLightGray)
                            .foregroundStyle(selectedItemType == .event ? AppColors.primary : AppColors.textSecondary)
                            .cornerRadius(AppTheme.cornerRadiusMedium)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                                    .stroke(selectedItemType == .event ? AppColors.primary : Color.clear, lineWidth: 2)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }

                // AI Input Section
                AIInputSection(
                    nlpService: nlpService,
                    itemType: selectedItemType,
                    onTaskParsed: { parsed in
                        handleAITaskParsed(parsed)
                    },
                    onEventParsed: { parsed in
                        handleAIEventParsed(parsed)
                    }
                )

                // Title Section
                Section(header: Text("task.title")) {
                    TextField("task.title", text: $title)
                }

                // Date & Time Section
                Section(header: Text("task.date")) {
                    DatePicker(
                        "task.date",
                        selection: $date,
                        displayedComponents: .date
                    )

                    Toggle(String(localized: "task.addTime"), isOn: $hasTime)

                    if hasTime {
                        DatePicker(
                            "task.startTime",
                            selection: $startTime,
                            displayedComponents: .hourAndMinute
                        )

                        DatePicker(
                            "task.endTime",
                            selection: $endTime,
                            displayedComponents: .hourAndMinute
                        )
                    }
                }

                // Category Section
                Section(header: Text("task.category")) {
                    Picker("task.category", selection: $selectedCategory) {
                        ForEach(TaskCategory.allCases, id: \.self) { category in
                            HStack {
                                Text(category.displayName)
                                    .tag(category)

                                Spacer()

                                Circle()
                                    .fill(category.colorValue)
                                    .frame(width: 12, height: 12)
                            }
                        }
                    }
                }

                // Priority Section (Tasks only)
                if selectedItemType == .task {
                    Section(header: Text("task.priority")) {
                        Picker("task.priority", selection: $selectedPriority) {
                            ForEach(Priority.allCases) { priority in
                                HStack {
                                    Circle()
                                        .fill(priority.color)
                                        .frame(width: 12, height: 12)
                                    Text(priority.displayName)
                                }
                                .tag(priority)
                            }
                        }
                    }
                }

                // Location Section (Events only)
                if selectedItemType == .event {
                    Section(header: Text("task.location")) {
                        TextField("task.locationPlaceholder", text: $location)
                    }
                }

                // Reminder Section
                Section(header: Text("task.reminder")) {
                    Picker("task.reminder", selection: $selectedReminder) {
                        Text("reminder.none").tag(Int?.none)

                        Text("reminder.15min").tag(15 as Int?)
                        Text("reminder.30min").tag(30 as Int?)
                        Text("reminder.1hr").tag(60 as Int?)
                    }
                }

                // Recurrence Section (Tasks only)
                if selectedItemType == .task {
                    Section(header: Text("task.recurrence")) {
                        Picker("task.recurrence", selection: $selectedRecurrence) {
                            ForEach(RecurrenceType.allCases, id: \.self) { recurrence in
                                Text(recurrence.displayName).tag(recurrence)
                            }
                        }
                    }
                }

                // Notes Section
                Section(header: Text("task.notes")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                        .foregroundStyle(AppColors.textPrimary)
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("task.cancel") {
                        dismiss()
                    }
                    .foregroundStyle(AppColors.primary)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("task.done") {
                        saveTask()
                    }
                    .foregroundStyle(isValid ? AppColors.primary : AppColors.textDisabled)
                    .disabled(!isValid)
                }
            }
        }
        .onAppear {
            if let editingEvent = editingEvent {
                populateForm(with: editingEvent)
            } else if let initialType = initialItemType {
                selectedItemType = initialType
            }
        }
    }

    private func handleAITaskParsed(_ parsed: ParsedTask) {
        title = parsed.title

        if let dueDate = parsed.dueDate {
            date = dueDate
        }

        if let category = parsed.category {
            selectedCategory = TaskCategory(rawValue: category) ?? .personal
        }

        if let dueTime = parsed.dueTime {
            hasTime = true
            startTime = dueTime
            endTime = Calendar.current.date(byAdding: .hour, value: 1, to: dueTime) ?? dueTime
        }

        if let notes = parsed.notes {
            self.notes = notes
        }

        if parsed.hasReminder {
            selectedReminder = 15
        }
    }

    private func handleAIEventParsed(_ parsed: ParsedEvent) {
        title = parsed.title

        if let startDate = parsed.startDate {
            date = startDate
        }

        if !parsed.isAllDay {
            hasTime = true
            if let startDate = parsed.startDate {
                startTime = startDate
            }
            if let endDate = parsed.endDate {
                endTime = endDate
            }
        }

        if let location = parsed.location {
            self.location = location
        }

        if let notes = parsed.notes {
            self.notes = notes
        }
    }

    private func populateForm(with syncableEvent: SyncableEvent) {
        title = syncableEvent.title
        date = syncableEvent.startDate
        selectedCategory = TaskCategory.allCases.first(where: {
            $0.rawValue.caseInsensitiveCompare(syncableEvent.category) == .orderedSame
        }) ?? .personal
        selectedReminder = syncableEvent.reminderMinutes
        notes = syncableEvent.notes ?? ""
        selectedItemType = syncableEvent.itemTypeEnum
        selectedPriority = syncableEvent.priorityEnum
        location = syncableEvent.location ?? ""

        if !syncableEvent.isAllDay, let startDate = syncableEvent.startDate as Date? {
            hasTime = true
            self.startTime = startDate
            if let endDate = syncableEvent.endDate {
                self.endTime = endDate
            }
        }
    }

    private func saveTask() {
        var finalStartTime: Date? = nil
        var finalEndTime: Date? = nil

        if hasTime {
            finalStartTime = startTime
            finalEndTime = endTime
        }

        let syncableEvent: SyncableEvent
        if let existing = editingEvent {
            // Update existing
            existing.title = title
            existing.startDate = finalStartTime ?? date
            existing.endDate = finalEndTime
            existing.isAllDay = finalStartTime == nil
            existing.category = selectedCategory.rawValue
            existing.notes = notes.isEmpty ? nil : notes
            existing.reminderMinutes = selectedReminder
            existing.itemType = selectedItemType.rawValue
            existing.priority = selectedPriority.rawValue
            existing.location = location.isEmpty ? nil : location
            existing.lastModifiedLocal = Date()
            existing.setSyncStatus(.pending)
            syncableEvent = existing
        } else {
            // Create new
            syncableEvent = SyncableEvent(
                title: title,
                startDate: finalStartTime ?? date,
                endDate: finalEndTime,
                isAllDay: finalStartTime == nil,
                notes: notes.isEmpty ? nil : notes,
                category: selectedCategory.rawValue,
                reminderMinutes: selectedReminder,
                syncStatus: SyncStatus.pending.rawValue,
                itemType: selectedItemType.rawValue,
                priority: selectedPriority.rawValue,
                location: location.isEmpty ? nil : location
            )
            modelContext.insert(syncableEvent)
        }

        do {
            try modelContext.save()

            // Sync will be handled by the CalendarSyncService observing changes
        } catch {
            print("Error saving task: \(error)")
        }

        onSave(syncableEvent)
        dismiss()
    }

}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: SyncableEvent.self, configurations: config)
    let modelContext = ModelContext(container)
    let eventKitService = EventKitService()
    let syncService = CalendarSyncService(
        eventKitService: eventKitService,
        modelContext: modelContext
    )

    AddEditTaskSheet(
        editingEventId: nil,
        initialItemType: nil,
        onSave: { _ in }
    )
    .environmentObject(syncService)
    .modelContext(modelContext)
}
