//
//  XuatHanhSummary.swift
//  lich-plus
//
//  Compact giờ hoàng đạo / giờ nên tránh summaries for UI and widgets.
//

import Foundation

struct XuatHanhSummary: Equatable, Sendable {
    let luckyHours: [HourlyZodiac]
    let avoidHours: [HourlyZodiac]

    static func forDate(_ date: Date) -> XuatHanhSummary {
        let hourly = HoangDaoCalculator.getHourlyZodiacs(for: date)
        return XuatHanhSummary(
            luckyHours: hourly.filter(\.isAuspicious),
            avoidHours: hourly.filter { !$0.isAuspicious }
        )
    }

    var luckyCompactLabels: [String] {
        luckyHours.map { hourLabel($0) }
    }

    var avoidCompactLabels: [String] {
        avoidHours.map { hourLabel($0) }
    }

    var luckySummary: String {
        luckyCompactLabels.joined(separator: ", ")
    }

    var avoidSummary: String {
        avoidCompactLabels.joined(separator: ", ")
    }

    private func hourLabel(_ hour: HourlyZodiac) -> String {
        let range = hour.chi.hourRange
        if hour.chi == .ty {
            return "\(hour.chi.vietnameseName) (23-1)"
        }
        return "\(hour.chi.vietnameseName) (\(range.start)-\(range.end))"
    }
}
