//
//  ActivityVerdictCalculator.swift
//  lich-plus
//
//  Rule-based xem ngày cho việc from 12 Trực, Lục Hắc Đạo, stars, and tuổi xung.
//

import Foundation

struct ActivityVerdictCalculator {

    static func verdict(
        for date: Date,
        purpose: ActivityPurpose,
        birthYear: Int? = nil
    ) -> ActivityVerdict {
        let dayQuality = HoangDaoCalculator.determineDayQuality(for: date)
        let lunar = LunarCalendar.solarToLunar(date)
        let dayCanChi = CanChiCalculator.calculateDayCanChi(for: date)
        let dayCanChiString = CanChiCalculator.canChiToString(dayCanChi)
        let starAvailability = StarCalculator.dataAvailability(
            lunarMonth: lunar.month,
            dayCanChi: dayCanChiString
        )

        if starAvailability == .missingForDay {
            return incompleteVerdict(
                purpose: purpose,
                dayQuality: dayQuality,
                dayCanChi: dayCanChi,
                birthYear: birthYear,
                message: String(
                    format: String(localized: "Star data for lunar month %lld is incomplete — no entry for %@."),
                    lunar.month,
                    dayCanChiString
                )
            )
        }

        var score = 0.0
        var reasons: [String] = []

        // Lục Hắc Đạo
        if let unluckyDay = dayQuality.unluckyDayType {
            if purpose.blockedByLucHacDao {
                score -= Double(unluckyDay.severity) * 0.4
                reasons.append(unluckyDay.description)
            }
        }

        // 12 Trực activity fit
        let keywords = purpose.activityKeywords
        let suitableHit = dayQuality.suitableActivities.contains { activity in
            keywords.contains { activity.localizedCaseInsensitiveContains($0) }
        }
        let tabooHit = dayQuality.tabooActivities.contains { activity in
            keywords.contains { activity.localizedCaseInsensitiveContains($0) }
        }

        if suitableHit { score += 1.2 }
        if tabooHit { score -= 1.5 }

        switch dayQuality.zodiacHour.quality {
        case .veryAuspicious:
            score += 0.4
        case .severelyInauspicious:
            score -= 0.8
        case .inauspicious:
            score -= 0.3
        case .neutral:
            break
        }

        // Purpose-specific bad stars (when star data exists)
        if let badStars = dayQuality.badStars {
            for star in badStars where purpose.conflictingBadStars.contains(star) {
                score -= abs(star.score) * 0.5
                reasons.append(String(format: String(localized: "Unfavorable star: %@"), star.rawValue))
            }
        }

        if let goodStars = dayQuality.goodStars, !goodStars.isEmpty, purpose != .ancestorWorship {
            score += min(0.4, Double(goodStars.count) * 0.15)
        }

        // Birth year xung
        var isXung = false
        if let birthYear,
           let xung = TuoiHopXungCalculator.isXungDay(birthYear: birthYear, dayChi: dayCanChi.chi) {
            isXung = true
            score -= 1.0
            reasons.append(xung.reason)
        }

        let nguHanhHint = birthYear.map {
            TuoiHopXungCalculator.nguHanhHint(
                birthYear: $0,
                dayCan: dayCanChi.can,
                isXung: isXung
            )
        }

        let status: ActivityVerdictStatus
        if score >= 0.6 {
            status = .good
        } else if score <= -0.6 {
            status = .bad
        } else {
            status = .neutral
        }

        let summary = summaryText(
            status: status,
            purpose: purpose,
            truc: dayQuality.zodiacHour,
            isXung: isXung,
            starPartial: starAvailability == .monthPartial
        )

        if starAvailability == .monthPartial {
            reasons.insert(
                String(
                    format: String(localized: "Star table for lunar month %lld is partially complete."),
                    lunar.month
                ),
                at: 0
            )
        }

        if reasons.isEmpty {
            reasons.append(dayQuality.zodiacHour.fullDescription)
        }

        return ActivityVerdict(
            purpose: purpose,
            status: status,
            summary: summary,
            reasons: reasons,
            isStarDataIncomplete: starAvailability == .monthPartial,
            isBirthYearXung: isXung,
            nguHanhHint: nguHanhHint,
            trucName: dayQuality.zodiacHour.vietnameseName
        )
    }

    // MARK: - Private

    private static func incompleteVerdict(
        purpose: ActivityPurpose,
        dayQuality: DayQuality,
        dayCanChi: CanChiPair,
        birthYear: Int?,
        message: String
    ) -> ActivityVerdict {
        var reasons = [
            String(localized: "12 Trực and Hoàng Đạo hours are still shown below."),
            dayQuality.zodiacHour.fullDescription,
        ]

        var isXung = false
        if let birthYear,
           let xung = TuoiHopXungCalculator.isXungDay(birthYear: birthYear, dayChi: dayCanChi.chi) {
            isXung = true
            reasons.insert(xung.reason, at: 0)
        }

        let nguHanhHint = birthYear.map {
            TuoiHopXungCalculator.nguHanhHint(
                birthYear: $0,
                dayCan: dayCanChi.can,
                isXung: isXung
            )
        }

        return ActivityVerdict(
            purpose: purpose,
            status: .incomplete,
            summary: message,
            reasons: reasons,
            isStarDataIncomplete: true,
            isBirthYearXung: isXung,
            nguHanhHint: nguHanhHint,
            trucName: dayQuality.zodiacHour.vietnameseName
        )
    }

    private static func summaryText(
        status: ActivityVerdictStatus,
        purpose: ActivityPurpose,
        truc: ZodiacHourType,
        isXung: Bool,
        starPartial: Bool
    ) -> String {
        var parts: [String] = [status.displayName]

        if isXung {
            parts.append(String(localized: "Birth year clash"))
        }

        if starPartial {
            parts.append(String(localized: "Partial star data"))
        }

        parts.append(String(format: String(localized: "12 Trực: %@"), truc.vietnameseName))
        _ = purpose
        return parts.joined(separator: " · ")
    }
}
