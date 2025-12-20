//
//  AllDayStrip.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 13/12/25.
//

import SwiftUI

struct AllDayStrip: View {
    let events: [TaskItem]
    let onEventTap: (TaskItem) -> Void
    let onExpand: () -> Void

    // MARK: - Configuration

    private let maxVisibleEvents: Int = 3

    // MARK: - Computed Properties

    private var visibleEvents: [TaskItem] {
        Array(events.prefix(maxVisibleEvents))
    }

    private var hiddenEventCount: Int {
        max(0, events.count - maxVisibleEvents)
    }

    private var isEmpty: Bool {
        events.isEmpty
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: AppTheme.spacing12) {
                // "All Day" label
                VStack {
                    Text(String(localized: "timeline.allDay"))
                        .font(.system(size: AppTheme.fontCaption))
                        .foregroundColor(AppColors.textSecondary)
                    Spacer()
                }
                .frame(width: TimelineConfiguration.rulerWidth - AppTheme.spacing8, alignment: .leading)

                // Events scroll view
                if isEmpty {
                    Text(String(localized: "timeline.noAllDayEvents"))
                        .font(.system(size: AppTheme.fontCaption))
                        .foregroundColor(AppColors.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: AppTheme.spacing12) {
                            // Visible event chips
                            ForEach(visibleEvents, id: \.id) { event in
                                AllDayEventChip(event: event) {
                                    onEventTap(event)
                                }
                            }

                            // "+N more" indicator
                            if hiddenEventCount > 0 {
                                MoreEventsIndicator(count: hiddenEventCount) {
                                    onExpand()
                                }
                            }
                        }
                        .padding(.trailing, AppTheme.spacing12)
                    }
                }

                Spacer()
            }
            .padding(.leading, AppTheme.spacing8)
            .padding(.vertical, AppTheme.spacing8)

            // Divider
            Divider()
                .background(AppColors.borderLight)
        }
        .frame(height: TimelineConfiguration.allDayHeight)
        .background(AppColors.backgroundLightGray)
    }
}

// MARK: - All Day Event Chip Component

struct AllDayEventChip: View {
    let event: TaskItem
    let onTap: () -> Void

    // MARK: - Computed Properties

    private var chipBackground: Color {
        event.category.colorValue.opacity(0.15)
    }

    private var borderColor: Color {
        event.category.colorValue
    }

    // MARK: - Body

    var body: some View {
        HStack(spacing: AppTheme.spacing8) {
            Image(systemName: event.category.icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(borderColor)

            Text(event.title)
                .font(.system(size: AppTheme.fontCaption, weight: .medium))
                .lineLimit(1)
                .foregroundColor(AppColors.textPrimary)
        }
        .padding(.horizontal, AppTheme.spacing12)
        .padding(.vertical, AppTheme.spacing8)
        .background(chipBackground)
        .border(borderColor, width: 3)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium))
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}

// MARK: - More Events Indicator Component

struct MoreEventsIndicator: View {
    let count: Int
    let onTap: () -> Void

    var body: some View {
        HStack(spacing: AppTheme.spacing8) {
            Text("+\(count) more")
                .font(.system(size: AppTheme.fontCaption, weight: .medium))
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(.horizontal, AppTheme.spacing12)
        .padding(.vertical, AppTheme.spacing8)
        .background(AppColors.badgeBackground)
        .border(AppColors.borderLight, width: 1)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium))
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}

// MARK: - Previews

#Preview("Empty State") {
    AllDayStrip(
        events: [],
        onEventTap: { _ in },
        onExpand: {}
    )
    .background(AppColors.background)
}

#Preview("Single Event") {
    AllDayStrip(
        events: [
            TaskItem(
                id: UUID(),
                title: "Sinh nhật Lan",
                date: Date(),
                category: .birthday,
                itemType: .event,
                source: .local
            )
        ],
        onEventTap: { _ in },
        onExpand: {}
    )
    .background(AppColors.background)
}

#Preview("Multiple Events (No Overflow)") {
    AllDayStrip(
        events: [
            TaskItem(
                id: UUID(),
                title: "Sinh nhật Lan",
                date: Date(),
                category: .birthday,
                itemType: .event,
                source: .local
            ),
            TaskItem(
                id: UUID(),
                title: "Hội nghị công ty",
                date: Date(),
                category: .meeting,
                itemType: .event,
                source: .local
            ),
            TaskItem(
                id: UUID(),
                title: "Dự án quan trọng",
                date: Date(),
                category: .work,
                itemType: .event,
                source: .local
            )
        ],
        onEventTap: { _ in },
        onExpand: {}
    )
    .background(AppColors.background)
}

#Preview("Overflow (5 Events)") {
    AllDayStrip(
        events: [
            TaskItem(
                id: UUID(),
                title: "Sinh nhật Lan",
                date: Date(),
                category: .birthday,
                itemType: .event,
                source: .local
            ),
            TaskItem(
                id: UUID(),
                title: "Hội nghị công ty",
                date: Date(),
                category: .meeting,
                itemType: .event,
                source: .local
            ),
            TaskItem(
                id: UUID(),
                title: "Dự án quan trọng",
                date: Date(),
                category: .work,
                itemType: .event,
                source: .local
            ),
            TaskItem(
                id: UUID(),
                title: "Công việc cá nhân",
                date: Date(),
                category: .personal,
                itemType: .event,
                source: .local
            ),
            TaskItem(
                id: UUID(),
                title: "Ngày lễ quốc gia",
                date: Date(),
                category: .holiday,
                itemType: .event,
                source: .local
            )
        ],
        onEventTap: { _ in },
        onExpand: {}
    )
    .background(AppColors.background)
}

#Preview("Long Titles (Truncation)") {
    AllDayStrip(
        events: [
            TaskItem(
                id: UUID(),
                title: "Hội nghị kế hoạch chiến lược công ty năm 2025",
                date: Date(),
                category: .work,
                itemType: .event,
                source: .local
            ),
            TaskItem(
                id: UUID(),
                title: "Sinh nhật của em gái tôi",
                date: Date(),
                category: .birthday,
                itemType: .event,
                source: .local
            )
        ],
        onEventTap: { _ in },
        onExpand: {}
    )
    .background(AppColors.background)
}

#Preview("All Categories") {
    AllDayStrip(
        events: [
            TaskItem(
                id: UUID(),
                title: "Công việc",
                date: Date(),
                category: .work,
                itemType: .event,
                source: .local
            ),
            TaskItem(
                id: UUID(),
                title: "Cá nhân",
                date: Date(),
                category: .personal,
                itemType: .event,
                source: .local
            ),
            TaskItem(
                id: UUID(),
                title: "Sinh nhật",
                date: Date(),
                category: .birthday,
                itemType: .event,
                source: .local
            ),
            TaskItem(
                id: UUID(),
                title: "Ngày lễ",
                date: Date(),
                category: .holiday,
                itemType: .event,
                source: .local
            ),
            TaskItem(
                id: UUID(),
                title: "Cuộc họp",
                date: Date(),
                category: .meeting,
                itemType: .event,
                source: .local
            ),
            TaskItem(
                id: UUID(),
                title: "Khác",
                date: Date(),
                category: .other,
                itemType: .event,
                source: .local
            )
        ],
        onEventTap: { _ in },
        onExpand: {}
    )
    .background(AppColors.background)
}
