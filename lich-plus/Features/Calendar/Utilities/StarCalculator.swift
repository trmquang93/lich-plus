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
        // Currently only Month 9 data is implemented as proof-of-concept
        // TODO: Add data for months 1-8, 10-12
        guard lunarMonth == 9 else {
            return nil  // No data for other months yet
        }

        return Month9StarData.data.starsForDay(canChi: dayCanChi)
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

// MARK: - Data Status

extension StarCalculator {
    /// Print current implementation status
    static func printImplementationStatus() {
        print("=== Star System Implementation Status ===")
        print("")

        // Check which months have data
        let monthsWithData = [9]  // Currently only Month 9
        let monthsNeeded = Array(1...12)
        let missingMonths = monthsNeeded.filter { !monthsWithData.contains($0) }

        print("Implemented months: \(monthsWithData.count)/12")
        print("✅ Months with data: \(monthsWithData.map { String($0) }.joined(separator: ", "))")

        if !missingMonths.isEmpty {
            print("❌ Missing months: \(missingMonths.map { String($0) }.joined(separator: ", "))")
        }

        print("")
        Month9StarData.printDataStatus()

        print("")
        let totalEntries = 12 * 60  // 12 months × 60 Can-Chi = 720 entries
        let completedEntries = Month9StarData.dataCompleteness.completed
        let percentage = Double(completedEntries) / Double(totalEntries) * 100.0
        print("Overall progress: \(completedEntries)/\(totalEntries) entries (\(String(format: "%.1f", percentage))%)")

        if percentage < 100.0 {
            let remaining = totalEntries - completedEntries
            print("⚠️ Need \(remaining) more entries to reach 100% accuracy")
            print("📖 Requires extraction from Lịch Vạn Niên book pages for remaining months")
        } else {
            print("✅ Complete star data for all months - 100% accuracy possible!")
        }
        print("")
    }
}
