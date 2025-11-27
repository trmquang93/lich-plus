//
//  GoogleCalendarPickerView.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 28/11/25.
//

import SwiftUI
import SwiftData

struct GoogleCalendarPickerView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var syncService: GoogleCalendarSyncService

    @Query(filter: #Predicate<SyncedCalendar> { $0.source == "googleCalendar" })
    private var calendars: [SyncedCalendar]

    @State private var isRefreshing = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            List {
                if calendars.isEmpty {
                    emptyStateSection
                } else {
                    calendarsSection
                }
            }
            .navigationTitle("Google Calendars")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        refreshCalendars()
                    } label: {
                        if isRefreshing {
                            ProgressView()
                        } else {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                    .disabled(isRefreshing)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateSection: some View {
        Section {
            VStack(spacing: AppTheme.spacing16) {
                Image(systemName: "calendar")
                    .font(.system(size: 40))
                    .foregroundStyle(AppColors.textSecondary)

                Text("No calendars found")
                    .font(.headline)
                    .foregroundStyle(AppColors.textPrimary)

                Text("Tap the refresh button to fetch your Google calendars.")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)

                Button {
                    refreshCalendars()
                } label: {
                    HStack {
                        if isRefreshing {
                            ProgressView()
                                .tint(.white)
                        }
                        Text(isRefreshing ? "Loading..." : "Refresh Calendars")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppTheme.spacing12)
                }
                .buttonStyle(.borderedProminent)
                .tint(AppColors.primary)
                .disabled(isRefreshing)
            }
            .padding(.vertical, AppTheme.spacing24)
        }
    }

    // MARK: - Calendars List

    private var calendarsSection: some View {
        Section {
            ForEach(calendars, id: \.calendarIdentifier) { calendar in
                calendarRow(calendar)
            }
        } header: {
            Text("Available Calendars")
        } footer: {
            Text("Enable the calendars you want to display in this app. Changes are saved automatically.")
        }
    }

    private func calendarRow(_ calendar: SyncedCalendar) -> some View {
        Toggle(isOn: Binding(
            get: { calendar.isEnabled },
            set: { newValue in
                calendar.isEnabled = newValue
                try? modelContext.save()

                // Trigger sync if enabling a calendar
                if newValue {
                    Task {
                        try? await syncService.pullRemoteChanges()
                    }
                }
            }
        )) {
            HStack(spacing: AppTheme.spacing12) {
                Circle()
                    .fill(Color(hex: calendar.colorHex) ?? AppColors.primary)
                    .frame(width: 12, height: 12)

                Text(calendar.title)
                    .foregroundStyle(AppColors.textPrimary)
            }
        }
        .tint(AppColors.primary)
    }

    // MARK: - Actions

    private func refreshCalendars() {
        isRefreshing = true
        Task {
            do {
                _ = try await syncService.refreshCalendarList()
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
            isRefreshing = false
        }
    }
}

// MARK: - Color Extension for Hex

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.hasPrefix("#") ? String(hexSanitized.dropFirst()) : hexSanitized

        guard hexSanitized.count == 6,
              let rgb = UInt64(hexSanitized, radix: 16) else {
            return nil
        }

        self.init(
            red: Double((rgb & 0xFF0000) >> 16) / 255.0,
            green: Double((rgb & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgb & 0x0000FF) / 255.0
        )
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: SyncedCalendar.self, configurations: config)
    let modelContext = ModelContext(container)
    let authService = GoogleAuthService()
    let calendarService = GoogleCalendarService(authService: authService)

    NavigationStack {
        GoogleCalendarPickerView()
            .environmentObject(GoogleCalendarSyncService(
                authService: authService,
                calendarService: calendarService,
                modelContext: modelContext
            ))
            .modelContainer(container)
    }
}
