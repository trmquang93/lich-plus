import Foundation

/// Converts between time values and Y-position pixels on the timeline.
///
/// The timeline assumes a 24-hour day mapped to a vertical scrollable view. This converter
/// calculates where events should be positioned based on their start/end times.
///
/// Example calculation with 60pt/hour (default):
/// - 00:00 (midnight) = Y position 0
/// - 12:00 (noon) = Y position 12 * 60 = 720pt
/// - 23:59 = Y position ~1440pt
struct TimeToPixelConverter {

    /// Height in points for one hour, based on the current timeline scale
    let hourHeight: CGFloat

    /// Calendar used for date component calculations
    let calendar: Calendar

    init(hourHeight: CGFloat, calendar: Calendar = .current) {
        self.hourHeight = hourHeight
        self.calendar = calendar
    }

    // MARK: - Y Position Calculations

    /// Convert a Date to its Y position on the timeline.
    ///
    /// Extracts the hour and minute components from the date and calculates:
    /// `Y = (hours + minutes/60) * hourHeight`
    ///
    /// - Parameter date: The date to convert
    /// - Returns: Y position in points (0 = midnight)
    func yPosition(for date: Date) -> CGFloat {
        let components = calendar.dateComponents([.hour, .minute], from: date)
        let hours = CGFloat(components.hour ?? 0)
        let minutes = CGFloat(components.minute ?? 0)

        let totalHours = hours + (minutes / 60)
        return totalHours * hourHeight
    }

    /// Convert a Y position back to a time of day on a reference date.
    ///
    /// Calculates the duration from midnight based on Y position, then applies
    /// those hours/minutes to the reference date while preserving the date component.
    ///
    /// Example: With hourHeight=60, yPosition=180 gives 3 hours, which becomes 03:00 on the reference date.
    ///
    /// - Parameters:
    ///   - yPosition: Y coordinate in points (0 = midnight)
    ///   - referenceDate: The date whose date component is used as the base
    /// - Returns: A date with the calculated time on the reference date
    func date(from yPosition: CGFloat, referenceDate: Date) -> Date {
        // Calculate total hours and minutes from Y position
        let totalHours = yPosition / hourHeight
        let hours = Int(totalHours)
        let minutes = Int((totalHours - CGFloat(hours)) * 60)

        // Create a date components from reference date's date components
        var components = calendar.dateComponents([.year, .month, .day], from: referenceDate)
        components.hour = hours
        components.minute = minutes
        components.second = 0

        return calendar.date(from: components) ?? referenceDate
    }

    // MARK: - Block Height Calculations

    /// Calculate the visual height of an event block based on its duration.
    ///
    /// Computes the duration between start and end times, converting to hours and
    /// multiplying by hourHeight. Enforces a minimum height of 20pt to ensure
    /// very short events remain visible.
    ///
    /// - Parameters:
    ///   - start: The event start time
    ///   - end: The event end time
    /// - Returns: Height in points, minimum 20pt
    func blockHeight(start: Date, end: Date) -> CGFloat {
        let duration = end.timeIntervalSince(start)
        let hours = duration / 3600  // seconds to hours
        let height = CGFloat(hours) * hourHeight

        // Enforce minimum height for visibility
        return max(height, 20)
    }

    // MARK: - Current Time Indicator

    /// Get the Y position for the current time.
    ///
    /// Useful for drawing a "now" indicator on the timeline.
    ///
    /// - Returns: Y position of the current time
    func currentTimeY() -> CGFloat {
        return yPosition(for: Date())
    }

    // MARK: - Grid Snapping

    /// Snap a Y position to the nearest grid interval based on the time scale.
    ///
    /// Used for drag-to-create interactions to align events to standard time intervals.
    /// Different scales snap to different intervals:
    /// - `.fifteenMin`: Snap to nearest 15-minute interval
    /// - `.thirtyMin`: Snap to nearest 30-minute interval
    /// - `.oneHour`: Snap to nearest hour
    ///
    /// - Parameters:
    ///   - yPosition: The Y position to snap
    ///   - scale: The time scale defining the snap interval
    /// - Returns: Snapped Y position
    func snapToGrid(_ yPosition: CGFloat, scale: TimelineConfiguration.TimeScale) -> CGFloat {
        // Determine the snap interval based on scale
        let snapInterval: CGFloat
        switch scale {
        case .fifteenMin:
            // 15 minutes = 15/60 * hourHeight
            snapInterval = (15.0 / 60.0) * scale.rawValue
        case .thirtyMin:
            // 30 minutes = 30/60 * hourHeight
            snapInterval = (30.0 / 60.0) * scale.rawValue
        case .oneHour:
            // 1 hour = hourHeight
            snapInterval = scale.rawValue
        }

        // Round to nearest snap interval
        let snappedValue = (yPosition / snapInterval).rounded() * snapInterval
        return snappedValue
    }
}
