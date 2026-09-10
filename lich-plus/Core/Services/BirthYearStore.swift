//
//  BirthYearStore.swift
//  lich-plus
//
//  Local-only birth year for tuổi hợp/xung. Stored in UserDefaults — never uploaded or logged.
//

import Foundation
import Combine

/// Device-local birth year used for tuổi hợp/xung. Not synced, not sent to analytics.
@MainActor
final class BirthYearStore: ObservableObject {
    static let shared = BirthYearStore()

    private static let storageKey = "lich_plus.local_birth_year"

    @Published private(set) var birthYear: Int?

    private init() {
        let stored = UserDefaults.standard.object(forKey: Self.storageKey) as? Int
        if let stored, (1920...2100).contains(stored) {
            birthYear = stored
        } else {
            birthYear = nil
        }
    }

    func setBirthYear(_ year: Int?) {
        if let year, (1920...2100).contains(year) {
            UserDefaults.standard.set(year, forKey: Self.storageKey)
            birthYear = year
        } else {
            UserDefaults.standard.removeObject(forKey: Self.storageKey)
            birthYear = nil
        }
    }

    var hasBirthYear: Bool {
        birthYear != nil
    }
}
