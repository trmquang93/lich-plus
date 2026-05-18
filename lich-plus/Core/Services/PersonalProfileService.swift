//
//  PersonalProfileService.swift
//  lich-plus
//

import Foundation
import SwiftData

/// Singleton fetch-or-create accessor for `PersonalProfile`.
///
/// All SwiftData access happens on the main actor, matching the
/// project's `@MainActor` rule for SwiftData-touching services.
@MainActor
final class PersonalProfileService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// Returns the singleton `PersonalProfile`, creating it on first access.
    @discardableResult
    func getProfile() -> PersonalProfile {
        let descriptor = FetchDescriptor<PersonalProfile>()
        if let existing = try? modelContext.fetch(descriptor).first {
            return existing
        }
        let profile = PersonalProfile()
        modelContext.insert(profile)
        try? modelContext.save()
        return profile
    }

    /// Persist any pending changes on the profile.
    func save() {
        try? modelContext.save()
    }

    func addDeceasedRelative(_ relative: DeceasedRelative, to profile: PersonalProfile) {
        modelContext.insert(relative)
        profile.deceasedRelatives.append(relative)
        profile.updatedAt = Date()
        save()
    }

    func removeDeceasedRelative(_ relative: DeceasedRelative, from profile: PersonalProfile) {
        profile.deceasedRelatives.removeAll { $0.id == relative.id }
        modelContext.delete(relative)
        profile.updatedAt = Date()
        save()
    }
}
