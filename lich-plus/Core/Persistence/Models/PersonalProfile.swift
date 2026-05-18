//
//  PersonalProfile.swift
//  lich-plus
//

import Foundation
import SwiftData

/// User's personal information used to prefill văn khấn (formal prayer) texts.
///
/// Single-row singleton enforced by `PersonalProfileService`.
@Model
final class PersonalProfile {
    @Attribute(.unique) var id: String

    var fullName: String
    var address: String

    /// Họ của gia đình (e.g. "Nguyễn", "Trần") — dùng trong văn khấn
    /// "...gia tiên nội ngoại họ {familyName}".
    var familyName: String = ""

    /// Whether the "gia tiên" (ancestor invocation) section is rendered in
    /// văn khấn bodies. Some users skip this section by family practice.
    var showAncestorsSection: Bool = true

    /// "nam" / "nữ" — drives the "tín chủ con là …" pronoun
    var gender: String?

    var dateOfBirth: Date?

    var spouseName: String?
    var childrenNames: [String]
    var parentsNames: [String]

    @Relationship(deleteRule: .cascade) var deceasedRelatives: [DeceasedRelative]

    var updatedAt: Date

    init(
        fullName: String = "",
        address: String = "",
        familyName: String = "",
        gender: String? = nil,
        dateOfBirth: Date? = nil,
        spouseName: String? = nil,
        childrenNames: [String] = [],
        parentsNames: [String] = [],
        deceasedRelatives: [DeceasedRelative] = []
    ) {
        self.id = "personal_profile"
        self.fullName = fullName
        self.address = address
        self.familyName = familyName
        self.gender = gender
        self.dateOfBirth = dateOfBirth
        self.spouseName = spouseName
        self.childrenNames = childrenNames
        self.parentsNames = parentsNames
        self.deceasedRelatives = deceasedRelatives
        self.updatedAt = Date()
    }
}
