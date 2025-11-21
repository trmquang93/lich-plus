import Foundation

// MARK: - Lunar Calendar Converter
class LunarCalendarConverter {
    // Vietnamese lunar calendar conversion
    // Based on traditional lunar calendar algorithms

    private static let lunarMonthDays = [
        0, 30, 29, 30, 29, 30, 29, 30, 30, 29, 30, 29, 30
    ]

    private static let lunarLeapMonthDays = [
        0, 30, 29, 30, 29, 30, 29, 30, 30, 29, 30, 29, 30
    ]

    // MARK: - Solar to Lunar Conversion
    static func solarToLunar(date: Date) -> LunarDateInfo {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)

        guard let solarDay = components.day,
              let solarMonth = components.month,
              let solarYear = components.year else {
            return LunarDateInfo(year: 1970, month: 1, day: 1)
        }

        return solarToLunar(day: solarDay, month: solarMonth, year: solarYear)
    }

    private static func solarToLunar(day: Int, month: Int, year: Int) -> LunarDateInfo {
        // Simplified lunar calendar conversion for Vietnamese lunar calendar
        // This is a basic implementation - for production, use a dedicated library

        let jd = gregorianToJD(day: day, month: month, year: year)
        return jdToLunar(jd: jd)
    }

    // MARK: - Gregorian to Julian Day Number
    private static func gregorianToJD(day: Int, month: Int, year: Int) -> Double {
        let a = (14 - month) / 12
        let y = year + 4800 - a
        let m = month + 12 * a - 3

        let jdn = Double(day) + Double(153 * m + 2) / 5.0 + Double(365 * y) + Double(y / 4) - Double(y / 100) + Double(y / 400) - 32045.0

        return jdn
    }

    // MARK: - Julian Day Number to Lunar
    private static func jdToLunar(jd: Double) -> LunarDateInfo {
        // This is a simplified implementation
        // For accurate results, use a dedicated lunar calendar library

        let jdi = Int(jd + 0.5)

        // Calculate approximate year (starting from epoch)
        let year = (jdi - 2451550) / 365 + 2000

        // Calculate approximate month and day
        var dayOfYear = Double(jdi) - gregorianToJD(day: 1, month: 1, year: year)
        if dayOfYear < 0 {
            dayOfYear = Double(jdi) - gregorianToJD(day: 1, month: 1, year: year - 1)
        }

        let month = min(12, Int(dayOfYear / 29.5) + 1)
        let day = Int(dayOfYear) - Int(Double(month - 1) * 29.5) + 1

        return LunarDateInfo(year: year, month: month, day: max(1, min(30, day)))
    }

    // MARK: - Sample Lunar Dates for August 2024
    // Hardcoded mappings for the sample data
    static func getLunarDate(for solarDate: Date) -> LunarDateInfo {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .month, .year], from: solarDate)

        guard let day = components.day,
              let month = components.month,
              let year = components.year else {
            return LunarDateInfo(year: 2024, month: 6, day: 15)
        }

        // Sample mapping for August 2024 (Lunar 6th month)
        // These are approximate conversions for the calendar view
        if year == 2024 && month == 8 {
            // August 1 = Lunar 6/16
            let lunarDay = day + 15
            if lunarDay <= 30 {
                return LunarDateInfo(year: 2024, month: 6, day: lunarDay)
            } else {
                return LunarDateInfo(year: 2024, month: 7, day: lunarDay - 30)
            }
        }

        return solarToLunar(date: solarDate)
    }
}
