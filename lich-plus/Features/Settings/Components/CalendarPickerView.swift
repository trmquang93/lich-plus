//
//  CalendarPickerView.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 25/11/25.
//

import SwiftUI
import EventKit
import SwiftData

struct CalendarPickerView: View {
    @EnvironmentObject var eventKitService: EventKitService
    @Environment(\.modelContext) var modelContext
    @Query var syncedCalendars: [SyncedCalendar]

    private var groupedCalendars: [String: [EKCalendar]] {
        Dictionary(grouping: eventKitService.availableCalendars) { calendar in
            calendar.source?.title ?? "Other"
        }
    }

    private func getSyncStatus(for calendar: EKCalendar) -> Bool {
        syncedCalendars.first { $0.calendarIdentifier == calendar.calendarIdentifier }?.isEnabled ?? false
    }

    private func toggleCalendarSync(calendar: EKCalendar) {
        let identifier = calendar.calendarIdentifier
        let accountName = calendar.source?.title

        if let existing = syncedCalendars.first(where: { $0.calendarIdentifier == identifier }) {
            // Update existing
            existing.isEnabled.toggle()
        } else {
            // Create new
            let colorHex = colorToHex(calendar.cgColor)
            let newSync = SyncedCalendar(
                calendarIdentifier: identifier,
                title: calendar.title,
                colorHex: colorHex,
                isEnabled: true,
                accountName: accountName
            )
            modelContext.insert(newSync)
        }
        do {
            try modelContext.save()
        } catch {
            print("Failed to save calendar sync status: \(error)")
        }
    }

    private func colorToHex(_ color: CGColor) -> String {
        guard let components = color.components, components.count >= 3 else {
            return "#FF0000"
        }
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }

    var body: some View {
        NavigationStack {
            List {
                if eventKitService.availableCalendars.isEmpty {
                    Section {
                        VStack(spacing: AppTheme.spacing12) {
                            Image(systemName: "calendar")
                                .font(.title)
                                .foregroundStyle(AppColors.secondary)

                            Text("No Calendars Found")
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundStyle(AppColors.textPrimary)

                            Text("You don't have any calendars available for syncing.")
                                .font(.caption)
                                .foregroundStyle(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(AppTheme.spacing12)
                        .frame(maxWidth: .infinity)
                    }
                } else {
                    ForEach(Array(groupedCalendars.sorted { $0.key < $1.key }), id: \.key) { accountName, calendars in
                        Section(header: Text(accountName)) {
                            ForEach(calendars, id: \.calendarIdentifier) { calendar in
                                HStack(spacing: AppTheme.spacing12) {
                                    // Color indicator
                                    Circle()
                                        .fill(Color(cgColor: calendar.cgColor))
                                        .frame(width: 12, height: 12)

                                    // Calendar title
                                    VStack(alignment: .leading, spacing: AppTheme.spacing2) {
                                        Text(calendar.title)
                                            .font(.body)
                                            .fontWeight(.medium)
                                            .foregroundStyle(AppColors.textPrimary)

                                        if let source = calendar.source?.title {
                                            Text(source)
                                                .font(.caption)
                                                .foregroundStyle(AppColors.textSecondary)
                                        }
                                    }

                                    Spacer()

                                    // Toggle switch
                                    Toggle(
                                        "",
                                        isOn: Binding(
                                            get: { getSyncStatus(for: calendar) },
                                            set: { _ in toggleCalendarSync(calendar: calendar) }
                                        )
                                    )
                                    .tint(AppColors.primary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Calendars")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    CalendarPickerView()
        .environmentObject(EventKitService())
}
