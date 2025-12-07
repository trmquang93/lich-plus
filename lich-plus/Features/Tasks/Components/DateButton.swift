//
//  DateButton.swift
//  lich-plus
//
//  Button component for date selection
//

import SwiftUI

struct DateButton: View {
    let date: Date
    let action: () -> Void

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM, h:mm a"
        return formatter
    }

    var body: some View {
        Button(action: action) {
            Text(dateFormatter.string(from: date))
                .font(.system(size: AppTheme.fontBody))
                .foregroundStyle(AppColors.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppTheme.spacing12)
                .background(AppColors.background)
                .cornerRadius(AppTheme.cornerRadiusLarge)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge)
                        .stroke(AppColors.borderLight, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}
