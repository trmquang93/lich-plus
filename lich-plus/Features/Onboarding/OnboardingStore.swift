//
//  OnboardingStore.swift
//  lich-plus
//
//  First-run onboarding completion flag. Persisted in UserDefaults only.
//

import Foundation

@MainActor
final class OnboardingStore {
    static let shared = OnboardingStore()

    /// UserDefaults key — also used by `@AppStorage` in the app entry point.
    static let completionKey = "lich_plus.onboarding_completed_v1"

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var hasCompletedOnboarding: Bool {
        defaults.bool(forKey: Self.completionKey)
    }

    func markCompleted() {
        defaults.set(true, forKey: Self.completionKey)
    }

    /// Clears onboarding state for QA. Does not remove birth year or notification prefs.
    func resetForQA() {
        defaults.removeObject(forKey: Self.completionKey)
    }
}
