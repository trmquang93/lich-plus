//
//  HoangDaoCalculator.swift
//  lich-plus
//
//  Hoàng Đạo (Auspicious Hours) Calculator
//  This file implements the traditional Vietnamese astrology system for calculating
//  the 12 Zodiac Hours (12 Kiến Trừ) and determining auspicious/inauspicious times
//

import Foundation

// MARK: - Hoàng Đạo Calculator

struct HoangDaoCalculator {

    // MARK: - Main Zodiac Hour Calculation

    /// Calculate the zodiac hour type for a specific lunar date
    /// The 12 zodiac hours (12 Kiến Trừ) rotate based on the lunar month and day
    /// Formula: (lunarDay + lunarMonth - 1) % 12
    /// - Parameter lunarDate: Tuple of (day, month, year)
    /// - Returns: The zodiac hour type for that day
    static func calculateZodiacHour(for lunarDate: (day: Int, month: Int, year: Int)) -> ZodiacHourType {
        // Check for special dates first
        if SpecialLunarDates.isSpecialAuspiciousDate(lunarDay: lunarDate.day, lunarMonth: lunarDate.month) {
            // Special auspicious dates get the Tứ Hộ Thần (4 Very Auspicious zodiac hours)
            let specialZodiacs: [ZodiacHourType] = [.tru, .dinh, .nguy, .khai]
            let index = (lunarDate.day + lunarDate.month) % specialZodiacs.count
            return specialZodiacs[index]
        }

        if SpecialLunarDates.isSpecialInauspiciousDate(lunarDay: lunarDate.day, lunarMonth: lunarDate.month) {
            // Special inauspicious dates get worse zodiac hours
            let specialZodiacs: [ZodiacHourType] = [.pha, .nguy, .be, .chap]
            let index = (lunarDate.day + lunarDate.month) % specialZodiacs.count
            return specialZodiacs[index]
        }

        // Standard calculation based on the 12 Kiến Trừ cycle
        // The formula cycles through the 12 zodiac hours based on lunar day and month
        let zodiacIndex = (lunarDate.day + lunarDate.month - 1) % 12
        return ZodiacHourType(rawValue: zodiacIndex) ?? .kien
    }

    // MARK: - Day Quality Determination

    /// Determine the overall quality and astrological data for a specific date
    /// - Parameters:
    ///   - lunarDay: Day of the lunar month
    ///   - lunarMonth: Lunar month
    ///   - lunarYear: Lunar year
    ///   - dayCanChi: The Can-Chi string for the day
    /// - Returns: Complete DayQuality with zodiac hour, activities, and lucky attributes
    static func determineDayQuality(
        lunarDay: Int,
        lunarMonth: Int,
        lunarYear: Int,
        dayCanChi: String
    ) -> DayQuality {
        let lunarDate = (day: lunarDay, month: lunarMonth, year: lunarYear)
        let zodiacHour = calculateZodiacHour(for: lunarDate)

        // Get suitable and taboo activities
        let suitableActivities = ZodiacHourData.getSuitableActivities(for: zodiacHour)
        let tabooActivities = ZodiacHourData.getTabooActivities(for: zodiacHour)

        // Get lucky direction and color
        let luckyDirection = ZodiacHourData.getLuckyDirection(for: zodiacHour, dayCanChi: dayCanChi)
        let luckyColor = ZodiacHourData.getLuckyColor(for: zodiacHour)

        return DayQuality(
            zodiacHour: zodiacHour,
            dayCanChi: dayCanChi,
            suitableActivities: suitableActivities,
            tabooActivities: tabooActivities,
            luckyDirection: luckyDirection,
            luckyColor: luckyColor
        )
    }

    /// Simplified version that takes a Date object
    static func determineDayQuality(for date: Date) -> DayQuality {
        let lunarDate = LunarCalendar.solarToLunar(date)
        let dayCanChi = CanChiCalculator.calculateDayCanChi(for: date)
        let dayCanChiString = CanChiCalculator.canChiToString(dayCanChi)

        return determineDayQuality(
            lunarDay: lunarDate.day,
            lunarMonth: lunarDate.month,
            lunarYear: lunarDate.year,
            dayCanChi: dayCanChiString
        )
    }

    // MARK: - Hourly Zodiac Calculation

    /// Calculate the auspicious hours for a specific day
    /// Returns the zodiac information for each 2-hour period (12 periods total)
    /// - Parameter zodiacHour: The zodiac hour type for the day
    /// - Returns: Array of HourlyZodiac with times and suitable activities
    static func getHourlyZodiacs(for date: Date) -> [HourlyZodiac] {
        let dayCanChi = CanChiCalculator.calculateDayCanChi(for: date)
        let dayChi = dayCanChi.chi
        let dayQuality = determineDayQuality(for: date)
        let dayZodiacHour = dayQuality.zodiacHour

        // Get the auspicious hour indices for this day
        let auspiciousHourIndices = HourlyZodiacHelper.getAuspiciousHours(
            for: dayZodiacHour,
            dayChi: dayChi
        )

        var hourlyZodiacs: [HourlyZodiac] = []

        // Generate zodiac info for all 12 two-hour periods
        for hourIndex in 0..<12 {
            let chi = ChiEnum(rawValue: hourIndex) ?? .ty
            let isAuspicious = auspiciousHourIndices.contains(hourIndex)

            // Calculate the zodiac hour for this time period
            // It rotates based on the day's zodiac
            let hourZodiacIndex = (dayZodiacHour.rawValue + hourIndex) % 12
            let hourZodiac = ZodiacHourType(rawValue: hourZodiacIndex) ?? .kien

            // Get activities for this hour
            let activities: [String]
            if isAuspicious {
                activities = ZodiacHourData.getSuitableActivities(for: hourZodiac)
            } else {
                // For inauspicious hours, suggest rest or minor activities
                activities = ["Nghỉ ngơi", "Suy nghĩ", "Hoạch định"]
            }

            let hourlyZodiac = HourlyZodiac(
                hour: hourIndex,
                chi: chi,
                zodiacHour: hourZodiac,
                isAuspicious: isAuspicious,
                suitableActivities: Array(activities.prefix(3)) // Limit to 3 activities
            )

            hourlyZodiacs.append(hourlyZodiac)
        }

        return hourlyZodiacs
    }

    /// Get only the auspicious hours for a day (filtered list)
    static func getAuspiciousHoursOnly(for date: Date) -> [HourlyZodiac] {
        let allHours = getHourlyZodiacs(for: date)
        return allHours.filter { $0.isAuspicious }
    }

    // MARK: - Day Type Mapping

    /// Map ZodiacHourType to DayType using the three-tier quality system
    /// - Parameter zodiacHour: The zodiac hour type
    /// - Returns: Simple DayType (good/bad/neutral)
    static func mapToDayType(_ zodiacHour: ZodiacHourType) -> DayType {
        switch zodiacHour.quality {
        case .veryAuspicious:
            return .good
        case .neutral:
            return .neutral
        case .inauspicious:
            return .bad
        }
    }

    /// Determine DayType for a specific date
    static func determineDayType(for date: Date) -> DayType {
        let lunarDate = LunarCalendar.solarToLunar(date)
        let zodiacHour = calculateZodiacHour(for: lunarDate)
        return mapToDayType(zodiacHour)
    }

    // MARK: - Special Date Helpers

    /// Check if a date is particularly auspicious
    static func isVeryAuspiciousDay(for date: Date) -> Bool {
        let lunarDate = LunarCalendar.solarToLunar(date)

        // Check special dates
        if SpecialLunarDates.isSpecialAuspiciousDate(
            lunarDay: lunarDate.day,
            lunarMonth: lunarDate.month
        ) {
            return true
        }

        // Check zodiac hour - only Tứ Hộ Thần (4 Very Auspicious)
        let zodiacHour = calculateZodiacHour(for: lunarDate)
        return zodiacHour == .tru || zodiacHour == .dinh ||
               zodiacHour == .nguy || zodiacHour == .khai
    }

    /// Check if a date is particularly inauspicious
    static func isVeryInauspiciousDay(for date: Date) -> Bool {
        let lunarDate = LunarCalendar.solarToLunar(date)

        // Check special dates
        if SpecialLunarDates.isSpecialInauspiciousDate(
            lunarDay: lunarDate.day,
            lunarMonth: lunarDate.month
        ) {
            return true
        }

        // Check zodiac hour
        let zodiacHour = calculateZodiacHour(for: lunarDate)
        return zodiacHour == .pha || zodiacHour == .nguy
    }

    /// Get a user-friendly description of the day's quality
    static func getDayQualityDescription(for date: Date) -> String {
        let lunarDate = LunarCalendar.solarToLunar(date)
        let zodiacHour = calculateZodiacHour(for: lunarDate)

        // Check for special date descriptions
        if let specialDesc = SpecialLunarDates.getSpecialDateDescription(
            lunarDay: lunarDate.day,
            lunarMonth: lunarDate.month
        ) {
            return specialDesc
        }

        // Return zodiac hour description
        return zodiacHour.fullDescription
    }
}

// MARK: - Date Extensions for Hoàng Đạo

extension Date {
    /// Get the zodiac hour type for this date
    var zodiacHour: ZodiacHourType {
        let lunarDate = LunarCalendar.solarToLunar(self)
        return HoangDaoCalculator.calculateZodiacHour(for: lunarDate)
    }

    /// Get the day quality for this date
    var dayQuality: DayQuality {
        return HoangDaoCalculator.determineDayQuality(for: self)
    }

    /// Get all hourly zodiacs for this date
    var hourlyZodiacs: [HourlyZodiac] {
        return HoangDaoCalculator.getHourlyZodiacs(for: self)
    }

    /// Get only auspicious hours for this date
    var auspiciousHours: [HourlyZodiac] {
        return HoangDaoCalculator.getAuspiciousHoursOnly(for: self)
    }

    /// Check if this is a very auspicious day
    var isVeryAuspiciousDay: Bool {
        return HoangDaoCalculator.isVeryAuspiciousDay(for: self)
    }

    /// Check if this is a very inauspicious day
    var isVeryInauspiciousDay: Bool {
        return HoangDaoCalculator.isVeryInauspiciousDay(for: self)
    }
}
