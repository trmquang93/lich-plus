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
    @EnvironmentObject var syncService: CalendarSyncService

    private var displayedDate: Date {
        Calendar.current.date(byAdding: .month, value: displayedMonthOffset, to: Date()) ?? Date()
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
                    initialIndex: displayedMonthOffset,
                    currentValue: displayedMonthOffset,
                    refreshTrigger: AnyHashable(dataManager.selectedDate),
                    content: { offset in
                        CalendarGridView(
                            month: dataManager.getMonthFromToday(offset: offset),
                            selectedDate: $dataManager.selectedDate,
                            onDaySelected: { day in
                                dataManager.selectDay(day)
                            }
                        )
                    },
                    onPageChanged: { newOffset in
                        displayedMonthOffset = newOffset
                    }
                )

                // Quick info banner + events with swipe navigation
                if let _ = dataManager.selectedDay {
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
                            }
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
