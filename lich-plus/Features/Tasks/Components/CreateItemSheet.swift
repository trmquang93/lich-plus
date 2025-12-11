//
//  CreateItemSheet.swift
//  lich-plus
//
//  Modern event/task creation sheet with card-based design
//

import SwiftUI
import SwiftData

struct CreateItemSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var syncService: CalendarSyncService

    // MARK: - State
    @State private var selectedItemType: ItemType = .event
    @State private var title: String = ""
    @State private var selectedCategory: TaskCategory = .personal
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date(timeIntervalSinceNow: AppTheme.defaultEventDuration)
    @State private var location: String = ""
    @State private var notes: String = ""
    @State private var selectedRecurrence: RecurrenceType = .none
    @State private var selectedPriority: Priority = .medium
    @State private var selectedReminder: Int? = nil

    // Date picker states
    @State private var showStartDatePicker = false
    @State private var showEndDatePicker = false
    @State private var showRecurrencePicker = false

    let editingEvent: SyncableEvent?
    let initialItemType: ItemType?
    let onSave: (SyncableEvent) -> Void

    var isEditMode: Bool {
        editingEvent != nil
    }

    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    init(
        editingEvent: SyncableEvent? = nil,
        initialItemType: ItemType? = nil,
        onSave: @escaping (SyncableEvent) -> Void
    ) {
        self.editingEvent = editingEvent
        self.initialItemType = initialItemType
        self.onSave = onSave
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView

            // Content
            ScrollView {
                VStack(spacing: AppTheme.spacing24) {
                    // Item Type Toggle
                    itemTypeToggle

                    // Form content based on type
                    if selectedItemType == .event {
                        eventFormContent
                    } else {
                        taskFormContent
                    }
                }
                .padding(.horizontal, AppTheme.spacing16)
                .padding(.top, AppTheme.spacing24)
                .padding(.bottom, AppTheme.footerHeight)
            }

            // Footer
            footerView
        }
        .background(AppColors.backgroundLightGray)
        .onAppear {
            if let editingEvent = editingEvent {
                populateForm(with: editingEvent)
            } else if let initialType = initialItemType {
                selectedItemType = initialType
            }
        }
        .sheet(isPresented: $showStartDatePicker) {
            CalendarDatePickerSheet(
                title: String(localized: "createItem.starts"),
                selectedDate: $startDate,
                onDone: {
                    showStartDatePicker = false
                    // Ensure end date is after start date
                    if endDate < startDate {
                        endDate = startDate.addingTimeInterval(AppTheme.defaultEventDuration)
                    }
                }
            )
            .presentationDetents([.large])
        }
        .sheet(isPresented: $showEndDatePicker) {
            CalendarDatePickerSheet(
                title: String(localized: "createItem.ends"),
                selectedDate: $endDate,
                onDone: { showEndDatePicker = false }
            )
            .presentationDetents([.large])
        }
        .sheet(isPresented: $showRecurrencePicker) {
            RecurrencePickerSheet(
                selectedRecurrence: $selectedRecurrence,
                onDone: { showRecurrencePicker = false }
            )
            .presentationDetents([.medium])
        }
    }

    // MARK: - Header View
    private var headerView: some View {
        HStack {
            // Empty space for balance
            Color.clear
                .frame(width: 32, height: 32)

            Spacer()

            Text(String(localized: "createItem.title"))
                .font(.system(size: AppTheme.fontTitle3, weight: .bold))
                .foregroundStyle(AppColors.textPrimary)

            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(AppColors.textSecondary)
                    .frame(width: 32, height: 32)
            }
        }
        .padding(.horizontal, AppTheme.spacing16)
        .padding(.top, AppTheme.spacing20)
        .padding(.bottom, AppTheme.spacing16)
        .background(AppColors.backgroundLightGray)
    }

    // MARK: - Item Type Toggle
    private var itemTypeToggle: some View {
        Picker("", selection: $selectedItemType) {
            ForEach(ItemType.allCases) { type in
                Text(type.displayName).tag(type)
            }
        }
        .pickerStyle(.segmented)
    }

    // MARK: - Event Form Content
    private var eventFormContent: some View {
        VStack(spacing: AppTheme.spacing24) {
            // Title
            FormSection(title: String(localized: "createItem.eventTitle")) {
                TextField(String(localized: "createItem.eventTitlePlaceholder"), text: $title)
                    .font(.system(size: AppTheme.fontBody))
                    .padding(AppTheme.spacing12)
                    .background(AppColors.background)
                    .cornerRadius(AppTheme.cornerRadiusLarge)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge)
                            .stroke(AppColors.borderLight, lineWidth: 1)
                    )
            }

            // Category
            FormSection(title: String(localized: "createItem.eventCategory")) {
                categoryPills
            }

            // Start/End Time
            HStack(spacing: AppTheme.spacing16) {
                FormSection(title: String(localized: "createItem.starts")) {
                    DateButton(date: startDate) {
                        showStartDatePicker = true
                    }
                }

                FormSection(title: String(localized: "createItem.ends")) {
                    DateButton(date: endDate) {
                        showEndDatePicker = true
                    }
                }
            }

            // Location
            FormSection(title: String(localized: "createItem.location")) {
                HStack(spacing: AppTheme.spacing8) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(AppColors.primary)

                    TextField(String(localized: "createItem.locationPlaceholder"), text: $location)
                        .font(.system(size: AppTheme.fontBody))

                    if !location.isEmpty {
                        Button {
                            location = ""
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(AppColors.textSecondary)
                        }
                    }
                }
                .padding(AppTheme.spacing12)
                .background(AppColors.background)
                .cornerRadius(AppTheme.cornerRadiusLarge)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge)
                        .stroke(AppColors.borderLight, lineWidth: 1)
                )
            }

            // Description
            FormSection(title: String(localized: "createItem.description")) {
                TextEditor(text: $notes)
                    .font(.system(size: AppTheme.fontBody))
                    .frame(minHeight: 80)
                    .padding(AppTheme.spacing8)
                    .background(AppColors.background)
                    .cornerRadius(AppTheme.cornerRadiusLarge)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge)
                            .stroke(AppColors.borderLight, lineWidth: 1)
                    )
                    .scrollContentBackground(.hidden)
            }

            // Recurrence
            FormSection(title: String(localized: "createItem.recurrence")) {
                recurrenceButton
            }
        }
    }

    // MARK: - Task Form Content
    private var taskFormContent: some View {
        VStack(spacing: AppTheme.spacing24) {
            // Title
            FormSection(title: String(localized: "createItem.taskTitle")) {
                TextField(String(localized: "createItem.taskTitlePlaceholder"), text: $title)
                    .font(.system(size: AppTheme.fontBody))
                    .padding(AppTheme.spacing12)
                    .background(AppColors.background)
                    .cornerRadius(AppTheme.cornerRadiusLarge)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge)
                            .stroke(AppColors.borderLight, lineWidth: 1)
                    )
            }

            // Category
            FormSection(title: String(localized: "createItem.category")) {
                taskCategoryPills
            }

            // Due Date
            FormSection(title: String(localized: "createItem.dueDate")) {
                DateButton(date: startDate) {
                    showStartDatePicker = true
                }
            }

            // Priority
            FormSection(title: String(localized: "createItem.priority")) {
                priorityButtons
            }

            // Recurrence
            FormSection(title: String(localized: "createItem.recurrence")) {
                recurrenceButton
            }

            // Description
            FormSection(title: String(localized: "createItem.description")) {
                TextEditor(text: $notes)
                    .font(.system(size: AppTheme.fontBody))
                    .frame(minHeight: 80)
                    .padding(AppTheme.spacing8)
                    .background(AppColors.background)
                    .cornerRadius(AppTheme.cornerRadiusLarge)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge)
                            .stroke(AppColors.borderLight, lineWidth: 1)
                    )
                    .scrollContentBackground(.hidden)
            }
        }
    }

    // MARK: - Shared UI Components

    /// Shared recurrence button view
    private var recurrenceButton: some View {
        Button {
            showRecurrencePicker = true
        } label: {
            HStack {
                Text(selectedRecurrence.displayName)
                    .font(.system(size: AppTheme.fontBody))
                    .foregroundStyle(AppColors.textPrimary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppColors.textSecondary)
            }
            .padding(AppTheme.spacing12)
            .background(AppColors.background)
            .cornerRadius(AppTheme.cornerRadiusLarge)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge)
                    .stroke(AppColors.borderLight, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    /// Create category pills view for given categories
    private func categoryPillsView(categories: [TaskCategory]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.spacing8) {
                ForEach(categories, id: \.self) { category in
                    CategoryPill(
                        category: category,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                    }
                }
            }
        }
    }

    // MARK: - Category Pills (Event)
    private var categoryPills: some View {
        categoryPillsView(categories: [.work, .personal, .meeting])
    }

    // MARK: - Category Pills (Task)
    private var taskCategoryPills: some View {
        categoryPillsView(categories: [.work, .personal, .other])
    }

    // MARK: - Priority Buttons
    private var priorityButtons: some View {
        HStack(spacing: AppTheme.spacing12) {
            PriorityButton(
                priority: .high,
                isSelected: selectedPriority == .high
            ) {
                selectedPriority = .high
            }

            PriorityButton(
                priority: .medium,
                isSelected: selectedPriority == .medium
            ) {
                selectedPriority = .medium
            }

            PriorityButton(
                priority: .low,
                isSelected: selectedPriority == .low
            ) {
                selectedPriority = .low
            }
        }
    }

    // MARK: - Footer View
    private var footerView: some View {
        VStack {
            Button {
                saveItem()
            } label: {
                Text(selectedItemType == .event
                     ? String(localized: "createItem.createEvent")
                     : String(localized: "createItem.createTask"))
                    .font(.system(size: AppTheme.fontSubheading, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppTheme.spacing12)
                    .background(isValid ? AppColors.primary : AppColors.primary.opacity(0.5))
                    .cornerRadius(AppTheme.cornerRadiusLarge)
                    .shadow(color: AppColors.primary.opacity(0.3), radius: 8, y: 4)
            }
            .disabled(!isValid)
            .buttonStyle(.plain)
        }
        .padding(.horizontal, AppTheme.spacing16)
        .padding(.vertical, AppTheme.spacing16)
        .padding(.bottom, AppTheme.spacing16)
        .background(AppColors.backgroundLightGray)
    }

    // MARK: - Helper Methods
    private func populateForm(with syncableEvent: SyncableEvent) {
        title = syncableEvent.title
        startDate = syncableEvent.startDate
        selectedCategory = TaskCategory.allCases.first(where: {
            $0.rawValue.caseInsensitiveCompare(syncableEvent.category) == .orderedSame
        }) ?? .personal
        selectedReminder = syncableEvent.reminderMinutes
        notes = syncableEvent.notes ?? ""
        selectedItemType = syncableEvent.itemTypeEnum
        selectedPriority = syncableEvent.priorityEnum
        location = syncableEvent.location ?? ""

        if let endDate = syncableEvent.endDate {
            self.endDate = endDate
        }

        // Load recurrence from persisted data
        if let recurrenceData = syncableEvent.recurrenceRuleData {
            decodeRecurrence(from: recurrenceData)
        }
    }

    private func saveItem() {
        let syncableEvent: SyncableEvent

        if let existing = editingEvent {
            // Prevent updating deleted events
            guard !existing.isDeleted else {
                dismiss()
                return
            }
            // Update existing
            existing.title = title
            existing.startDate = startDate
            existing.endDate = selectedItemType == .event ? endDate : nil
            existing.isAllDay = false
            existing.category = selectedCategory.rawValue
            existing.notes = notes.isEmpty ? nil : notes
            existing.reminderMinutes = selectedReminder
            existing.itemType = selectedItemType.rawValue
            existing.priority = selectedPriority.rawValue
            existing.location = location.isEmpty ? nil : location
            existing.lastModifiedLocal = Date()
            existing.setSyncStatus(.pending)

            // Persist recurrence data
            if let recurrenceData = createRecurrenceData() {
                existing.recurrenceRuleData = recurrenceData
            } else {
                existing.recurrenceRuleData = nil
            }

            syncableEvent = existing
        } else {
            // Create new
            syncableEvent = SyncableEvent(
                title: title,
                startDate: startDate,
                endDate: selectedItemType == .event ? endDate : nil,
                isAllDay: false,
                notes: notes.isEmpty ? nil : notes,
                category: selectedCategory.rawValue,
                reminderMinutes: selectedReminder,
                syncStatus: SyncStatus.pending.rawValue,
                itemType: selectedItemType.rawValue,
                priority: selectedPriority.rawValue,
                location: location.isEmpty ? nil : location
            )

            // Persist recurrence data
            if let recurrenceData = createRecurrenceData() {
                syncableEvent.recurrenceRuleData = recurrenceData
            }

            modelContext.insert(syncableEvent)
        }

        do {
            try modelContext.save()

            // Notify calendar to refresh
            NotificationCenter.default.post(name: .calendarDataDidChange, object: nil)
        } catch {
            print("Error saving item: \(error)")
        }

        onSave(syncableEvent)
        dismiss()
    }

    // MARK: - Lunar Date Derivation

    /// Derive lunar date from the event's start date
    private func deriveLunarDate() -> (day: Int, month: Int, year: Int) {
        return LunarCalendar.solarToLunar(startDate)
    }

    // MARK: - Recurrence Persistence Helpers

    /// Create serialized recurrence data from selected recurrence type
    private func createRecurrenceData() -> Data? {
        guard selectedRecurrence != .none else { return nil }

        if selectedRecurrence.isLunar {
            // Auto-derive lunar date from startDate
            let lunar = deriveLunarDate()
            let frequency: LunarFrequency = selectedRecurrence == .lunarMonthly ? .monthly : .yearly

            let lunarRule = SerializableLunarRecurrenceRule(
                frequency: frequency,
                lunarDay: lunar.day,
                lunarMonth: selectedRecurrence == .lunarYearly ? lunar.month : nil,
                leapMonthBehavior: .includeLeap,
                interval: 1,
                recurrenceEnd: nil
            )
            return try? JSONEncoder().encode(RecurrenceRuleContainer.lunar(lunarRule))
        } else {
            // Create solar recurrence rule
            let solarRule = createSolarRecurrenceRule(from: selectedRecurrence)
            return try? JSONEncoder().encode(RecurrenceRuleContainer.solar(solarRule))
        }
    }

    /// Create a SerializableRecurrenceRule from a RecurrenceType
    private func createSolarRecurrenceRule(from recurrence: RecurrenceType) -> SerializableRecurrenceRule {
        let frequency: Int
        switch recurrence {
        case .daily:
            frequency = 0  // EKRecurrenceFrequency.daily
        case .weekly:
            frequency = 1
        case .monthly:
            frequency = 2
        case .yearly:
            frequency = 3
        default:
            frequency = 0
        }

        return SerializableRecurrenceRule(
            frequency: frequency,
            interval: 1
        )
    }

    /// Decode recurrence from persisted data and populate state
    private func decodeRecurrence(from data: Data) {
        guard let container = try? JSONDecoder().decode(RecurrenceRuleContainer.self, from: data) else {
            return
        }

        switch container {
        case .solar(let rule):
            // Convert serialized rule back to RecurrenceType
            selectedRecurrence = convertToRecurrenceType(from: rule)

        case .lunar(let rule):
            // Set appropriate recurrence type based on lunar frequency
            selectedRecurrence = rule.frequency == .monthly ? .lunarMonthly : .lunarYearly

        case .none:
            selectedRecurrence = .none
        }
    }

    /// Convert a SerializableRecurrenceRule to RecurrenceType
    private func convertToRecurrenceType(from rule: SerializableRecurrenceRule) -> RecurrenceType {
        switch rule.frequency {
        case 0:
            return .daily
        case 1:
            return .weekly
        case 2:
            return .monthly
        case 3:
            return .yearly
        default:
            return .none
        }
    }
}

// MARK: - Preview

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: SyncableEvent.self, configurations: config)
    let modelContext = ModelContext(container)
    let eventKitService = EventKitService()
    let syncService = CalendarSyncService(
        eventKitService: eventKitService,
        modelContext: modelContext
    )

    CreateItemSheet(
        editingEvent: nil,
        initialItemType: nil,
        onSave: { _ in }
    )
    .environmentObject(syncService)
    .modelContext(modelContext)
}
