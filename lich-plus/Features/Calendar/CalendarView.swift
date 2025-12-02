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
    @State private var scrollOffset: CGFloat = 0
    @State private var displayMode: CalendarDisplayMode = .expanded

    private var displayedDate: Date {
        Calendar.current.date(byAdding: .month, value: displayedMonthOffset, to: Date()) ?? Date()
    }

    private var navigationUnit: NavigationUnit {
        switch displayMode {
        case .compact:
            return .week
        case .expanded, .transitioning:
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
        guard let weekDate = Calendar.current.date(byAdding: .weekOfYear, value: displayedWeekOffset, to: today) else { return }

        // Calculate which month this week belongs to
        let calendar = Calendar.current
        let todayComponents = calendar.dateComponents([.year, .month], from: today)
        let weekComponents = calendar.dateComponents([.year, .month], from: weekDate)

        // Calculate month difference
        let monthDiff = (weekComponents.year! - todayComponents.year!) * 12 + (weekComponents.month! - todayComponents.month!)

        // Update month offset if different
        if displayedMonthOffset != monthDiff {
            displayedMonthOffset = monthDiff
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header with month/year selector
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
                        let todayComponents = calendar.dateComponents([.year, .month], from: today)
                        let monthDiff = (year - todayComponents.year!) * 12 + (month - todayComponents.month!)
                        displayedMonthOffset = monthDiff
                    }
                )

                // Calendar grid with horizontal swipe navigation
                InfinitePageView(
                    initialIndex: currentNavigationOffset,
                    currentValue: currentNavigationOffset,
                    refreshTrigger: AnyHashable("\(dataManager.selectedDate)_\(displayMode)"),
                    content: { offset in
                        let month = navigationUnit == .month
                            ? dataManager.getMonthFromToday(offset: offset)
                            : dataManager.getMonthForWeek(offset: offset)

                        let weekIndex: Int? = {
                            guard case .compact = displayMode else { return nil }
                            return calculateWeekIndex(for: dataManager.selectedDate, in: month)
                        }()

                        return CalendarGridView(
                            month: month,
                            selectedDate: $dataManager.selectedDate,
                            onDaySelected: { day in
                                dataManager.selectDay(day)
                            },
                            displayMode: displayMode,
                            visibleWeekIndex: weekIndex
                        )
                    },
                    onPageChanged: { newOffset in
                        if navigationUnit == .month {
                            displayedMonthOffset = newOffset
                        } else {
                            displayedWeekOffset = newOffset
                            syncMonthOffsetFromWeek()
                        }
                    }
                )

                // Quick info banner + events with swipe navigation
                if dataManager.selectedDay != nil {
                    Divider()
                        .foregroundStyle(AppColors.borderLight)
                        .padding(.horizontal, AppTheme.spacing16)

                    InfinitePageView(
                        initialIndex: dataManager.selectedDate,
                        currentValue: dataManager.selectedDate,
                        content: { date in
                            let day = dataManager.createCalendarDay(
                                from: date,
                                isCurrentMonth: true,
                                isToday: Calendar.current.isDateInToday(date)
                            )
                            let hours = DayTypeCalculator.getLuckyHours(for: date)

                            // ScrollView inside each page for scrollable content
                            return ScrollView {
                                VStack(spacing: 0) {
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
                                .trackScrollOffset { offset in
                                    scrollOffset = offset
                                    updateDisplayMode(for: offset)
                                }
                            }
                            .coordinateSpace(name: "scrollView")
                        },
                        onPageChanged: { newDate in
                            dataManager.selectedDate = newDate

                            let newOffset = dataManager.calculateMonthOffsetFromToday(for: newDate)
                            if newOffset != displayedMonthOffset {
                                displayedMonthOffset = newOffset
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
        }
    }

    // MARK: - Private Methods

    private func updateDisplayMode(for offset: CGFloat) {
        let adjustedOffset = -offset // Negative because scrolling down gives negative Y

        if adjustedOffset > CalendarDisplayMode.collapseThreshold {
            let progress = 1.0 - min(1.0,
                (adjustedOffset - CalendarDisplayMode.collapseThreshold) /
                (CalendarDisplayMode.collapseThreshold * 2))

            if progress <= 0.1 {
                displayMode = .compact
                // Initialize week offset based on selected date when entering compact mode
                displayedWeekOffset = calculateWeekOffsetForDate(dataManager.selectedDate)
            } else {
                displayMode = .transitioning(progress: progress)
            }
        } else if adjustedOffset < CalendarDisplayMode.expandThreshold {
            displayMode = .expanded
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
