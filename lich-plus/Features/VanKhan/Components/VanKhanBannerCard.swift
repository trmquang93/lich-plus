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

    /// Up to 2 matches surfaced; at most one giỗ to avoid spam when
    /// multiple deceased relatives share a lunar date.
    private var matches: [VanKhanOccasionMatcher.Match] {
        let raw = VanKhanOccasionMatcher.match(date: day.date, profile: profiles.first, max: 4)
        var result: [VanKhanOccasionMatcher.Match] = []
        var giỗSeen = false
        for m in raw {
            if m.occasion.category == .anniversary {
                if giỗSeen { continue }
                giỗSeen = true
            }
            result.append(m)
            if result.count >= 2 { break }
        }
        return result
    }

    var body: some View {
        if matches.isEmpty {
            EmptyView()
        } else {
            VStack(alignment: .leading, spacing: 10) {
                header
                VStack(spacing: 6) {
                    ForEach(Array(matches.enumerated()), id: \.offset) { _, match in
                        NavigationLink {
                            VanKhanDetailView(
                                occasion: match.occasion,
                                initialDeceasedId: match.deceasedRelative?.id
                            )
                        } label: {
                            optionPill(for: match)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 14)
            .padding(.bottom, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.vkGoldTint)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(AppColors.vkGoldSoft, lineWidth: 1)
                    )
            )
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 10) {
            emblem
            VStack(alignment: .leading, spacing: 2) {
                Text(eyebrowText)
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1.2)
                    .textCase(.uppercase)
                    .foregroundStyle(AppColors.hoangDaoGold)
                Text(String(localized: "Văn khấn hôm nay"))
                    .font(.system(size: 18, weight: .semibold, design: .serif))
                    .foregroundStyle(AppColors.primaryDark)
                    .lineLimit(2)
            }
            Spacer(minLength: 0)
        }
    }

    private var emblem: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            AppColors.hoangDaoGold,
                            Color(red: 185/255, green: 143/255, blue: 44/255)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: AppColors.hoangDaoGold.opacity(0.4), radius: 4, x: 0, y: 2)
            Image(systemName: "scroll.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
        }
        .frame(width: 40, height: 40)
    }

    private var eyebrowText: String {
        let lunar = LunarCalendar.solarToLunar(day.date)
        switch lunar.day {
        case 1:  return String(localized: "Hôm nay là ngày Mùng 1")
        case 15: return String(localized: "Hôm nay là ngày Rằm")
        default: return String(localized: "Văn khấn gợi ý hôm nay")
        }
    }

    // MARK: - Option pill

    private func optionPill(for match: VanKhanOccasionMatcher.Match) -> some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(AppColors.backgroundLight)
                Image(systemName: match.occasion.iconName)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppColors.primary)
            }
            .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 1) {
                Text(displayTitle(for: match))
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(1)
                Text(displaySubtitle(for: match))
                    .font(.system(size: 12))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 4)

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AppColors.textDisabled)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(minHeight: 48)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(AppColors.background)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(AppColors.hoangDaoGold.opacity(0.35), lineWidth: 1)
                )
        )
        .contentShape(Rectangle())
    }

    private func displayTitle(for match: VanKhanOccasionMatcher.Match) -> String {
        if let r = match.deceasedRelative {
            return String(format: String(localized: "Giỗ %@ %@"), r.relation, r.name)
        }
        return match.occasion.title
    }

    private func displaySubtitle(for match: VanKhanOccasionMatcher.Match) -> String {
        if match.deceasedRelative != nil {
            return String(localized: "Đã điền sẵn thông tin")
        }
        return match.occasion.subtitle ?? ""
    }
}
