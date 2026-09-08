//
//  TodayWidgetEntry.swift
//  LichPlusWidgets
//

import Foundation
import WidgetKit

struct TodayWidgetEntry: TimelineEntry {
    let date: Date
    let day: WidgetDayEntry?
    let localeCode: String
    let isPlaceholder: Bool
}
