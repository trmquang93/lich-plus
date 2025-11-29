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
                    initialPage: displayedMonthOffset,
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
                ScrollView {
                    VStack(spacing: 0) {

                        // Quick info banner for selected day or today
                        if let selectedDay = dataManager.selectedDay {
                            Divider()
                                .foregroundStyle(AppColors.borderLight)
                                .padding(.horizontal, AppTheme.spacing16)

                            let luckyHours = DayTypeCalculator.getLuckyHours(for: selectedDay.date)
                            QuickInfoBannerView(
                                day: selectedDay,
                                luckyHours: luckyHours,
                                onTap: {
                                    showDayDetail = true
                                }
                            )
                        }

                        // Events list for selected day
                        if let selectedDay = dataManager.selectedDay {
                            EventsListView(
                                events: selectedDay.events,
                                day: selectedDay
                            )
                        }

                        Spacer(minLength: AppTheme.spacing16)
                    }
                    .background(AppColors.background)
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
