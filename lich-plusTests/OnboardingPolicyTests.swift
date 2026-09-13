//
//  OnboardingPolicyTests.swift
//  lich-plusTests
//

import XCTest
import SwiftData
@testable import lich_plus

@MainActor
final class OnboardingPolicyTests: XCTestCase {
    private func makeSettings() -> NotificationSettings {
        NotificationSettings()
    }

    private func makeContext() throws -> ModelContext {
        let schema = Schema([
            SyncableEvent.self,
            SyncedCalendar.self,
            ICSSubscription.self,
            NotificationSettings.self,
            PersonalProfile.self,
            DeceasedRelative.self,
        ])
        let container = try ModelContainer(
            for: schema,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        return ModelContext(container)
    }

    // MARK: - Reminder opt-in

    func testRamOnlyOptInDoesNotArmMung1OrGio() {
        // WHY: subcategory defaults are opt-out (true). Enabling Rằm on onboarding
        // must not let rescheduleAllNotifications() fire Mùng 1 or giỗ.
        let settings = makeSettings()
        XCTAssertTrue(settings.mung1NotificationsEnabled)
        XCTAssertTrue(settings.gioNotificationsEnabled)
        XCTAssertTrue(settings.ramNotificationsEnabled)
        XCTAssertFalse(settings.isEnabled)

        settings.isEnabled = true
        XCTAssertTrue(
            OnboardingPolicy.armedPresets(from: settings).mung1,
            "The default-true trap: master on without an onboarding apply arms Mùng 1"
        )

        OnboardingPolicy.applyReminderOptIn(
            to: settings,
            selection: .init(ramEnabled: true, gioEnabled: false)
        )

        let armed = OnboardingPolicy.armedPresets(from: settings)
        XCTAssertTrue(armed.ram)
        XCTAssertFalse(armed.gio)
        XCTAssertFalse(armed.mung1)
        XCTAssertFalse(armed.ngayChay)
        XCTAssertFalse(armed.fixedEvent)
        XCTAssertTrue(settings.isEnabled)
        XCTAssertFalse(settings.mung1NotificationsEnabled)
        XCTAssertFalse(settings.gioNotificationsEnabled)
    }

    func testGioOnlyOptInDoesNotArmRamOrMung1() {
        // WHY: the same default-true trap applies when only giỗ is chosen.
        let settings = makeSettings()
        OnboardingPolicy.applyReminderOptIn(
            to: settings,
            selection: .init(ramEnabled: false, gioEnabled: true)
        )

        let armed = OnboardingPolicy.armedPresets(from: settings)
        XCTAssertFalse(armed.ram)
        XCTAssertTrue(armed.gio)
        XCTAssertFalse(armed.mung1)
        XCTAssertTrue(settings.isEnabled)
        XCTAssertFalse(settings.ramNotificationsEnabled)
        XCTAssertFalse(settings.mung1NotificationsEnabled)
    }

    func testToggleOffPersistsDisabledSelection() {
        // WHY: if off does not persist, Done → rescheduleAll still schedules the preset
        // the user just turned off.
        let settings = makeSettings()
        OnboardingPolicy.applyReminderOptIn(
            to: settings,
            selection: .init(ramEnabled: true, gioEnabled: false)
        )
        OnboardingPolicy.applyReminderOptIn(
            to: settings,
            selection: .init(ramEnabled: false, gioEnabled: false)
        )

        XCTAssertFalse(settings.isEnabled)
        XCTAssertFalse(settings.ramNotificationsEnabled)
        XCTAssertFalse(OnboardingPolicy.armedPresets(from: settings).ram)
    }

    func testDeniedPermissionDoesNotLeaveToggleEnabled() {
        // WHY: the switch must not look opted-in when the system denied auth,
        // and off must win immediately even if a grant arrives later.
        XCTAssertTrue(
            OnboardingPolicy.resolvedReminderToggleState(desired: true, authorizationGranted: nil),
            "Enable is optimistic so the control does not snap back while the sheet is up"
        )
        XCTAssertFalse(
            OnboardingPolicy.resolvedReminderToggleState(desired: true, authorizationGranted: false)
        )
        XCTAssertFalse(
            OnboardingPolicy.resolvedReminderToggleState(desired: false, authorizationGranted: true)
        )
        XCTAssertFalse(
            OnboardingPolicy.resolvedReminderToggleState(desired: false, authorizationGranted: nil)
        )
    }

    // MARK: - Birth year

    func testEnablingBirthYearDoesNotClobberStoredYear() {
        // WHY: existing testers already have a natal year; the current-30 placeholder
        // must not replace it when onboarding hydrates or the toggle turns on.
        let draft = OnboardingPolicy.birthYearDraft(storedYear: 1960, currentYear: 2026)
        XCTAssertTrue(draft.isEnabled)
        XCTAssertEqual(draft.year, 1960)

        let kept = OnboardingPolicy.yearAfterBirthYearToggle(
            enabled: true,
            draftYear: 1996,
            storedYear: 1960
        )
        XCTAssertEqual(kept, 1960)

        let firstRun = OnboardingPolicy.yearAfterBirthYearToggle(
            enabled: true,
            draftYear: 1996,
            storedYear: nil
        )
        XCTAssertEqual(firstRun, 1996)

        XCTAssertNil(
            OnboardingPolicy.yearAfterBirthYearToggle(enabled: false, draftYear: 1960, storedYear: 1960)
        )
    }

    func testFreshBirthYearDraftStaysDisabled() {
        // WHY: first-run users must not have a year written until they opt in.
        let draft = OnboardingPolicy.birthYearDraft(storedYear: nil, currentYear: 2026)
        XCTAssertFalse(draft.isEnabled)
        XCTAssertEqual(draft.year, 1996)
    }

    // MARK: - Upgrade skip

    func testExistingUsersWithDataSkipOnboarding() {
        // WHY: an upgrade must not trap TestFlight users behind first-run if they
        // already have calendar/giỗ/birth-year/notification data.
        XCTAssertFalse(
            OnboardingPolicy.ExistingUserSnapshot().shouldSkipFirstRun,
            "A truly empty install still sees onboarding"
        )
        XCTAssertTrue(OnboardingPolicy.ExistingUserSnapshot(hasCompletedOnboarding: true).shouldSkipFirstRun)
        XCTAssertTrue(OnboardingPolicy.ExistingUserSnapshot(hasBirthYear: true).shouldSkipFirstRun)
        XCTAssertTrue(OnboardingPolicy.ExistingUserSnapshot(hasEventsOrTasks: true).shouldSkipFirstRun)
        XCTAssertTrue(OnboardingPolicy.ExistingUserSnapshot(hasGioRelatives: true).shouldSkipFirstRun)
        XCTAssertTrue(OnboardingPolicy.ExistingUserSnapshot(hasCalendarSubscriptions: true).shouldSkipFirstRun)
        XCTAssertTrue(OnboardingPolicy.ExistingUserSnapshot(hasEnabledNotifications: true).shouldSkipFirstRun)
    }

    func testProbeDoesNotTreatEmptyStoreAsExistingUser() throws {
        // WHY: merely opening SwiftData (or creating default notification rows later)
        // must not skip first-run for a new install.
        let context = try makeContext()
        let snapshot = OnboardingPolicy.existingUserSnapshot(
            modelContext: context,
            hasCompletedOnboarding: false,
            hasBirthYear: false
        )
        XCTAssertFalse(snapshot.shouldSkipFirstRun)
        XCTAssertFalse(snapshot.hasEventsOrTasks)
        XCTAssertFalse(snapshot.hasGioRelatives)
        XCTAssertFalse(snapshot.hasCalendarSubscriptions)
        XCTAssertFalse(snapshot.hasEnabledNotifications)
    }

    func testProbeSkipsWhenUserAlreadyHasLocalData() throws {
        // WHY: built-in ICS subscriptions, events, giỗ, or an enabled master
        // notification toggle are enough to prove this is not first-run.
        let context = try makeContext()
        context.insert(ICSSubscription(name: "Vietnamese Holidays", url: "https://example.com/holidays.ics"))
        try context.save()

        var snapshot = OnboardingPolicy.existingUserSnapshot(
            modelContext: context,
            hasCompletedOnboarding: false,
            hasBirthYear: false
        )
        XCTAssertTrue(snapshot.hasCalendarSubscriptions)
        XCTAssertTrue(snapshot.shouldSkipFirstRun)

        let eventsContext = try makeContext()
        eventsContext.insert(SyncableEvent(title: "Giỗ bà", startDate: Date()))
        try eventsContext.save()
        snapshot = OnboardingPolicy.existingUserSnapshot(
            modelContext: eventsContext,
            hasCompletedOnboarding: false,
            hasBirthYear: false
        )
        XCTAssertTrue(snapshot.hasEventsOrTasks)
        XCTAssertTrue(snapshot.shouldSkipFirstRun)

        let gioContext = try makeContext()
        gioContext.insert(DeceasedRelative(relation: "bà", name: "Nguyễn", lunarDay: 10, lunarMonth: 7))
        try gioContext.save()
        snapshot = OnboardingPolicy.existingUserSnapshot(
            modelContext: gioContext,
            hasCompletedOnboarding: false,
            hasBirthYear: false
        )
        XCTAssertTrue(snapshot.hasGioRelatives)
        XCTAssertTrue(snapshot.shouldSkipFirstRun)

        let notifContext = try makeContext()
        let settings = NotificationSettings()
        settings.isEnabled = true
        notifContext.insert(settings)
        try notifContext.save()
        snapshot = OnboardingPolicy.existingUserSnapshot(
            modelContext: notifContext,
            hasCompletedOnboarding: false,
            hasBirthYear: false
        )
        XCTAssertTrue(snapshot.hasEnabledNotifications)
        XCTAssertTrue(snapshot.shouldSkipFirstRun)
    }

    func testProbeIgnoresDisabledDefaultNotificationSettings() throws {
        // WHY: getSettings() creates a default row with isEnabled false. That is not
        // prior use and must not skip onboarding.
        let context = try makeContext()
        context.insert(NotificationSettings())
        try context.save()

        let snapshot = OnboardingPolicy.existingUserSnapshot(
            modelContext: context,
            hasCompletedOnboarding: false,
            hasBirthYear: false
        )
        XCTAssertFalse(snapshot.hasEnabledNotifications)
        XCTAssertFalse(snapshot.shouldSkipFirstRun)
    }

    func testUpgradeSkipMarksCompletionSoRelaunchDoesNotShowOnboarding() {
        // WHY: skipping for existing data must persist the same flag the app gate reads,
        // otherwise the next cold start still presents first-run.
        let suiteName = "OnboardingPolicyTests.upgrade.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let store = OnboardingStore(defaults: defaults)
        let snapshot = OnboardingPolicy.ExistingUserSnapshot(hasBirthYear: true)
        XCTAssertTrue(snapshot.shouldSkipFirstRun)
        XCTAssertFalse(store.hasCompletedOnboarding)

        if snapshot.shouldSkipFirstRun {
            store.markCompleted()
        }

        XCTAssertTrue(store.hasCompletedOnboarding)
        XCTAssertTrue(OnboardingStore(defaults: defaults).hasCompletedOnboarding)
    }
}
