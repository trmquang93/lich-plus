//
//  CanChiCalculator.swift
//  lich-plus
//
//  Can-Chi (Heavenly Stems & Earthly Branches) Calculator
//  This file implements the traditional Vietnamese calendar algorithms for calculating
//  Can-Chi pairs for years, months, days, and hours based on the lunar calendar system
//

import Foundation
import VietnameseLunar

// MARK: - Can-Chi Calculator

struct CanChiCalculator {

    // MARK: - Year Can-Chi Calculation

    /// Calculate Can-Chi for a lunar year using the VietnameseLunar library
    /// - Parameter lunarYear: The lunar year (e.g., 2024)
    /// - Returns: Can-Chi pair for the year
    static func calculateYearCanChi(lunarYear: Int) -> CanChiPair {
        // Can cycles every 10 years, Chi cycles every 12 years
        // The calculation is based on a known reference point

        let canIndex = lunarYear % 10
        let chiIndex = lunarYear % 12

        let can = CanEnum(rawValue: canIndex) ?? .giap
        let chi = ChiEnum(rawValue: chiIndex) ?? .ty

        return CanChiPair(can: can, chi: chi)
    }

    /// Calculate Can-Chi for a lunar year from a solar date using VietnameseLunar
    /// - Parameter date: Solar date
    /// - Returns: Can-Chi pair for the lunar year
    static func calculateYearCanChi(for date: Date) -> CanChiPair {
        let vietnameseCalendar = VietnameseCalendar(date: date)
        guard let vietnameseDate = vietnameseCalendar.vietnameseDate else {
            return CanChiPair(can: .giap, chi: .ty)
        }

        // Extract Can and Chi from the Vietnamese calendar
        let can = parseCanFromString(vietnameseDate.can)
        let chi = parseChiFromString(vietnameseDate.chi)

        return CanChiPair(can: can, chi: chi)
    }

    // MARK: - Day Can-Chi Calculation

    /// Calculate Can-Chi for a specific solar date
    /// Uses the Vạn Niên Calendar algorithm (similar to Julian Day Number method)
    /// - Parameter date: Solar date
    /// - Returns: Can-Chi pair for the day
    static func calculateDayCanChi(for date: Date) -> CanChiPair {
        // Calculate Julian Day Number
        let jdn = calculateJulianDayNumber(for: date)

        // Calculate Can and Chi based on JDN
        // The reference point: JDN 11 = Giáp Tý (0, 0)
        // Can cycles every 10 days, Chi cycles every 12 days

        // Traditional formula: (jdn + 9) % 10 for Can where Giáp = 0
        // CanEnum offset: +4 because enum starts with Canh instead of Giáp
        let canIndex = (jdn + 13) % 10  // +9 traditional formula + 4 enum offset
        let chiIndex = (jdn + 1) % 12

        let can = CanEnum(rawValue: canIndex) ?? .giap
        let chi = ChiEnum(rawValue: chiIndex) ?? .ty

        return CanChiPair(can: can, chi: chi)
    }

    // MARK: - Month Can-Chi Calculation

    /// Calculate Can-Chi for a lunar month
    /// Month Can is derived from the year's Can following a specific pattern
    /// Month Chi corresponds to the lunar month (1 = Dần, 2 = Mão, etc.)
    /// - Parameters:
    ///   - lunarMonth: Lunar month (1-12)
    ///   - yearCan: The Can of the lunar year
    /// - Returns: Can-Chi pair for the month
    static func calculateMonthCanChi(lunarMonth: Int, yearCan: CanEnum) -> CanChiPair {
        // Month Chi: Lunar month 1 = Dần (2), month 2 = Mão (3), etc.
        // Offset by 2 because Tý (0) and Sửu (1) come before Dần
        let monthChiIndex = (lunarMonth + 1) % 12
        let monthChi = ChiEnum(rawValue: monthChiIndex) ?? .dan

        // Month Can follows a pattern based on year Can
        // This is the "Five Tigers Escape" (Ngũ Hổ Độn) formula
        // Year Can: Giáp/Kỷ -> month 1 = Bính Dần
        // Year Can: Ất/Canh -> month 1 = Mậu Dần
        // Year Can: Bính/Tân -> month 1 = Canh Dần
        // Year Can: Đinh/Nhâm -> month 1 = Nhâm Dần
        // Year Can: Mậu/Quý -> month 1 = Giáp Dần

        let monthCanBase: Int
        switch yearCan {
        case .giap, .ky:    // Giáp, Kỷ
            monthCanBase = 6 // Bính (rawValue: 6)
        case .at, .canh:    // Ất, Canh
            monthCanBase = 8 // Mậu (rawValue: 8)
        case .binh, .tan:   // Bính, Tân
            monthCanBase = 0 // Canh (rawValue: 0)
        case .dinh, .nham:  // Đinh, Nhâm
            monthCanBase = 2 // Nhâm (rawValue: 2)
        case .mau, .quy:    // Mậu, Quý
            monthCanBase = 4 // Giáp (rawValue: 4)
        }

        let monthCanIndex = (monthCanBase + lunarMonth - 1) % 10
        let monthCan = CanEnum(rawValue: monthCanIndex) ?? .giap

        return CanChiPair(can: monthCan, chi: monthChi)
    }

    // MARK: - Hour Can-Chi Calculation

    /// Calculate Can-Chi for a specific solar hour
    /// Hour Chi cycles through 12 branches (2 hours per branch)
    /// Hour Can is derived from the day's Can following a specific pattern
    /// - Parameters:
    ///   - solarHour: Solar hour (0-23)
    ///   - dayCan: The Can of the day
    /// - Returns: Can-Chi pair for the hour
    static func calculateHourCanChi(solarHour: Int, dayCan: CanEnum) -> CanChiPair {
        // Convert 24-hour to 12 two-hour periods
        // 23:00-01:00 = Tý (0), 01:00-03:00 = Sửu (1), etc.
        var hourIndex = (solarHour + 1) / 2
        if solarHour == 23 {
            hourIndex = 0 // Special case for Tý hour
        }
        let hourChi = ChiEnum(rawValue: hourIndex % 12) ?? .ty

        // Hour Can follows the "Five Rats Escape" (Ngũ Tý Độn) formula
        // Day Can: Giáp/Kỷ -> Tý hour = Giáp Tý
        // Day Can: Ất/Canh -> Tý hour = Bính Tý
        // Day Can: Bính/Tân -> Tý hour = Mậu Tý
        // Day Can: Đinh/Nhâm -> Tý hour = Canh Tý
        // Day Can: Mậu/Quý -> Tý hour = Nhâm Tý

        let hourCanBase: Int
        switch dayCan {
        case .giap, .ky:    // Giáp, Kỷ
            hourCanBase = 4 // Giáp (rawValue: 4)
        case .at, .canh:    // Ất, Canh
            hourCanBase = 6 // Bính (rawValue: 6)
        case .binh, .tan:   // Bính, Tân
            hourCanBase = 8 // Mậu (rawValue: 8)
        case .dinh, .nham:  // Đinh, Nhâm
            hourCanBase = 0 // Canh (rawValue: 0)
        case .mau, .quy:    // Mậu, Quý
            hourCanBase = 2 // Nhâm (rawValue: 2)
        }

        let hourCanIndex = (hourCanBase + hourIndex) % 10
        let hourCan = CanEnum(rawValue: hourCanIndex) ?? .giap

        return CanChiPair(can: hourCan, chi: hourChi)
    }

    // MARK: - Formatting

    /// Format a Can-Chi pair as a string
    /// - Parameters:
    ///   - can: The Heavenly Stem
    ///   - chi: The Earthly Branch
    /// - Returns: Formatted string (e.g., "Giáp Tý")
    static func canChiToString(can: CanEnum, chi: ChiEnum) -> String {
        return "\(can.vietnameseName) \(chi.vietnameseName)"
    }

    /// Format a CanChiPair as a string
    static func canChiToString(_ pair: CanChiPair) -> String {
        return pair.displayName
    }

    // MARK: - Helper Functions

    /// Calculate Julian Day Number for a date
    /// This is used for day Can-Chi calculations
    private static func calculateJulianDayNumber(for date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)

        guard let year = components.year,
              let month = components.month,
              let day = components.day else {
            return 0
        }

        // Julian Day Number algorithm
        let a = (14 - month) / 12
        let y = year + 4800 - a
        let m = month + 12 * a - 3

        let jdn = day + (153 * m + 2) / 5 + 365 * y + y / 4 - y / 100 + y / 400 - 32045

        return jdn
    }

    /// Parse Can from Vietnamese string
    private static func parseCanFromString(_ canString: String) -> CanEnum {
        switch canString {
        case "Giáp": return .giap
        case "Ất": return .at
        case "Bính": return .binh
        case "Đinh": return .dinh
        case "Mậu": return .mau
        case "Kỷ": return .ky
        case "Canh": return .canh
        case "Tân": return .tan
        case "Nhâm": return .nham
        case "Quý": return .quy
        default: return .giap
        }
    }

    /// Parse Chi from Vietnamese string
    private static func parseChiFromString(_ chiString: String) -> ChiEnum {
        switch chiString {
        case "Tý": return .ty
        case "Sửu": return .suu
        case "Dần": return .dan
        case "Mão": return .mao
        case "Thìn": return .thin
        case "Tỵ": return .ty2
        case "Ngọ": return .ngo
        case "Mùi": return .mui
        case "Thân": return .than
        case "Dậu": return .dau
        case "Tuất": return .tuat
        case "Hợi": return .hoi
        default: return .ty
        }
    }
}

// MARK: - Date Extensions for Can-Chi

extension Date {
    /// Get the Can-Chi for this date
    var dayCanChi: CanChiPair {
        return CanChiCalculator.calculateDayCanChi(for: self)
    }

    /// Get the Can-Chi for the lunar year of this date
    var yearCanChi: CanChiPair {
        return CanChiCalculator.calculateYearCanChi(for: self)
    }

    /// Get the Can-Chi for a specific hour of this date
    func hourCanChi(hour: Int) -> CanChiPair {
        let dayCan = self.dayCanChi.can
        return CanChiCalculator.calculateHourCanChi(solarHour: hour, dayCan: dayCan)
    }
}
