//
//  KinhDichView.swift
//  lich-plus
//
//  Offline I Ching divination — entertainment / tradition framing.
//

import SwiftUI

struct KinhDichView: View {
    @State private var question: String = ""
    @State private var tossResults: [KinhDichLineValue] = []
    @State private var reading: KinhDichReading?
    @State private var isAnimating = false

    private var canToss: Bool { tossResults.count < 6 && !isAnimating }
    private var canReset: Bool { !tossResults.isEmpty || reading != nil }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.spacing16) {
                introSection
                questionSection
                tossSection
                if let reading {
                    resultSection(reading)
                }
            }
            .padding(AppTheme.spacing16)
        }
        .background(AppColors.vkCream)
        .navigationTitle(String(localized: "Xem quẻ Kinh Dịch"))
        .navigationBarTitleDisplayMode(.inline)
        .trackAnalyticsScreen(.kinh_dich)
    }

    private var introSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing8) {
            Text(String(localized: "Gieo 3 đồng sáu lần để lấy một quẻ. Chỉ mang tính tham khảo — không thay lời khuyên chuyên môn."))
                .elderModeFont(size: AppTheme.fontBody)
                .foregroundStyle(AppColors.textSecondary)
        }
    }

    private var questionSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing8) {
            Text(String(localized: "Optional question (kept on device only)"))
                .elderModeFont(size: AppTheme.fontCaption, weight: .semibold)
                .foregroundStyle(AppColors.textSecondary)
            TextField(String(localized: "What is on your mind?"), text: $question, axis: .vertical)
                .lineLimit(2...4)
                .textFieldStyle(.roundedBorder)
        }
    }

    private var tossSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing12) {
            HStack {
                Text(String(format: String(localized: "Toss %lld of 6"), min(tossResults.count + 1, 6)))
                    .elderModeFont(size: AppTheme.fontSubheading, weight: .semibold)
                Spacer()
                if canReset {
                    Button(String(localized: "Reset")) { reset() }
                        .elderModeFont(size: AppTheme.fontBody, weight: .medium)
                        .accessibilityIdentifier("kinhdich.reset")
                }
            }

            HStack(spacing: AppTheme.spacing8) {
                ForEach(0..<6, id: \.self) { index in
                    lineChip(index: index)
                }
            }

            Button {
                performToss()
            } label: {
                Label(
                    tossResults.count == 6 ? String(localized: "Complete") : String(localized: "Gieo 3 đồng"),
                    systemImage: "circle.grid.3x3.fill"
                )
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(AppColors.primary)
            .disabled(!canToss)
            .accessibilityIdentifier("kinhdich.toss")
        }
        .padding(AppTheme.spacing16)
        .background(AppColors.background)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge))
    }

    private func lineChip(index: Int) -> some View {
        let filled = index < tossResults.count
        let line = filled ? tossResults[index] : nil
        return VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 2)
                .fill(filled ? AppColors.primary : AppColors.borderLight)
                .frame(height: line?.isYang == false ? 4 : 8)
            if line?.isYang == false {
                RoundedRectangle(cornerRadius: 2)
                    .fill(filled ? AppColors.primary : AppColors.borderLight)
                    .frame(height: 4)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 28)
    }

    private func resultSection(_ reading: KinhDichReading) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing12) {
            Text(reading.hexagram.name)
                .elderModeFont(size: AppTheme.fontTitle2, weight: .bold, design: .serif)
                .foregroundStyle(AppColors.primaryDark)

            Text(String(localized: "Lời bàn"))
                .elderModeFont(size: AppTheme.fontCaption, weight: .semibold)
                .foregroundStyle(AppColors.textSecondary)

            Text(reading.summary)
                .elderModeFont(size: AppTheme.fontBody)
                .foregroundStyle(AppColors.textPrimary)

            if let note = reading.changingNote {
                Text(note)
                    .elderModeFont(size: AppTheme.fontCaption)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .padding(AppTheme.spacing16)
        .background(AppColors.vkPaper)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge)
                .strokeBorder(AppColors.vkGoldSoft, lineWidth: 1)
        )
        .accessibilityIdentifier("kinhdich.result")
        .onAppear {
            AnalyticsService.shared.logFeatureUsed(.xem_que)
        }
    }

    private func performToss() {
        guard canToss else { return }
        isAnimating = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            var rng = SystemRandomNumberGenerator()
            let line = KinhDichEngine.tossCoins(rng: &rng)
            tossResults.append(line)
            if tossResults.count == 6 {
                reading = KinhDichEngine.reading(from: tossResults)
            }
            isAnimating = false
        }
    }

    private func reset() {
        tossResults = []
        reading = nil
    }
}

#Preview {
    NavigationStack {
        KinhDichView()
    }
}
