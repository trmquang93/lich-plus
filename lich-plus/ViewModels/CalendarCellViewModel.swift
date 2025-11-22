import Foundation
import SwiftUI

// MARK: - Calendar Cell View Model
struct CalendarCellViewModel {

    // MARK: - Properties
    var date: Date?
    var lunarInfo: LunarDateInfo
    var auspiciousInfo: AuspiciousDayInfo
    var isCurrentMonth: Bool
    var isToday: Bool

    // MARK: - Initializer
    init(
        date: Date?,
        lunarInfo: LunarDateInfo,
        auspiciousInfo: AuspiciousDayInfo,
        isCurrentMonth: Bool,
        isToday: Bool
    ) {
        self.date = date
        self.lunarInfo = lunarInfo
        self.auspiciousInfo = auspiciousInfo
        self.isCurrentMonth = isCurrentMonth
        self.isToday = isToday
    }

    // MARK: - Solar Day Color
    var solarDayColor: Color {
        // Return gray for non-current month dates
        guard isCurrentMonth, let date = date else {
            return .gray.opacity(0.5)
        }

        // Get weekday component (1=Sunday, 2=Monday, ..., 7=Saturday)
        let weekday = Calendar.current.component(.weekday, from: date)

        switch weekday {
        case 1: // Sunday
            return Color(hex: "#F5A623") ?? .orange
        case 7: // Saturday
            return Color(hex: "#50E3C2") ?? .cyan
        default: // Weekdays (Monday-Friday)
            return .black
        }
    }

    // MARK: - Lunar Display Text
    var lunarDisplayText: String {
        return lunarInfo.calendarDisplayString
    }

    // MARK: - Auspicious Dot Visibility
    var shouldShowAuspiciousDot: Bool {
        return auspiciousInfo.type == .auspicious
    }

    var shouldShowInauspiciousDot: Bool {
        return auspiciousInfo.type == .inauspicious
    }

    // MARK: - Lunar Month Start Detection
    var isLunarMonthStart: Bool {
        return lunarInfo.day == 1
    }

    // MARK: - Lunar Text Color
    var lunarTextColor: Color {
        if isLunarMonthStart {
            return Color(hex: "#D0021B") ?? .red
        } else {
            return .gray
        }
    }

    // MARK: - Today Border Color
    var todayBorderColor: Color {
        if isToday {
            return Color(hex: "#5BC0A6") ?? .green
        } else {
            return .clear
        }
    }
}
