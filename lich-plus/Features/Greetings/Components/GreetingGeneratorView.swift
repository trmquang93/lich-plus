//
//  GreetingGeneratorView.swift
//  lich-plus
//
//  Created by Claude on 17/01/26.
//

import SwiftUI

struct GreetingGeneratorView: View {
    @State private var selectedRecipient: RecipientType = .parents
    @State private var selectedTone: GreetingTone = .formal
    @State private var recipientName: String = ""
    @State private var additionalInfo: String = ""
    @State private var generatedGreeting: GeneratedGreeting?
    @State private var isGenerating: Bool = false
    @State private var errorMessage: String?
    @State private var showCopiedToast: Bool = false

    private let greetingService = GreetingService()
    private let currentYear = Calendar.current.component(.year, from: Date())

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: AppTheme.spacing20) {
                // Header
                headerSection

                // Recipient Selection
                recipientSection

                // Tone Selection
                toneSection

                // Optional Name Input
                nameInputSection

                // Additional Info Input
                additionalInfoSection

                // Generate Button
                generateButton

                // Generated Greeting Card
                if let greeting = generatedGreeting {
                    greetingCard(greeting)
                        .id("greetingCard")
                }

                // Error Message
                if let error = errorMessage {
                    errorView(error)
                }

                Spacer(minLength: AppTheme.spacing24)
            }
            .padding(.horizontal, AppTheme.spacing16)
            .padding(.top, AppTheme.spacing16)
        }
            .background(AppColors.backgroundLightGray)
            .scrollDismissesKeyboard(.interactively)
            .overlay(alignment: .top) {
                if showCopiedToast {
                    copiedToast
                }
            }
            .onChange(of: generatedGreeting) { _, newGreeting in
                if newGreeting != nil {
                    withAnimation {
                        proxy.scrollTo("greetingCard", anchor: .bottom)
                    }
                }
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: AppTheme.spacing8) {
            Text("🧧")
                .font(.system(size: 48))

            Text(String(localized: "Tet Greetings \(GreetingOccasion.canChi(for: currentYear))"))
                .font(.system(size: AppTheme.fontTitle2, weight: .bold))
                .foregroundColor(AppColors.textPrimary)

            Text(String(localized: "Year of") + " \(GreetingOccasion.zodiacAnimal(for: currentYear) ?? "Unknown")")
                .font(.system(size: AppTheme.fontBody))
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(.vertical, AppTheme.spacing8)
    }

    // MARK: - Recipient Section

    private var recipientSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing12) {
            Text(String(localized: "Send to"))
                .font(.system(size: AppTheme.fontSubheading, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: AppTheme.spacing8) {
                ForEach(RecipientType.allCases) { recipient in
                    recipientButton(recipient)
                }
            }
        }
        .padding(AppTheme.spacing16)
        .background(AppColors.background)
        .cornerRadius(AppTheme.cornerRadiusLarge)
    }

    private func recipientButton(_ recipient: RecipientType) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedRecipient = recipient
            }
        } label: {
            VStack(spacing: AppTheme.spacing4) {
                Image(systemName: recipient.icon)
                    .font(.system(size: 20))
                    .foregroundColor(selectedRecipient == recipient ? AppColors.white : AppColors.primary)

                Text(recipient.displayName)
                    .font(.system(size: AppTheme.fontCaption))
                    .foregroundColor(selectedRecipient == recipient ? AppColors.white : AppColors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.spacing12)
            .background(selectedRecipient == recipient ? AppColors.primary : AppColors.backgroundLight)
            .cornerRadius(AppTheme.cornerRadiusMedium)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Tone Section

    private var toneSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing12) {
            Text(String(localized: "Style"))
                .font(.system(size: AppTheme.fontSubheading, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)

            HStack(spacing: AppTheme.spacing8) {
                ForEach(availableTones) { tone in
                    toneButton(tone)
                }
            }
        }
        .padding(AppTheme.spacing16)
        .background(AppColors.background)
        .cornerRadius(AppTheme.cornerRadiusLarge)
    }

    /// Filter tones based on recipient type
    private var availableTones: [GreetingTone] {
        switch selectedRecipient {
        case .partner:
            return GreetingTone.allCases
        case .friends:
            return [.formal, .casual, .funny]
        default:
            return [.formal, .casual]
        }
    }

    private func toneButton(_ tone: GreetingTone) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTone = tone
            }
        } label: {
            HStack(spacing: AppTheme.spacing4) {
                Image(systemName: tone.icon)
                    .font(.system(size: 14))
                Text(tone.displayName)
                    .font(.system(size: AppTheme.fontBody))
            }
            .foregroundColor(selectedTone == tone ? AppColors.white : AppColors.textPrimary)
            .padding(.horizontal, AppTheme.spacing12)
            .padding(.vertical, AppTheme.spacing8)
            .background(selectedTone == tone ? AppColors.primary : AppColors.backgroundLight)
            .cornerRadius(AppTheme.cornerRadiusMedium)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Name Input Section

    private var nameInputSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing12) {
            Text(String(localized: "Recipient name (optional)"))
                .font(.system(size: AppTheme.fontSubheading, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)

            TextField(String(localized: "e.g. Grandpa, Mom, Brother..."), text: $recipientName)
                .font(.system(size: AppTheme.fontBody))
                .padding(AppTheme.spacing12)
                .background(AppColors.backgroundLightGray)
                .cornerRadius(AppTheme.cornerRadiusMedium)
        }
        .padding(AppTheme.spacing16)
        .background(AppColors.background)
        .cornerRadius(AppTheme.cornerRadiusLarge)
    }

    // MARK: - Additional Info Section

    private var additionalInfoSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing12) {
            Text(String(localized: "Additional info (optional)"))
                .font(.system(size: AppTheme.fontSubheading, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)

            TextField(String(localized: "e.g. Just got a promotion, New house..."), text: $additionalInfo, axis: .vertical)
                .font(.system(size: AppTheme.fontBody))
                .lineLimit(3...6)
                .padding(AppTheme.spacing12)
                .background(AppColors.backgroundLightGray)
                .cornerRadius(AppTheme.cornerRadiusMedium)
        }
        .padding(AppTheme.spacing16)
        .background(AppColors.background)
        .cornerRadius(AppTheme.cornerRadiusLarge)
    }

    // MARK: - Generate Button

    private var generateButton: some View {
        Button {
            generateGreeting()
        } label: {
            HStack(spacing: AppTheme.spacing8) {
                if isGenerating {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                } else {
                    Image(systemName: "sparkles")
                }
                Text(isGenerating ? String(localized: "Creating...") : String(localized: "Create greeting"))
                    .font(.system(size: AppTheme.fontSubheading, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.spacing16)
            .background(isGenerating ? AppColors.secondary : AppColors.primary)
            .cornerRadius(AppTheme.cornerRadiusLarge)
        }
        .disabled(isGenerating)
        .buttonStyle(.plain)
    }

    // MARK: - Greeting Card

    private func greetingCard(_ greeting: GeneratedGreeting) -> some View {
        VStack(spacing: AppTheme.spacing16) {
            // Header with recipient info
            HStack {
                Text("🧧")
                    .font(.system(size: 24))
                Text(String(localized: "Greetings for") + " \(greeting.request.recipientType.displayName)")
                    .font(.system(size: AppTheme.fontSubheading, weight: .semibold))
                    .foregroundColor(AppColors.primary)
                Spacer()
            }

            // Greeting text
            Text(greeting.text)
                .font(.system(size: AppTheme.fontSubheading))
                .foregroundColor(AppColors.textPrimary)
                .multilineTextAlignment(.leading)
                .lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(AppTheme.spacing16)
                .background(AppColors.backgroundLight)
                .cornerRadius(AppTheme.cornerRadiusMedium)

            // Action buttons
            HStack(spacing: AppTheme.spacing12) {
                // Copy button
                Button {
                    copyToClipboard(greeting.text)
                } label: {
                    HStack(spacing: AppTheme.spacing4) {
                        Image(systemName: "doc.on.doc")
                        Text(String(localized: "Copy"))
                    }
                    .font(.system(size: AppTheme.fontBody))
                    .foregroundColor(AppColors.primary)
                    .padding(.horizontal, AppTheme.spacing16)
                    .padding(.vertical, AppTheme.spacing8)
                    .background(AppColors.backgroundLight)
                    .cornerRadius(AppTheme.cornerRadiusMedium)
                }
                .buttonStyle(.plain)

                // Share button
                ShareLink(item: greeting.text) {
                    HStack(spacing: AppTheme.spacing4) {
                        Image(systemName: "square.and.arrow.up")
                        Text(String(localized: "Share"))
                    }
                    .font(.system(size: AppTheme.fontBody))
                    .foregroundColor(AppColors.primary)
                    .padding(.horizontal, AppTheme.spacing16)
                    .padding(.vertical, AppTheme.spacing8)
                    .background(AppColors.backgroundLight)
                    .cornerRadius(AppTheme.cornerRadiusMedium)
                }

                Spacer()

                // Regenerate button
                Button {
                    generateGreeting()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 18))
                        .foregroundColor(AppColors.textSecondary)
                        .padding(AppTheme.spacing8)
                        .background(AppColors.backgroundLightGray)
                        .cornerRadius(AppTheme.cornerRadiusMedium)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppTheme.spacing16)
        .background(AppColors.background)
        .cornerRadius(AppTheme.cornerRadiusLarge)
        .shadow(color: AppColors.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    // MARK: - Error View

    private func errorView(_ message: String) -> some View {
        HStack(spacing: AppTheme.spacing8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(AppColors.eventOrange)
            Text(message)
                .font(.system(size: AppTheme.fontBody))
                .foregroundColor(AppColors.textSecondary)
            Spacer()
        }
        .padding(AppTheme.spacing12)
        .background(AppColors.priorityMediumBackground)
        .cornerRadius(AppTheme.cornerRadiusMedium)
    }

    // MARK: - Copied Toast

    private var copiedToast: some View {
        HStack(spacing: AppTheme.spacing8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(AppColors.accent)
            Text(String(localized: "Copied!"))
                .font(.system(size: AppTheme.fontBody, weight: .medium))
                .foregroundColor(AppColors.textPrimary)
        }
        .padding(.horizontal, AppTheme.spacing16)
        .padding(.vertical, AppTheme.spacing12)
        .background(AppColors.background)
        .cornerRadius(AppTheme.cornerRadiusLarge)
        .shadow(color: AppColors.black.opacity(0.15), radius: 8, x: 0, y: 4)
        .transition(.move(edge: .top).combined(with: .opacity))
        .padding(.top, AppTheme.spacing8)
    }

    // MARK: - Actions

    private func generateGreeting() {
        // Reset state
        errorMessage = nil

        // Validate tone for recipient
        if !availableTones.contains(selectedTone) {
            selectedTone = availableTones.first ?? .formal
        }

        let request = GreetingRequest(
            recipientType: selectedRecipient,
            tone: selectedTone,
            occasion: .tet,
            recipientName: recipientName.isEmpty ? nil : recipientName,
            additionalInfo: additionalInfo.isEmpty ? nil : additionalInfo,
            year: currentYear
        )

        isGenerating = true

        Task {
            do {
                let text = try await greetingService.generateGreeting(for: request)
                await MainActor.run {
                    generatedGreeting = GeneratedGreeting(text: text, request: request)
                    isGenerating = false
                }
            } catch {
                await MainActor.run {
                    // Fallback to offline greeting
                    let offlineText = greetingService.generateOfflineGreeting(for: request)
                    generatedGreeting = GeneratedGreeting(text: offlineText, request: request)
                    isGenerating = false

                    if !greetingService.isBackendConfigured {
                        errorMessage = String(localized: "Using sample greetings (offline mode).")
                    } else {
                        errorMessage = String(localized: "Cannot connect to server. Using sample greetings.")
                    }
                }
            }
        }
    }

    private func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text

        withAnimation(.easeInOut(duration: 0.3)) {
            showCopiedToast = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showCopiedToast = false
            }
        }
    }
}

// MARK: - Preview

#Preview {
    GreetingGeneratorView()
}
