//
//  AnalyticsScreenTracker.swift
//  lich-plus
//
//  SwiftUI helper for logging product-surface screen views.
//

import SwiftUI

private struct AnalyticsScreenTracker: ViewModifier {
    let screen: AnalyticsScreen

    func body(content: Content) -> some View {
        content.onAppear {
            AnalyticsService.shared.logScreen(screen)
        }
    }
}

extension View {
    /// Logs a privacy-safe `screen_view` when the view appears.
    func trackAnalyticsScreen(_ screen: AnalyticsScreen) -> some View {
        modifier(AnalyticsScreenTracker(screen: screen))
    }
}
