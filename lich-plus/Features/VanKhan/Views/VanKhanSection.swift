//
//  VanKhanSection.swift
//  lich-plus
//
//  Văn Khấn list section embedded in the Phong tục feed.
//

import SwiftUI

struct VanKhanSection: View {
    /// When non-nil, render exactly these groups (used by search). When nil,
    /// fall back to the full library.
    var filteredGroups: [(VanKhanCategory, [VanKhanOccasion])]? = nil

    private var groups: [(VanKhanCategory, [VanKhanOccasion])] {
        filteredGroups ?? VanKhanLibrary.grouped()
    }

    var body: some View {
        if filteredGroups?.isEmpty == true {
            EmptyView()
        } else {
            VStack(alignment: .leading, spacing: 0) {
                groupTitle

                ForEach(groups, id: \.0.id) { (category, occasions) in
                    if !occasions.isEmpty {
                        categoryBlock(category: category, occasions: occasions)
                    }
                }
            }
        }
    }

    private var groupTitle: some View {
        HStack {
            Text(String(localized: "Văn khấn"))
                .font(.system(size: 13, weight: .semibold))
                .tracking(0.8)
                .textCase(.uppercase)
                .foregroundStyle(AppColors.primaryDark)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .padding(.bottom, 4)
    }

    @ViewBuilder
    private func categoryBlock(category: VanKhanCategory, occasions: [VanKhanOccasion]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader(for: category)

            VStack(spacing: 0) {
                ForEach(Array(occasions.enumerated()), id: \.element.id) { idx, occ in
                    NavigationLink {
                        VanKhanDetailView(occasion: occ)
                    } label: {
                        row(occ)
                    }
                    .buttonStyle(.plain)

                    if idx < occasions.count - 1 {
                        Divider()
                            .background(AppColors.borderLight)
                            .padding(.leading, 64)
                    }
                }

                if category == .anniversary {
                    Divider()
                        .background(AppColors.borderLight)
                        .padding(.leading, 64)
                    NavigationLink {
                        PersonalProfileView()
                    } label: {
                        addDeceasedRow
                    }
                    .buttonStyle(.plain)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.background)
                    .shadow(color: Color.black.opacity(0.04), radius: 1, x: 0, y: 1)
            )
            .padding(.horizontal, 16)
        }
    }

    @ViewBuilder
    private func sectionHeader(for category: VanKhanCategory) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(category.headerLabel)
                .font(.system(size: 13, weight: .semibold))
                .tracking(0.6)
                .textCase(.uppercase)
                .foregroundStyle(AppColors.textSecondary)
            Spacer()
            if category == .festival {
                Text(String(localized: "Xem tất cả"))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(AppColors.primary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, category == .monthly ? 4 : 24)
    }

    private func row(_ occasion: VanKhanOccasion) -> some View {
        HStack(spacing: 12) {
            occasionIcon(occasion)
            VStack(alignment: .leading, spacing: 2) {
                Text(occasion.title)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)
                if let s = occasion.subtitle {
                    Text(s)
                        .font(.system(size: 13))
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(2)
                }
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

    private var addDeceasedRow: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppColors.vkCream)
                    .overlay(Circle().strokeBorder(AppColors.borderLight, lineWidth: 1))
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppColors.primary)
            }
            .frame(width: 36, height: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(String(localized: "Thêm người đã khuất"))
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(AppColors.primary)
                Text(String(localized: "Lưu ngày giỗ âm lịch để nhắc"))
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

    @ViewBuilder
    private func occasionIcon(_ occasion: VanKhanOccasion) -> some View {
        let style = occasion.category.iconStyle
        ZStack {
            Circle()
                .fill(style.background)
                .overlay(
                    Circle().strokeBorder(style.border, lineWidth: style.borderWidth)
                )
            Image(systemName: occasion.iconName)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(style.foreground)
        }
        .frame(width: 36, height: 36)
    }
}

// MARK: - Per-occasion icons + per-category styling

extension VanKhanOccasion {
    var iconName: String {
        switch id {
        case "mung-1-hang-thang":  return "circle"
        case "ram-hang-thang":     return "moon.fill"
        case "than-tai-tho-dia":   return "wallet.pass.fill"
        case "giao-thua":          return "sparkles"
        case "nguyen-dan":         return "star.fill"
        case "ram-thang-gieng":    return "moon.stars.fill"
        case "ong-cong-ong-tao":   return "house.fill"
        case "thanh-minh":         return "leaf.fill"
        case "vu-lan":             return "heart.fill"
        case "trung-thu":          return "moon.haze.fill"
        case "gio":                return "person.crop.circle.fill"
        case "cuoi-hoi":           return "heart.circle.fill"
        case "nhap-trach":         return "house.lodge.fill"
        case "day-thang":          return "figure.and.child.holdinghands"
        case "thoi-noi":           return "figure.child.circle.fill"
        default:                   return "scroll"
        }
    }
}

private struct IconStyle {
    let background: Color
    let foreground: Color
    let border: Color
    let borderWidth: CGFloat
}

private extension VanKhanCategory {
    var headerLabel: String {
        switch self {
        case .monthly:     return String(localized: "Hằng tháng")
        case .festival:    return String(localized: "Lễ Tết lớn")
        case .anniversary: return String(localized: "Giỗ & Gia tiên")
        case .family:      return String(localized: "Sự kiện gia đình")
        }
    }

    var iconStyle: IconStyle {
        switch self {
        case .monthly:
            return IconStyle(
                background: AppColors.backgroundLight,
                foreground: AppColors.primaryDark,
                border: .clear,
                borderWidth: 0
            )
        case .festival, .family:
            return IconStyle(
                background: AppColors.vkGoldTint,
                foreground: AppColors.hoangDaoGold,
                border: AppColors.vkGoldSoft,
                borderWidth: 1
            )
        case .anniversary:
            return IconStyle(
                background: AppColors.primaryDark,
                foreground: .white,
                border: .clear,
                borderWidth: 0
            )
        }
    }
}

#Preview {
    NavigationStack {
        ScrollView { VanKhanSection() }
            .background(AppColors.vkCream)
    }
}
