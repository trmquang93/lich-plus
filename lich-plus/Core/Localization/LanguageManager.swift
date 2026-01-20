//
//  LanguageManager.swift
//  lich-plus
//

import Foundation

final class LanguageManager {
    static let shared = LanguageManager()

    private let languageKey = "app_language"
    private let initializedKey = "app_language_initialized"

    private(set) var currentLanguage: AppLanguage
    var currentLanguageCode: String {
        currentLanguage.code
    }

    private init() {
        let savedLanguage = UserDefaults.standard.string(forKey: languageKey)
        self.currentLanguage = savedLanguage.flatMap { AppLanguage(rawValue: $0) } ?? .vietnamese
    }

    func initialize() {
        if isFirstLaunch() {
            currentLanguage = .vietnamese
            saveLanguage()
            updateAppleLanguages()
            markAsInitialized()
        } else {
            updateAppleLanguages()
        }
    }

    func setLanguage(_ language: AppLanguage) {
        currentLanguage = language
        saveLanguage()
        updateAppleLanguages()
    }

    private func saveLanguage() {
        UserDefaults.standard.set(currentLanguage.rawValue, forKey: languageKey)
    }

    private func updateAppleLanguages() {
        UserDefaults.standard.set([currentLanguageCode], forKey: "AppleLanguages")
    }

    private func isFirstLaunch() -> Bool {
        !UserDefaults.standard.bool(forKey: initializedKey)
    }

    private func markAsInitialized() {
        UserDefaults.standard.set(true, forKey: initializedKey)
    }
}
