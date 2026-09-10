//
//  StarCalculator.swift
//  lich-plus
//
//  Created by AI Assistant on 2025-11-24.
//  Calculator for traditional Vietnamese astrology star system
//  Source: Lịch Vạn Niên 2005-2009, Pages 153+ (all 12 months)
//

import Foundation

/// Calculator for good and bad stars based on lunar month and day Can-Chi
struct StarCalculator {

    // MARK: - Star Detection

    /// Detect stars for a given lunar date
    /// - Parameters:
    ///   - lunarMonth: Lunar month (1-12)
    ///   - dayCanChi: Day Can-Chi string (e.g., "Giáp Tý")
    /// - Returns: Star data if available for this month and Can-Chi
    static func detectStars(lunarMonth: Int, dayCanChi: String) -> DayStarData? {
        // All 12 months are now implemented
        switch lunarMonth {
        case 1:
            return Month1StarData.data.starsForDay(canChi: dayCanChi)
        case 2:
            return Month2StarData.data.starsForDay(canChi: dayCanChi)
        case 3:
            return Month3StarData.data.starsForDay(canChi: dayCanChi)
        case 4:
            return Month4StarData.data.starsForDay(canChi: dayCanChi)
        case 5:
            return Month5StarData.data.starsForDay(canChi: dayCanChi)
        case 6:
            return Month6StarData.data.starsForDay(canChi: dayCanChi)
        case 7:
            return Month7StarData.data.starsForDay(canChi: dayCanChi)
        case 8:
            return Month8StarData.data.starsForDay(canChi: dayCanChi)
        case 9:
            return Month9StarData.data.starsForDay(canChi: dayCanChi)
        case 10:
            return Month10StarData.data.starsForDay(canChi: dayCanChi)
        case 11:
            return Month11StarData.data.starsForDay(canChi: dayCanChi)
        case 12:
            return Month12StarData.data.starsForDay(canChi: dayCanChi)
        default:
            return nil
        }
    }

    /// Detect stars for a Gregorian date
    /// - Parameter date: Gregorian date
    /// - Returns: Star data if available
    static func detectStars(for date: Date) -> DayStarData? {
        // Convert to lunar calendar
        let lunarDate = LunarCalendar.solarToLunar(date)

        // Get day Can-Chi
        let dayCanChi = CanChiCalculator.calculateDayCanChi(for: date)
        let canChiString = "\(dayCanChi.can.vietnameseName) \(dayCanChi.chi.vietnameseName)"

        return detectStars(lunarMonth: lunarDate.month, dayCanChi: canChiString)
    }

    // MARK: - Score Calculation

    /// Calculate the net star score contribution
    /// - Parameter starData: Star data for the day
    /// - Returns: Net score from good stars (positive) and bad stars (negative)
    static func calculateStarScore(from starData: DayStarData?) -> Double {
        guard let starData = starData else {
            return 0.0  // No stars, no contribution
        }

        return starData.netScore
    }

    // MARK: - Star Information

    /// Get a summary of stars present on a day
    /// - Parameter starData: Star data for the day
    /// - Returns: Human-readable summary
    static func starSummary(from starData: DayStarData?) -> String? {
        guard let starData = starData else {
            return nil
        }

        var parts: [String] = []

        if !starData.goodStars.isEmpty {
            let names = starData.goodStars.map { $0.rawValue }.joined(separator: ", ")
            parts.append("Sao tốt: \(names)")
        }

        if !starData.badStars.isEmpty {
            let names = starData.badStars.map { $0.rawValue }.joined(separator: ", ")
            parts.append("Sao xấu: \(names)")
        }

        return parts.isEmpty ? nil : parts.joined(separator: " | ")
    }

    /// Check if a specific good star is present
    /// - Parameters:
    ///   - star: The good star to check
    ///   - starData: Star data for the day
    /// - Returns: True if the star is present
    static func hasGoodStar(_ star: GoodStar, in starData: DayStarData?) -> Bool {
        return starData?.goodStars.contains(star) ?? false
    }

    /// Check if a specific bad star is present
    /// - Parameters:
    ///   - star: The bad star to check
    ///   - starData: Star data for the day
    /// - Returns: True if the star is present
    static func hasBadStar(_ star: ExtendedBadStar, in starData: DayStarData?) -> Bool {
        return starData?.badStars.contains(star) ?? false
    }
}

// MARK: - Integration with DayQuality

extension StarCalculator {

    /// Enhanced day quality calculation including star system
    /// - Parameters:
    ///   - date: The date to analyze
    ///   - zodiacHour: The 12 Trực type
    ///   - unluckyDay: The Lục Hắc Đạo unlucky day type (if any)
    ///   - starData: The star data (if available)
    /// - Returns: Final quality rating
    static func calculateEnhancedQuality(
        for date: Date,
        zodiacHour: ZodiacHourType,
        unluckyDay: LucHacDaoCalculator.UnluckyDayType?,
        starData: DayStarData?
    ) -> DayType {
        // Base score from 12 Trực
        var score: Double = 0.0

        switch zodiacHour {
        case .tru, .dinh, .nguy, .chap:  // Hoàng Đạo (Good)
            score = 2.0
        case .thanh, .khai:               // Moderate
            score = -0.3
        case .kien, .man, .binh, .thu:    // Hắc Đạo (Bad) - Neutral base
            score = 0.0
        case .pha, .be:                   // Very Bad
            score = -3.0
        }

        // Add Lục Hắc Đạo penalty
        if let unluckyDay = unluckyDay {
            let severity = Double(unluckyDay.severity)
            score -= (severity / 5.0 * 2.5)  // Scale severity 1-5 to penalty 0.5-2.5
        }

        // Add star system contribution (NEW!)
        score += calculateStarScore(from: starData)

        // Determine final quality
        if score >= 1.0 {
            return .good
        } else if score >= -1.0 {
            return .neutral
        } else {
            return .bad
        }
    }
}

// MARK: - Data Availability

extension StarCalculator {
    enum StarDataAvailability: Equatable, Sendable {
        case complete
        case monthPartial
        case missingForDay
    }

    static func monthCompleteness(lunarMonth: Int) -> (completed: Int, total: Int) {
        // Count rows with actual stars — padded empty placeholders are not complete.
        let populated = monthData(lunarMonth)?.dayData.values.filter(\.hasAnyStars).count ?? 0
        return (populated, 60)
    }

    /// Whether star data is complete enough to give a confident purpose verdict.
    /// Empty placeholder entries (no good or bad stars) are not treated as complete.
    static func dataAvailability(lunarMonth: Int, dayCanChi: String) -> StarDataAvailability {
        let completeness = monthCompleteness(lunarMonth: lunarMonth)
        let starData = detectStars(lunarMonth: lunarMonth, dayCanChi: dayCanChi)
        let hasRealStars = starData?.hasAnyStars ?? false

        if completeness.completed < completeness.total {
            return hasRealStars ? .monthPartial : .missingForDay
        }
        return starData != nil ? .complete : .missingForDay
    }

    private static func monthData(_ lunarMonth: Int) -> MonthStarData? {
        switch lunarMonth {
        case 1: return Month1StarData.data
        case 2: return Month2StarData.data
        case 3: return Month3StarData.data
        case 4: return Month4StarData.data
        case 5: return Month5StarData.data
        case 6: return Month6StarData.data
        case 7: return Month7StarData.data
        case 8: return Month8StarData.data
        case 9: return Month9StarData.data
        case 10: return Month10StarData.data
        case 11: return Month11StarData.data
        case 12: return Month12StarData.data
        default: return nil
        }
    }
}

// MARK: - Data Status

extension StarCalculator {
    /// Print current implementation status
    static func printImplementationStatus() {
        print("=== Star System Implementation Status ===")
        print("")

        // All 12 months are now implemented
        let monthsWithData = Array(1...12)
        print("Implemented months: \(monthsWithData.count)/12")
        print("✅ All months have data structure")

        print("")
        print("=== Month-by-Month Status ===")
        Month1StarData.printDataStatus()
        Month2StarData.printDataStatus()
        Month3StarData.printDataStatus()
        Month4StarData.printDataStatus()
        Month5StarData.printDataStatus()
        Month6StarData.printDataStatus()
        Month7StarData.printDataStatus()
        Month8StarData.printDataStatus()
        Month9StarData.printDataStatus()
        Month10StarData.printDataStatus()
        Month11StarData.printDataStatus()
        Month12StarData.printDataStatus()

        print("")
        let totalEntries = 12 * 60  // 12 months × 60 Can-Chi = 720 entries
        let completedEntries = Month1StarData.dataCompleteness.completed +
                               Month2StarData.dataCompleteness.completed +
                               Month3StarData.dataCompleteness.completed +
                               Month4StarData.dataCompleteness.completed +
                               Month5StarData.dataCompleteness.completed +
                               Month6StarData.dataCompleteness.completed +
                               Month7StarData.dataCompleteness.completed +
                               Month8StarData.dataCompleteness.completed +
                               Month9StarData.dataCompleteness.completed +
                               Month10StarData.dataCompleteness.completed +
                               Month11StarData.dataCompleteness.completed +
                               Month12StarData.dataCompleteness.completed
        let percentage = Double(completedEntries) / Double(totalEntries) * 100.0
        print("Overall progress: \(completedEntries)/\(totalEntries) entries (\(String(format: "%.1f", percentage))%)")
        print("✅ Complete structural coverage for all 12 months")
        print("📖 Star data extracted from Lịch Vạn Niên 2005-2009")
        print("")
    }
}
