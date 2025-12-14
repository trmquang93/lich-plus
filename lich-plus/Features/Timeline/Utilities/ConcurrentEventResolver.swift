import Foundation

/// Represents an event positioned on the timeline with resolved overlapping information.
struct PositionedEvent {
    /// The original task/event
    let event: TaskItem

    /// Y position of the event block start (in points from top of timeline)
    let yStart: CGFloat

    /// Height of the event block (in points)
    let height: CGFloat

    /// Fraction of available width (e.g., 0.5 for half-width when overlapping)
    let widthFraction: CGFloat

    /// Horizontal offset for side-by-side layout (e.g., 0.0 or 0.5)
    let xOffset: CGFloat

    /// Column index in the overlap group (0 = leftmost)
    let column: Int

    /// Total number of columns in the overlap group
    let totalColumns: Int
}

/// Resolves overlapping events by calculating their positions and dimensions on the timeline.
///
/// When events overlap in time, they are displayed side-by-side. This class handles:
/// - Detecting which events overlap
/// - Assigning column positions (0, 1, 2, ...)
/// - Calculating width fractions so events fit together
/// - Capping maximum concurrent display at 3 columns
/// - Skipping all-day events (handled separately)
///
/// Example output for 3 overlapping events:
/// ```
/// Event A: column=0, totalColumns=3, widthFraction=0.333, xOffset=0.0
/// Event B: column=1, totalColumns=3, widthFraction=0.333, xOffset=0.333
/// Event C: column=2, totalColumns=3, widthFraction=0.333, xOffset=0.666
/// ```
struct ConcurrentEventResolver {

    /// Time-to-pixel converter for calculating Y positions and heights
    let converter: TimeToPixelConverter

    /// Maximum number of concurrent events to display side-by-side
    /// (beyond this, a "+N more" indicator would be shown)
    private static let maxConcurrentColumns = 3

    /// Resolve positions for a list of events, handling overlaps.
    ///
    /// Algorithm:
    /// 1. Filter out all-day events (no startTime)
    /// 2. Sort remaining events by start time
    /// 3. Find groups of overlapping events
    /// 4. Within each group, assign column positions
    /// 5. Calculate dimensions based on column assignment
    ///
    /// - Parameter events: Raw list of events, may include all-day events
    /// - Returns: List of positioned events with overlap information
    func resolvePositions(events: [TaskItem]) -> [PositionedEvent] {
        // Filter out all-day events (those without startTime)
        let timedEvents = events.filter { !$0.isAllDay }

        // Sort by start time
        let sortedEvents = timedEvents.sorted { a, b in
            let aStart = a.startTime ?? a.date
            let bStart = b.startTime ?? b.date
            return aStart < bStart
        }

        // Find overlap groups
        let overlapGroups = findOverlapGroups(sortedEvents)

        // Convert each group to positioned events
        var positioned: [PositionedEvent] = []

        for group in overlapGroups {
            let groupPositioned = assignColumnsInGroup(group)
            positioned.append(contentsOf: groupPositioned)
        }

        return positioned
    }

    // MARK: - Private Methods

    /// Find groups of overlapping events.
    ///
    /// Events in the same group overlap with at least one other event in the group.
    /// Uses a greedy approach: start a new group when an event doesn't overlap with any
    /// event already added to the current group.
    ///
    /// - Parameter sortedEvents: Events sorted by start time
    /// - Returns: Array of event groups, each containing overlapping events
    private func findOverlapGroups(_ sortedEvents: [TaskItem]) -> [[TaskItem]] {
        var groups: [[TaskItem]] = []
        var currentGroup: [TaskItem] = []

        for event in sortedEvents {
            // Check if this event overlaps with any event in the current group
            let overlapsWithGroup = currentGroup.contains { groupEvent in
                eventsOverlap(event, groupEvent)
            }

            if overlapsWithGroup {
                // Add to current group
                currentGroup.append(event)
            } else {
                // Start a new group if current group is not empty
                if !currentGroup.isEmpty {
                    groups.append(currentGroup)
                }
                currentGroup = [event]
            }
        }

        // Don't forget the last group
        if !currentGroup.isEmpty {
            groups.append(currentGroup)
        }

        return groups
    }

    /// Assign column positions within an overlap group.
    ///
    /// Sorts events by start time and assigns sequential columns (0, 1, 2, ...).
    /// Caps at maxConcurrentColumns to prevent excessive crowding.
    ///
    /// - Parameter group: Events that overlap with each other
    /// - Returns: Array of positioned events within this group
    private func assignColumnsInGroup(_ group: [TaskItem]) -> [PositionedEvent] {
        // Re-sort by start time (should already be sorted, but ensure it)
        let sorted = group.sorted { a, b in
            let aStart = a.startTime ?? a.date
            let bStart = b.startTime ?? b.date
            return aStart < bStart
        }

        // Determine total columns (capped at max)
        let totalColumns = min(sorted.count, Self.maxConcurrentColumns)

        // Create positioned events
        return sorted.enumerated().map { index, event in
            let column = index < totalColumns ? index : index % totalColumns
            let widthFraction = 1.0 / CGFloat(totalColumns)
            let xOffset = CGFloat(column) * widthFraction

            let yStart = converter.yPosition(for: event.startTime ?? event.date)
            let height = {
                guard let endTime = event.endTime else {
                    // No end time: assume 1-hour duration
                    return converter.blockHeight(
                        start: event.startTime ?? event.date,
                        end: {
                            let calendar = Calendar.current
                            return calendar.date(byAdding: .hour, value: 1, to: event.startTime ?? event.date) ?? event.date
                        }()
                    )
                }
                return converter.blockHeight(start: event.startTime ?? event.date, end: endTime)
            }()

            return PositionedEvent(
                event: event,
                yStart: yStart,
                height: height,
                widthFraction: widthFraction,
                xOffset: xOffset,
                column: column,
                totalColumns: totalColumns
            )
        }
    }

    /// Check if two events overlap in time.
    ///
    /// Two events overlap if one starts before the other ends.
    /// Handles edge case where end time is nil (assumes 1-hour duration).
    ///
    /// - Parameters:
    ///   - a: First event
    ///   - b: Second event
    /// - Returns: True if events overlap
    private func eventsOverlap(_ a: TaskItem, _ b: TaskItem) -> Bool {
        let aStart = a.startTime ?? a.date
        let bStart = b.startTime ?? b.date

        let aEnd = a.endTime ?? {
            let calendar = Calendar.current
            return calendar.date(byAdding: .hour, value: 1, to: aStart) ?? aStart
        }()

        let bEnd = b.endTime ?? {
            let calendar = Calendar.current
            return calendar.date(byAdding: .hour, value: 1, to: bStart) ?? bStart
        }()

        // Events overlap if: a.start < b.end AND b.start < a.end
        return aStart < bEnd && bStart < aEnd
    }
}
