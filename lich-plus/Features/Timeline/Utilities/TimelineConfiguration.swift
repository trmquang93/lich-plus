import SwiftUI

/// Configuration for the timeline view's visual parameters and time scales.
///
/// Supports pinch-to-zoom with three predefined time scales (15-minute, 30-minute, and 1-hour intervals).
/// All other dimensions are constants that define the fixed layout structure.
struct TimelineConfiguration {

    /// Time scale levels for pinch-to-zoom interaction.
    /// Each scale defines the pixel height of one hour.
    enum TimeScale: CGFloat, CaseIterable {
        /// Highest zoom level: 1 hour = 120pt
        case fifteenMin = 120

        /// Default zoom level: 1 hour = 60pt
        case thirtyMin = 60

        /// Lowest zoom level: 1 hour = 40pt
        case oneHour = 40
    }

    /// Currently active time scale for the timeline
    var currentScale: TimeScale = .thirtyMin

    // MARK: - Computed Properties

    /// Height of one hour in points, based on the current scale
    var hourHeight: CGFloat { currentScale.rawValue }

    /// Total height of the entire timeline (24 hours)
    var totalHeight: CGFloat { hourHeight * 24 }

    // MARK: - Layout Constants

    /// Width of the time ruler (left side showing time labels)
    static let rulerWidth: CGFloat = 50

    /// Height of the all-day events section at the top
    static let allDayHeight: CGFloat = 60

    /// Height of the day header section at the very top
    static let headerHeight: CGFloat = 100

    /// Height of the "now" indicator line
    static let nowIndicatorHeight: CGFloat = 20
}
