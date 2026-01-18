//
//  NotificationSettingsView.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 20/12/25.
//

import SwiftUI
import SwiftData

struct NotificationSettingsView: View {
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var notificationService: NotificationService
    
    @State private var settings: NotificationSettings?
    @State private var showPermissionAlert = false
    @State private var isToggling = false
    
    var body: some View {
        List {
            // Master toggle section
            Section {
                Toggle(String(localized: "Enable Notifications"), isOn: masterToggleBinding)
                    .onChange(of: masterToggleBinding.wrappedValue) { oldValue, newValue in
                        if newValue && notificationService.authorizationStatus == .denied {
                            // User denied permission previously
                            showPermissionAlert = true
                            masterToggleBinding.wrappedValue = false
                        } else if newValue {
                            // Request permission
                            requestPermissionAndEnable()
                        }
                    }
            }
            
            // Permission denied warning
            if notificationService.authorizationStatus == .denied {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(String(localized: "Enable notifications in Settings to receive reminders."))
                            .font(.caption)
                            .foregroundStyle(AppColors.textSecondary)
                        
                        Button(action: openAppSettings) {
                            Label(
                                String(localized: "Open Settings"),
                                systemImage: "gear"
                            )
                            .foregroundStyle(AppColors.primary)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            
            // Only show settings if notifications are enabled
            if let settingsValue = settings, settingsValue.isEnabled {
                // Event notifications section
                Section(String(localized: "Event Reminders")) {
                    Toggle(
                        String(localized: "Event Reminders"),
                        isOn: Binding(
                            get: { settingsValue.eventNotificationsEnabled },
                            set: { newValue in
                                settingsValue.eventNotificationsEnabled = newValue
                                saveSettings()
                            }
                        )
                    )
                    
                    VStack {
                        HStack(spacing: 0) {
                            Text(String(localized: "Default Reminder"))
                            Spacer()
                        }
                        Picker("", selection: Binding(
                            get: { settingsValue.defaultReminderMinutes },
                            set: { newValue in
                                settingsValue.defaultReminderMinutes = newValue
                                saveSettings()
                            }
                        )) {
                            ForEach([5, 10, 15, 30, 60], id: \.self) { minutes in
                                Text(String(format: NSLocalizedString(
                                    "notification.minutesBefore",
                                    comment: "Minutes before event"
                                ), minutes)).tag(minutes)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }
                
                // Rằm section
                Section(String(localized: "Rằm (15th) Reminders")) {
                    Toggle(
                        String(localized: "Rằm Reminders"),
                        isOn: Binding(
                            get: { settingsValue.ramNotificationsEnabled },
                            set: { newValue in
                                settingsValue.ramNotificationsEnabled = newValue
                                saveSettings()
                                if newValue {
                                    Task {
                                        await notificationService.scheduleRamNotifications()
                                    }
                                } else {
                                    removeRamNotifications()
                                }
                            }
                        )
                    )
                    
                    if settingsValue.ramNotificationsEnabled {
                        HStack {
                            Text(String(localized: "Time"))
                            Spacer()
                            DatePicker(
                                "",
                                selection: ramTimeBinding,
                                displayedComponents: .hourAndMinute
                            )
                            .labelsHidden()
                        }
                        .onChange(of: ramTimeBinding.wrappedValue) { oldValue, newValue in
                            updateRamTime()
                        }
                    }
                }
                
                // Mùng 1 section
                Section(String(localized: "Mùng 1 Reminders")) {
                    Toggle(
                        String(localized: "Mùng 1 Reminders"),
                        isOn: Binding(
                            get: { settingsValue.mung1NotificationsEnabled },
                            set: { newValue in
                                settingsValue.mung1NotificationsEnabled = newValue
                                saveSettings()
                                if newValue {
                                    Task {
                                        await notificationService.scheduleMung1Notifications()
                                    }
                                } else {
                                    removeMung1Notifications()
                                }
                            }
                        )
                    )
                    
                    if settingsValue.mung1NotificationsEnabled {
                        HStack {
                            Text(String(localized: "Time"))
                            Spacer()
                            DatePicker(
                                "",
                                selection: mung1TimeBinding,
                                displayedComponents: .hourAndMinute
                            )
                            .labelsHidden()
                        }
                        .onChange(of: mung1TimeBinding.wrappedValue) { oldValue, newValue in
                            updateMung1Time()
                        }
                    }
                }
                
                // Fixed events section
                Section(String(localized: "Fixed Reminders")) {
                    Toggle(
                        String(localized: "Fixed Reminders"),
                        isOn: Binding(
                            get: { settingsValue.fixedEventNotificationsEnabled },
                            set: { newValue in
                                settingsValue.fixedEventNotificationsEnabled = newValue
                                saveSettings()
                                if newValue {
                                    Task {
                                        await notificationService.scheduleFixedEventNotifications()
                                    }
                                } else {
                                    removeFixedEventNotifications()
                                }
                            }
                        )
                    )
                    
                    if settingsValue.fixedEventNotificationsEnabled {
                        Picker(
                            String(localized: "Reminder Days"),
                            selection: Binding(
                                get: { settingsValue.fixedEventReminderDays },
                                set: { newValue in
                                    settingsValue.fixedEventReminderDays = newValue
                                    saveSettings()
                                    Task {
                                        await notificationService.scheduleFixedEventNotifications()
                                    }
                                }
                            )
                        ) {
                            ForEach(0..<7, id: \.self) { days in
                                if days == 0 {
                                    Text(String(localized: "On day")).tag(days)
                                } else {
                                    Text(String(format: NSLocalizedString(
                                        "notification.daysBefore",
                                        comment: "Days before event"
                                    ), days)).tag(days)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(String(localized: "Notification Settings"))
        .onAppear {
            settings = notificationService.getSettings()
        }
        .alert(
            String(localized: "Enable Notifications"),
            isPresented: $showPermissionAlert
        ) {
            Button(String(localized: "Open Settings"), action: openAppSettings)
            Button(String(localized: "Cancel"), role: .cancel) { }
        } message: {
            Text(String(localized: "Please enable notifications in Settings to receive reminders."))
        }
    }
    
    // MARK: - Bindings
    
    private var masterToggleBinding: Binding<Bool> {
        Binding(
            get: { settings?.isEnabled ?? false },
            set: { newValue in
                if let settingsValue = settings {
                    settingsValue.isEnabled = newValue
                    saveSettings()
                    if newValue {
                        Task {
                            await notificationService.rescheduleAllNotifications()
                        }
                    }
                }
            }
        )
    }
    
    private var ramTimeBinding: Binding<Date> {
        Binding(
            get: {
                guard let settings = settings else { return Date() }
                var components = DateComponents()
                components.hour = settings.ramNotificationHour
                components.minute = settings.ramNotificationMinute
                return Calendar.current.date(from: components) ?? Date()
            },
            set: { _ in }
        )
    }
    
    private var mung1TimeBinding: Binding<Date> {
        Binding(
            get: {
                guard let settings = settings else { return Date() }
                var components = DateComponents()
                components.hour = settings.mung1NotificationHour
                components.minute = settings.mung1NotificationMinute
                return Calendar.current.date(from: components) ?? Date()
            },
            set: { _ in }
        )
    }
    
    // MARK: - Helper Methods
    
    private func requestPermissionAndEnable() {
        Task {
            let granted = await notificationService.requestAuthorization()
            if granted {
                if let settingsValue = settings {
                    settingsValue.isEnabled = true
                    saveSettings()
                    await notificationService.rescheduleAllNotifications()
                }
            }
        }
    }
    
    private func updateRamTime() {
        guard let settingsValue = settings else { return }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: ramTimeBinding.wrappedValue)
        settingsValue.ramNotificationHour = components.hour ?? 6
        settingsValue.ramNotificationMinute = components.minute ?? 0
        saveSettings()
        Task {
            await notificationService.scheduleRamNotifications()
        }
    }
    
    private func updateMung1Time() {
        guard let settingsValue = settings else { return }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: mung1TimeBinding.wrappedValue)
        settingsValue.mung1NotificationHour = components.hour ?? 6
        settingsValue.mung1NotificationMinute = components.minute ?? 0
        saveSettings()
        Task {
            await notificationService.scheduleMung1Notifications()
        }
    }
    
    private func saveSettings() {
        if let settings = settings {
            notificationService.updateSettings(settings)
        }
    }
    
    private func removeRamNotifications() {
        Task {
            await notificationService.removeAllRamNotifications()
        }
    }
    
    private func removeMung1Notifications() {
        Task {
            await notificationService.removeAllMung1Notifications()
        }
    }
    
    private func removeFixedEventNotifications() {
        Task {
            await notificationService.removeAllFixedEventNotifications()
        }
    }
    
    private func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: NotificationSettings.self,
        configurations: config
    )
    let modelContext = ModelContext(container)
    
    return NavigationStack {
        NotificationSettingsView()
            .environmentObject(NotificationService(modelContext: modelContext))
            .modelContext(modelContext)
    }
}
