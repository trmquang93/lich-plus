//
//  CalendarView.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 23/11/25.
//

import SwiftData
import SwiftUI

// MARK: - Calendar View

struct CalendarView: View {
    @Environment(\.modelContext) var modelContext
    @StateObject private var dataManager = CalendarDataManager()
    @State private var showDayDetail = false
    @State private var displayedMonthOffset: Int = 0
    @State private var displayedWeekOffset: Int = 0
    @EnvironmentObject var syncService: CalendarSyncService
    @State private var collapseProgress: CGFloat = 0
    @State private var refreshCounter: Int = 0

    private var displayedDate: Date {
        Calendar.current.date(byAdding: .month, value: displayedMonthOffset, to: Date()) ?? Date()
    }

    private var navigationUnit: NavigationUnit {
        if collapseProgress > 0.9 {
            return .week
        } else {
            return .month
        }
    }

    private var currentNavigationOffset: Int {
        navigationUnit == .month ? displayedMonthOffset : displayedWeekOffset
    }

    private func calculateWeekIndex(for date: Date, in month: CalendarMonth) -> Int {
        let weeks = month.weeksOfDays
        guard !weeks.isEmpty else { return 0 }

        for (index, week) in weeks.enumerated() {
            if week.contains(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
                return index
            }
        }

        // If selected date is not in this month, return first week
        return 0
    }

    private func calculateWeekOffsetForDate(_ date: Date) -> Int {
        let calendar = Calendar.current
        let today = Date()
        let startOfToday = calendar.startOfDay(for: today)
        let startOfDate = calendar.startOfDay(for: date)

        let components = calendar.dateComponents([.weekOfYear], from: startOfToday, to: startOfDate)
        return components.weekOfYear ?? 0
    }

    private func syncMonthOffsetFromWeek() {
        // Get the date for the current week offset
        let today = Date()
        guard
            let weekDate = Calendar.current.date(
                byAdding: .weekOfYear, value: displayedWeekOffset, to: today)
        else { return }

        // Calculate which month this week belongs to
        let calendar = Calendar.current
        let todayComponents = calendar.dateComponents([.year, .month], from: today)
        let weekComponents = calendar.dateComponents([.year, .month], from: weekDate)

        // Calculate month difference
        let monthDiff =
            (weekComponents.year! - todayComponents.year!) * 12
            + (weekComponents.month! - todayComponents.month!)

        // Update month offset if different
        if displayedMonthOffset != monthDiff {
            displayedMonthOffset = monthDiff
        }
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Header with month/year selector (stays fixed at top)
                    CalendarHeaderView(
                        selectedDate: .constant(displayedDate),
                        onPreviousMonth: {
                            displayedMonthOffset -= 1
                        },
                        onNextMonth: {
                            displayedMonthOffset += 1
                        },
                        onMonthSelected: { month, year in
                            let today = Date()
                            let calendar = Calendar.current
                            let todayComponents = calendar.dateComponents(
                                [.year, .month], from: today)
                            let monthDiff =
                                (year - todayComponents.year!) * 12
                                + (month - todayComponents.month!)
                            displayedMonthOffset = monthDiff
                        }
                    )

                    // Parallax scroll container
                    ParallaxScrollView(
                        minHeaderHeight: CalendarDisplayMode.minHeight,
                        maxHeaderHeight: CalendarDisplayMode.maxHeight,
                        header: { height, progress in
                            // Calendar grid with horizontal swipe navigation
                            return InfinitePageView(
                                initialIndex: currentNavigationOffset,
                                currentValue: currentNavigationOffset,
                                refreshTrigger: AnyHashable(
                                    "\(dataManager.selectedDate)_\(progress)"),
                                content: { offset in
                                    let month =
                                        navigationUnit == .month
                                        ? dataManager.getMonthFromToday(offset: offset)
                                        : dataManager.getMonthForWeek(offset: offset)

                                    return CalendarGridView(
                                        month: month,
                                        selectedDate: $dataManager.selectedDate,
                                        onDaySelected: { day in
                                            dataManager.selectDay(day)
                                        },
                                        collapseProgress: progress
                                    )
                                },
                                onPageChanged: { newOffset in
                                    if navigationUnit == .month {
                                        displayedMonthOffset = newOffset
                                    } else {
                                        // Calculate week delta and update selected date
                                        let weekDelta = newOffset - displayedWeekOffset
                                        if weekDelta != 0,
                                           let newDate = Calendar.current.date(
                                               byAdding: .weekOfYear,
                                               value: weekDelta,
                                               to: dataManager.selectedDate
                                           ) {
                                            dataManager.selectedDate = newDate
                                        }
                                        displayedWeekOffset = newOffset
                                        syncMonthOffsetFromWeek()
                                    }
                                }
                            )
                            .onChange(of: progress) { _, newProgress in
                                collapseProgress = newProgress
                                if newProgress >= 0.9 {
                                    displayedWeekOffset = calculateWeekOffsetForDate(
                                        dataManager.selectedDate)
                                }
                            }
                        },
                        content: {
                            // QuickInfo + Events content
                            if dataManager.selectedDay != nil {
                                VStack(spacing: 0) {
                                    Divider()
                                        .foregroundStyle(AppColors.borderLight)
                                        .padding(.horizontal, AppTheme.spacing16)

                                    InfinitePageView(
                                        initialIndex: dataManager.selectedDate,
                                        currentValue: dataManager.selectedDate,
                                        refreshTrigger: AnyHashable(refreshCounter),
                                        content: { date in
                                            let day = dataManager.createCalendarDay(
                                                from: date,
                                                isCurrentMonth: true,
                                                isToday: Calendar.current.isDateInToday(date)
                                            )
                                            let hours = DayTypeCalculator.getLuckyHours(for: date)

                                            // No ScrollView needed - ParallaxScrollView handles scrolling
                                            return VStack(spacing: 0) {
                                                QuickInfoBannerView(
                                                    day: day,
                                                    luckyHours: hours,
                                                    onTap: {
                                                        showDayDetail = true
                                                    }
                                                )

                                                EventsListView(
                                                    events: day.events,
                                                    day: day
                                                )

                                                Spacer(minLength: AppTheme.spacing16)
                                            }
                                            .background(AppColors.background)
                                        },
                                        onPageChanged: { newDate in
                                            dataManager.selectedDate = newDate

                                            let newOffset =
                                                dataManager.calculateMonthOffsetFromToday(
                                                    for: newDate)
                                            if newOffset != displayedMonthOffset {
                                                displayedMonthOffset = newOffset
                                            }
                                        }
                                    )
                                    .frame(height: geometry.size.height - 60)
                                }
                            }
                        }
                    )
                }
            }
            .navigationDestination(isPresented: $showDayDetail) {
                if let selectedDay = dataManager.selectedDay {
                    DayDetailView(day: selectedDay)
                }
            }
            .onAppear {
                dataManager.setModelContext(modelContext)
            }
            .onReceive(NotificationCenter.default.publisher(for: .calendarDataDidChange)) { _ in
                dataManager.refreshCurrentMonth()
                refreshCounter += 1
            }
        }
    }

}

// MARK: - Preview

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: SyncableEvent.self, SyncedCalendar.self, ICSSubscription.self, configurations: config)
    let modelContext = ModelContext(container)
    let eventKitService = EventKitService()

    return CalendarView()
        .environmentObject(
            CalendarSyncService(eventKitService: eventKitService, modelContext: modelContext)
        )
        .modelContainer(container)
}
