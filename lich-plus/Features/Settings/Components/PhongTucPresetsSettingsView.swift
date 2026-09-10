//
//  PhongTucPresetsSettingsView.swift
//  lich-plus
//
//  First-class presets for Rằm, Mùng 1, and ngày chay reminders.
//

import SwiftUI
import SwiftData

struct PhongTucPresetsSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var notificationService: NotificationService

    @State private var settings: NotificationSettings?

    var body: some View {
        List {
            Section {
                Text(String(localized: "Automatic monthly reminders for traditional lunar days. No need to create recurring events by hand."))
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }

            if let settingsValue = settings {
                Section(String(localized: "Monthly lunar days")) {
                    presetToggle(
                        title: String(localized: "Mùng 1 reminders"),
                        subtitle: String(localized: "1st day of each lunar month"),
                        isOn: Binding(
                            get: { settingsValue.mung1NotificationsEnabled },
                            set: { updateMung1($0, settingsValue) }
                        )
                    )

                    presetToggle(
                        title: String(localized: "Rằm reminders"),
                        subtitle: String(localized: "15th day of each lunar month"),
                        isOn: Binding(
                            get: { settingsValue.ramNotificationsEnabled },
                            set: { updateRam($0, settingsValue) }
                        )
                    )

                    presetToggle(
                        title: String(localized: "Ngày chay night-before"),
                        subtitle: String(localized: "Remind the evening before Mùng 1 or Rằm"),
                        isOn: Binding(
                            get: { settingsValue.ngayChayNotificationsEnabled },
                            set: { updateNgayChay($0, settingsValue) }
                        )
                    )
                }

                Section(String(localized: "Giỗ from Personal Profile")) {
                    presetToggle(
                        title: String(localized: "Giỗ reminders"),
                        subtitle: String(localized: "7, 3, and 1 days before each giỗ"),
                        isOn: Binding(
                            get: { settingsValue.gioNotificationsEnabled },
                            set: { updateGio($0, settingsValue) }
                        )
                    )

                    NavigationLink {
                        PersonalProfileView()
                    } label: {
                        Label(String(localized: "Manage deceased relatives"), systemImage: "person.2")
                    }
                }

                Section(String(localized: "Calendar events")) {
                    NavigationLink {
                        let service = LunarSpecialDateService(modelContext: modelContext)
                        let viewModel = LunarSpecialDatesViewModel(service: service)
                        LunarSpecialDatesSettingsView(viewModel: viewModel)
                    } label: {
                        Label(String(localized: "Add Mùng 1 / Rằm to calendar"), systemImage: "moon.stars")
                    }
                }
            }
        }
        .navigationTitle(String(localized: "Phong tục presets"))
        .onAppear {
            settings = notificationService.getSettings()
            AnalyticsService.shared.logFeatureUsed(.gio_reminder_preset)
        }
        .trackAnalyticsScreen(.phong_tuc_presets)
    }

    @ViewBuilder
    private func presetToggle(title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            VStack(alignment: .leading, spacing: AppTheme.spacing2) {
                Text(title)
                    .foregroundStyle(AppColors.textPrimary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
    }

    private func save(_ settings: NotificationSettings) {
        notificationService.updateSettings(settings)
    }

    private func updateMung1(_ enabled: Bool, _ settings: NotificationSettings) {
        settings.mung1NotificationsEnabled = enabled
        save(settings)
        Task {
            if enabled { await notificationService.scheduleMung1Notifications() }
            else { await notificationService.removeAllMung1Notifications() }
        }
    }

    private func updateRam(_ enabled: Bool, _ settings: NotificationSettings) {
        settings.ramNotificationsEnabled = enabled
        save(settings)
        Task {
            if enabled { await notificationService.scheduleRamNotifications() }
            else { await notificationService.removeAllRamNotifications() }
        }
    }

    private func updateNgayChay(_ enabled: Bool, _ settings: NotificationSettings) {
        settings.ngayChayNotificationsEnabled = enabled
        save(settings)
        Task {
            if enabled { await notificationService.scheduleNgayChayNotifications() }
            else { await notificationService.removeAllNgayChayNotifications() }
        }
    }

    private func updateGio(_ enabled: Bool, _ settings: NotificationSettings) {
        settings.gioNotificationsEnabled = enabled
        save(settings)
        Task {
            if enabled { await notificationService.scheduleGioNotifications() }
            else { await notificationService.removeAllGioNotifications() }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: NotificationSettings.self, configurations: config)
    let modelContext = ModelContext(container)

    NavigationStack {
        PhongTucPresetsSettingsView()
            .environmentObject(NotificationService(modelContext: modelContext))
            .modelContainer(container)
    }
}
