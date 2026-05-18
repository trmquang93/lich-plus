//
//  VanKhanOccasionMatcher.swift
//  lich-plus
//
//  Matches a date (+ optional profile) to văn khấn occasions.
//  Pure logic — unit-testable.
//

import Foundation

enum VanKhanOccasionMatcher {

    /// A matched occasion plus optional bound context (deceased relative for giỗ).
    struct Match {
        let occasion: VanKhanOccasion
        let deceasedRelative: DeceasedRelative?

        init(occasion: VanKhanOccasion, deceasedRelative: DeceasedRelative? = nil) {
            self.occasion = occasion
            self.deceasedRelative = deceasedRelative
        }
    }

    /// Returns up to `max` matches for the given date, ranked by priority:
    /// family/giỗ → festival → monthly. Festival wins over monthly when both
    /// match (e.g. Rằm tháng Giêng shows the festival, not the monthly Rằm).
    static func match(date: Date, profile: PersonalProfile?, max: Int = 2) -> [Match] {
        let lunar = LunarCalendar.solarToLunar(date)
        let solar = Calendar(identifier: .gregorian).dateComponents([.month, .day], from: date)
        let solarMonth = solar.month ?? 0
        let solarDay = solar.day ?? 0

        var matches: [Match] = []

        // Anniversary (giỗ) — highest priority
        if let p = profile {
            for relative in p.deceasedRelatives
            where relative.lunarDay == lunar.day && relative.lunarMonth == lunar.month {
                if let occ = VanKhanLibrary.occasion(id: "gio") {
                    matches.append(Match(occasion: occ, deceasedRelative: relative))
                }
            }
        }

        // Festival (fixed lunar / solar / last-day-of-year)
        for occ in VanKhanLibrary.festivals {
            switch occ.trigger {
            case .lunarDate(let m, let d):
                if lunar.month == m && lunar.day == d {
                    matches.append(Match(occasion: occ))
                }
            case .lunarLastDayOfYear:
                if isLastLunarDayOfYear(date: date, lunar: lunar) {
                    matches.append(Match(occasion: occ))
                }
            case .solar(let m, let d):
                // Thanh Minh — allow ±1 day tolerance
                if solarMonth == m && abs(solarDay - d) <= 1 {
                    matches.append(Match(occasion: occ))
                }
            default:
                break
            }
        }

        // Monthly (only if no festival already matches today)
        if matches.allSatisfy({ $0.occasion.category != .festival && $0.occasion.category != .anniversary }) || matches.isEmpty {
            for occ in VanKhanLibrary.monthly {
                if case .lunarDay(let d) = occ.trigger, lunar.day == d,
                   !matches.contains(where: { $0.occasion.id == occ.id }) {
                    // Skip the monthly Rằm/Mùng-1 if a festival on the same lunar day already matched
                    let festivalConflict = matches.contains { m in
                        if case .lunarDate(_, let fd) = m.occasion.trigger { return fd == d }
                        return false
                    }
                    if !festivalConflict {
                        matches.append(Match(occasion: occ))
                    }
                }
            }
        }

        return Array(matches.prefix(max))
    }

    /// True iff `date` is the last day of the current lunar year (Giao Thừa).
    /// The lunar year ends on day 29 or 30 of lunar month 12 — detected by
    /// checking whether the *next* solar day rolls over to lunar 1/1.
    private static func isLastLunarDayOfYear(date: Date, lunar: (day: Int, month: Int, year: Int)) -> Bool {
        guard lunar.month == 12 else { return false }
        let nextDay = Calendar(identifier: .gregorian).date(byAdding: .day, value: 1, to: date) ?? date
        let next = LunarCalendar.solarToLunar(nextDay)
        return next.month == 1 && next.day == 1
    }
}
