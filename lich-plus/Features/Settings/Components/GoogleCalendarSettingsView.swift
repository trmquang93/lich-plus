//
//  GoogleCalendarSettingsView.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 28/11/25.
//

import SwiftUI
import SwiftData

struct GoogleCalendarSettingsView: View {
    @EnvironmentObject var authService: GoogleAuthService
    @EnvironmentObject var syncService: GoogleCalendarSyncService

    @State private var isSigningIn = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            List {
                if authService.isSignedIn {
                    connectedSection
                    syncStatusSection
                    calendarsSection
                    disconnectSection
                } else {
                    notConnectedSection
                }
            }
            .navigationTitle("Google Calendar")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    // MARK: - Not Connected State

    private var notConnectedSection: some View {
        Section {
            VStack(spacing: AppTheme.spacing16) {
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 48))
                    .foregroundStyle(AppColors.primary)

                Text("Connect your Google account to sync your Google Calendar events with this app.")
                    .font(.body)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)

                Button {
                    signIn()
                } label: {
                    HStack(spacing: AppTheme.spacing8) {
                        if isSigningIn {
                            ProgressView()
                                .tint(.white)
                        }
                        Text(isSigningIn ? "Signing in..." : "Connect with Google")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppTheme.spacing12)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(red: 0.26, green: 0.52, blue: 0.96)) // Google blue
                .disabled(isSigningIn)
            }
            .padding(.vertical, AppTheme.spacing16)
        }
    }

    // MARK: - Connected State

    private var connectedSection: some View {
        Section {
            HStack(spacing: AppTheme.spacing12) {
                Image(systemName: "person.circle.fill")
                    .font(.title)
                    .foregroundStyle(AppColors.textSecondary)

                VStack(alignment: .leading, spacing: AppTheme.spacing2) {
                    Text("Signed in as")
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                    Text(authService.userEmail ?? "Unknown")
                        .font(.body)
                        .foregroundStyle(AppColors.textPrimary)
                }
            }
        } header: {
            Text("Account")
        }
    }

    private var syncStatusSection: some View {
        Section {
            HStack {
                Text("Status")
                Spacer()
                syncStatusBadge
            }

            if let lastSync = syncService.lastSyncDate {
                HStack {
                    Text("Last synced")
                    Spacer()
                    Text(lastSync, style: .relative)
                        .foregroundStyle(AppColors.textSecondary)
                }
            }

            Button {
                syncNow()
            } label: {
                HStack {
                    Image(systemName: "arrow.triangle.2.circlepath")
                    Text("Sync Now")
                }
            }
            .disabled(syncService.syncState == .syncing)
        } header: {
            Text("Sync")
        }
    }

    private var syncStatusBadge: some View {
        HStack(spacing: AppTheme.spacing4) {
            switch syncService.syncState {
            case .idle:
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                Text("Synced")
                    .foregroundStyle(.green)
            case .syncing:
                ProgressView()
                    .scaleEffect(0.8)
                Text("Syncing...")
                    .foregroundStyle(AppColors.textSecondary)
            case .error:
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
                Text("Error")
                    .foregroundStyle(.red)
            }
        }
        .font(.subheadline)
    }

    private var calendarsSection: some View {
        Section {
            NavigationLink {
                GoogleCalendarPickerView()
            } label: {
                HStack {
                    Text("Select Calendars")
                    Spacer()
                    Text(enabledCalendarCount)
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
        } header: {
            Text("Calendars")
        } footer: {
            Text("Choose which Google calendars to display in this app.")
        }
    }

    private var disconnectSection: some View {
        Section {
            Button(role: .destructive) {
                disconnect()
            } label: {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text("Disconnect Google Account")
                }
            }
        } footer: {
            Text("This will remove all synced Google Calendar events from this app.")
        }
    }

    // MARK: - Computed Properties

    private var enabledCalendarCount: String {
        do {
            let calendars = try syncService.getEnabledGoogleCalendars()
            return "\(calendars.count) selected"
        } catch {
            return "0 selected"
        }
    }

    // MARK: - Actions

    private func signIn() {
        isSigningIn = true
        Task {
            do {
                try await authService.signIn()
                // After sign-in, refresh calendar list
                _ = try await syncService.refreshCalendarList()
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
            isSigningIn = false
        }
    }

    private func syncNow() {
        Task {
            do {
                try await syncService.pullRemoteChanges()
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }

    private func disconnect() {
        Task {
            do {
                try syncService.deleteAllGoogleData()
                authService.signOut()
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: SyncedCalendar.self, SyncableEvent.self, configurations: config)
    let modelContext = ModelContext(container)
    let authService = GoogleAuthService()
    let calendarService = GoogleCalendarService(authService: authService)

    NavigationStack {
        GoogleCalendarSettingsView()
            .environmentObject(authService)
            .environmentObject(GoogleCalendarSyncService(
                authService: authService,
                calendarService: calendarService,
                modelContext: modelContext
            ))
            .modelContainer(container)
    }
}
