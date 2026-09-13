//
//  OnboardingView.swift
//  lich-plus
//
//  Three-screen first-run onboarding: widgets, lunar reminders, optional birth year.
//

import SwiftUI
import SwiftData

struct OnboardingView: View {
    @EnvironmentObject private var notificationService: NotificationService
    @Environment(\.modelContext) private var modelContext
    @Environment(\.elderModeEnabled) private var elderModeEnabled

    @ObservedObject private var birthYearStore = BirthYearStore.shared

    let onComplete: () -> Void

    @State private var pageIndex = 0
    @State private var notificationSettings: NotificationSettings?
    @State private var ramRemindersEnabled = false
    @State private var gioRemindersEnabled = false
    @State private var ramOptedIn = false
    @State private var gioOptedIn = false
    @State private var birthYearEnabled = false
    @State private var draftBirthYear = Calendar.current.component(.year, from: Date()) - 30

    private let pageCount = 3

    private var yearRange: [Int] {
        let current = Calendar.current.component(.year, from: Date())
        return Array((current - 100)...current).reversed()
    }

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $pageIndex) {
                widgetsPage
                    .tag(0)
                remindersPage
                    .tag(1)
                birthYearPage
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .animation(.easeInOut, value: pageIndex)

            bottomBar
        }
        .background(AppColors.background.ignoresSafeArea())
        .onAppear {
            notificationSettings = notificationService.getSettings()
            let draft = OnboardingPolicy.birthYearDraft(
                storedYear: birthYearStore.birthYear,
                currentYear: Calendar.current.component(.year, from: Date())
            )
            birthYearEnabled = draft.isEnabled
            draftBirthYear = draft.year
            AnalyticsService.shared.logScreen(.onboarding)
        }
    }

    // MARK: - Pages

    private var widgetsPage: some View {
        onboardingPage(
            systemImage: "square.grid.3x3.fill",
            title: String(localized: "Widgets on Home & Lock Screen"),
            body: String(localized: "See today’s lunar date, giờ hoàng đạo, and festival countdown without opening the app."),
            steps: [
                String(localized: "Long-press the Home Screen or Lock Screen"),
                String(localized: "Tap the + button in the top corner"),
                String(localized: "Search for Lich+ and choose Today or Countdown"),
            ]
        )
    }

    private var remindersPage: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.spacing16) {
                onboardingHeader(
                    systemImage: "bell.badge.fill",
                    title: String(localized: "Rằm & giỗ reminders"),
                    body: String(localized: "Turn on presets for Rằm and giỗ anniversaries. You can add Mùng 1 and fine-tune everything later in Settings → Phong tục presets.")
                )

                VStack(spacing: AppTheme.spacing12) {
                    reminderToggle(
                        title: String(localized: "Rằm reminders"),
                        subtitle: String(localized: "15th day of each lunar month"),
                        isOn: Binding(
                            get: { ramRemindersEnabled },
                            set: { updateRamReminders($0) }
                        )
                    )

                    reminderToggle(
                        title: String(localized: "Giỗ reminders"),
                        subtitle: String(localized: "7, 3, and 1 days before each giỗ in Personal Profile"),
                        isOn: Binding(
                            get: { gioRemindersEnabled },
                            set: { updateGioReminders($0) }
                        )
                    )
                }
                .padding(.horizontal, AppTheme.spacing24)
            }
            .padding(.vertical, AppTheme.spacing24)
        }
    }

    private var birthYearPage: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.spacing16) {
                onboardingHeader(
                    systemImage: "calendar.badge.clock",
                    title: String(localized: "Birth year for tuổi hợp"),
                    body: String(localized: "Optional. Used on-device for ngày xung tuổi and Ngũ hành hints in xem ngày. Never uploaded or sent to analytics.")
                )

                VStack(spacing: AppTheme.spacing12) {
                    Toggle(isOn: $birthYearEnabled) {
                        VStack(alignment: .leading, spacing: AppTheme.spacing2) {
                            Text(String(localized: "Set my birth year"))
                                .elderModeFont(size: AppTheme.fontBody, weight: .medium)
                                .foregroundStyle(AppColors.textPrimary)
                            Text(String(localized: "Lunar Can-Chi year for compatibility checks"))
                                .elderModeFont(size: AppTheme.fontCaption)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                    }
                    .tint(AppColors.primary)
                    .onChange(of: birthYearEnabled) { _, enabled in
                        let year = OnboardingPolicy.yearAfterBirthYearToggle(
                            enabled: enabled,
                            draftYear: draftBirthYear,
                            storedYear: birthYearStore.birthYear
                        )
                        birthYearStore.setBirthYear(year)
                        if let year {
                            draftBirthYear = year
                        }
                    }

                    if birthYearEnabled {
                        Picker(String(localized: "Birth year"), selection: $draftBirthYear) {
                            ForEach(yearRange, id: \.self) { year in
                                Text(String(year)).tag(year)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(maxHeight: 160)
                        .onChange(of: draftBirthYear) { _, year in
                            birthYearStore.setBirthYear(year)
                        }

                        if let birthYear = birthYearStore.birthYear {
                            let canChi = TuoiHopXungCalculator.birthYearCanChi(for: birthYear)
                            Text(String(format: String(localized: "Your Can-Chi year: %@"), canChi.displayName))
                                .elderModeFont(size: AppTheme.fontCaption)
                                .foregroundStyle(AppColors.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .padding(AppTheme.spacing16)
                .background(AppColors.backgroundLightGray)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge))
                .padding(.horizontal, AppTheme.spacing24)
            }
            .padding(.vertical, AppTheme.spacing24)
        }
    }

    // MARK: - Shared layout

    private func onboardingPage(
        systemImage: String,
        title: String,
        body: String,
        steps: [String]
    ) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.spacing16) {
                onboardingHeader(systemImage: systemImage, title: title, body: body)

                VStack(alignment: .leading, spacing: AppTheme.spacing12) {
                    ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .top, spacing: AppTheme.spacing12) {
                            Text("\(index + 1).")
                                .elderModeFont(size: AppTheme.fontBody, weight: .semibold)
                                .foregroundStyle(AppColors.primary)
                                .frame(width: 24, alignment: .leading)
                            Text(step)
                                .elderModeFont(size: AppTheme.fontBody)
                                .foregroundStyle(AppColors.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding(.horizontal, AppTheme.spacing24)
            }
            .padding(.vertical, AppTheme.spacing24)
        }
    }

    private func onboardingHeader(systemImage: String, title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing12) {
            Image(systemName: systemImage)
                .font(.system(size: elderModeEnabled ? 52 : 44))
                .foregroundStyle(AppColors.primary)
                .accessibilityHidden(true)

            Text(title)
                .elderModeFont(size: AppTheme.fontTitle2, weight: .semibold)
                .foregroundStyle(AppColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text(body)
                .elderModeFont(size: AppTheme.fontBody)
                .foregroundStyle(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, AppTheme.spacing24)
    }

    private func reminderToggle(
        title: String,
        subtitle: String,
        isOn: Binding<Bool>
    ) -> some View {
        Toggle(isOn: isOn) {
            VStack(alignment: .leading, spacing: AppTheme.spacing2) {
                Text(title)
                    .elderModeFont(size: AppTheme.fontBody, weight: .medium)
                    .foregroundStyle(AppColors.textPrimary)
                Text(subtitle)
                    .elderModeFont(size: AppTheme.fontCaption)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .tint(AppColors.primary)
        .padding(AppTheme.spacing16)
        .background(AppColors.backgroundLightGray)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge))
    }

    // MARK: - Bottom bar

    private var bottomBar: some View {
        HStack {
            Button(String(localized: "Skip")) {
                finish(skipped: true)
            }
            .elderModeFont(size: AppTheme.fontBody)
            .foregroundStyle(AppColors.textSecondary)
            .accessibilityIdentifier("onboarding.skip")

            Spacer()

            Button(pageIndex == pageCount - 1 ? String(localized: "Done") : String(localized: "Next")) {
                if pageIndex < pageCount - 1 {
                    pageIndex += 1
                } else {
                    finish(skipped: false)
                }
            }
            .elderModeFont(size: AppTheme.fontBody, weight: .semibold)
            .foregroundStyle(AppColors.primary)
            .accessibilityIdentifier(pageIndex == pageCount - 1 ? "onboarding.done" : "onboarding.next")
        }
        .elderModePadding(.horizontal, AppTheme.spacing24)
        .elderModePadding(.vertical, AppTheme.spacing16)
        .background(AppColors.background)
    }

    // MARK: - Actions

    private func finish(skipped: Bool) {
        if ramOptedIn || gioOptedIn {
            persistReminderSelection()
        }
        OnboardingStore.shared.markCompleted()
        AnalyticsService.shared.logFeatureUsed(skipped ? .onboarding_skip : .onboarding_complete)
        onComplete()
    }

    private var reminderSelection: OnboardingPolicy.ReminderSelection {
        OnboardingPolicy.ReminderSelection(ramEnabled: ramOptedIn, gioEnabled: gioOptedIn)
    }

    private func persistReminderSelection() {
        guard let settings = notificationSettings else { return }
        OnboardingPolicy.applyReminderOptIn(to: settings, selection: reminderSelection)
        notificationService.updateSettings(settings)
    }

    private func updateRamReminders(_ enabled: Bool) {
        ramRemindersEnabled = OnboardingPolicy.resolvedReminderToggleState(
            desired: enabled,
            authorizationGranted: enabled ? nil : false
        )
        if enabled {
            Task {
                let granted = await notificationService.requestAuthorization()
                AnalyticsService.shared.logNotificationPermission(granted: granted)
                ramRemindersEnabled = OnboardingPolicy.resolvedReminderToggleState(
                    desired: ramRemindersEnabled,
                    authorizationGranted: granted
                )
                guard ramRemindersEnabled, granted else {
                    ramOptedIn = false
                    AnalyticsService.shared.logNotificationOptIn(optedIn: false)
                    return
                }
                ramOptedIn = true
                persistReminderSelection()
                await notificationService.scheduleRamNotifications()
                AnalyticsService.shared.logNotificationOptIn(optedIn: true)
            }
        } else {
            ramOptedIn = false
            persistReminderSelection()
            Task { await notificationService.removeAllRamNotifications() }
        }
    }

    private func updateGioReminders(_ enabled: Bool) {
        gioRemindersEnabled = OnboardingPolicy.resolvedReminderToggleState(
            desired: enabled,
            authorizationGranted: enabled ? nil : false
        )
        if enabled {
            Task {
                let granted = await notificationService.requestAuthorization()
                AnalyticsService.shared.logNotificationPermission(granted: granted)
                gioRemindersEnabled = OnboardingPolicy.resolvedReminderToggleState(
                    desired: gioRemindersEnabled,
                    authorizationGranted: granted
                )
                guard gioRemindersEnabled, granted else {
                    gioOptedIn = false
                    AnalyticsService.shared.logNotificationOptIn(optedIn: false)
                    return
                }
                gioOptedIn = true
                persistReminderSelection()
                await notificationService.scheduleGioNotifications()
                AnalyticsService.shared.logNotificationOptIn(optedIn: true)
            }
        } else {
            gioOptedIn = false
            persistReminderSelection()
            Task { await notificationService.removeAllGioNotifications() }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: NotificationSettings.self, configurations: config)

    OnboardingView(onComplete: {})
        .environmentObject(NotificationService(modelContext: ModelContext(container)))
        .modelContainer(container)
        .environment(\.elderModeEnabled, false)
}
