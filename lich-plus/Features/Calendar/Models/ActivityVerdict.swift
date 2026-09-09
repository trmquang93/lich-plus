//
//  ActivityVerdict.swift
//  lich-plus
//
//  Result of xem ngày cho việc for a specific day and purpose.
//

import Foundation

enum ActivityVerdictStatus: Equatable, Sendable {
    case good
    case bad
    case neutral
    case incomplete

    var displayName: String {
        switch self {
        case .good: return String(localized: "Good for this activity")
        case .bad: return String(localized: "Avoid for this activity")
        case .neutral: return String(localized: "Use with caution")
        case .incomplete: return String(localized: "Star data incomplete")
        }
    }
}

struct ActivityVerdict: Equatable, Sendable {
    let purpose: ActivityPurpose
    let status: ActivityVerdictStatus
    let summary: String
    let reasons: [String]
    let isStarDataIncomplete: Bool
    let isBirthYearXung: Bool
    let nguHanhHint: String?
    let trucName: String
}
