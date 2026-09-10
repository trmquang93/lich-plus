//
//  XemNgayCardView.swift
//  lich-plus
//
//  Xem ngày cho việc — purpose picker and day verdict.
//

import SwiftUI

struct XemNgayCardView: View {
    let date: Date
    @ObservedObject private var birthYearStore = BirthYearStore.shared
    @State private var selectedPurpose: ActivityPurpose = .travel

    private var verdict: ActivityVerdict {
        ActivityVerdictCalculator.verdict(
            for: date,
            purpose: selectedPurpose,
            birthYear: birthYearStore.birthYear
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing12) {
            header

            purposePicker

            verdictSection

            if let hint = verdict.nguHanhHint {
                nguHanhRow(hint)
            }

            if verdict.isBirthYearXung {
                xungBadge
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .elderModePadding(.all, AppTheme.spacing16)
        .background(AppColors.background)
        .cornerRadius(AppTheme.cornerRadiusLarge)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        .accessibilityIdentifier("xemngay.card")
        .onChange(of: selectedPurpose) { _, _ in
            AnalyticsService.shared.logFeatureUsed(.xem_ngay)
        }
    }

    private var header: some View {
        HStack(spacing: AppTheme.spacing8) {
            Image(systemName: "sparkles")
                .font(.system(size: AppTheme.fontBody, weight: .semibold))
                .foregroundStyle(AppColors.primary)
            Text(String(localized: "Check Day for Activity"))
                .elderModeFont(size: AppTheme.fontTitle3, weight: .bold)
                .foregroundStyle(AppColors.textPrimary)
        }
    }

    private var purposePicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.spacing8) {
                ForEach(ActivityPurpose.allCases) { purpose in
                    purposeChip(purpose)
                }
            }
        }
    }

    private func purposeChip(_ purpose: ActivityPurpose) -> some View {
        let isSelected = selectedPurpose == purpose
        return Button {
            selectedPurpose = purpose
        } label: {
            HStack(spacing: AppTheme.spacing4) {
                Image(systemName: purpose.iconName)
                    .font(.system(size: 12))
                Text(purpose.displayName)
                    .elderModeFont(size: AppTheme.fontCaption, weight: .medium)
            }
            .padding(.horizontal, AppTheme.spacing12)
            .padding(.vertical, AppTheme.spacing8)
            .background(isSelected ? AppColors.primary.opacity(0.12) : AppColors.backgroundLightGray)
            .foregroundStyle(isSelected ? AppColors.primary : AppColors.textSecondary)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? AppColors.primary : AppColors.borderLight, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("xemngay.purpose.\(purpose.id)")
    }

    private var verdictSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing8) {
            Text(verdict.summary)
                .elderModeFont(size: AppTheme.fontBody, weight: .semibold)
                .foregroundStyle(statusColor)

            if verdict.isStarDataIncomplete || verdict.status == .incomplete {
                incompleteBanner
            }

            ForEach(Array(verdict.reasons.prefix(4).enumerated()), id: \.offset) { _, reason in
                Text(reason)
                    .elderModeFont(size: AppTheme.fontCaption)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
    }

    private var incompleteBanner: some View {
        HStack(spacing: AppTheme.spacing8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(AppColors.secondary)
            Text(String(localized: "Star data for this lunar month is incomplete. Verdict uses 12 Trực and Hoàng Đạo only."))
                .elderModeFont(size: AppTheme.fontCaption)
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(AppTheme.spacing12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.backgroundLightGray)
        .cornerRadius(AppTheme.cornerRadiusMedium)
    }

    private func nguHanhRow(_ hint: String) -> some View {
        HStack(alignment: .top, spacing: AppTheme.spacing8) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 14))
                .foregroundStyle(AppColors.accent)
            Text(hint)
                .elderModeFont(size: AppTheme.fontCaption)
                .foregroundStyle(AppColors.textSecondary)
        }
    }

    private var xungBadge: some View {
        Text(String(localized: "Birth year clash day"))
            .elderModeFont(size: AppTheme.fontCaption, weight: .semibold)
            .foregroundStyle(AppColors.white)
            .padding(.horizontal, AppTheme.spacing12)
            .padding(.vertical, AppTheme.spacing4)
            .background(AppColors.primary)
            .clipShape(Capsule())
    }

    private var statusColor: Color {
        switch verdict.status {
        case .good: return AppColors.accent
        case .bad: return AppColors.primary
        case .neutral: return AppColors.textSecondary
        case .incomplete: return AppColors.secondary
        }
    }
}

#Preview {
    XemNgayCardView(date: Date())
        .padding()
        .background(AppColors.backgroundLightGray)
}
