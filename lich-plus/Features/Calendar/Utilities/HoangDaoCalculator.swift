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
    /// Uses the traditional Vietnamese 12 Trực calculation method
    /// Based on: "Tháng nào trực nấy" principle (Each month has its own Trực)
    /// References: vansu.net, phongthuytuongminh.com, xemngay.com
    ///
    /// Traditional Method:
    /// 1. Each lunar month corresponds to a Chi value
    /// 2. Find the first day in that month whose Chi matches the month's Chi
    /// 3. That day is Trực Kiến (position 0)
    /// 4. Subsequent days cycle through 12 Trực based on their Chi position
    ///
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

        // Traditional method: Calculate based on month and day using month-Chi relationship
        // This implements the "Tháng nào trực nấy" principle where each month has a base offset
        // that determines how the 12 Trực cycle through the days of that month
        //
        // Algorithm:
        // The 12 Trực cycle follows a traditional pattern based on the lunar month
        // Formula: Trực position = (monthOffset + day - 1) % 12
        // where the monthOffset is determined by the lunar month number

        // Get month offset for 12 Trực calculation
        let monthOffset = getMonthOffsetForTruc(lunarDate.month)

        // Calculate Trực based on day within month
        let zodiacIndex = (monthOffset + lunarDate.day - 1) % 12
        return ZodiacHourType(rawValue: zodiacIndex) ?? .kien
    }

    /// Calculate the zodiac hour type using the traditional solar term-based method
    /// This implements the authentic Vietnamese astrology algorithm
    /// Based on research from xemngay.com and traditional tiết khí (solar terms) system
    ///
    /// Algorithm:
    /// 1. Determine which solar term "month" the date falls in (using sun longitude)
    /// 2. Each solar term month corresponds to a Chi (Earthly Branch)
    /// 3. The day whose Chi matches that solar term Chi is Trực Kiến (0)
    /// 4. Subsequent days cycle through the 12 Trực
    ///
    /// - Parameters:
    ///   - solarDate: The solar date
    ///   - lunarMonth: The lunar month (for fallback approximation)
    /// - Returns: The zodiac hour type for that day
    static func calculateZodiacHourChiBased(solarDate: Date, lunarMonth: Int) -> ZodiacHourType {
        // Get day Can-Chi to extract day Chi
        let dayCanChi = CanChiCalculator.calculateDayCanChi(for: solarDate)
        let dayChi = dayCanChi.chi

        // Get the solar term Chi using astronomical calculation
        let solarTermChi = getSolarTermChi(solarDate)

        // Calculate Trực using the traditional solar term-based formula
        // The day whose Chi equals the solar term Chi has Trực Kiến (0)
        // Formula: Trực = (dayChi - solarTermChi + 12) % 12
        let zodiacIndex = (dayChi.rawValue - solarTermChi.rawValue + 12) % 12

        return ZodiacHourType(rawValue: zodiacIndex) ?? .kien
    }

    /// Get the Chi (Earthly Branch) for the solar term period that contains this date
    /// Uses astronomical calculation of sun longitude
    /// Based on Ho Ngoc Duc's algorithm and traditional Vietnamese astrology
    /// - Parameter date: The solar date
    /// - Returns: The Chi corresponding to that solar term period
    private static func getSolarTermChi(_ date: Date) -> ChiEnum {
        // Calculate Julian Day Number
        let jdn = calculateJulianDayNumber(for: date)

        // Get sun longitude in degrees (0-360)
        let sunLongitudeDegrees = getSunLongitudeDegrees(jdn: jdn, timeZone: 7)

        // Calculate Chi based on solar term position
        // Lập Xuân (Beginning of Spring) starts at 315° and corresponds to Chi Dần (2)
        // Each 30° sector corresponds to one Chi in the cycle
        // Adjust degrees relative to Lập Xuân (315°)
        let adjustedDegrees = sunLongitudeDegrees >= 315.0 ?
            sunLongitudeDegrees - 315.0 : sunLongitudeDegrees + 45.0

        // Calculate which 30° sector (0-11) we're in
        let sector = Int(floor(adjustedDegrees / 30.0))

        // Map sector to Chi, starting from Dần (2)
        // Sector 0 (315-345°) = Dần (2)
        // Sector 1 (345-15°) = Mão (3)
        // etc.
        let chiIndex = (sector + 2) % 12

        return ChiEnum(rawValue: chiIndex) ?? .dan
    }

    /// Get sun longitude in degrees (0-360)
    /// Extracted from getSunLongitude for reuse
    private static func getSunLongitudeDegrees(jdn: Int, timeZone: Int) -> Double {
        let T = (Double(jdn) - 2451545.5 - Double(timeZone) / 24.0) / 36525.0
        let T2 = T * T
        let dr = Double.pi / 180.0

        let M = 357.52910 + 35999.05030 * T - 0.0001559 * T2 - 0.00000048 * T * T2
        let L0 = 280.46645 + 36000.76983 * T + 0.0003032 * T2

        var DL = (1.914600 - 0.004817 * T - 0.000014 * T2) * sin(dr * M)
        DL = DL + (0.019993 - 0.000101 * T) * sin(dr * 2 * M) + 0.000290 * sin(dr * 3 * M)

        var L = (L0 + DL) * dr
        L = L - Double.pi * 2 * Double(Int(L / (Double.pi * 2)))

        return L * 180.0 / Double.pi
    }

    /// Calculate Julian Day Number for a date
    /// This is used for solar term calculations
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

    /// Calculate sun longitude at local midnight for Vietnamese timezone (GMT+7)
    /// Returns value 0-11 representing 30-degree sectors of the ecliptic
    /// Based on Ho Ngoc Duc's algorithm
    /// - Parameters:
    ///   - jdn: Julian Day Number
    ///   - timeZone: Timezone offset in hours (7 for Vietnam)
    /// - Returns: Sun longitude sector (0-11)
    private static func getSunLongitude(jdn: Int, timeZone: Int) -> Int {
        let degrees = getSunLongitudeDegrees(jdn: jdn, timeZone: timeZone)
        // Convert to 30-degree sectors (0-11)
        return Int(floor(degrees / 30.0))
    }

    /// Get the Chi (Earthly Branch) that corresponds to a lunar month
    /// Traditional Vietnamese astrology: "Tháng nào trực nấy" (Each month has its own Trực)
    ///
    /// Month-to-Chi Mapping:
    /// Month 1 = Dần (2), Month 2 = Mão (3), Month 3 = Thìn (4), Month 4 = Tỵ (5)
    /// Month 5 = Ngọ (6), Month 6 = Mùi (7), Month 7 = Thân (8), Month 8 = Dậu (9)
    /// Month 9 = Tuất (10), Month 10 = Hợi (11), Month 11 = Tý (0), Month 12 = Sửu (1)
    ///
    /// Sources: vansu.net, phongthuytuongminh.com, xemngay.com
    /// - Parameter lunarMonth: Lunar month (1-12)
    /// - Returns: The Chi enum corresponding to the month
    private static func getMonthChi(_ lunarMonth: Int) -> ChiEnum {
        let chiIndex: Int
        if lunarMonth <= 10 {
            chiIndex = lunarMonth + 1  // Months 1-10 map to Chi 2-11
        } else if lunarMonth == 11 {
            chiIndex = 0  // Month 11 = Tý (0)
        } else {  // lunarMonth == 12
            chiIndex = 1  // Month 12 = Sửu (1)
        }

        return ChiEnum(rawValue: chiIndex) ?? .dan
    }

    /// Get the month offset for 12 Trực calculation
    /// Pattern: Each month has a specific offset that determines the zodiac hour cycle
    /// The pattern increases by 5 (mod 12) for each month, forming a cyclic system
    /// - Parameter lunarMonth: Lunar month (1-12)
    /// - Returns: The offset value (0-11)
    private static func getMonthOffsetForTruc(_ lunarMonth: Int) -> Int {
        // Offset pattern based on lunar month
        // NOTE: This is an approximation. The traditional method uses day Chi, not day number.
        // Month: 1   2   3   4   5   6   7   8   9  10  11  12
        // Offset:9   2   7   0   5  10   3   8   1   6  11   4
        let offsets: [Int] = [
            9,   // Month 1
            2,   // Month 2
            7,   // Month 3
            0,   // Month 4
            5,   // Month 5
            10,  // Month 6
            3,   // Month 7
            8,   // Month 8
            1,   // Month 9
            6,   // Month 10
            11,  // Month 11
            4    // Month 12
        ]

        let validMonth = max(1, min(lunarMonth, 12))
        return offsets[validMonth - 1]
    }

    // MARK: - Day Quality Determination

    /// Determine the overall quality and astrological data for a specific date
    /// Combines multiple Vietnamese astrology systems (12 Trực + Lục Hắc Đạo)
    /// - Parameters:
    ///   - solarDate: The solar date for solar term calculation
    ///   - lunarDay: Day of the lunar month
    ///   - lunarMonth: Lunar month
    ///   - lunarYear: Lunar year
    ///   - dayCanChi: The Can-Chi string for the day (e.g., "Đinh Dậu")
    /// - Returns: Complete DayQuality with zodiac hour, unlucky day type, activities, and lucky attributes
    static func determineDayQuality(
        solarDate: Date,
        lunarDay: Int,
        lunarMonth: Int,
        lunarYear: Int,
        dayCanChi: String
    ) -> DayQuality {
        // Use the solar term-based calculation (the correct method)
        let zodiacHour = calculateZodiacHourChiBased(solarDate: solarDate, lunarMonth: lunarMonth)

        // Extract Chi from dayCanChi string to check for unlucky days
        // dayCanChi format: "Can Chi" (e.g., "Đinh Dậu")
        let dayChiString = dayCanChi.split(separator: " ").last.map(String.init) ?? ""
        let dayChi = parseChiFromString(dayChiString)

        // Check if this is an unlucky day (Lục Hắc Đạo)
        let unluckyDayType = LucHacDaoCalculator.calculateUnluckyDay(
            lunarMonth: lunarMonth,
            dayChi: dayChi
        )

        // Adjust activities based on unlucky day status
        var suitableActivities = ZodiacHourData.getSuitableActivities(for: zodiacHour)
        var tabooActivities = ZodiacHourData.getTabooActivities(for: zodiacHour)

        if unluckyDayType != nil {
            // Unlucky days have limited suitable activities
            suitableActivities = ["Nghỉ ngơi", "Cầu an", "Tụng kinh"]
            tabooActivities = ["Mọi hoạt động quan trọng"]
        }

        // Get lucky direction and color
        let luckyDirection = ZodiacHourData.getLuckyDirection(for: zodiacHour, dayCanChi: dayCanChi)
        let luckyColor = ZodiacHourData.getLuckyColor(for: zodiacHour)

        // MARK: - Star System Detection (NEW - Phase 2 Enhancement)
        // Detect good and bad stars from traditional star system
        // This is the key to reaching 100% accuracy with xemngay.com
        let starData = StarCalculator.detectStars(lunarMonth: lunarMonth, dayCanChi: dayCanChi)

        return DayQuality(
            zodiacHour: zodiacHour,
            dayCanChi: dayCanChi,
            unluckyDayType: unluckyDayType,
            suitableActivities: suitableActivities,
            tabooActivities: tabooActivities,
            luckyDirection: luckyDirection,
            luckyColor: luckyColor,
            goodStars: starData?.goodStars,
            badStars: starData?.badStars
        )
    }

    /// Simplified version that takes a Date object
    static func determineDayQuality(for date: Date) -> DayQuality {
        let lunarDate = LunarCalendar.solarToLunar(date)
        let dayCanChi = CanChiCalculator.calculateDayCanChi(for: date)
        let dayCanChiString = CanChiCalculator.canChiToString(dayCanChi)

        return determineDayQuality(
            solarDate: date,
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

    /// Map ZodiacHourType to DayType using the four-tier quality system
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
        case .severelyInauspicious:
            return .bad  // Very bad days map to .bad
        }
    }

    /// Determine DayType for a specific date
    /// Uses full calculation including 12 Trực, Lục Hắc Đạo, and star system
    static func determineDayType(for date: Date) -> DayType {
        // Use the complete day quality calculation which includes:
        // 1. Base score from 12 Trực (zodiac hour)
        // 2. Lục Hắc Đạo penalties
        // 3. Good and bad stars from MonthXStarData
        let dayQuality = determineDayQuality(for: date)
        return dayQuality.finalQuality
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

    // MARK: - Helper Functions

    /// Parse Chi name (Vietnamese text) to ChiEnum
    /// - Parameter chiString: The Chi name (e.g., "Dậu")
    /// - Returns: The corresponding ChiEnum
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
        default: return .ty  // Fallback
        }
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
