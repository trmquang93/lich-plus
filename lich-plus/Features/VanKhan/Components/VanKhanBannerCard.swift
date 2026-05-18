//
//  VanKhanBannerCard.swift
//  lich-plus
//
//  "Văn khấn hôm nay" card injected into DayDetailView when an occasion
//  matches the day's lunar / solar date.
//

import SwiftUI
import SwiftData

struct VanKhanBannerCard: View {
    let day: CalendarDay
    @Query private var profiles: [PersonalProfile]

    private var matches: [VanKhanOccasionMatcher.Match] {
        // Cap at 1 to avoid banner spam when multiple giỗ share a lunar date
        VanKhanOccasionMatcher.match(date: day.date, profile: profiles.first, max: 1)
    }

    var body: some View {
        if let match = matches.first {
            NavigationLink {
                VanKhanDetailView(
                    occasion: match.occasion,
                    initialDeceasedId: match.deceasedRelative?.id
                )
            } label: {
                content(for: match)
            }
            .buttonStyle(.plain)
        } else {
            EmptyView()
        }
    }

    private func content(for match: VanKhanOccasionMatcher.Match) -> some View {
        HStack(spacing: AppTheme.spacing12) {
            Image(systemName: "scroll.fill")
                .font(.title2)
                .foregroundStyle(AppColors.primary)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: AppTheme.spacing2) {
                Text(String(localized: "Văn khấn hôm nay"))
                    .font(.system(size: AppTheme.fontCaption, weight: .semibold))
                    .foregroundStyle(AppColors.hoangDaoGold)
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
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge)
                .fill(AppColors.backgroundLight.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge)
                        .stroke(AppColors.hoangDaoGold.opacity(0.5), lineWidth: 1)
                )
        )
    }
}
