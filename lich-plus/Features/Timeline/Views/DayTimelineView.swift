//
//  DayTimelineView.swift
//  lich-plus
//
//  Main timeline orchestrator for displaying events in a single day with
//  time grid, event positioning, and now indicator.
//

import SwiftUI

struct DayTimelineView: View {
    let date: Date
    let events: [TaskItem]
    let hoangDaoHours: Set<Int>
    let onEventTap: (TaskItem) -> Void
    let onAddEvent: (Date) -> Void
    let onToggleCompletion: (TaskItem) -> Void

    @State private var configuration = TimelineConfiguration()
    @State private var hasScrolledToNow = false
    @State private var currentTime = Date()

    private let calendar = Calendar.current

    var body: some View {
        VStack(spacing: 0) {
            // Header (placeholder)
            TimelineDayHeaderPlaceholder(date: date)
            .onAppear {
                // Initialize currentTime and set up periodic updates
                currentTime = Date()
                scheduleTimeUpdates()
            }

            // All-day strip (placeholder)
            AllDayStripPlaceholder(events: allDayEvents)

            // Main timeline with events
            ScrollViewReader { proxy in
                ScrollView {
                    HStack(spacing: 0) {
                        // Time ruler (left side - fixed width)
                        TimeRulerView(
                            hourHeight: configuration.hourHeight,
                            auspiciousHours: hoangDaoHours,
                            currentHour: calendar.component(.hour, from: currentTime)
                        )
                        .frame(width: TimelineConfiguration.rulerWidth)

                        // Event area (right side - flexible)
                        ZStack(alignment: .topLeading) {
                            // Grid lines background
                            TimelineGridLines(hourHeight: configuration.hourHeight)

                            // Event blocks positioned and layered
                            ForEach(positionedEventsWithState, id: \.event.id) { positionedEvent in
                                positionedEventView(for: positionedEvent)
                            }

                            // Now indicator (positioned on timeline)
                            if isNowIndicatorVisible {
                                NowIndicator()
                                    .offset(y: nowIndicatorY)
                                    .id("nowIndicator")
                            }
                        }
                    }
                }
                .onAppear {
                    if !hasScrolledToNow && isNowIndicatorVisible {
                        // Use async dispatch to break the synchronous loop and allow layout to settle
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                proxy.scrollTo("nowIndicator", anchor: .center)
                            }
                            hasScrolledToNow = true
                        }
                    }
                }
            }
        }
    }

    // MARK: - View Builders

    @ViewBuilder
    private func positionedEventView(for positionedEvent: PositionedEventWithState) -> some View {
        TimelineEventBlock(
            event: positionedEvent.event,
            blockHeight: positionedEvent.height,
            widthFraction: positionedEvent.widthFraction,
            isPast: positionedEvent.isPast,
            isCurrent: positionedEvent.isCurrent
        )
        .frame(width: availableEventWidth * positionedEvent.widthFraction)
        .offset(
            x: availableEventWidth * positionedEvent.xOffset,
            y: positionedEvent.yStart
        )
        .onTapGesture {
            onEventTap(positionedEvent.event)
        }
    }

    // MARK: - Computed Properties

    private var allDayEvents: [TaskItem] {
        events.filter { $0.isAllDay }
    }

    private var timedEvents: [TaskItem] {
        events.filter { !$0.isAllDay }
    }

    private var positionedEvents: [PositionedEvent] {
        let converter = TimeToPixelConverter(hourHeight: configuration.hourHeight)
        let resolver = ConcurrentEventResolver(converter: converter)
        return resolver.resolvePositions(events: timedEvents)
    }

    private var positionedEventsWithState: [PositionedEventWithState] {
        return positionedEvents.map { positioned in
            let isPast = (positioned.event.endTime ?? positioned.event.date) < currentTime
            let isCurrent = (positioned.event.startTime ?? positioned.event.date) <= currentTime &&
                           currentTime < (positioned.event.endTime ?? positioned.event.date)

            return PositionedEventWithState(
                event: positioned.event,
                yStart: positioned.yStart,
                height: positioned.height,
                widthFraction: positioned.widthFraction,
                xOffset: positioned.xOffset,
                column: positioned.column,
                totalColumns: positioned.totalColumns,
                isPast: isPast,
                isCurrent: isCurrent
            )
        }
    }

    private var nowIndicatorY: CGFloat {
        let converter = TimeToPixelConverter(hourHeight: configuration.hourHeight)
        return converter.yPosition(for: currentTime)
    }

    private var isNowIndicatorVisible: Bool {
        Calendar.current.isDate(date, inSameDayAs: currentTime)
    }

    private var availableEventWidth: CGFloat {
        // Available width = screen width - ruler width
        UIScreen.main.bounds.width - TimelineConfiguration.rulerWidth
    }

    // MARK: - Methods

    private func scheduleTimeUpdates() {
        // Update current time every 60 seconds to reflect minute changes
        DispatchQueue.main.asyncAfter(deadline: .now() + 60) {
            currentTime = Date()
            scheduleTimeUpdates()
        }
    }
}

// MARK: - Helper Struct

struct PositionedEventWithState {
    let event: TaskItem
    let yStart: CGFloat
    let height: CGFloat
    let widthFraction: CGFloat
    let xOffset: CGFloat
    let column: Int
    let totalColumns: Int
    let isPast: Bool
    let isCurrent: Bool
}

// MARK: - Helper Components

struct TimelineGridLines: View {
    let hourHeight: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<24, id: \.self) { _ in
                Rectangle()
                    .fill(AppColors.timelineGridLine)
                    .frame(height: 1)
                Spacer()
                    .frame(height: hourHeight - 1)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct TimelineDayHeaderPlaceholder: View {
    let date: Date

    var body: some View {
        VStack(spacing: AppTheme.spacing8) {
            HStack {
                Text(dateString)
                    .font(.system(size: AppTheme.fontTitle2, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                Button(action: {}) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: AppTheme.fontTitle2))
                        .foregroundColor(AppColors.primary)
                }
            }
            .padding(AppTheme.spacing16)

            Divider()
        }
        .background(AppColors.background)
    }

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: date)
    }
}

struct AllDayStripPlaceholder: View {
    let events: [TaskItem]

    var body: some View {
        VStack(spacing: AppTheme.spacing8) {
            if !events.isEmpty {
                Text(String(localized: "event.allDay"))
                    .font(.system(size: AppTheme.fontCaption, weight: .semibold))
                    .foregroundColor(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, AppTheme.spacing16)

                VStack(spacing: AppTheme.spacing8) {
                    ForEach(events) { event in
                        HStack(spacing: AppTheme.spacing8) {
                            Circle()
                                .fill(event.category.colorValue)
                                .frame(width: AppTheme.categoryDotSize, height: AppTheme.categoryDotSize)

                            Text(event.title)
                                .font(.system(size: AppTheme.fontBody))
                                .foregroundColor(AppColors.textPrimary)
                                .lineLimit(1)

                            Spacer()
                        }
                        .padding(AppTheme.spacing12)
                        .background(AppColors.backgroundLight)
                        .cornerRadius(AppTheme.cornerRadiusMedium)
                        .padding(.horizontal, AppTheme.spacing16)
                    }
                }
            }

            Divider()
        }
        .padding(.vertical, AppTheme.spacing12)
        .background(AppColors.background)
    }
}

struct FloatingNowButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.spacing8) {
                Image(systemName: "clock.fill")
                    .font(.system(size: AppTheme.fontCaption, weight: .semibold))
                    .foregroundColor(.white)

                Text("Now")
                    .font(.system(size: AppTheme.fontCaption, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(.vertical, AppTheme.spacing8)
            .padding(.horizontal, AppTheme.spacing12)
            .background(AppColors.primary)
            .cornerRadius(AppTheme.cornerRadiusLarge)
        }
        .shadow(color: AppColors.primary.opacity(0.3), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Preview

#Preview("DayTimelineView - Today with Events") {
    let now = Date()
    let event1 = TaskItem(
        title: "Team Meeting",
        date: now,
        startTime: Calendar.current.date(byAdding: .hour, value: 2, to: now)!,
        endTime: Calendar.current.date(byAdding: .hour, value: 3, to: now)!,
        category: .meeting,
        itemType: .event,
        location: "Room 301"
    )

    let event2 = TaskItem(
        title: "Project Review",
        date: now,
        startTime: Calendar.current.date(byAdding: .hour, value: 4, to: now)!,
        endTime: Calendar.current.date(byAdding: .hour, value: 5, to: now)!,
        category: .work,
        itemType: .event
    )

    let allDayEvent = TaskItem(
        title: "Company Holiday",
        date: now,
        category: .holiday,
        itemType: .event
    )

    return DayTimelineView(
        date: now,
        events: [event1, event2, allDayEvent],
        hoangDaoHours: [0, 1, 4, 5, 7, 10],
        onEventTap: { _ in },
        onAddEvent: { _ in },
        onToggleCompletion: { _ in }
    )
}

#Preview("DayTimelineView - Overlapping Events") {
    let now = Date()
    let start = Calendar.current.date(byAdding: .hour, value: 3, to: now)!
    let end1 = Calendar.current.date(byAdding: .hour, value: 4, to: start)!
    let end2 = Calendar.current.date(byAdding: .hour, value: 4, to: start)!

    let event1 = TaskItem(
        title: "Quick Sync",
        date: now,
        startTime: start,
        endTime: end1,
        category: .meeting,
        itemType: .event
    )

    let event2 = TaskItem(
        title: "Design Review",
        date: now,
        startTime: Calendar.current.date(byAdding: .minute, value: 30, to: start)!,
        endTime: end2,
        category: .work,
        itemType: .event
    )

    return DayTimelineView(
        date: now,
        events: [event1, event2],
        hoangDaoHours: [0, 1, 4, 5, 7, 10],
        onEventTap: { _ in },
        onAddEvent: { _ in },
        onToggleCompletion: { _ in }
    )
}
