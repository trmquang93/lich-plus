//
//  LichPlusWidgetsBundle.swift
//  LichPlusWidgets
//

import SwiftUI
import WidgetKit

@main
struct LichPlusWidgetsBundle: WidgetBundle {
    var body: some Widget {
        TodayWidget()
        CountdownWidget()
        FestivalLiveActivityWidget()
    }
}
