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
                Toggle(String(localized: "notification.enable"), isOn: masterToggleBinding)
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
                        Text(String(localized: "notification.permissionDenied.footer"))
                            .font(.caption)
                            .foregroundStyle(AppColors.textSecondary)
                        
                        Button(action: openAppSettings) {
                            Label(
                                String(localized: "notification.openSettings"),
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
                Section(String(localized: "notification.events.section")) {
                    Toggle(
                        String(localized: "notification.events.enable"),
                        isOn: Binding(
                            get: { settingsValue.eventNotificationsEnabled },
                            set: { newValue in
                                if var updatedSettings = settings {
                                    updatedSettings.eventNotificationsEnabled = newValue
                                    settings = updatedSettings
                                    saveSettings()
                                }
                            }
                        )
                    )
                    
                    HStack {
                        Text(String(localized: "notification.defaultReminder"))
                        Spacer()
                        Picker("", selection: Binding(
                            get: { settingsValue.defaultReminderMinutes },
                            set: { newValue in
                                if var updatedSettings = settings {
                                    updatedSettings.defaultReminderMinutes = newValue
                                    settings = updatedSettings
                                    saveSettings()
                                }
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
                Section(String(localized: "notification.ram.section")) {
                    Toggle(
                        String(localized: "notification.ram.enable"),
                        isOn: Binding(
                            get: { settingsValue.ramNotificationsEnabled },
                            set: { newValue in
                                if var updatedSettings = settings {
                                    updatedSettings.ramNotificationsEnabled = newValue
                                    settings = updatedSettings
                                    saveSettings()
                                    if newValue {
                                        notificationService.scheduleRamNotifications()
                                    } else {
                                        removeRamNotifications()
                                    }
                                }
                            }
                        )
                    )
                    
                    if settingsValue.ramNotificationsEnabled {
                        HStack {
                            Text(String(localized: "notification.time"))
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
                Section(String(localized: "notification.mung1.section")) {
                    Toggle(
                        String(localized: "notification.mung1.enable"),
                        isOn: Binding(
                            get: { settingsValue.mung1NotificationsEnabled },
                            set: { newValue in
                                if var updatedSettings = settings {
                                    updatedSettings.mung1NotificationsEnabled = newValue
                                    settings = updatedSettings
                                    saveSettings()
                                    if newValue {
                                        notificationService.scheduleMung1Notifications()
                                    } else {
                                        removeMung1Notifications()
                                    }
                                }
                            }
                        )
                    )
                    
                    if settingsValue.mung1NotificationsEnabled {
                        HStack {
                            Text(String(localized: "notification.time"))
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
                Section(String(localized: "notification.fixed.section")) {
                    Toggle(
                        String(localized: "notification.fixed.enable"),
                        isOn: Binding(
                            get: { settingsValue.fixedEventNotificationsEnabled },
                            set: { newValue in
                                if var updatedSettings = settings {
                                    updatedSettings.fixedEventNotificationsEnabled = newValue
                                    settings = updatedSettings
                                    saveSettings()
                                    if newValue {
                                        notificationService.scheduleFixedEventNotifications()
                                    } else {
                                        removeFixedEventNotifications()
                                    }
                                }
                            }
                        )
                    )
                    
                    if settingsValue.fixedEventNotificationsEnabled {
                        Picker(
                            String(localized: "notification.fixed.reminderDays"),
                            selection: Binding(
                                get: { settingsValue.fixedEventReminderDays },
                                set: { newValue in
                                    if var updatedSettings = settings {
                                        updatedSettings.fixedEventReminderDays = newValue
                                        settings = updatedSettings
                                        saveSettings()
                                        notificationService.scheduleFixedEventNotifications()
                                    }
                                }
                            )
                        ) {
                            ForEach(0..<7, id: \.self) { days in
                                if days == 0 {
                                    Text(String(localized: "notification.onDay")).tag(days)
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
        .navigationTitle(String(localized: "notification.settings.title"))
        .onAppear {
            settings = notificationService.getSettings()
        }
        .alert(
            String(localized: "notification.permissionRequired.title"),
            isPresented: $showPermissionAlert
        ) {
            Button(String(localized: "notification.openSettings"), action: openAppSettings)
            Button(String(localized: "notification.cancel"), role: .cancel) { }
        } message: {
            Text(String(localized: "notification.permissionRequired.message"))
        }
    }
    
    // MARK: - Bindings
    
    private var masterToggleBinding: Binding<Bool> {
        Binding(
            get: { settings?.isEnabled ?? false },
            set: { newValue in
                if var settingsValue = settings {
                    settingsValue.isEnabled = newValue
                    settings = settingsValue
                    saveSettings()
                    if newValue {
                        notificationService.rescheduleAllNotifications()
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
                if var settingsValue = settings {
                    settingsValue.isEnabled = true
                    settings = settingsValue
                    saveSettings()
                    notificationService.rescheduleAllNotifications()
                }
            }
        }
    }
    
    private func updateRamTime() {
        guard var settingsValue = settings else { return }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: ramTimeBinding.wrappedValue)
        settingsValue.ramNotificationHour = components.hour ?? 6
        settingsValue.ramNotificationMinute = components.minute ?? 0
        settings = settingsValue
        saveSettings()
        notificationService.scheduleRamNotifications()
    }
    
    private func updateMung1Time() {
        guard var settingsValue = settings else { return }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: mung1TimeBinding.wrappedValue)
        settingsValue.mung1NotificationHour = components.hour ?? 6
        settingsValue.mung1NotificationMinute = components.minute ?? 0
        settings = settingsValue
        saveSettings()
        notificationService.scheduleMung1Notifications()
    }
    
    private func saveSettings() {
        if let settings = settings {
            notificationService.updateSettings(settings)
        }
    }
    
    private func removeRamNotifications() {
        // NotificationService will remove them when scheduleRamNotifications is not called
        // For now, we just need to update the UI
    }
    
    private func removeMung1Notifications() {
        // NotificationService will remove them when scheduleMung1Notifications is not called
        // For now, we just need to update the UI
    }
    
    private func removeFixedEventNotifications() {
        // NotificationService will remove them when scheduleFixedEventNotifications is not called
        // For now, we just need to update the UI
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
