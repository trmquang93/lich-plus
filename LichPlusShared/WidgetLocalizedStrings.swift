//
//  WidgetLocalizedStrings.swift
//  LichPlusShared
//

import Foundation

enum WidgetLocalizedStrings {
    static func todayTitle(localeCode: String) -> String {
        localeCode == "vi" ? "Hôm nay" : "Today"
    }

    static func nextHolidayTitle(localeCode: String) -> String {
        localeCode == "vi" ? "Ngày lễ tới" : "Next holiday"
    }

    static func openAppPrompt(localeCode: String) -> String {
        localeCode == "vi" ? "Mở Lich+" : "Open Lich+"
    }

    static func openAppRefreshPrompt(localeCode: String) -> String {
        localeCode == "vi" ? "Mở Lich+ để cập nhật" : "Open Lich+ to refresh"
    }

    static func lunarLine(day: Int, month: Int, year: Int, localeCode: String) -> String {
        if localeCode == "vi" {
            return "Âm \(day)/\(month)/\(year)"
        }
        return "Lunar \(day)/\(month)/\(year)"
    }

    static func daysLabel(_ daysUntil: Int, localeCode: String) -> String {
        if daysUntil == 0 {
            return localeCode == "vi" ? "Hôm nay" : "Today"
        }
        if daysUntil == 1 {
            return localeCode == "vi" ? "Ngày mai" : "Tomorrow"
        }
        if localeCode == "vi" {
            return "\(daysUntil) ngày nữa"
        }
        return "\(daysUntil) days"
    }

    static func luckyHoursTitle(localeCode: String) -> String {
        localeCode == "vi" ? "Giờ tốt" : "Lucky hours"
    }

    static func avoidHoursTitle(localeCode: String) -> String {
        localeCode == "vi" ? "Nên tránh" : "Avoid"
    }

    static func directionTitle(localeCode: String) -> String {
        localeCode == "vi" ? "Hướng tốt" : "Direction"
    }

    static func liveActivityCountdownTitle(localeCode: String) -> String {
        localeCode == "vi" ? "Đếm ngược lễ" : "Festival countdown"
    }

    static func liveActivityTetCountdownTitle(localeCode: String) -> String {
        localeCode == "vi" ? "Đếm ngược Tết" : "Tết countdown"
    }
}
