//
//  TodayHighlightsSection.swift
//  lich-plus
//
//  "Hôm nay" hero — surfaces today's matched văn khấn (if any).
//

import SwiftUI
import SwiftData

struct TodayHighlightsSection: View {
    @Query private var profiles: [PersonalProfile]

    private var matches: [VanKhanOccasionMatcher.Match] {
        VanKhanOccasionMatcher.match(date: Date(), profile: profiles.first, max: 2)
    }

    var body: some View {
        if matches.isEmpty {
            EmptyView()
        } else {
            VStack(alignment: .leading, spacing: AppTheme.spacing12) {
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundStyle(AppColors.hoangDaoGold)
                    Text(String(localized: "Hôm nay"))
                        .font(.system(size: AppTheme.fontTitle3, weight: .bold))
                        .foregroundStyle(AppColors.textPrimary)
                    Spacer()
                }

                ForEach(Array(matches.enumerated()), id: \.offset) { _, match in
                    NavigationLink {
                        VanKhanDetailView(
                            occasion: match.occasion,
                            initialDeceasedId: match.deceasedRelative?.id
                        )
                    } label: {
                        card(for: match)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func card(for match: VanKhanOccasionMatcher.Match) -> some View {
        HStack(spacing: AppTheme.spacing12) {
            Image(systemName: "scroll.fill")
                .foregroundStyle(AppColors.primary)
                .font(.title2)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: AppTheme.spacing2) {
                Text(match.occasion.title)
                    .font(.system(size: AppTheme.fontSubheading, weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)
                if let r = match.deceasedRelative {
                    Text("\(r.relation) \(r.name)")
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                } else if let s = match.occasion.subtitle {
                    Text(s)
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(AppTheme.spacing12)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                .fill(AppColors.backgroundLight.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                        .stroke(AppColors.hoangDaoGold.opacity(0.4), lineWidth: 1)
                )
        )
    }
}
