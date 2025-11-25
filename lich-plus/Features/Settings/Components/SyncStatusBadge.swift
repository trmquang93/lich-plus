//
//  SyncStatusBadge.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 25/11/25.
//

import SwiftUI

struct SyncStatusBadge: View {
    enum Status {
        case syncing
        case synced
        case error
        case disabled
    }

    let status: Status
    var lastSyncDate: Date?

    private var statusColor: Color {
        switch status {
        case .syncing:
            return AppColors.primary
        case .synced:
            return AppColors.accent
        case .error:
            return Color.red
        case .disabled:
            return AppColors.secondary
        }
    }

    private var statusIcon: String {
        switch status {
        case .syncing:
            return ""
        case .synced:
            return "checkmark.circle.fill"
        case .error:
            return "exclamationmark.triangle.fill"
        case .disabled:
            return "minus.circle"
        }
    }

    private var statusText: String {
        switch status {
        case .syncing:
            return "Syncing..."
        case .synced:
            return "Synced"
        case .error:
            return "Sync Error"
        case .disabled:
            return "Sync Off"
        }
    }

    private var relativeSyncTime: String? {
        guard let lastSyncDate = lastSyncDate else { return nil }
        let formatter = RelativeDateTimeFormatter()
        return formatter.localizedString(for: lastSyncDate, relativeTo: Date())
    }

    var body: some View {
        HStack(spacing: AppTheme.spacing8) {
            if status == .syncing {
                ProgressView()
                    .scaleEffect(0.8, anchor: .center)
            } else {
                Image(systemName: statusIcon)
                    .font(.body)
                    .foregroundStyle(statusColor)
            }

            VStack(alignment: .leading, spacing: AppTheme.spacing2) {
                Text(statusText)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(AppColors.textPrimary)

                if let relativeTime = relativeSyncTime {
                    Text(relativeTime)
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }
            }

            Spacer()
        }
        .padding(AppTheme.spacing12)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                .fill(AppColors.backgroundLightGray)
        )
    }
}

#Preview {
    VStack(spacing: AppTheme.spacing16) {
        SyncStatusBadge(status: .syncing)
        SyncStatusBadge(
            status: .synced,
            lastSyncDate: Date().addingTimeInterval(-3600)
        )
        SyncStatusBadge(status: .error)
        SyncStatusBadge(status: .disabled)
    }
    .padding()
}
