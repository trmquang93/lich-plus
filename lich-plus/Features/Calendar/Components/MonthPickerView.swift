//
//  MonthPickerView.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 27/11/25.
//

import SwiftUI

struct MonthPickerView: View {
    let selectedDate: Date
    let onMonthSelected: (Int, Int) -> Void
    let onDismiss: () -> Void

    @State private var displayYear: Int
    @State private var swipeStartX: CGFloat = 0

    private let monthLabels = ["Th.1", "Th.2", "Th.3", "Th.4", "Th.5", "Th.6",
                               "Th.7", "Th.8", "Th.9", "Th.10", "Th.11", "Th.12"]
    private let minYear = 1900
    private let maxYear = 2100
    private let columns = [
        GridItem(.flexible(), spacing: AppTheme.spacing12),
        GridItem(.flexible(), spacing: AppTheme.spacing12),
        GridItem(.flexible(), spacing: AppTheme.spacing12)
    ]

    init(selectedDate: Date, onMonthSelected: @escaping (Int, Int) -> Void, onDismiss: @escaping () -> Void) {
        self.selectedDate = selectedDate
        self.onMonthSelected = onMonthSelected
        self.onDismiss = onDismiss

        let calendar = Calendar.current
        let year = calendar.component(.year, from: selectedDate)
        _displayYear = State(initialValue: year)
    }

    var currentYear: Int {
        let calendar = Calendar.current
        return calendar.component(.year, from: Date())
    }

    var currentMonth: Int {
        let calendar = Calendar.current
        return calendar.component(.month, from: Date())
    }

    var selectedMonth: Int {
        let calendar = Calendar.current
        return calendar.component(.month, from: selectedDate)
    }

    var selectedYear: Int {
        let calendar = Calendar.current
        return calendar.component(.year, from: selectedDate)
    }

    var body: some View {
        VStack(spacing: AppTheme.spacing16) {
            // Year header with navigation
            HStack(spacing: AppTheme.spacing16) {
                Button(action: previousYear) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: AppTheme.fontTitle3, weight: .semibold))
                        .foregroundStyle(AppColors.primary)
                        .frame(width: 44, height: 44)
                }
                .disabled(displayYear <= minYear)

                Spacer()

                Text("\(displayYear)")
                    .font(.system(size: AppTheme.fontTitle2, weight: .bold))
                    .foregroundStyle(AppColors.textPrimary)

                Spacer()

                Button(action: nextYear) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: AppTheme.fontTitle3, weight: .semibold))
                        .foregroundStyle(AppColors.primary)
                        .frame(width: 44, height: 44)
                }
                .disabled(displayYear >= maxYear)
            }
            .padding(.horizontal, AppTheme.spacing16)
            .padding(.top, AppTheme.spacing16)

            // Month grid (3x4)
            LazyVGrid(columns: columns, spacing: AppTheme.spacing12) {
                ForEach(1...12, id: \.self) { month in
                    monthButton(for: month)
                }
            }
            .padding(.horizontal, AppTheme.spacing16)

            // Close button
            Button(action: onDismiss) {
                Text("Done")
                    .font(.system(size: AppTheme.fontBody, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(AppColors.primary)
                    .cornerRadius(AppTheme.cornerRadiusMedium)
            }
            .padding(.horizontal, AppTheme.spacing16)
            .padding(.bottom, AppTheme.spacing16)
        }
        .frame(maxWidth: .infinity)
        .background(AppColors.background)
        .cornerRadius(AppTheme.cornerRadiusLarge, corners: [.topLeft, .topRight])
        .gesture(
            DragGesture()
                .onChanged { value in
                    if swipeStartX == 0 {
                        swipeStartX = value.translation.height
                    }
                }
                .onEnded { value in
                    let translation = value.translation.height
                    let threshold: CGFloat = 50

                    if translation < -threshold {
                        // Swipe up = next year
                        nextYear()
                    } else if translation > threshold {
                        // Swipe down = previous year
                        previousYear()
                    }

                    swipeStartX = 0
                }
        )
    }

    @ViewBuilder
    private func monthButton(for month: Int) -> some View {
        let isCurrentMonth = month == currentMonth && displayYear == currentYear
        let isSelectedMonth = month == selectedMonth && displayYear == selectedYear

        Button(action: {
            onMonthSelected(month, displayYear)
            onDismiss()
        }) {
            Text(monthLabels[month - 1])
                .font(.system(size: AppTheme.fontBody, weight: .semibold))
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .foregroundStyle(
                    isCurrentMonth ? AppColors.white :
                    isSelectedMonth ? AppColors.primary :
                    AppColors.textPrimary
                )
                .background(
                    isCurrentMonth ? AppColors.primary :
                    isSelectedMonth ? AppColors.backgroundLight :
                    AppColors.clear
                )
                .cornerRadius(AppTheme.cornerRadiusMedium)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                        .stroke(
                            isCurrentMonth ? AppColors.primary :
                            isSelectedMonth ? AppColors.primary :
                            AppColors.borderLight,
                            lineWidth: isCurrentMonth || isSelectedMonth ? 1.5 : 1
                        )
                )
        }
    }

    private func previousYear() {
        if displayYear > minYear {
            displayYear -= 1
        }
    }

    private func nextYear() {
        if displayYear < maxYear {
            displayYear += 1
        }
    }
}

// MARK: - RoundedCorner Shape Extension

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.gray.opacity(0.3).ignoresSafeArea()

        VStack {
            Spacer()

            MonthPickerView(
                selectedDate: Date(),
                onMonthSelected: { month, year in
                    print("Selected month: \(month)/\(year)")
                },
                onDismiss: {
                    print("Dismissed month picker")
                }
            )
        }
    }
}
