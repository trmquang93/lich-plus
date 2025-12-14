//
//  TimelineEventBlock.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 13/12/25.
//

import SwiftUI

struct TimelineEventBlock: View {
    let event: TaskItem
    let blockHeight: CGFloat
    let widthFraction: CGFloat
    let isPast: Bool
    let isCurrent: Bool

    // MARK: - Private Properties

    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    // MARK: - Computed Properties

    /// Get category color based on event category
    private var categoryColor: Color {
        event.category.colorValue
    }

    /// Format time range for display (24-hour format)
    private var timeRangeText: String {
        guard let startTime = event.startTime else {
            return String(localized: "event.allDay")
        }

        let startStr = timeFormatter.string(from: startTime)

        // Only show end time if different from start time
        if let endTime = event.endTime,
           timeFormatter.string(from: endTime) != startStr
        {
            let endStr = timeFormatter.string(from: endTime)
            return "\(startStr) - \(endStr)"
        }

        return startStr
    }

    /// Extract location from notes if available
    private var locationText: String? {
        event.location
    }

    /// Determine event state for visual styling
    private var eventState: EventState {
        if event.isCompleted {
            return .completed
        } else if isPast {
            return .past
        } else if isCurrent {
            return .current
        } else {
            return .future
        }
    }

    /// Opacity based on event state
    private var contentOpacity: Double {
        switch eventState {
        case .past:
            return 0.6
        default:
            return 1.0
        }
    }

    /// Text color based on event state
    private var textColor: Color {
        if eventState == .past {
            return AppColors.textSecondary
        } else {
            return AppColors.textPrimary
        }
    }

    // MARK: - View

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Background with category color strip
            EventBlockBackground(
                categoryColor: categoryColor,
                isPast: isPast,
                isCurrent: isCurrent
            )

            // Content
            VStack(alignment: .leading, spacing: AppTheme.spacing4) {
                // Title with category indicator
                HStack(spacing: AppTheme.spacing8) {
                    // Category dot
                    Circle()
                        .fill(categoryColor)
                        .frame(width: AppTheme.categoryDotSize, height: AppTheme.categoryDotSize)

                    // Title
                    VStack(alignment: .leading, spacing: 2) {
                        Text(event.title)
                            .font(.system(size: AppTheme.fontBody, weight: .semibold))
                            .lineLimit(2)
                            .strikethrough(eventState == .completed)
                            .opacity(contentOpacity)

                        if eventState == .completed {
                            // Show checkmark for completed tasks
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(AppColors.accent)
                                Text(String(localized: "task.completed"))
                                    .font(.caption)
                                    .foregroundColor(AppColors.accent)
                            }
                        }
                    }

                    Spacer()
                }

                // Time range
                HStack(spacing: AppTheme.spacing4) {
                    Image(systemName: "clock")
                        .font(.caption2)
                        .foregroundColor(textColor)

                    Text(timeRangeText)
                        .font(.caption)
                        .foregroundColor(textColor)
                }
                .opacity(contentOpacity)

                // Location (if available)
                if let location = locationText, !location.isEmpty {
                    HStack(spacing: AppTheme.spacing4) {
                        Image(systemName: "mappin")
                            .font(.caption2)
                            .foregroundColor(textColor)

                        Text(location)
                            .font(.caption)
                            .foregroundColor(textColor)
                            .lineLimit(1)
                    }
                    .opacity(contentOpacity)
                }
            }
            .padding(AppTheme.spacing12)
        }
        .frame(height: blockHeight)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - EventState Enum

enum EventState {
    case past
    case current
    case future
    case completed
}

// MARK: - Preview

#Preview("TimelineEventBlock - Future Event") {
    let futureDate = Calendar.current.date(byAdding: .hour, value: 2, to: Date())!
    let endDate = Calendar.current.date(byAdding: .minute, value: 60, to: futureDate)!

    let event = TaskItem(
        title: "Team Meeting",
        date: futureDate,
        startTime: futureDate,
        endTime: endDate,
        category: .meeting,
        itemType: .event,
        location: "Room 301"
    )

    TimelineEventBlock(
        event: event,
        blockHeight: 80,
        widthFraction: 1.0,
        isPast: false,
        isCurrent: false
    )
    .padding()
    .background(AppColors.backgroundLightGray)
}

#Preview("TimelineEventBlock - Current Event") {
    let now = Date()
    let endDate = Calendar.current.date(byAdding: .minute, value: 45, to: now)!

    let event = TaskItem(
        title: "Project Review",
        date: now,
        startTime: now,
        endTime: endDate,
        category: .work,
        itemType: .event,
        priority: .none,
        location: "Conference Room B"
    )

    TimelineEventBlock(
        event: event,
        blockHeight: 90,
        widthFraction: 1.0,
        isPast: false,
        isCurrent: true
    )
    .padding()
    .background(AppColors.backgroundLightGray)
}

#Preview("TimelineEventBlock - Past Event") {
    let pastDate = Calendar.current.date(byAdding: .hour, value: -3, to: Date())!
    let endDate = Calendar.current.date(byAdding: .minute, value: 60, to: pastDate)!

    let event = TaskItem(
        title: "Client Call",
        date: pastDate,
        startTime: pastDate,
        endTime: endDate,
        category: .personal,
        itemType: .event
    )

    TimelineEventBlock(
        event: event,
        blockHeight: 80,
        widthFraction: 1.0,
        isPast: true,
        isCurrent: false
    )
    .padding()
    .background(AppColors.backgroundLightGray)
}

#Preview("TimelineEventBlock - Completed Task") {
    let now = Date()
    let endDate = Calendar.current.date(byAdding: .minute, value: 30, to: now)!

    let event = TaskItem(
        title: "Prepare presentation slides",
        date: now,
        startTime: now,
        endTime: endDate,
        category: .work,
        isCompleted: true,
        itemType: .task
    )

    TimelineEventBlock(
        event: event,
        blockHeight: 80,
        widthFraction: 1.0,
        isPast: false,
        isCurrent: false
    )
    .padding()
    .background(AppColors.backgroundLightGray)
}

#Preview("TimelineEventBlock - All Day Event") {
    let now = Date()

    let event = TaskItem(
        title: "Holiday - Tet",
        date: now,
        category: .holiday,
        itemType: .event
    )

    TimelineEventBlock(
        event: event,
        blockHeight: 60,
        widthFraction: 1.0,
        isPast: false,
        isCurrent: false
    )
    .padding()
    .background(AppColors.backgroundLightGray)
}

#Preview("TimelineEventBlock - Long Duration Event") {
    let futureDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
    let endDate = Calendar.current.date(byAdding: .hour, value: 3, to: futureDate)!

    let event = TaskItem(
        title: "Workshop - Swift Concurrency Best Practices",
        date: futureDate,
        startTime: futureDate,
        endTime: endDate,
        category: .personal,
        itemType: .event,
        priority: .none,
        location: "Virtual - Zoom"
    )

    TimelineEventBlock(
        event: event,
        blockHeight: 140,
        widthFraction: 1.0,
        isPast: false,
        isCurrent: false
    )
    .padding()
    .background(AppColors.backgroundLightGray)
}

#Preview("TimelineEventBlock - Concurrent Events (Half Width)") {
    let futureDate = Calendar.current.date(byAdding: .hour, value: 2, to: Date())!
    let endDate = Calendar.current.date(byAdding: .minute, value: 90, to: futureDate)!

    let event = TaskItem(
        title: "Quick Sync",
        date: futureDate,
        startTime: futureDate,
        endTime: endDate,
        category: .meeting,
        itemType: .event
    )

    return HStack(spacing: 0) {
        TimelineEventBlock(
            event: event,
            blockHeight: 100,
            widthFraction: 0.5,
            isPast: false,
            isCurrent: false
        )

        TimelineEventBlock(
            event: TaskItem(
                title: "Design Review",
                date: futureDate,
                startTime: futureDate,
                endTime: endDate,
                category: .work,
                itemType: .event
            ),
            blockHeight: 100,
            widthFraction: 0.5,
            isPast: false,
            isCurrent: false
        )
    }
    .padding()
    .background(AppColors.backgroundLightGray)
}
