//
//  VanKhanDetailView.swift
//  lich-plus
//

import SwiftUI
import SwiftData

struct VanKhanDetailView: View {
    let occasion: VanKhanOccasion
    /// Optional: bind a specific deceased relative when entering from a giỗ banner.
    let initialDeceasedId: UUID?

    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [PersonalProfile]

    @State private var addressOverride: String = ""
    @State private var nameOverride: String = ""
    @State private var childNameOverride: String = ""
    @State private var partnerNameOverride: String = ""
    @State private var selectedDeceasedId: UUID?
    @State private var isEditingInfo: Bool = false
    @State private var pdfURL: URL?
    @State private var isExporting = false

    init(occasion: VanKhanOccasion, initialDeceasedId: UUID? = nil) {
        self.occasion = occasion
        self.initialDeceasedId = initialDeceasedId
    }

    private var profile: PersonalProfile? { profiles.first }

    private var selectedDeceased: DeceasedRelative? {
        guard let p = profile, let id = selectedDeceasedId else { return nil }
        return p.deceasedRelatives.first { $0.id == id }
    }

    private var renderContext: VanKhanRenderer.Context {
        VanKhanRenderer.Context(
            date: Date(),
            deceasedRelative: selectedDeceased,
            childName: childNameOverride.isEmpty ? nil : childNameOverride
        )
    }

    private var hiddenSections: Set<VanKhanSectionTag> {
        var hidden: Set<VanKhanSectionTag> = []
        if profile?.showAncestorsSection == false { hidden.insert(.ancestors) }
        return hidden
    }

    private var overrides: [String: String] {
        var dict: [String: String] = [:]
        if !nameOverride.isEmpty { dict[VanKhanToken.name.rawValue] = nameOverride }
        if !addressOverride.isEmpty { dict[VanKhanToken.address.rawValue] = addressOverride }
        if !partnerNameOverride.isEmpty { dict[VanKhanToken.partnerName.rawValue] = partnerNameOverride }
        return dict
    }

    private var text: VanKhanText {
        VanKhanLibrary.text(for: occasion.id) ??
        VanKhanText(occasionId: occasion.id, body: "[Chưa có bản văn khấn cho dịp này]")
    }

    private var resolvedName: String {
        !nameOverride.isEmpty ? nameOverride : (profile?.fullName ?? "")
    }

    private var resolvedAddress: String {
        !addressOverride.isEmpty ? addressOverride : (profile?.address ?? "")
    }

    private var lunarKicker: String {
        let lunar = LunarCalendar.solarToLunar(Date())
        return String(format: String(localized: "%d tháng %d ÂL"), lunar.day, lunar.month)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                titleBlock
                if occasion.category == .anniversary {
                    deceasedPickerSection
                }
                infoSection
                paperSection
                Spacer(minLength: 24)
            }
        }
        .background(AppColors.vkCream)
        .scrollContentBackground(.hidden)
        .navigationTitle(navTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task { await exportPDF() }
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
                .tint(AppColors.primary)
                .disabled(isExporting)
            }
        }
        .safeAreaInset(edge: .bottom) {
            actionBar
        }
        .onAppear {
            selectedDeceasedId = initialDeceasedId ?? profile?.deceasedRelatives.first?.id
        }
        .sheet(item: Binding(
            get: { pdfURL.map { ShareablePDFURL(url: $0) } },
            set: { if $0 == nil { pdfURL = nil } }
        )) { wrapper in
            ShareSheet(items: [wrapper.url])
        }
    }

    private var navTitle: String {
        occasion.title.replacingOccurrences(of: "Văn khấn ", with: "")
    }

    // MARK: - Title block

    private var titleBlock: some View {
        VStack(spacing: 8) {
            Text(lunarKicker)
                .font(.system(size: 11, weight: .bold))
                .tracking(1.4)
                .textCase(.uppercase)
                .foregroundStyle(AppColors.hoangDaoGold)

            Text(occasion.title)
                .font(.system(size: 30, weight: .semibold, design: .serif))
                .tracking(-0.3)
                .foregroundStyle(AppColors.primaryDark)
                .multilineTextAlignment(.center)
                .lineLimit(3)

            if let s = occasion.subtitle {
                Text(s)
                    .font(.system(size: 14))
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            ornament
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .padding(.bottom, 8)
    }

    private var ornament: some View {
        HStack(spacing: 10) {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.clear, AppColors.vkGoldSoft],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 56, height: 1)
            Image(systemName: "sparkle")
                .font(.system(size: 12))
                .foregroundStyle(AppColors.hoangDaoGold)
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [AppColors.vkGoldSoft, .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 56, height: 1)
        }
    }

    // MARK: - Deceased picker (anniversary only)

    @ViewBuilder
    private var deceasedPickerSection: some View {
        if let p = profile, !p.deceasedRelatives.isEmpty {
            sectionHeader(String(localized: "Người được giỗ"), trailing: nil)
            VStack(spacing: 0) {
                Picker(String(localized: "Người được giỗ"), selection: $selectedDeceasedId) {
                    ForEach(p.deceasedRelatives) { r in
                        Text("\(r.relation) \(r.name)").tag(Optional(r.id))
                    }
                }
                .pickerStyle(.menu)
                .tint(AppColors.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(minHeight: 48)
            }
            .background(
                RoundedRectangle(cornerRadius: 16).fill(AppColors.background)
            )
            .padding(.horizontal, 16)
        } else {
            Text(String(localized: "Hãy thêm Người đã khuất trong Cài đặt → Cá nhân để cá nhân hoá nội dung văn khấn giỗ."))
                .font(.system(size: 13))
                .foregroundStyle(AppColors.textSecondary)
                .padding(.horizontal, 16)
                .padding(.top, 8)
        }
    }

    // MARK: - Personal info section

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader(
                String(localized: "Thông tin cá nhân"),
                trailing: isEditingInfo ? String(localized: "Xong") : String(localized: "Chỉnh sửa")
            ) {
                isEditingInfo.toggle()
            }

            VStack(spacing: 0) {
                infoRow(
                    label: String(localized: "Tín chủ"),
                    value: resolvedName,
                    placeholder: String(localized: "Chưa có tên"),
                    binding: $nameOverride
                )
                Divider().padding(.leading, 16)
                infoRow(
                    label: String(localized: "Địa chỉ"),
                    value: resolvedAddress,
                    placeholder: String(localized: "Chưa có địa chỉ"),
                    binding: $addressOverride
                )
                if needsChildName {
                    Divider().padding(.leading, 16)
                    infoRow(
                        label: String(localized: "Tên bé"),
                        value: childNameOverride,
                        placeholder: String(localized: "Nhập tên bé"),
                        binding: $childNameOverride
                    )
                }
                if needsPartnerName {
                    Divider().padding(.leading, 16)
                    infoRow(
                        label: String(localized: "Tên bạn đời"),
                        value: partnerNameOverride,
                        placeholder: String(localized: "Tên vợ/chồng của con"),
                        binding: $partnerNameOverride
                    )
                }
                Divider().padding(.leading, 16)
                infoRow(
                    label: String(localized: "Ngày khấn"),
                    value: lunarKicker,
                    placeholder: "",
                    binding: nil
                )
            }
            .background(
                RoundedRectangle(cornerRadius: 16).fill(AppColors.background)
            )
            .padding(.horizontal, 16)
        }
    }

    private var needsChildName: Bool {
        occasion.id == "day-thang" || occasion.id == "thoi-noi"
    }

    private var needsPartnerName: Bool {
        occasion.id == "cuoi-hoi"
    }

    private func infoRow(
        label: String,
        value: String,
        placeholder: String,
        binding: Binding<String>?
    ) -> some View {
        HStack(spacing: 12) {
            Text(label)
                .font(.system(size: 13))
                .foregroundStyle(AppColors.textSecondary)
                .frame(width: 92, alignment: .leading)

            if isEditingInfo, let binding = binding {
                TextField(placeholder, text: binding)
                    .font(.system(size: 17))
                    .foregroundStyle(AppColors.textPrimary)
                    .textFieldStyle(.plain)
                    .submitLabel(.done)
            } else if value.isEmpty {
                Text(placeholder)
                    .font(.system(size: 17, weight: .regular))
                    .italic()
                    .foregroundStyle(AppColors.primary)
                Spacer(minLength: 0)
            } else {
                Text(value)
                    .font(.system(size: 17))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)
                Spacer(minLength: 0)
            }

            if binding != nil {
                Image(systemName: isEditingInfo ? "checkmark.circle.fill" : "pencil")
                    .font(.system(size: 13))
                    .foregroundStyle(isEditingInfo ? AppColors.primary : AppColors.textDisabled)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(minHeight: 48)
    }

    // MARK: - Paper card

    private var paperSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader(String(localized: "Bài khấn"), trailing: nil)

            VStack(alignment: .leading, spacing: 14) {
                VanKhanRenderedBody(
                    text: text,
                    profile: profile,
                    overrides: overrides,
                    context: renderContext,
                    hiddenSections: hiddenSections
                )
                .frame(maxWidth: .infinity, alignment: .leading)

                paperFooter
            }
            .padding(.horizontal, 22)
            .padding(.top, 24)
            .padding(.bottom, 22)
            .background(
                RoundedRectangle(cornerRadius: 18).fill(AppColors.vkPaper)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(AppColors.vkGoldSoft, lineWidth: 1)
            )
            .padding(.horizontal, 16)
        }
    }

    private var paperFooter: some View {
        VStack(spacing: 12) {
            // Dashed gold rule
            DashedGoldRule()
                .frame(height: 1)
            HStack {
                Text(String(localized: "Theo Văn khấn cổ truyền Việt Nam"))
                Spacer()
                Text("1 / 1")
            }
            .font(.system(size: 13))
            .foregroundStyle(AppColors.textSecondary)
        }
    }

    // MARK: - Section header helper

    private func sectionHeader(_ title: String, trailing: String?, onTap: (() -> Void)? = nil) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .tracking(0.6)
                .textCase(.uppercase)
                .foregroundStyle(AppColors.textSecondary)
            Spacer()
            if let trailing {
                Button(action: { onTap?() }) {
                    Text(trailing)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(AppColors.primary)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 8)
    }

    // MARK: - Sticky bottom action bar

    private var actionBar: some View {
        HStack(spacing: 10) {
            Button {
                copyToClipboard()
            } label: {
                Image(systemName: "doc.on.doc")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(AppColors.primaryDark)
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(AppColors.background)
                            .overlay(Circle().strokeBorder(AppColors.borderLight, lineWidth: 1))
                    )
            }

            Button {
                Task { await exportPDF() }
            } label: {
                HStack(spacing: 8) {
                    if isExporting {
                        ProgressView().tint(.white)
                    } else {
                        Image(systemName: "doc.text")
                        Text(String(localized: "Xuất PDF để in"))
                    }
                }
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(Capsule().fill(AppColors.primary))
            }
            .disabled(isExporting)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(
            AppColors.vkCream.opacity(0.94)
                .background(.ultraThinMaterial)
        )
        .overlay(alignment: .top) {
            Rectangle().fill(AppColors.borderLight).frame(height: 0.5)
        }
    }

    // MARK: - Actions

    private func copyToClipboard() {
        let rendered = VanKhanRenderer.render(
            text: text,
            profile: profile,
            overrides: overrides,
            context: renderContext,
            hiddenSections: hiddenSections
        )
        UIPasteboard.general.string = rendered
    }

    @MainActor
    private func exportPDF() async {
        isExporting = true
        defer { isExporting = false }

        let rendered = VanKhanRenderer.render(
            text: text,
            profile: profile,
            overrides: overrides,
            context: renderContext,
            hiddenSections: hiddenSections
        )

        let url = VanKhanPDFRenderer.renderToTempFile(
            title: occasion.title,
            subtitle: occasion.subtitle,
            body: rendered,
            slug: occasion.id
        )
        pdfURL = url
    }
}

// MARK: - Dashed gold rule

private struct DashedGoldRule: View {
    var body: some View {
        GeometryReader { geo in
            Path { p in
                p.move(to: CGPoint(x: 0, y: 0))
                p.addLine(to: CGPoint(x: geo.size.width, y: 0))
            }
            .stroke(
                AppColors.vkGoldSoft,
                style: StrokeStyle(lineWidth: 1, dash: [4, 4])
            )
        }
    }
}

// MARK: - ShareSheet helpers

private struct ShareablePDFURL: Identifiable {
    let id = UUID()
    let url: URL
}

private struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        VanKhanDetailView(occasion: VanKhanLibrary.monthly[1])
            .modelContainer(PersistenceController.preview.container)
    }
}
