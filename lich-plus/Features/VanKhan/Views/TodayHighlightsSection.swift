//
//  TodayHighlightsSection.swift
//  lich-plus
//
//  "Hôm nay" hero — red-gradient feature card that surfaces today's
//  primary matched văn khấn (if any). Tapping pushes its detail view.
//

import SwiftUI
import SwiftData

struct TodayHighlightsSection: View {
    @Query private var profiles: [PersonalProfile]

    private var firstMatch: VanKhanOccasionMatcher.Match? {
        VanKhanOccasionMatcher.match(date: Date(), profile: profiles.first, max: 1).first
    }

    var body: some View {
        if let match = firstMatch {
            NavigationLink {
                VanKhanDetailView(
                    occasion: match.occasion,
                    initialDeceasedId: match.deceasedRelative?.id
                )
            } label: {
                hero(for: match)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16)
            .padding(.top, 16)
        } else {
            EmptyView()
        }
    }

    private func hero(for match: VanKhanOccasionMatcher.Match) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(kickerText)
                .font(.system(size: 11, weight: .semibold))
                .tracking(1.2)
                .textCase(.uppercase)
                .foregroundStyle(AppColors.vkGoldSoft)

            Text(heroTitle(for: match))
                .font(.system(size: 26, weight: .semibold, design: .serif))
                .foregroundStyle(.white)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .padding(.top, 2)

            Text(heroSubtitle(for: match))
                .font(.system(size: 14))
                .foregroundStyle(Color.white.opacity(0.78))
                .padding(.top, 2)

            HStack(spacing: 6) {
                Text(String(localized: "Xem gợi ý hôm nay"))
                    .font(.system(size: 14, weight: .semibold))
                Image(systemName: "arrow.right")
                    .font(.system(size: 12, weight: .bold))
            }
            .foregroundStyle(AppColors.primaryDark)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Capsule().fill(AppColors.hoangDaoGold))
            .padding(.top, 12)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 18)
        .padding(.bottom, 20)
        .background(
            ZStack {
                LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primary],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                // Gold radial accent in top-right
                GeometryReader { geo in
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [AppColors.hoangDaoGold.opacity(0.45), .clear],
                                center: .topTrailing,
                                startRadius: 4,
                                endRadius: 110
                            )
                        )
                        .frame(width: 160, height: 160)
                        .offset(x: geo.size.width - 120, y: -40)
                }
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .contentShape(RoundedRectangle(cornerRadius: 20))
    }

    private var kickerText: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "vi_VN")
        f.dateFormat = "EEEE d/M"
        let solar = f.string(from: Date()).capitalized(with: f.locale)
        return String(format: String(localized: "Hôm nay · %@"), solar)
    }

    private func heroTitle(for match: VanKhanOccasionMatcher.Match) -> String {
        if let r = match.deceasedRelative {
            return String(format: String(localized: "Giỗ %@ %@"), r.relation, r.name)
        }
        return match.occasion.title
            .replacingOccurrences(of: "Văn khấn ", with: "")
    }

    private func heroSubtitle(for match: VanKhanOccasionMatcher.Match) -> String {
        match.occasion.subtitle ?? String(localized: "Đã điền sẵn thông tin của bạn")
    }
}
