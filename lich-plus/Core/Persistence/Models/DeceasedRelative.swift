//
//  DeceasedRelative.swift
//  lich-plus
//

import Foundation
import SwiftData

/// A deceased relative recorded in the user's PersonalProfile.
/// Used to surface giỗ (death-anniversary) văn khấn on the matching lunar date.
@Model
final class DeceasedRelative {
    @Attribute(.unique) var id: UUID
    var relation: String       // "ông", "bà", "bố", "mẹ", "cô", "chú", …
    var name: String
    var lunarDay: Int          // 1…30
    var lunarMonth: Int        // 1…12
    var note: String?

    init(
        id: UUID = UUID(),
        relation: String,
        name: String,
        lunarDay: Int,
        lunarMonth: Int,
        note: String? = nil
    ) {
        self.id = id
        self.relation = relation
        self.name = name
        self.lunarDay = lunarDay
        self.lunarMonth = lunarMonth
        self.note = note
    }
}
