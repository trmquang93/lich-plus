//
//  AIInputSection.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 27/11/25.
//

import SwiftUI

struct AIInputSection: View {
    @State private var inputText: String = ""
    @State private var isExpanded: Bool = false
    @State private var isParsing: Bool = false
    @State private var errorMessage: String? = nil

    let nlpService: NLPService
    let itemType: ItemType
    let onTaskParsed: (ParsedTask) -> Void
    let onEventParsed: (ParsedEvent) -> Void

    init(
        nlpService: NLPService,
        itemType: ItemType,
        onTaskParsed: @escaping (ParsedTask) -> Void = { _ in },
        onEventParsed: @escaping (ParsedEvent) -> Void = { _ in }
    ) {
        self.nlpService = nlpService
        self.itemType = itemType
        self.onTaskParsed = onTaskParsed
        self.onEventParsed = onEventParsed
    }

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: AppTheme.spacing8) {
                // Header with expand/collapse button
                Button(action: { withAnimation { isExpanded.toggle() } }) {
                    HStack(spacing: AppTheme.spacing8) {
                        Image(systemName: "sparkles")
                            .foregroundStyle(AppColors.primary)
                            .font(.system(size: 16))

                        Text(String(localized: "ai.input.title"))
                            .font(.system(size: AppTheme.fontBody, weight: .medium))
                            .foregroundStyle(AppColors.textPrimary)

                        Spacer()

                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .foregroundStyle(AppColors.textSecondary)
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                // Input section (shown when expanded)
                if isExpanded {
                    VStack(alignment: .leading, spacing: AppTheme.spacing8) {
                        // Text field
                        HStack(spacing: AppTheme.spacing8) {
                            TextField(
                                String(localized: "ai.input.placeholder"),
                                text: $inputText
                            )
                            .textFieldStyle(.roundedBorder)
                            .disabled(isParsing)
                            .opacity(isParsing ? 0.6 : 1.0)

                            // Parse button with loading state
                            if isParsing {
                                ProgressView()
                                    .frame(width: 16, height: 16)
                            } else {
                                Button(action: parseInput) {
                                    Text(String(localized: "ai.input.parse"))
                                        .font(.system(size: AppTheme.fontCaption, weight: .semibold))
                                        .foregroundStyle(.white)
                                        .padding(.vertical, AppTheme.spacing8)
                                        .padding(.horizontal, AppTheme.spacing12)
                                        .background(AppColors.primary)
                                        .cornerRadius(AppTheme.cornerRadiusSmall)
                                }
                                .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty)
                                .opacity(inputText.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1.0)
                            }
                        }

                        // Error message
                        if let error = errorMessage {
                            HStack(spacing: AppTheme.spacing8) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundStyle(AppColors.primary)
                                    .font(.system(size: 14))

                                Text(error)
                                    .font(.system(size: AppTheme.fontCaption))
                                    .foregroundStyle(AppColors.primary)

                                Spacer()
                            }
                            .padding(AppTheme.spacing8)
                            .background(AppColors.primary.opacity(0.1))
                            .cornerRadius(AppTheme.cornerRadiusSmall)
                        }

                        // Hint text
                        Text(String(localized: "ai.input.hint"))
                            .font(.system(size: AppTheme.fontCaption))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
            }
            .padding(.vertical, AppTheme.spacing4)
        } header: {
            // Empty header - main header is in the button
        }
    }

    private func parseInput() {
        guard !inputText.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        isParsing = true
        errorMessage = nil

        Task {
            do {
                if itemType == .task {
                    let parsed = try await nlpService.parseTaskInput(
                        inputText,
                        currentDate: Date()
                    )
                    DispatchQueue.main.async {
                        onTaskParsed(parsed)
                        clearInput()
                    }
                } else {
                    let parsed = try await nlpService.parseEventInput(
                        inputText,
                        currentDate: Date()
                    )
                    DispatchQueue.main.async {
                        onEventParsed(parsed)
                        clearInput()
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = error.localizedDescription
                    isParsing = false
                }
            }
        }
    }

    private func clearInput() {
        withAnimation {
            inputText = ""
            isParsing = false
            isExpanded = false
        }
    }
}

#Preview {
    Form {
        AIInputSection(
            nlpService: MockNLPService(),
            itemType: .task,
            onTaskParsed: { task in
                print("Parsed task: \(task.title)")
            }
        )
    }
}
