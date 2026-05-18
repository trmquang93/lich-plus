//
//  VanKhanSection.swift
//  lich-plus
//
//  Văn Khấn list section embedded in the Phong tục feed.
//

import SwiftUI

struct VanKhanSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing12) {
            sectionHeader

            ForEach(VanKhanLibrary.grouped(), id: \.0.id) { (category, occasions) in
                if !occasions.isEmpty {
                    categoryBlock(title: category.title, occasions: occasions)
                }
            }
        }
    }

    private var sectionHeader: some View {
        HStack(spacing: AppTheme.spacing8) {
            Image(systemName: "scroll")
                .foregroundStyle(AppColors.primary)
            Text(String(localized: "Văn khấn"))
                .font(.system(size: AppTheme.fontTitle3, weight: .bold))
                .foregroundStyle(AppColors.textPrimary)
            Spacer()
        }
    }

    @ViewBuilder
    private func categoryBlock(title: String, occasions: [VanKhanOccasion]) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing8) {
            Text(title)
                .font(.system(size: AppTheme.fontBody, weight: .semibold))
                .foregroundStyle(AppColors.textSecondary)

            VStack(spacing: 0) {
                ForEach(Array(occasions.enumerated()), id: \.element.id) { idx, occ in
                    NavigationLink {
                        VanKhanDetailView(occasion: occ)
                    } label: {
                        row(occ)
                    }
                    .buttonStyle(.plain)

                    if idx < occasions.count - 1 {
                        Divider().padding(.leading, AppTheme.spacing16)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                    .fill(AppColors.background)
            )
        }
    }

    private func row(_ occasion: VanKhanOccasion) -> some View {
        HStack(spacing: AppTheme.spacing12) {
            VStack(alignment: .leading, spacing: AppTheme.spacing2) {
                Text(occasion.title)
                    .font(.system(size: AppTheme.fontSubheading, weight: .medium))
                    .foregroundStyle(AppColors.textPrimary)
                if let s = occasion.subtitle {
                    Text(s)
                        .font(.system(size: AppTheme.fontCaption))
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(AppColors.textSecondary)
                .font(.system(size: AppTheme.fontCaption, weight: .semibold))
        }
        .padding(AppTheme.spacing12)
    }
}

#Preview {
    NavigationStack {
        ScrollView { VanKhanSection().padding() }
            .background(AppColors.backgroundLightGray)
    }
}
