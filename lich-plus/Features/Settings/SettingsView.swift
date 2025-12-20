//
//  SettingsView.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 23/11/25.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @EnvironmentObject var syncService: CalendarSyncService
    @EnvironmentObject var googleAuthService: GoogleAuthService
    @EnvironmentObject var microsoftAuthService: MicrosoftAuthService

    private var syncStatusIcon: String {
        switch syncService.syncState {
        case .syncing:
            return "arrow.triangle.2.circlepath"
        case .error:
            return "exclamationmark.triangle.fill"
        case .idle:
            return syncService.lastSyncDate != nil ? "checkmark.circle.fill" : "minus.circle"
        }
    }

    private var syncStatusColor: Color {
        switch syncService.syncState {
        case .syncing:
            return AppColors.primary
        case .error:
            return .red
        case .idle:
            return syncService.lastSyncDate != nil ? .green : AppColors.secondary
        }
    }

    var body: some View {
        NavigationStack {
            List {
                // Notifications
                NavigationLink {
                    NotificationSettingsView()
                } label: {
                    HStack(spacing: AppTheme.spacing12) {
                        Image(systemName: "bell.badge")
                            .font(.title2)
                            .foregroundStyle(AppColors.primary)
                            .frame(width: 32)

                        VStack(alignment: .leading, spacing: AppTheme.spacing2) {
                            Text(String(localized: "notification.settings.title"))
                                .font(.body)
                                .foregroundStyle(AppColors.textPrimary)

                            Text("Manage reminders and alerts")
                                .font(.caption)
                                .foregroundStyle(AppColors.textSecondary)
                        }

                        Spacer()
                    }
                }
                
                // Sync Section
                Section {
                    NavigationLink {
                        CalendarSyncSettingsView()
                    } label: {
                        HStack(spacing: AppTheme.spacing12) {
                            Image(systemName: "calendar.badge.clock")
                                .font(.title2)
                                .foregroundStyle(AppColors.primary)
                                .frame(width: 32)

                            VStack(alignment: .leading, spacing: AppTheme.spacing2) {
                                Text("Calendar Sync")
                                    .font(.body)
                                    .foregroundStyle(AppColors.textPrimary)

                                Text("Sync with Apple Calendar")
                                    .font(.caption)
                                    .foregroundStyle(AppColors.textSecondary)
                            }

                            Spacer()

                            Image(systemName: syncStatusIcon)
                                .foregroundStyle(syncStatusColor)
                        }
                    }

                    NavigationLink {
                        GoogleCalendarSettingsView()
                    } label: {
                        HStack(spacing: AppTheme.spacing12) {
                            Image(systemName: "g.circle.fill")
                                .font(.title2)
                                .foregroundStyle(Color(red: 0.26, green: 0.52, blue: 0.96)) // Google blue
                                .frame(width: 32)

                            VStack(alignment: .leading, spacing: AppTheme.spacing2) {
                                Text("Google Calendar")
                                    .font(.body)
                                    .foregroundStyle(AppColors.textPrimary)

                                Text(googleAuthService.isSignedIn ? "Connected" : "Not connected")
                                    .font(.caption)
                                    .foregroundStyle(AppColors.textSecondary)
                            }

                            Spacer()
                        }
                    }

                    NavigationLink {
                        MicrosoftCalendarSettingsView()
                    } label: {
                        HStack(spacing: AppTheme.spacing12) {
                            Image(systemName: "m.circle.fill")
                                .font(.title2)
                                .foregroundStyle(Color(red: 0.0, green: 0.47, blue: 0.84)) // Microsoft blue
                                .frame(width: 32)

                            VStack(alignment: .leading, spacing: AppTheme.spacing2) {
                                Text("Outlook Calendar")
                                    .font(.body)
                                    .foregroundStyle(AppColors.textPrimary)

                                Text(microsoftAuthService.isSignedIn ? "Connected" : "Not connected")
                                    .font(.caption)
                                    .foregroundStyle(AppColors.textSecondary)
                            }

                            Spacer()
                        }
                    }

                    NavigationLink {
                        ICSCalendarSettingsView()
                    } label: {
                        HStack(spacing: AppTheme.spacing12) {
                            Image(systemName: "calendar.badge.plus")
                                .font(.title2)
                                .foregroundStyle(AppColors.primary)
                                .frame(width: 32)

                            VStack(alignment: .leading, spacing: AppTheme.spacing2) {
                                Text("ICS Calendar")
                                    .font(.body)
                                    .foregroundStyle(AppColors.textPrimary)

                                Text("Subscribe to calendars")
                                    .font(.caption)
                                    .foregroundStyle(AppColors.textSecondary)
                            }

                            Spacer()
                        }
                    }
                } header: {
                    Text("Sync")
                }

                // About Section
                Section {
                    HStack {
                        Image(systemName: "info.circle")
                            .font(.title2)
                            .foregroundStyle(AppColors.secondary)
                            .frame(width: 32)

                        VStack(alignment: .leading, spacing: AppTheme.spacing2) {
                            Text("Version")
                                .font(.body)
                                .foregroundStyle(AppColors.textPrimary)

                            Text("1.0.0")
                                .font(.caption)
                                .foregroundStyle(AppColors.textSecondary)
                        }

                        Spacer()
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: SyncableEvent.self, SyncedCalendar.self, configurations: config)
    let modelContext = ModelContext(container)

    SettingsView()
        .environmentObject(EventKitService())
        .environmentObject(CalendarSyncService(eventKitService: EventKitService(), modelContext: modelContext))
        .environmentObject(GoogleAuthService())
        .environmentObject(MicrosoftAuthService())
        .modelContainer(container)
}
