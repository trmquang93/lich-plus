//
//  EventsListView.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 23/11/25.
//

import SwiftUI

// MARK: - Events List View

struct EventsListView: View {
    let events: [Event]
    let day: CalendarDay?

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing12) {
            HStack(spacing: AppTheme.spacing8) {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: AppTheme.fontBody, weight: .semibold))
                    .foregroundStyle(AppColors.primary)

                Text("Sự kiện hôm nay")
                    .font(.system(size: AppTheme.fontTitle3, weight: .bold))
                    .foregroundStyle(AppColors.textPrimary)

                Spacer()

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
                EmptyEventsView()
            } else {
                VStack(spacing: AppTheme.spacing8) {
                    ForEach(events) { event in
                        EventRow(event: event)
                    }
                }
            }
        }
        .padding(AppTheme.spacing16)
        .background(AppColors.backgroundLightGray)
        .cornerRadius(AppTheme.cornerRadiusMedium)
        .padding(.horizontal, AppTheme.spacing16)
        .padding(.vertical, AppTheme.spacing8)
    }
}

// MARK: - Event Row

struct EventRow: View {
    let event: Event

    var body: some View {
        HStack(spacing: AppTheme.spacing12) {
            VStack(alignment: .leading, spacing: AppTheme.spacing4) {
                HStack(spacing: AppTheme.spacing8) {
                    Text(event.time)
                        .font(.system(size: AppTheme.fontCaption, weight: .semibold))
                        .foregroundStyle(AppColors.textSecondary)
                        .frame(width: 40)

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
                        .padding(.leading, 40)
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
    var body: some View {
        VStack(spacing: AppTheme.spacing12) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 32, weight: .semibold))
                .foregroundStyle(AppColors.secondary.opacity(0.5))

            VStack(spacing: AppTheme.spacing4) {
                Text("Không có sự kiện nào")
                    .font(.system(size: AppTheme.fontBody, weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)

                Text("Hôm nay là một ngày trống rỗi. Thêm sự kiện mới?")
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
    VStack(spacing: 20) {
        // With events
        EventsListView(
            events: [
                Event(
                    title: "Morning Standup",
                    time: "09:00",
                    category: .meeting,
                    description: "Team sync meeting"
                ),
                Event(
                    title: "Client Call",
                    time: "14:00",
                    category: .work,
                    description: "Quarterly review"
                ),
                Event(
                    title: "Dinner",
                    time: "19:00",
                    category: .personal,
                    description: nil
                ),
            ],
            day: nil
        )

        Divider()

        // Empty state
        EventsListView(
            events: [],
            day: nil
        )

        Spacer()
    }
    .background(AppColors.background)
}
