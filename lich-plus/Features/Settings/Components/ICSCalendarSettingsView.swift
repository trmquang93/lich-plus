//
//  ICSCalendarSettingsView.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 30/11/25.
//

import SwiftUI
import SwiftData

struct ICSCalendarSettingsView: View {
    @EnvironmentObject var syncService: ICSCalendarSyncService
    @State private var showAddSubscription = false
    @State private var newSubscriptionName = ""
    @State private var newSubscriptionURL = ""
    @State private var errorMessage: String?
    @State private var showError = false

    // MARK: - Computed Properties

    var builtInSubscriptions: [ICSSubscription] {
        syncService.subscriptions.filter { $0.isBuiltIn }
    }

    var userSubscriptions: [ICSSubscription] {
        syncService.subscriptions.filter { !$0.isBuiltIn }
    }

    var body: some View {
        NavigationStack {
            List {
                // Sync Status Section
                Section {
                    HStack(spacing: AppTheme.spacing12) {
                        Image(systemName: syncStatusIcon)
                            .font(.title2)
                            .foregroundStyle(syncStatusColor)
                            .frame(width: 24)

                        VStack(alignment: .leading, spacing: AppTheme.spacing4) {
                            Text(syncStatusText)
                                .font(.body)
                                .foregroundStyle(AppColors.textPrimary)

                            if let lastSync = syncService.lastSyncDate {
                                Text("Last sync: \(formatDate(lastSync))")
                                    .font(.caption)
                                    .foregroundStyle(AppColors.textSecondary)
                            }
                        }

                        Spacer()

                        Button(action: { syncNow() }) {
                            if syncService.syncState == .syncing {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "arrow.clockwise")
                                    .font(.body)
                                    .foregroundStyle(AppColors.primary)
                            }
                        }
                        .disabled(syncService.syncState == .syncing)
                    }
                    .padding(.vertical, AppTheme.spacing8)
                } header: {
                    Text("Sync Status")
                }

                // Built-in Calendars Section
                if !builtInSubscriptions.isEmpty {
                    Section {
                        ForEach(builtInSubscriptions, id: \.id) { subscription in
                            BuiltInSubscriptionRowView(subscription: subscription) {
                                Task {
                                    do {
                                        try await syncService.updateSubscription(subscription, isEnabled: !subscription.isEnabled)
                                    } catch {
                                        errorMessage = error.localizedDescription
                                        showError = true
                                    }
                                }
                            }
                        }
                    } header: {
                        Text("settings.builtInCalendars")
                    }
                }

                // My Calendars Section
                Section {
                    if userSubscriptions.isEmpty && builtInSubscriptions.isEmpty {
                        // Show comprehensive empty state only when both are empty
                        VStack(alignment: .center, spacing: AppTheme.spacing12) {
                            Image(systemName: "calendar.badge.plus")
                                .font(.title)
                                .foregroundStyle(AppColors.secondary)
                                .padding(.top, AppTheme.spacing16)

                            Text("No Calendar Subscriptions")
                                .font(.body)
                                .foregroundStyle(AppColors.textPrimary)

                            Text("Add an ICS calendar URL to get started")
                                .font(.caption)
                                .foregroundStyle(AppColors.textSecondary)
                                .multilineTextAlignment(.center)

                            Button(action: { showAddSubscription = true }) {
                                Text("Add Calendar")
                                    .font(.body)
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, AppTheme.spacing12)
                                    .background(AppColors.primary)
                                    .cornerRadius(AppTheme.cornerRadiusMedium)
                            }
                            .padding(.vertical, AppTheme.spacing8)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppTheme.spacing12)
                    } else if !userSubscriptions.isEmpty {
                        // Show user subscriptions with delete actions
                        ForEach(userSubscriptions, id: \.id) { subscription in
                            SubscriptionRowView(subscription: subscription) {
                                Task {
                                    do {
                                        try await syncService.updateSubscription(subscription, isEnabled: !subscription.isEnabled)
                                    } catch {
                                        errorMessage = error.localizedDescription
                                        showError = true
                                    }
                                }
                            } onDelete: {
                                deleteSubscription(subscription)
                            }
                        }
                    }
                } header: {
                    HStack {
                        Text("settings.myCalendars")
                        Spacer()
                        Button(action: { showAddSubscription = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.body)
                                .foregroundStyle(AppColors.primary)
                        }
                    }
                }

                // Information Section
                Section {
                    VStack(alignment: .leading, spacing: AppTheme.spacing8) {
                        Text("ICS Calendar subscriptions are read-only. Events are automatically synced with your calendar app.")
                            .font(.caption)
                            .foregroundStyle(AppColors.textSecondary)

                        Text("Supported URL formats:")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundStyle(AppColors.textPrimary)
                            .padding(.top, AppTheme.spacing4)

                        VStack(alignment: .leading, spacing: AppTheme.spacing4) {
                            Text("• https://example.com/calendar.ics")
                            Text("• http://calendar-server.com/events.ics")
                        }
                        .font(.caption2)
                        .foregroundStyle(AppColors.textSecondary)
                    }
                    .padding(.vertical, AppTheme.spacing4)
                } header: {
                    Text("Information")
                }
            }
            .navigationTitle("ICS Calendar")
            .sheet(isPresented: $showAddSubscription) {
                AddICSSubscriptionSheet(
                    isPresented: $showAddSubscription,
                    onAdd: { name, url in
                        addSubscription(name: name, url: url)
                    }
                )
            }
            .alert("Error", isPresented: $showError, presenting: errorMessage) { _ in
                Button("OK") { errorMessage = nil }
            } message: { message in
                Text(message)
            }
        }
    }

    // MARK: - Private Methods

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

    private var syncStatusText: String {
        switch syncService.syncState {
        case .syncing:
            return "Syncing calendars..."
        case .error:
            return "Sync failed"
        case .idle:
            return "Sync complete"
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
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

    private func addSubscription(name: String, url: String) {
        Task {
            do {
                try await syncService.addSubscription(name: name, urlString: url)
                showAddSubscription = false
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }

    private func deleteSubscription(_ subscription: ICSSubscription) {
        Task {
            do {
                try await syncService.removeSubscription(subscription)
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

// MARK: - Subscription Row View

struct SubscriptionRowView: View {
    let subscription: ICSSubscription
    let onToggle: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing8) {
            HStack(spacing: AppTheme.spacing12) {
                VStack(alignment: .leading, spacing: AppTheme.spacing2) {
                    Text(subscription.name)
                        .font(.body)
                        .foregroundStyle(AppColors.textPrimary)

                    Text(subscription.url)
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(1)
                }

                Spacer()

                Toggle("", isOn: .constant(subscription.isEnabled))
                    .onChange(of: subscription.isEnabled) {
                        onToggle()
                    }
            }

            if let lastSync = subscription.lastSyncDate {
                Text("Last synced: \(formatDate(lastSync))")
                    .font(.caption2)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .padding(.vertical, AppTheme.spacing8)
        .swipeActions(edge: .trailing) {
            if subscription.isDeletable {
                Button(role: .destructive, action: onDelete) {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Built-In Subscription Row View

struct BuiltInSubscriptionRowView: View {
    let subscription: ICSSubscription
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: AppTheme.spacing12) {
            // Star icon for built-in
            Image(systemName: "star.fill")
                .foregroundStyle(AppColors.primary)
                .font(.body)

            VStack(alignment: .leading, spacing: AppTheme.spacing2) {
                Text(subscription.name)
                    .font(.body)
                    .foregroundStyle(AppColors.textPrimary)

                Text("settings.systemCalendar")
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()

            Toggle("", isOn: .constant(subscription.isEnabled))
                .onChange(of: subscription.isEnabled) {
                    onToggle()
                }
        }
        .padding(.vertical, AppTheme.spacing8)
    }
}

// MARK: - Add ICS Subscription Sheet

struct AddICSSubscriptionSheet: View {
    @Binding var isPresented: Bool
    var onAdd: (String, String) -> Void

    @State private var name = ""
    @State private var url = ""
    @State private var errorMessage: String?
    @State private var showError = false

    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !url.trimmingCharacters(in: .whitespaces).isEmpty &&
        (url.lowercased().starts(with: "http://") || url.lowercased().starts(with: "https://"))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Calendar Name", text: $name)
                        .autocapitalization(.words)

                    TextField("Calendar URL", text: $url)
                        .autocapitalization(.none)
                        .keyboardType(.URL)
                        .textContentType(.URL)
                } header: {
                    Text("Add ICS Calendar")
                }

                Section {
                    Button(action: {
                        if isValid {
                            onAdd(name, url)
                            isPresented = false
                        } else {
                            errorMessage = "Please enter a valid calendar name and HTTPS URL"
                            showError = true
                        }
                    }) {
                        Text("Add Calendar")
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(isValid ? .white : AppColors.secondary)
                    }
                    .disabled(!isValid)
                    .listRowBackground(isValid ? AppColors.primary : AppColors.backgroundLightGray)
                }
            }
            .navigationTitle("Add Calendar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
            .alert("Error", isPresented: $showError, presenting: errorMessage) { _ in
                Button("OK") { errorMessage = nil }
            } message: { message in
                Text(message)
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: SyncableEvent.self, SyncedCalendar.self, ICSSubscription.self,
        configurations: config
    )
    let modelContext = ModelContext(container)

    return ICSCalendarSettingsView()
        .environmentObject(ICSCalendarSyncService(modelContext: modelContext))
        .modelContainer(container)
}
