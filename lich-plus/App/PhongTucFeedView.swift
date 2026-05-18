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
                VStack(alignment: .leading, spacing: 0) {
                    screenHeader
                    TodayHighlightsSection()
                    greetingsSection
                    VanKhanSection()
                    Spacer(minLength: 32)
                }
            }
            .background(AppColors.vkCream)
            .scrollContentBackground(.hidden)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var screenHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(String(localized: "Phong tục"))
                .font(.system(size: 34, weight: .semibold, design: .serif))
                .foregroundStyle(AppColors.primaryDark)
                .tracking(-0.4)
            Text(String(localized: "Lời chúc và văn khấn cổ truyền — gợi ý theo ngày âm lịch của bạn."))
                .font(.system(size: 15))
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    private var greetingsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(String(localized: "Lời chúc"))
                .font(.system(size: 13, weight: .semibold))
                .tracking(0.6)
                .textCase(.uppercase)
                .foregroundStyle(AppColors.textSecondary)
                .padding(.horizontal, 20)
                .padding(.top, 24)

            NavigationLink {
                GreetingGeneratorView()
                    .navigationTitle(String(localized: "Tet Greetings"))
                    .navigationBarTitleDisplayMode(.inline)
            } label: {
                greetingsRow
            }
            .buttonStyle(.plain)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.background)
                    .shadow(color: Color.black.opacity(0.04), radius: 1, x: 0, y: 1)
            )
            .padding(.horizontal, 16)
        }
    }

    private var greetingsRow: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(AppColors.backgroundLight)
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(AppColors.primaryDark)
            }
            .frame(width: 36, height: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(String(localized: "Tạo lời chúc"))
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(AppColors.textPrimary)
                Text(String(localized: "Lời chúc Tết, sinh nhật, đám cưới…"))
                    .font(.system(size: 13))
                    .foregroundStyle(AppColors.textSecondary)
            }
            Spacer(minLength: 8)
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AppColors.textDisabled)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(minHeight: 60)
        .contentShape(Rectangle())
    }
}

#Preview {
    PhongTucFeedView()
}
