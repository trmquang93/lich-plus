//
//  CalendarSyncSettingsView.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 25/11/25.
//

import SwiftUI
import EventKit
import SwiftData

struct CalendarSyncSettingsView: View {
    @EnvironmentObject var eventKitService: EventKitService
    @EnvironmentObject var syncService: CalendarSyncService
    @Query var syncedCalendars: [SyncedCalendar]

    private var isAuthorized: Bool {
        eventKitService.authorizationStatus == .fullAccess
    }

    private var isDenied: Bool {
        eventKitService.authorizationStatus == .denied
    }

    private var selectedCalendarCount: Int {
        syncedCalendars.filter { $0.isEnabled }.count
    }

    private func requestAccess() async {
        let _ = await eventKitService.requestFullAccess()
    }

    private func performFullSync() {
        Task {
            do {
                try await syncService.performFullSync()
            } catch {
                // Error is already handled by syncService.syncError
            }
        }
    }

    private func importFromAppleCalendar() {
        Task {
            do {
                try await syncService.pullRemoteChanges()
            } catch {
                // Error is already handled by syncService.syncError
            }
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if !isAuthorized {
                    // Permission Section
                    Section {
                        VStack(spacing: AppTheme.spacing12) {
                            Image(systemName: "calendar.badge.exclamationmark")
                                .font(.title)
                                .foregroundStyle(AppColors.primary)

                            Text("Calendar Access Required")
                                .font(.headline)
                                .foregroundStyle(AppColors.textPrimary)

                            Text("To sync events with Apple Calendar, we need permission to access your calendars.")
                                .font(.caption)
                                .foregroundStyle(AppColors.textSecondary)
                                .multilineTextAlignment(.center)

                            if isDenied {
                                Text("You previously denied calendar access. Please enable it in Settings.")
                                    .font(.caption)
                                    .foregroundStyle(Color.red)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(AppTheme.spacing12)
                        .frame(maxWidth: .infinity)
                    }

                    Section {
                        Button(action: {
                            Task {
                                await requestAccess()
                            }
                        }) {
                            HStack {
                                Spacer()
                                Text("Grant Access")
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            .foregroundStyle(.white)
                        }
                        .listRowBackground(AppColors.primary)

                        if isDenied {
                            Link(destination: URL(string: UIApplication.openSettingsURLString)!) {
                                HStack {
                                    Image(systemName: "gear")
                                    Text("Open Settings")
                                }
                                .foregroundStyle(AppColors.primary)
                            }
                        }
                    }
                } else {
                    // Sync Status Section
                    Section("Sync Status") {
                        let statusValue: SyncStatusBadge.Status = {
                            switch syncService.syncState {
                            case .syncing:
                                return .syncing
                            case .error:
                                return .error
                            case .idle:
                                return syncService.lastSyncDate != nil ? .synced : .disabled
                            }
                        }()

                        SyncStatusBadge(status: statusValue, lastSyncDate: syncService.lastSyncDate)

                        if let error = syncService.syncError {
                            HStack {
                                Image(systemName: "exclamationmark.circle")
                                    .foregroundStyle(Color.red)
                                VStack(alignment: .leading, spacing: AppTheme.spacing2) {
                                    Text("Sync Error")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(Color.red)
                                    Text(error.localizedDescription)
                                        .font(.caption2)
                                        .foregroundStyle(Color.red)
                                }
                                Spacer()
                            }
                        }

                        Button(action: performFullSync) {
                            HStack {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                Text("Sync Now")
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundStyle(AppColors.primary)
                        }
                        .disabled(syncService.syncState == .syncing)

                        Button(action: importFromAppleCalendar) {
                            HStack {
                                Image(systemName: "arrow.down.circle")
                                Text("Import from Apple Calendar")
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundStyle(AppColors.primary)
                        }
                        .disabled(syncService.syncState == .syncing)
                    }

                    // Calendar Selection Section
                    Section("Calendars to Sync") {
                        NavigationLink {
                            CalendarPickerView()
                        } label: {
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundStyle(AppColors.primary)

                                VStack(alignment: .leading, spacing: AppTheme.spacing2) {
                                    Text("Select Calendars")
                                        .foregroundStyle(AppColors.textPrimary)

                                    Text("\(selectedCalendarCount) calendar\(selectedCalendarCount == 1 ? "" : "s") selected")
                                        .font(.caption)
                                        .foregroundStyle(AppColors.textSecondary)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .foregroundStyle(AppColors.secondary)
                            }
                        }
                    }

                    // Sync Options Section
                    Section {
                        HStack {
                            VStack(alignment: .leading, spacing: AppTheme.spacing4) {
                                Text("Background Sync")
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundStyle(AppColors.textPrimary)

                                Text("Automatically sync calendar changes")
                                    .font(.caption)
                                    .foregroundStyle(AppColors.textSecondary)
                            }

                            Spacer()

                            Toggle("", isOn: .constant(false))
                                .tint(AppColors.primary)
                                .disabled(true)
                        }
                    } footer: {
                        Text("Background sync feature coming soon")
                            .font(.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
            }
            .navigationTitle("Calendar Sync")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: SyncableEvent.self, SyncedCalendar.self, configurations: config)
    let modelContext = ModelContext(container)

    CalendarSyncSettingsView()
        .environmentObject(EventKitService())
        .environmentObject(CalendarSyncService(eventKitService: EventKitService(), modelContext: modelContext))
        .modelContainer(container)
}
