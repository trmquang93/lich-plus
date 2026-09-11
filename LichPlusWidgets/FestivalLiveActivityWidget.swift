//
//  FestivalLiveActivityWidget.swift
//  LichPlusWidgets
//
//  Lock Screen and Dynamic Island UI for public festival countdown.
//

import ActivityKit
import SwiftUI
import WidgetKit

struct FestivalLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FestivalLiveActivityAttributes.self) { context in
            FestivalLiveActivityLockScreenView(
                festivalTitle: context.state.festivalTitle,
                daysUntil: context.state.daysUntil,
                solarDateLabel: context.state.solarDateLabel,
                localeCode: context.state.localeCode,
                isTet: context.state.isTet
            )
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: context.state.isTet ? "sparkles" : "calendar")
                        .font(.title2)
                        .foregroundStyle(WidgetTheme.primary)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(context.state.daysUntil)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(WidgetTheme.primary)
                }
                DynamicIslandExpandedRegion(.center) {
                    VStack(spacing: 2) {
                        Text(context.state.festivalTitle)
                            .font(.headline.weight(.semibold))
                            .lineLimit(1)
                        Text(WidgetLocalizedStrings.daysLabel(context.state.daysUntil, localeCode: context.state.localeCode))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.state.solarDateLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } compactLeading: {
                Image(systemName: context.state.isTet ? "sparkles" : "calendar")
                    .foregroundStyle(WidgetTheme.primary)
            } compactTrailing: {
                Text("\(context.state.daysUntil)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(WidgetTheme.primary)
            } minimal: {
                Image(systemName: "sparkles")
                    .foregroundStyle(WidgetTheme.primary)
            }
        }
    }
}

struct FestivalLiveActivityLockScreenView: View {
    let festivalTitle: String
    let daysUntil: Int
    let solarDateLabel: String
    let localeCode: String
    let isTet: Bool

    private var headerTitle: String {
        if isTet {
            return WidgetLocalizedStrings.liveActivityTetCountdownTitle(localeCode: localeCode)
        }
        return WidgetLocalizedStrings.liveActivityCountdownTitle(localeCode: localeCode)
    }

    var body: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: isTet ? "sparkles" : "calendar")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(WidgetTheme.primary)
                    Text(headerTitle)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(WidgetTheme.primary)
                }
                Text(festivalTitle)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(WidgetTheme.textPrimary)
                    .lineLimit(2)
                Text(solarDateLabel)
                    .font(.caption)
                    .foregroundStyle(WidgetTheme.textSecondary)
            }

            Spacer(minLength: 0)

            VStack(spacing: 2) {
                Text("\(daysUntil)")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(WidgetTheme.primary)
                Text(WidgetLocalizedStrings.daysLabel(daysUntil, localeCode: localeCode))
                    .font(.caption2)
                    .foregroundStyle(WidgetTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(16)
        .activityBackgroundTint(WidgetTheme.backgroundLight)
    }
}
