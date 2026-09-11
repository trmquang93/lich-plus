//
//  FestivalLiveActivitySettingsView.swift
//  lich-plus
//
//  Settings for the Tết / public festival Live Activity.
//

import SwiftUI

struct FestivalLiveActivitySettingsView: View {
    @ObservedObject private var store = FestivalLiveActivityStore.shared
    @State private var nextFestival: FestivalCountdownEntry?
    @State private var isActive = FestivalLiveActivityManager.shared.isActive
    @State private var isSupported = FestivalLiveActivityManager.shared.isSupported

    private var withinWindow: Bool {
        nextFestival != nil
    }

    var body: some View {
        List {
            if !isSupported {
                Section {
                    Label {
                        Text(String(localized: "Live Activities are disabled in system Settings."))
                            .font(.body)
                            .foregroundStyle(AppColors.textSecondary)
                    } icon: {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                    }
                }
            }

            Section {
                Toggle(String(localized: "Auto-start before festivals"), isOn: Binding(
                    get: { store.autoStartEnabled },
                    set: { newValue in
                        store.setAutoStartEnabled(newValue)
                        if newValue {
                            FestivalLiveActivityManager.shared.refresh()
                        } else if isActive {
                            FestivalLiveActivityManager.shared.stopManually()
                        }
                        refreshStatus()
                    }
                ))
                .disabled(!isSupported)
                .accessibilityIdentifier("live.activity.auto.start.toggle")
            } footer: {
                Text(String(
                    format: String(localized: "Automatically shows a countdown on the Lock Screen and Dynamic Island when a public festival is within %lld days."),
                    FestivalLiveActivityConstants.autoStartDaysBefore
                ))
            }

            if let festival = nextFestival {
                Section(String(localized: "Next festival")) {
                    HStack {
                        VStack(alignment: .leading, spacing: AppTheme.spacing2) {
                            Text(festival.title)
                                .font(.body.weight(.semibold))
                                .foregroundStyle(AppColors.textPrimary)
                            Text(festival.solarDateLabel)
                                .font(.caption)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                        Spacer()
                        Text(festival.daysLabel)
                            .font(.title3.weight(.bold))
                            .foregroundStyle(festival.isTet ? AppColors.primary : AppColors.accent)
                    }

                    if isActive {
                        Button(role: .destructive) {
                            FestivalLiveActivityManager.shared.stopManually()
                            refreshStatus()
                        } label: {
                            Label(String(localized: "Stop Live Activity"), systemImage: "stop.circle")
                        }
                        .accessibilityIdentifier("live.activity.stop")
                    } else {
                        Button {
                            FestivalLiveActivityManager.shared.startManually()
                            refreshStatus()
                        } label: {
                            Label(String(localized: "Start Live Activity"), systemImage: "play.circle")
                        }
                        .disabled(!isSupported)
                        .accessibilityIdentifier("live.activity.start")
                    }
                }
            } else {
                Section {
                    Text(String(
                        format: String(localized: "No public festival is within the next %lld days. The Live Activity will appear closer to Tết or the next major holiday."),
                        FestivalLiveActivityConstants.autoStartDaysBefore
                    ))
                    .font(.body)
                    .foregroundStyle(AppColors.textSecondary)
                }
            }

            Section(String(localized: "What appears")) {
                Label {
                    Text(String(localized: "Lock Screen: festival name, solar date, and days remaining"))
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                } icon: {
                    Image(systemName: "lock.fill")
                        .foregroundStyle(AppColors.primary)
                }
                Label {
                    Text(String(localized: "Dynamic Island: compact countdown and expanded festival details (iPhone 14 Pro and later)"))
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                } icon: {
                    Image(systemName: "platter.filled.top.iphone")
                        .foregroundStyle(AppColors.primary)
                }
            }
        }
        .navigationTitle(String(localized: "Festival countdown"))
        .onAppear {
            refreshStatus()
            AnalyticsService.shared.logFeatureUsed(.tet_countdown)
        }
        .trackAnalyticsScreen(.festival_live_activity_settings)
    }

    private func refreshStatus() {
        nextFestival = FestivalLiveActivityManager.shared.eligibleFestival()
        isActive = FestivalLiveActivityManager.shared.isActive
        isSupported = FestivalLiveActivityManager.shared.isSupported
    }
}

#Preview {
    NavigationStack {
        FestivalLiveActivitySettingsView()
    }
}
