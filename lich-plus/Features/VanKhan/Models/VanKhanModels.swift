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
