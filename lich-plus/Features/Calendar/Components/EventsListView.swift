//
//  EventsListView.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 23/11/25.
//

import SwiftUI
import SwiftData

// MARK: - Events List View

struct EventsListView: View {
    let events: [Event]
    let day: CalendarDay?
    let onEventTap: ((Event) -> Void)?

    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var syncService: CalendarSyncService

    @State private var showAddEventSheet: Bool = false

    init(events: [Event], day: CalendarDay?, onEventTap: ((Event) -> Void)? = nil) {
        self.events = events
        self.day = day
        self.onEventTap = onEventTap
    }

    private var sectionTitle: String {
        if day?.isToday == true {
            return "Sự kiện hôm nay"
        } else if let day = day {
            return "Sự kiện ngày \(day.solarDay)/\(day.solarMonth)"
        } else {
            return "Sự kiện"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing12) {
            HStack(spacing: AppTheme.spacing8) {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: AppTheme.fontBody, weight: .semibold))
                    .foregroundStyle(AppColors.primary)

                Text(sectionTitle)
                    .font(.system(size: AppTheme.fontTitle3, weight: .bold))
                    .foregroundStyle(AppColors.textPrimary)

                Spacer()

                Button(action: { showAddEventSheet = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(AppColors.primary)
                }

                if !events.isEmpty {
                    Text(String(events.count))
                        .font(.system(size: AppTheme.fontCaption, weight: .semibold))
                        .foregroundStyle(AppColors.white)
                        .frame(width: 20, height: 20)
                        .background(AppColors.primary)
                        .clipShape(Circle())
                }
            }

            if events.isEmpty {
                EmptyEventsView(day: day)
            } else {
                VStack(spacing: AppTheme.spacing8) {
                    ForEach(events) { event in
                        EventRow(event: event)
                            .onTapGesture {
                                onEventTap?(event)
                            }
                    }
                }
            }
        }
        .padding(AppTheme.spacing16)
        .background(AppColors.backgroundLightGray)
        .cornerRadius(AppTheme.cornerRadiusMedium)
        .padding(.horizontal, AppTheme.spacing16)
        .padding(.vertical, AppTheme.spacing8)
        .sheet(isPresented: $showAddEventSheet) {
            CreateItemSheet(
                initialItemType: .event,
                onSave: { _ in
                    showAddEventSheet = false
                }
            )
            .environmentObject(syncService)
            .modelContext(modelContext)
        }
    }
}

// MARK: - Event Row

struct EventRow: View {
    let event: Event

    var body: some View {
        HStack(spacing: AppTheme.spacing12) {
            VStack(alignment: .leading, spacing: AppTheme.spacing4) {
                HStack(spacing: AppTheme.spacing8) {
                    if event.isAllDay {
                        Text(String(localized: "event.allDay"))
                            .font(.system(size: AppTheme.fontCaption, weight: .semibold))
                            .foregroundStyle(AppColors.primary)
                            .frame(width: 60, alignment: .leading)
                    } else {
                        Text(event.time ?? "")
                            .font(.system(size: AppTheme.fontCaption, weight: .semibold))
                            .foregroundStyle(AppColors.textSecondary)
                            .frame(width: 40, alignment: .leading)
                    }

                    Text(event.title)
                        .font(.system(size: AppTheme.fontBody, weight: .semibold))
                        .foregroundStyle(AppColors.textPrimary)

                    Spacer()

                    Text(event.category.rawValue)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(AppColors.white)
                        .padding(.horizontal, AppTheme.spacing8)
                        .padding(.vertical, 2)
                        .background(categoryColor)
                        .cornerRadius(4)
                }

                if let description = event.description {
                    Text(description)
                        .font(.system(size: AppTheme.fontCaption, weight: .regular))
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(2)
                        .padding(.leading, event.isAllDay ? 68 : 40)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppColors.secondary)
        }
        .padding(AppTheme.spacing12)
        .background(AppColors.white)
        .cornerRadius(AppTheme.cornerRadiusSmall)
    }

    private var categoryColor: Color {
        switch event.category {
        case .work:
            return AppColors.primary
        case .personal:
            return AppColors.eventBlue
        case .birthday:
            return AppColors.eventPink
        case .holiday:
            return AppColors.eventOrange
        case .meeting:
            return AppColors.accent
        case .other:
            return AppColors.secondary
        }
    }
}

// MARK: - Empty Events View

struct EmptyEventsView: View {
    let day: CalendarDay?

    private var emptyMessage: String {
        if day?.isToday == true {
            return "Hôm nay là một ngày trống rỗi. Thêm sự kiện mới?"
        } else if let day = day {
            return "Ngày \(day.solarDay)/\(day.solarMonth) không có sự kiện. Thêm sự kiện mới?"
        } else {
            return "Không có sự kiện. Thêm sự kiện mới?"
        }
    }

    var body: some View {
        VStack(spacing: AppTheme.spacing12) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 32, weight: .semibold))
                .foregroundStyle(AppColors.secondary.opacity(0.5))

            VStack(spacing: AppTheme.spacing4) {
                Text("Không có sự kiện nào")
                    .font(.system(size: AppTheme.fontBody, weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)

                Text(emptyMessage)
                    .font(.system(size: AppTheme.fontCaption, weight: .regular))
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(AppTheme.spacing24)
        .background(AppColors.white)
        .cornerRadius(AppTheme.cornerRadiusSmall)
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

    VStack(spacing: 20) {
        // With events (including all-day)
        EventsListView(
            events: [
                Event(
                    syncableEventId: nil,
                    title: "Holiday",
                    time: nil,
                    isAllDay: true,
                    category: .holiday,
                    description: "Tet Holiday"
                ),
                Event(
                    syncableEventId: nil,
                    title: "Morning Standup",
                    time: "09:00",
                    isAllDay: false,
                    category: .meeting,
                    description: "Team sync meeting"
                ),
                Event(
                    syncableEventId: nil,
                    title: "Client Call",
                    time: "14:00",
                    isAllDay: false,
                    category: .work,
                    description: "Quarterly review"
                ),
                Event(
                    syncableEventId: nil,
                    title: "Dinner",
                    time: "19:00",
                    isAllDay: false,
                    category: .personal,
                    description: nil
                ),
            ],
            day: CalendarDay(
                date: Date(),
                solarDay: 27,
                solarMonth: 11,
                solarYear: 2025,
                lunarDay: 27,
                lunarMonth: 10,
                lunarYear: 2025,
                dayType: .good,
                isCurrentMonth: true,
                isToday: true,
                events: [],
                isWeekend: false
            )
        )

        Divider()

        // Empty state
        EventsListView(
            events: [],
            day: CalendarDay(
                date: Date(),
                solarDay: 27,
                solarMonth: 11,
                solarYear: 2025,
                lunarDay: 27,
                lunarMonth: 10,
                lunarYear: 2025,
                dayType: .neutral,
                isCurrentMonth: true,
                isToday: false,
                events: [],
                isWeekend: false
            )
        )

        Spacer()
    }
    .background(AppColors.background)
    .environmentObject(syncService)
    .modelContext(modelContext)
}
