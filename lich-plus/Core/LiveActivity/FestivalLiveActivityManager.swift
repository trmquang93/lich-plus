//
//  FestivalLiveActivityManager.swift
//  lich-plus
//
//  Starts, updates, and ends the public festival Live Activity.
//  Uses FestivalCountdownProvider / PublicHolidayCatalog — no private data.
//

import ActivityKit
import Foundation

@MainActor
final class FestivalLiveActivityManager {
    static let shared = FestivalLiveActivityManager()

    private var vietnameseCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Ho_Chi_Minh") ?? .current
        return calendar
    }

    private init() {}

    /// Whether Live Activities are supported and allowed on this device.
    var isSupported: Bool {
        ActivityAuthorizationInfo().areActivitiesEnabled
    }

    /// Whether a festival Live Activity is currently running.
    var isActive: Bool {
        !Activity<FestivalLiveActivityAttributes>.activities.isEmpty
    }

    /// Next public festival within the auto-start window, if any.
    func eligibleFestival(from referenceDate: Date = .now) -> FestivalCountdownEntry? {
        guard let next = FestivalCountdownProvider.nextFestival(from: referenceDate) else {
            return nil
        }
        guard next.daysUntil <= FestivalLiveActivityConstants.autoStartDaysBefore else {
            return nil
        }
        return next
    }

    /// Syncs the Live Activity with current festival data and user preferences.
    func refresh(
        referenceDate: Date = .now,
        autoStartEnabled: Bool = FestivalLiveActivityStore.shared.autoStartEnabled,
        localeCode: String = LanguageManager.shared.currentLanguageCode
    ) {
        guard let entry = eligibleFestival(from: referenceDate) else {
            if isActive {
                endActivity(reason: .festivalOutOfWindow)
            }
            return
        }

        if isActive {
            updateActivity(with: entry, localeCode: localeCode)
        } else if autoStartEnabled {
            startActivity(with: entry, localeCode: localeCode)
        }
    }

    /// Manually starts the Live Activity for the next eligible public festival.
    func startManually(localeCode: String = LanguageManager.shared.currentLanguageCode) {
        guard let entry = eligibleFestival() else { return }
        if isActive {
            updateActivity(with: entry, localeCode: localeCode)
        } else {
            startActivity(with: entry, localeCode: localeCode)
        }
    }

    /// Ends any running festival Live Activity.
    func stopManually() {
        endActivity(reason: .userDisabled)
    }

    // MARK: - Private

    private func startActivity(with entry: FestivalCountdownEntry, localeCode: String) {
        guard isSupported else { return }

        let attributes = FestivalLiveActivityAttributes(festivalId: entry.id)
        let contentState = makeContentState(from: entry, localeCode: localeCode)

        do {
            _ = try Activity.request(
                attributes: attributes,
                content: .init(state: contentState, staleDate: staleDate(for: entry)),
                pushType: nil
            )
            AnalyticsService.shared.logFeatureUsed(.live_activity_start)
        } catch {
            #if DEBUG
            print("[LiveActivity] Failed to start: \(error)")
            #endif
        }
    }

    private func updateActivity(with entry: FestivalCountdownEntry, localeCode: String) {
        let contentState = makeContentState(from: entry, localeCode: localeCode)
        let content = ActivityContent(state: contentState, staleDate: staleDate(for: entry))

        if entry.daysUntil < 0 {
            endActivity(reason: .festivalPassed)
            return
        }

        for activity in Activity<FestivalLiveActivityAttributes>.activities {
            Task {
                await activity.update(content)
            }
        }
    }

    private func endActivity(reason: EndReason) {
        for activity in Activity<FestivalLiveActivityAttributes>.activities {
            Task {
                await activity.end(nil, dismissalPolicy: .default)
            }
        }
        if reason == .userDisabled || reason == .festivalPassed {
            AnalyticsService.shared.logFeatureUsed(.live_activity_end)
        }
    }

    private func makeContentState(
        from entry: FestivalCountdownEntry,
        localeCode: String
    ) -> FestivalLiveActivityAttributes.ContentState {
        FestivalLiveActivityAttributes.ContentState(
            festivalTitle: entry.title,
            daysUntil: entry.daysUntil,
            solarDateLabel: entry.solarDateLabel,
            localeCode: localeCode,
            isTet: entry.isTet
        )
    }

    private func staleDate(for entry: FestivalCountdownEntry) -> Date {
        let startOfTomorrow = vietnameseCalendar.date(
            byAdding: .day,
            value: 1,
            to: vietnameseCalendar.startOfDay(for: .now)
        ) ?? .now.addingTimeInterval(86400)
        return startOfTomorrow
    }

    private enum EndReason {
        case userDisabled
        case festivalPassed
        case festivalOutOfWindow
    }
}
