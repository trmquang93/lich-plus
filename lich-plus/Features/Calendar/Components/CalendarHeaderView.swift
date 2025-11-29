//
//  CalendarHeaderView.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 23/11/25.
//

import SwiftUI

// MARK: - Calendar Header View

struct CalendarHeaderView: View {
    @Binding var selectedDate: Date
    let onPreviousMonth: () -> Void
    let onNextMonth: () -> Void
    let onMonthSelected: ((Int, Int) -> Void)?

    @State private var showMonthPicker = false

    var currentMonthYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedDate)
    }

    var body: some View {
        VStack(spacing: AppTheme.spacing8) {
            // Month/Year with dropdown
            HStack {
                Button(action: onPreviousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: AppTheme.fontTitle3, weight: .semibold))
                        .foregroundStyle(AppColors.primary)
                        .frame(width: 40, height: 40)
                }

                Spacer()

                HStack(spacing: AppTheme.spacing8) {
                    Text(currentMonthYear)
                        .font(.system(size: AppTheme.fontTitle2, weight: .bold))
                        .foregroundStyle(AppColors.textPrimary)

                    Image(systemName: "chevron.down")
                        .font(.system(size: AppTheme.fontSubheading, weight: .semibold))
                        .foregroundStyle(AppColors.primary)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    showMonthPicker.toggle()
                }

                Spacer()

                Button(action: onNextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: AppTheme.fontTitle3, weight: .semibold))
                        .foregroundStyle(AppColors.primary)
                        .frame(width: 40, height: 40)
                }
            }
            .frame(height: 36)

            // Day labels (Monday to Sunday in Vietnamese)
            HStack(spacing: 0) {
                ForEach(["T2", "T3", "T4", "T5", "T6", "T7", "CN"], id: \.self) { day in
                    Text(day)
                        .font(.system(size: AppTheme.fontCaption, weight: .semibold))
                        .foregroundStyle(AppColors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 28)
                }
            }

            Divider()
                .foregroundStyle(AppColors.borderLight)
        }
        .padding(.horizontal, AppTheme.spacing16)
        .padding(.vertical, AppTheme.spacing8)
        .background(AppColors.background)
        .sheet(isPresented: $showMonthPicker) {
            MonthPickerView(
                selectedDate: selectedDate,
                onMonthSelected: { month, year in
                    onMonthSelected?(month, year)
                },
                onDismiss: {
                    showMonthPicker = false
                }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Preview

#Preview {
    VStack {
        CalendarHeaderView(
            selectedDate: .constant(Date()),
            onPreviousMonth: {},
            onNextMonth: {},
            onMonthSelected: nil
        )

        Spacer()
    }
    .background(AppColors.background)
}
