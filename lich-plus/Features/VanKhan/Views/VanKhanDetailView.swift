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
    @State private var selectedDeceasedId: UUID?
    @State private var showOverridesExpanded: Bool = false
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

    private var overrides: [String: String] {
        var dict: [String: String] = [:]
        if !nameOverride.isEmpty { dict["name"] = nameOverride }
        if !addressOverride.isEmpty { dict["address"] = addressOverride }
        return dict
    }

    private var text: VanKhanText {
        VanKhanLibrary.text(for: occasion.id) ??
        VanKhanText(occasionId: occasion.id, body: "[Chưa có bản văn khấn cho dịp này]")
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.spacing20) {
                titleSection
                if occasion.category == .anniversary {
                    deceasedPicker
                }
                paperCard
                overridesSection
                exportButton
            }
            .padding(AppTheme.spacing16)
        }
        .background(AppColors.backgroundLightGray)
        .navigationTitle(occasion.title)
        .navigationBarTitleDisplayMode(.inline)
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

    // MARK: - Sections

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing4) {
            Text(occasion.title)
                .font(.system(size: 22, weight: .semibold, design: .serif))
                .foregroundStyle(AppColors.primary)
            if let s = occasion.subtitle {
                Text(s)
                    .font(.system(size: AppTheme.fontBody))
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
    }

    @ViewBuilder
    private var deceasedPicker: some View {
        if let p = profile, !p.deceasedRelatives.isEmpty {
            VStack(alignment: .leading, spacing: AppTheme.spacing8) {
                Text(String(localized: "Người được giỗ"))
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
                Picker("", selection: $selectedDeceasedId) {
                    ForEach(p.deceasedRelatives) { r in
                        Text("\(r.relation) \(r.name)").tag(Optional(r.id))
                    }
                }
                .pickerStyle(.menu)
            }
        } else {
            Text(String(localized: "Hãy thêm Người đã khuất trong Cài đặt → Cá nhân để cá nhân hoá nội dung văn khấn giỗ."))
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)
                .padding(AppTheme.spacing12)
                .background(AppColors.backgroundLight)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium))
        }
    }

    private var paperCard: some View {
        VanKhanRenderedBody(
            text: text,
            profile: profile,
            overrides: overrides,
            context: renderContext
        )
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppTheme.spacing20)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge)
                .fill(AppColors.backgroundLight.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge)
                        .stroke(AppColors.hoangDaoGold.opacity(0.6), lineWidth: 1)
                )
        )
    }

    private var overridesSection: some View {
        DisclosureGroup(isExpanded: $showOverridesExpanded) {
            VStack(spacing: AppTheme.spacing12) {
                overrideField(title: String(localized: "Tên (Tín chủ)"), text: $nameOverride, placeholder: profile?.fullName ?? "")
                overrideField(title: String(localized: "Địa chỉ"), text: $addressOverride, placeholder: profile?.address ?? "")
                if occasion.id == "day-thang" || occasion.id == "thoi-noi" {
                    overrideField(title: String(localized: "Tên bé"), text: $childNameOverride, placeholder: "")
                }
            }
            .padding(.top, AppTheme.spacing8)
        } label: {
            Label(String(localized: "Tuỳ chỉnh thông tin"), systemImage: "pencil.circle")
                .foregroundStyle(AppColors.primary)
        }
        .padding(AppTheme.spacing12)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                .fill(AppColors.background)
        )
    }

    private func overrideField(title: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)
            TextField(placeholder, text: text, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(1...3)
        }
    }

    private var exportButton: some View {
        Button {
            Task { await exportPDF() }
        } label: {
            HStack {
                if isExporting {
                    ProgressView().tint(.white)
                } else {
                    Image(systemName: "doc.text")
                    Text(String(localized: "Xuất PDF"))
                }
            }
            .font(.system(size: AppTheme.fontSubheading, weight: .semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.spacing12)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                    .fill(AppColors.primary)
            )
        }
        .disabled(isExporting)
    }

    @MainActor
    private func exportPDF() async {
        isExporting = true
        defer { isExporting = false }

        let rendered = VanKhanRenderer.render(
            text: text,
            profile: profile,
            overrides: overrides,
            context: renderContext
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
