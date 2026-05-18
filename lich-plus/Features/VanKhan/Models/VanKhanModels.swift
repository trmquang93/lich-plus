//
//  VanKhanModels.swift
//  lich-plus
//
//  Domain types for the văn khấn (formal prayer) feature.
//

import Foundation

enum VanKhanCategory: String, CaseIterable, Identifiable {
    case monthly       // Hằng tháng: Rằm, Mùng 1, Thần Tài – Thổ Địa
    case festival      // Lễ Tết: Giao Thừa, Nguyên Đán, Vu Lan, …
    case anniversary   // Giỗ
    case family        // Cưới hỏi, Nhập trạch, Đầy tháng, …

    var id: String { rawValue }

    var title: String {
        switch self {
        case .monthly:     return String(localized: "Monthly")
        case .festival:    return String(localized: "Festivals")
        case .anniversary: return String(localized: "Death anniversary")
        case .family:      return String(localized: "Family events")
        }
    }
}

/// Trigger describing when an occasion is "active" for a given date / profile.
enum OccasionTrigger: Equatable {
    case lunarDay(Int)                       // 1 or 15
    case lunarDate(month: Int, day: Int)     // fixed lunar date, e.g. 23/12 ÂL (Ông Táo)
    case lunarLastDayOfYear                  // Giao Thừa
    case solar(month: Int, day: Int)         // e.g. Thanh Minh ≈ 4/4 dương
    case anniversary                         // matched against profile.deceasedRelatives
    case manual                              // user-initiated (cưới, nhập trạch, …)
}

struct VanKhanOccasion: Identifiable, Equatable {
    let id: String                  // stable slug, e.g. "ram-hang-thang"
    let title: String               // "Văn khấn rằm hằng tháng"
    let subtitle: String?           // short context
    let category: VanKhanCategory
    let trigger: OccasionTrigger
}

/// The text body for an occasion. Body contains `{token}` placeholders
/// that are substituted by `VanKhanRenderer`.
struct VanKhanText: Equatable {
    let occasionId: String
    let body: String
}

/// Typed placeholder keys used inside văn khấn bodies.
///
/// Interpolate a case directly into a body string (`"… họ \(VanKhanToken.familyName) …"`)
/// instead of typing `{familyName}` by hand — that way a typo becomes a compile
/// error and the set of known tokens lives in one place.
enum VanKhanToken: String, CustomStringConvertible, CaseIterable {
    case name
    case address
    case familyName
    case gender
    case spouseName
    case partnerName
    case deceasedName
    case deceasedRelation
    case childName
    case solarDate
    case lunarDate

    /// `"{rawValue}"` — the wire form `VanKhanRenderer` looks for.
    var placeholder: String { "{\(rawValue)}" }

    /// String-interpolation form. Lets bodies write `\(VanKhanToken.name)`.
    var description: String { placeholder }
}

/// Optional named regions inside a văn khấn body that the user can hide
/// via Personal Profile toggles. Wrap each region in the data file with
/// the `open` / `close` markers on their own lines:
///
///     \(VanKhanSectionTag.ancestors.open)
///     …ancestor paragraph…
///     \(VanKhanSectionTag.ancestors.close)
///
/// `VanKhanRenderer.applySections` strips the markers (show) or the whole
/// block (hide) before token substitution.
enum VanKhanSectionTag: String, CaseIterable {
    case ancestors

    var open: String { "<<\(rawValue)>>" }
    var close: String { "<</\(rawValue)>>" }
}
