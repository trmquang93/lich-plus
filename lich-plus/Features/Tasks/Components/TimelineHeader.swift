//
//  TimelineHeader.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 7/12/25.
//

import SwiftUI

struct TimelineHeader: View {
    @Binding var searchText: String
    @Binding var isSearchActive: Bool
    let onAddTapped: () -> Void

    var body: some View {
        VStack(spacing: AppTheme.spacing12) {
            // Title and Action Buttons Row
            HStack {
                Text("timeline.title")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(AppColors.textPrimary)

                Spacer()

                // Add Button
                Button(action: onAddTapped) {
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(AppColors.textPrimary)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("Add new item")

                // Search Button
                Button(action: { isSearchActive.toggle() }) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundStyle(AppColors.textPrimary)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("Search")
            }
            .padding(.horizontal, AppTheme.spacing16)

            // Expandable Search Bar
            if isSearchActive {
                HStack(spacing: AppTheme.spacing8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(AppColors.textSecondary)
                        .font(.system(size: 16))

                    TextField("timeline.search", text: $searchText)
                        .textContentType(.none)
                        .font(.system(size: AppTheme.fontBody))
                        .foregroundStyle(AppColors.textPrimary)

                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(AppColors.textSecondary)
                                .font(.system(size: 16))
                        }
                        .accessibilityLabel("Clear search")
                    }
                }
                .padding(.horizontal, AppTheme.spacing12)
                .padding(.vertical, AppTheme.spacing8)
                .background(AppColors.backgroundLightGray)
                .cornerRadius(AppTheme.cornerRadiusMedium)
                .padding(.horizontal, AppTheme.spacing16)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.vertical, AppTheme.spacing12)
        .background(AppColors.background)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSearchActive)
    }
}

#Preview {
    VStack(spacing: 0) {
        TimelineHeader(
            searchText: .constant(""),
            isSearchActive: .constant(false),
            onAddTapped: {}
        )

        Divider()

        TimelineHeader(
            searchText: .constant(""),
            isSearchActive: .constant(true),
            onAddTapped: {}
        )

        Divider()

        TimelineHeader(
            searchText: .constant("Meeting"),
            isSearchActive: .constant(true),
            onAddTapped: {}
        )

        Spacer()
    }
    .background(AppColors.background)
}
