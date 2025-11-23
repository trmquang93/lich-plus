//
//  AddEditTaskSheet.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 23/11/25.
//

import SwiftUI

struct AddEditTaskSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var title: String = ""
    @State private var date: Date = Date()
    @State private var hasTime: Bool = false
    @State private var startTime: Date = Date()
    @State private var endTime: Date = Date(timeIntervalSinceNow: 3600)
    @State private var selectedCategory: TaskCategory = .personal
    @State private var selectedReminder: Int? = nil
    @State private var selectedRecurrence: RecurrenceType = .none
    @State private var notes: String = ""

    let isEditMode: Bool
    let editingTask: Task?
    let onSave: (Task) -> Void

    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    init(
        isEditMode: Bool = false,
        editingTask: Task? = nil,
        onSave: @escaping (Task) -> Void
    ) {
        self.isEditMode = isEditMode
        self.editingTask = editingTask
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
            if let editingTask = editingTask {
                populateForm(with: editingTask)
            }
        }
    }

    private func populateForm(with task: Task) {
        title = task.title
        date = task.date
        selectedCategory = task.category
        selectedReminder = task.reminderMinutes
        selectedRecurrence = task.recurrence
        notes = task.notes ?? ""

        if let startTime = task.startTime {
            hasTime = true
            self.startTime = startTime
            if let endTime = task.endTime {
                self.endTime = endTime
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

        let task = Task(
            id: editingTask?.id ?? UUID(),
            title: title,
            date: date,
            startTime: finalStartTime,
            endTime: finalEndTime,
            category: selectedCategory,
            notes: notes.isEmpty ? nil : notes,
            isCompleted: editingTask?.isCompleted ?? false,
            reminderMinutes: selectedReminder,
            recurrence: selectedRecurrence,
            createdAt: editingTask?.createdAt ?? Date(),
            updatedAt: Date()
        )

        onSave(task)
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
    AddEditTaskSheet(isEditMode: false) { _ in }
}
