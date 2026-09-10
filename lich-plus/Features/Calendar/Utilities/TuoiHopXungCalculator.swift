//
//  TuoiHopXungCalculator.swift
//  lich-plus
//
//  Tuổi hợp / xung from birth year Can-Chi vs day Can-Chi (Tam Xung + Ngũ hành hints).
//

import Foundation

struct TuoiHopXungCalculator {

    struct XungResult: Equatable, Sendable {
        let birthYearChi: ChiEnum
        let dayChi: ChiEnum
        let conflictingChi: ChiEnum

        var reason: String {
            String(
                format: String(localized: "Day clashes with birth year (%@ xung %@)"),
                dayChi.vietnameseName,
                conflictingChi.vietnameseName
            )
        }
    }

    /// Tam Xung: opposing Earthly Branches (六冲).
    private static let xungPairs: [(ChiEnum, ChiEnum)] = [
        (.ty, .ngo), (.suu, .mui), (.dan, .than),
        (.mao, .dau), (.thin, .tuat), (.ty2, .hoi),
    ]

    static func birthYearCanChi(for birthYear: Int) -> CanChiPair {
        CanChiCalculator.calculateYearCanChi(lunarYear: birthYear)
    }

    static func conflictingChi(for chi: ChiEnum) -> ChiEnum? {
        for pair in xungPairs {
            if pair.0 == chi { return pair.1 }
            if pair.1 == chi { return pair.0 }
        }
        return nil
    }

    static func isXungDay(birthYear: Int, dayChi: ChiEnum) -> XungResult? {
        let birthChi = birthYearCanChi(for: birthYear).chi
        guard let conflicting = conflictingChi(for: birthChi), conflicting == dayChi else {
            return nil
        }
        return XungResult(birthYearChi: birthChi, dayChi: dayChi, conflictingChi: conflicting)
    }

    /// Ngũ hành producing cycle: Mộc→Hỏa→Thổ→Kim→Thủy→Mộc.
    private static func producingElement(for element: String) -> String {
        switch element {
        case "Mộc": return "Hỏa"
        case "Hỏa": return "Thổ"
        case "Thổ": return "Kim"
        case "Kim": return "Thủy"
        case "Thủy": return "Mộc"
        default: return element
        }
    }

    private static func controllingElement(for element: String) -> String {
        switch element {
        case "Mộc": return "Thổ"
        case "Hỏa": return "Kim"
        case "Thổ": return "Thủy"
        case "Kim": return "Mộc"
        case "Thủy": return "Hỏa"
        default: return element
        }
    }

    /// Short Ngũ hành hint shown beside xem ngày when birth year is set.
    static func nguHanhHint(birthYear: Int, dayCan: CanEnum, isXung: Bool) -> String {
        let birthElement = birthYearCanChi(for: birthYear).can.element
        let dayElement = dayCan.element

        if isXung {
            let supportive = producingElement(for: birthElement)
            return String(
                format: String(localized: "Clashing day — favor %@ colors/elements (supports your %@ year)"),
                supportive,
                birthElement
            )
        }

        if dayElement == birthElement {
            return String(
                format: String(localized: "Same element (%@) — harmonious for your birth year"),
                birthElement
            )
        }

        if producingElement(for: dayElement) == birthElement {
            return String(
                format: String(localized: "Day %@ nourishes your %@ birth element"),
                dayElement,
                birthElement
            )
        }

        if controllingElement(for: dayElement) == birthElement {
            return String(
                format: String(localized: "Day %@ may pressure your %@ birth element — proceed carefully"),
                dayElement,
                birthElement
            )
        }

        return String(
            format: String(localized: "Day element %@ with birth element %@"),
            dayElement,
            birthElement
        )
    }
}
