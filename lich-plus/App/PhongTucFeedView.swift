//
//  PhongTucFeedView.swift
//  lich-plus
//
//  Root of the Phong tục tab — merges Hôm nay + Lời chúc + Văn khấn into
//  a single scrolling feed under one NavigationStack.
//

import SwiftUI

struct PhongTucFeedView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.spacing20) {
                    TodayHighlightsSection()
                    greetingsLink
                    VanKhanSection()
                }
                .padding(AppTheme.spacing16)
            }
            .background(AppColors.backgroundLightGray)
            .navigationTitle(String(localized: "Phong tục"))
        }
    }

    private var greetingsLink: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing12) {
            HStack(spacing: AppTheme.spacing8) {
                Image(systemName: "gift.fill")
                    .foregroundStyle(AppColors.primary)
                Text(String(localized: "Lời chúc"))
                    .font(.system(size: AppTheme.fontTitle3, weight: .bold))
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
            }

            NavigationLink {
                GreetingGeneratorView()
                    .navigationTitle(String(localized: "Tet Greetings"))
                    .navigationBarTitleDisplayMode(.inline)
            } label: {
                HStack(spacing: AppTheme.spacing12) {
                    Image(systemName: "wand.and.stars")
                        .font(.title2)
                        .foregroundStyle(AppColors.primary)
                        .frame(width: 32)
                    VStack(alignment: .leading, spacing: AppTheme.spacing2) {
                        Text(String(localized: "Tạo lời chúc"))
                            .font(.system(size: AppTheme.fontSubheading, weight: .medium))
                            .foregroundStyle(AppColors.textPrimary)
                        Text(String(localized: "Lời chúc Tết, sinh nhật, đám cưới…"))
                            .font(.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(AppColors.textSecondary)
                }
                .padding(AppTheme.spacing12)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                        .fill(AppColors.background)
                )
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    PhongTucFeedView()
}
