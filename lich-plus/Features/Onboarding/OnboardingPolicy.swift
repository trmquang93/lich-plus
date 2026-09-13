//
//  OnboardingPolicy.swift
//  lich-plus
//
//  First-run onboarding rules that must stay testable without UIKit.
//  NotificationSettings subcategory defaults are opt-out; onboarding is opt-in.
//

import Foundation
import SwiftData

enum OnboardingPolicy {
    struct ReminderSelection: Equatable {
        var ramEnabled: Bool
        var gioEnabled: Bool

        var anyEnabled: Bool { ramEnabled || gioEnabled }
    }

    /// Presets `rescheduleAllNotifications()` will actually schedule.
    struct ArmedPresets: Equatable {
        var ram: Bool
        var gio: Bool
        var mung1: Bool
        var ngayChay: Bool
        var fixedEvent: Bool
    }

    struct BirthYearDraft: Equatable {
        var isEnabled: Bool
        var year: Int
    }

    struct ExistingUserSnapshot: Equatable {
        var hasCompletedOnboarding = false
        var hasBirthYear = false
        var hasEventsOrTasks = false
        var hasGioRelatives = false
        var hasCalendarSubscriptions = false
        var hasEnabledNotifications = false

        /// Conservative upgrade skip: any real prior use, not merely an empty SwiftData row.
        var shouldSkipFirstRun: Bool {
            hasCompletedOnboarding
                || hasBirthYear
                || hasEventsOrTasks
                || hasGioRelatives
                || hasCalendarSubscriptions
                || hasEnabledNotifications
        }
    }

    /// Clears unchosen lunar presets so onboarding cannot inherit default-true Mùng 1/Rằm/giỗ.
    /// Does not change Settings defaults for installs that never entered this path.
    static func applyReminderOptIn(to settings: NotificationSettings, selection: ReminderSelection) {
        settings.ramNotificationsEnabled = selection.ramEnabled
        settings.gioNotificationsEnabled = selection.gioEnabled
        settings.mung1NotificationsEnabled = false
        settings.ngayChayNotificationsEnabled = false
        settings.fixedEventNotificationsEnabled = false
        settings.isEnabled = selection.anyEnabled
    }

    static func armedPresets(from settings: NotificationSettings) -> ArmedPresets {
        let master = settings.isEnabled
        return ArmedPresets(
            ram: master && settings.ramNotificationsEnabled,
            gio: master && settings.gioNotificationsEnabled,
            mung1: master && settings.mung1NotificationsEnabled,
            ngayChay: master && settings.ngayChayNotificationsEnabled,
            fixedEvent: master && settings.fixedEventNotificationsEnabled
        )
    }

    /// Local toggle state: off is immediate; enable is optimistic until auth returns.
    /// Denied permission must not look opted-in.
    static func resolvedReminderToggleState(desired: Bool, authorizationGranted: Bool?) -> Bool {
        if !desired { return false }
        if authorizationGranted == false { return false }
        return true
    }

    static func birthYearDraft(storedYear: Int?, currentYear: Int) -> BirthYearDraft {
        if let storedYear {
            return BirthYearDraft(isEnabled: true, year: storedYear)
        }
        return BirthYearDraft(isEnabled: false, year: currentYear - 30)
    }

    /// Enabling must keep an existing natal year; the current-30 placeholder is first-run only.
    static func yearAfterBirthYearToggle(enabled: Bool, draftYear: Int, storedYear: Int?) -> Int? {
        guard enabled else { return nil }
        return storedYear ?? draftYear
    }

    static func existingUserSnapshot(
        modelContext: ModelContext,
        hasCompletedOnboarding: Bool,
        hasBirthYear: Bool
    ) -> ExistingUserSnapshot {
        ExistingUserSnapshot(
            hasCompletedOnboarding: hasCompletedOnboarding,
            hasBirthYear: hasBirthYear,
            hasEventsOrTasks: hasAny(SyncableEvent.self, in: modelContext, predicate: #Predicate { !$0.isDeleted }),
            hasGioRelatives: hasAny(DeceasedRelative.self, in: modelContext),
            hasCalendarSubscriptions: hasAny(ICSSubscription.self, in: modelContext),
            hasEnabledNotifications: existingNotificationSettings(in: modelContext)?.isEnabled == true
        )
    }

    private static func existingNotificationSettings(in context: ModelContext) -> NotificationSettings? {
        let descriptor = FetchDescriptor<NotificationSettings>(
            predicate: #Predicate { $0.id == "notification_settings" }
        )
        return try? context.fetch(descriptor).first
    }

    private static func hasAny<T: PersistentModel>(
        _: T.Type,
        in context: ModelContext,
        predicate: Predicate<T>? = nil
    ) -> Bool {
        var descriptor = FetchDescriptor<T>(predicate: predicate)
        descriptor.fetchLimit = 1
        return ((try? context.fetch(descriptor))?.isEmpty == false)
    }
}
