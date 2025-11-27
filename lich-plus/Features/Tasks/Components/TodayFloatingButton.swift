//
//  TodayFloatingButton.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 27/11/25.
//

import SwiftUI

struct TodayFloatingButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.spacing8) {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 16, weight: .semibold))
                Text(String(localized: "timeline.today"))
                    .font(.system(size: AppTheme.fontBody, weight: .semibold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, AppTheme.spacing16)
            .padding(.vertical, AppTheme.spacing12)
            .background(AppColors.primary)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        }
    }
}

#Preview {
    TodayFloatingButton(action: {})
}
