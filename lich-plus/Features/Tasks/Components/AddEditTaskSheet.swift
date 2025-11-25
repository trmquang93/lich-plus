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

    // SwiftData support
    @Query private var allEvents: [SyncableEvent]

    let editingEventId: UUID?
    let onSave: (SyncableEvent) -> Void

    var isEditMode: Bool {
        editingEventId != nil
    }

    var editingEvent: SyncableEvent? {
        allEvents.first { $0.id == editingEventId }
    }

    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    init(
        editingEventId: UUID? = nil,
        onSave: @escaping (SyncableEvent) -> Void
    ) {
        self.editingEventId = editingEventId
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
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

                    Toggle("Add Time", isOn: $hasTime)

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
                                    .fill(getCategoryColor(category))
                                    .frame(width: 12, height: 12)
                            }
                        }
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

                // Recurrence Section
                Section(header: Text("task.recurrence")) {
                    Picker("task.recurrence", selection: $selectedRecurrence) {
                        ForEach(RecurrenceType.allCases, id: \.self) { recurrence in
                            Text(recurrence.displayName).tag(recurrence)
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
            .navigationTitle(isEditMode ? "task.edit" : "task.addNew")
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
            }
        }
    }

    private func populateForm(with syncableEvent: SyncableEvent) {
        title = syncableEvent.title
        date = syncableEvent.startDate
        selectedCategory = TaskCategory(rawValue: syncableEvent.category.prefix(1).uppercased() + syncableEvent.category.dropFirst()) ?? .personal
        selectedReminder = syncableEvent.reminderMinutes
        notes = syncableEvent.notes ?? ""

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
                syncStatus: SyncStatus.pending.rawValue
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

    private func getCategoryColor(_ category: TaskCategory) -> Color {
        switch category {
        case .work:
            return AppColors.eventBlue
        case .personal:
            return AppColors.primary
        case .birthday:
            return AppColors.eventPink
        case .holiday:
            return AppColors.eventOrange
        case .meeting:
            return AppColors.eventYellow
        case .other:
            return AppColors.secondary
        }
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
        onSave: { _ in }
    )
    .environmentObject(syncService)
    .modelContext(modelContext)
}
