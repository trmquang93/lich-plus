//
//  TodayWidget.swift
//  LichPlusWidgets
//

import SwiftUI
import WidgetKit

struct TodayWidget: Widget {
    let kind = TodayWidgetConstants.kind

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TodayWidgetProvider()) { entry in
            TodayWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Today")
        .description("Solar and lunar date with the next public holiday.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryRectangular,
            .accessoryCircular,
        ])
    }
}
