//
//  CalendarView.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 23/11/25.
//

import SwiftUI

// MARK: - Calendar View

struct CalendarView: View {
    @StateObject private var dataManager = CalendarDataManager()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header with month/year selector
                CalendarHeaderView(
                    selectedDate: .constant(dataManager.currentMonth.days.first?.date ?? Date()),
                    onPreviousMonth: {
                        dataManager.goToPreviousMonth()
                    },
                    onNextMonth: {
                        dataManager.goToNextMonth()
                    }
                )

                ScrollView {
                    VStack(spacing: 0) {
                        // Calendar grid
                        CalendarGridView(
                            month: dataManager.currentMonth,
                            selectedDay: $dataManager.selectedDay,
                            onDaySelected: { day in
                                dataManager.selectDay(day)
                            }
                        )

                        // Quick info banner for selected day or today
                        if let selectedDay = dataManager.selectedDay {
                            Divider()
                                .foregroundStyle(AppColors.borderLight)
                                .padding(.horizontal, AppTheme.spacing16)

                            let luckyHours = DayTypeCalculator.getLuckyHours(for: selectedDay.date)
                            QuickInfoBannerView(
                                day: selectedDay,
                                luckyHours: luckyHours
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
        }
    }
}

// MARK: - Preview

#Preview {
    CalendarView()
}
