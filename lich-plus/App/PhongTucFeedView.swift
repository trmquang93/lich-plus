//
//  PhongTucFeedView.swift
//  lich-plus
//
//  Root of the Phong tục tab — merges Hôm nay + Lời chúc + Văn khấn into
//  a single scrolling feed under one NavigationStack.
//

import SwiftUI
import SwiftData

struct PhongTucFeedView: View {
    @State private var searchText: String = ""
    @FocusState private var isSearchFocused: Bool

    private var trimmedQuery: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isSearching: Bool { !trimmedQuery.isEmpty }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    screenHeader
                    searchBar
                    if !isSearching {
                        TodayHighlightsSection()
                    }
                    let greetings = filteredGreetings
                    let vanKhanGroups = filteredVanKhanGroups
                    if !greetings.isEmpty {
                        greetingsSection(items: greetings)
                    }
                    VanKhanSection(filteredGroups: isSearching ? vanKhanGroups : nil)
                    if isSearching && greetings.isEmpty && vanKhanGroups.isEmpty {
                        emptyResults
                    }
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

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(AppColors.textDisabled)
            TextField(
                String(localized: "Tìm lời chúc, bài khấn…"),
                text: $searchText
            )
            .font(.system(size: 15))
            .foregroundStyle(AppColors.textPrimary)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
            .submitLabel(.search)
            .focused($isSearchFocused)
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(AppColors.textDisabled)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(AppColors.background)
                .overlay(Capsule().strokeBorder(AppColors.borderLight, lineWidth: 1))
        )
        .contentShape(Capsule())
        .onTapGesture { isSearchFocused = true }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    private func greetingsSection(items: [GreetingCategoryItem]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(String(localized: "Lời chúc"))
                    .font(.system(size: 13, weight: .semibold))
                    .tracking(0.6)
                    .textCase(.uppercase)
                    .foregroundStyle(AppColors.textSecondary)
                Spacer()
                if !isSearching {
                    Text(String(localized: "Xem tất cả"))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(AppColors.primary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)

            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element.occasion) { idx, item in
                    NavigationLink {
                        GreetingGeneratorView(occasion: item.occasion)
                            .navigationTitle(item.title)
                            .navigationBarTitleDisplayMode(.inline)
                    } label: {
                        greetingRow(item)
                    }
                    .buttonStyle(.plain)

                    if idx < items.count - 1 {
                        Divider()
                            .background(AppColors.borderLight)
                            .padding(.leading, 64)
                    }
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

    private struct GreetingCategoryItem {
        let occasion: GreetingOccasion
        let title: String
        let subtitle: String
        let icon: String
    }

    private var greetingCategories: [GreetingCategoryItem] {
        [
            GreetingCategoryItem(
                occasion: .tet,
                title: String(localized: "Chúc Tết"),
                subtitle: String(localized: "Lời chúc năm mới"),
                icon: "envelope.fill"
            ),
            GreetingCategoryItem(
                occasion: .birthday,
                title: String(localized: "Sinh nhật"),
                subtitle: String(localized: "Gửi người thân, bạn bè"),
                icon: "gift.fill"
            ),
            GreetingCategoryItem(
                occasion: .wedding,
                title: String(localized: "Cưới hỏi"),
                subtitle: String(localized: "Lời chúc trăm năm hạnh phúc"),
                icon: "heart.fill"
            ),
            GreetingCategoryItem(
                occasion: .housewarming,
                title: String(localized: "Mừng tân gia"),
                subtitle: String(localized: "An cư lạc nghiệp"),
                icon: "house.fill"
            ),
        ]
    }

    private var filteredGreetings: [GreetingCategoryItem] {
        let q = trimmedQuery
        guard !q.isEmpty else { return greetingCategories }
        return greetingCategories.filter {
            Self.matches($0.title, q) || Self.matches($0.subtitle, q)
        }
    }

    private var filteredVanKhanGroups: [(VanKhanCategory, [VanKhanOccasion])] {
        let q = trimmedQuery
        let all = VanKhanLibrary.grouped()
        guard !q.isEmpty else { return all }
        return all.compactMap { (cat, occasions) in
            let matched = occasions.filter {
                Self.matches($0.title, q) || Self.matches($0.subtitle ?? "", q)
            }
            return matched.isEmpty ? nil : (cat, matched)
        }
    }

    private static func matches(_ haystack: String, _ needle: String) -> Bool {
        haystack.range(
            of: needle,
            options: [.caseInsensitive, .diacriticInsensitive]
        ) != nil
    }

    private var emptyResults: some View {
        VStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 28, weight: .light))
                .foregroundStyle(AppColors.textDisabled)
            Text(String(localized: "Không có kết quả"))
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(AppColors.textPrimary)
            Text(String(localized: "Thử từ khoá khác."))
                .font(.system(size: 13))
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }

    private func greetingRow(_ item: GreetingCategoryItem) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(AppColors.backgroundLight)
                Image(systemName: item.icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(AppColors.primaryDark)
            }
            .frame(width: 36, height: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(AppColors.textPrimary)
                Text(item.subtitle)
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
    let container = try! ModelContainer(
        for: PersonalProfile.self, DeceasedRelative.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let lunar = LunarCalendar.solarToLunar(Date())
    let relative = DeceasedRelative(
        relation: "ông",
        name: "Nguyễn Văn A",
        lunarDay: lunar.day,
        lunarMonth: lunar.month
    )
    let profile = PersonalProfile(
        fullName: "Trần Quang",
        address: "Hà Nội",
        deceasedRelatives: [relative]
    )
    container.mainContext.insert(profile)

    return PhongTucFeedView()
        .modelContainer(container)
}
