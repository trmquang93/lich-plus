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
}
