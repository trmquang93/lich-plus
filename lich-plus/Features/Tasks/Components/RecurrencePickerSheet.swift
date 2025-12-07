//
//  RecurrencePickerSheet.swift
//  lich-plus
//
//  Modal sheet for recurrence selection with solar and lunar calendar support
//

import SwiftUI

// MARK: - CalendarMode

enum CalendarMode {
    case solar
    case lunar
}

// MARK: - RecurrencePickerSheet

struct RecurrencePickerSheet: View {
    @Binding var selectedRecurrence: RecurrenceType
    @Binding var lunarRecurrenceRule: SerializableLunarRecurrenceRule?
    let onDone: () -> Void

    // MARK: - State
    @State private var calendarMode: CalendarMode = .solar
    @State private var lunarDay: Int = 15
    @State private var lunarMonth: Int = 1
    @State private var includeLeapMonth: Bool = false

    // MARK: - Computed Properties
    var filteredRecurrences: [RecurrenceType] {
        switch calendarMode {
        case .solar:
            return RecurrenceType.allCases.filter { !$0.isLunar }
        case .lunar:
            return RecurrenceType.allCases.filter { $0 == .none || $0.isLunar }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Calendar Mode Toggle
                Picker("", selection: $calendarMode) {
                    Text(String(localized: "recurrence.solar")).tag(CalendarMode.solar)
                    Text(String(localized: "recurrence.lunar")).tag(CalendarMode.lunar)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, AppTheme.spacing16)
                .padding(.vertical, AppTheme.spacing12)
                .background(AppColors.backgroundLightGray)

                Divider()
                    .background(AppColors.borderLight)

                // Recurrence List
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(filteredRecurrences, id: \.self) { recurrence in
                            VStack(spacing: 0) {
                                Button {
                                    selectedRecurrence = recurrence
                                } label: {
                                    HStack(spacing: AppTheme.spacing12) {
                                        Text(recurrence.displayName)
                                            .font(.system(size: AppTheme.fontBody))
                                            .foregroundStyle(AppColors.textPrimary)

                                        Spacer()

                                        if selectedRecurrence == recurrence {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundStyle(AppColors.primary)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, AppTheme.spacing16)
                                    .padding(.vertical, AppTheme.spacing12)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)

                                Divider()
                                    .background(AppColors.borderLight)
                            }
                        }
                    }
                }

                // Lunar Date Picker (shown only for lunar yearly)
                if calendarMode == .lunar && selectedRecurrence == .lunarYearly {
                    Divider()
                        .background(AppColors.borderLight)

                    LunarDatePickerView(
                        lunarDay: $lunarDay,
                        lunarMonth: $lunarMonth,
                        includeLeapMonth: $includeLeapMonth
                    )
                    .frame(maxHeight: 350)
                }
            }
            .navigationTitle(String(localized: "createItem.recurrence"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "task.done")) {
                        // Save lunar recurrence rule if applicable
                        if calendarMode == .lunar && selectedRecurrence.isLunar {
                            let leapBehavior: LeapMonthBehavior = includeLeapMonth ? .includeLeap : .skipLeap

                            lunarRecurrenceRule = SerializableLunarRecurrenceRule(
                                frequency: selectedRecurrence == .lunarMonthly ? .monthly : .yearly,
                                lunarDay: lunarDay,
                                lunarMonth: selectedRecurrence == .lunarYearly ? lunarMonth : nil,
                                leapMonthBehavior: leapBehavior,
                                interval: 1,
                                recurrenceEnd: nil
                            )
                        } else {
                            lunarRecurrenceRule = nil
                        }

                        onDone()
                    }
                    .foregroundStyle(AppColors.primary)
                }
            }
        }
        .onAppear {
            // Determine initial calendar mode based on selected recurrence
            if selectedRecurrence.isLunar {
                calendarMode = .lunar
            }

            // Load lunar date picker values from existing rule if available
            if let rule = lunarRecurrenceRule {
                lunarDay = rule.lunarDay
                lunarMonth = rule.lunarMonth ?? 1
                includeLeapMonth = rule.leapMonthBehavior == .includeLeap
            }
        }
        .onChange(of: calendarMode) { oldValue, newValue in
            // Reset selection when switching modes if current selection is invalid
            if !filteredRecurrences.contains(selectedRecurrence) {
                selectedRecurrence = .none
            }
        }
    }
}
