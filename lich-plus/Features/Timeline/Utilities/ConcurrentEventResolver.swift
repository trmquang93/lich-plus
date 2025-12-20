import Foundation

/// Helper struct to track column state during event assignment
private struct ColumnAssignment {
    var events: [TaskItem]
    var latestEndTime: Date  // Track when this column becomes free
}

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
/// - Detecting which events overlap using a greedy algorithm
/// - Assigning column positions intelligently (reusing columns when events don't overlap)
/// - Calculating width fractions so events fit together
/// - Capping maximum concurrent display at 3 columns
/// - Skipping all-day events (handled separately)
///
/// Algorithm: Greedy column assignment with earliest end time
/// Events are processed in sorted order (by start time, then by duration)
/// and assigned to the first available column where no overlap occurs.
/// This results in optimal column usage with no visual overlaps.
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
    /// (beyond this, events are wrapped using modulo, but no visual overlap occurs)
    private static let maxConcurrentColumns = 3

    /// Resolve positions for a list of events, handling overlaps using a greedy algorithm.
    ///
    /// Algorithm:
    /// 1. Filter out all-day events (no startTime)
    /// 2. Sort remaining events by start time, then by end time (shorter events first)
    /// 3. For each event, find the first column where it doesn't overlap with previous events
    /// 4. Find overlap clusters using Union-Find to determine which events share width calculations
    /// 5. Assign width based on max columns within each cluster (capped at 3)
    ///
    /// This algorithm reuses columns when events don't overlap, resulting in optimal
    /// column usage and ensuring no visual overlaps occur.
    ///
    /// - Parameter events: Raw list of events, may include all-day events
    /// - Returns: List of positioned events with overlap information
    func resolvePositions(events: [TaskItem]) -> [PositionedEvent] {
        // Filter out all-day events (those without startTime)
        let timedEvents = events.filter { !$0.isAllDay }

        // Sort by start time, then by end time (shorter events first)
        let sortedEvents = timedEvents.sorted { a, b in
            let aStart = a.startTime ?? a.date
            let bStart = b.startTime ?? b.date
            if aStart != bStart {
                return aStart < bStart
            }
            // Secondary sort by end time (shorter events first)
            let aEnd = a.endTime ?? {
                let calendar = Calendar.current
                return calendar.date(byAdding: .hour, value: 1, to: aStart) ?? aStart
            }()
            let bEnd = b.endTime ?? {
                let calendar = Calendar.current
                return calendar.date(byAdding: .hour, value: 1, to: bStart) ?? bStart
            }()
            return aEnd < bEnd
        }

        // Greedy column assignment: assign each event to the first available column
        var columns: [ColumnAssignment] = []
        var eventColumnMap: [UUID: Int] = [:]  // Map event ID to assigned column
        
        for event in sortedEvents {
            let eventStart = event.startTime ?? event.date
            let eventEnd = event.endTime ?? {
                let calendar = Calendar.current
                return calendar.date(byAdding: .hour, value: 1, to: eventStart) ?? eventStart
            }()
            
            // Find first column where the last event ends before this event starts
            var assignedColumn: Int? = nil
            for (index, column) in columns.enumerated() {
                if column.latestEndTime <= eventStart {
                    // This column is available - no overlap with previous events
                    assignedColumn = index
                    break
                }
            }
            
            if let column = assignedColumn {
                // Reuse existing column
                columns[column].events.append(event)
                columns[column].latestEndTime = max(columns[column].latestEndTime, eventEnd)
                eventColumnMap[event.id] = column
            } else {
                // Create new column
                let newColumn = ColumnAssignment(events: [event], latestEndTime: eventEnd)
                columns.append(newColumn)
                eventColumnMap[event.id] = columns.count - 1
            }
        }
        
        // Find overlap clusters using Union-Find
        // Events in the same cluster affect each other's width calculation
        let clusters = findOverlapClusters(sortedEvents)
        
        // Build PositionedEvent results
        var results: [PositionedEvent] = []
        for event in sortedEvents {
            let column = eventColumnMap[event.id] ?? 0
            let cluster = clusters.first { $0.contains(event.id) } ?? Set()
            
            // Calculate max column index in this cluster
            let maxColumnInCluster = cluster
                .compactMap { eventColumnMap[$0] }
                .max() ?? 0
            let maxColumnsInCluster = maxColumnInCluster + 1
            let totalColumns = min(maxColumnsInCluster, Self.maxConcurrentColumns)
            
            let widthFraction = 1.0 / CGFloat(totalColumns)
            let xOffset = CGFloat(column % totalColumns) * widthFraction
            
            let yStart = converter.yPosition(for: event.startTime ?? event.date)
            let height = calculateEventHeight(for: event)
            
            results.append(PositionedEvent(
                event: event,
                yStart: yStart,
                height: height,
                widthFraction: widthFraction,
                xOffset: xOffset,
                column: column % totalColumns,
                totalColumns: totalColumns
            ))
        }
        
        return results
    }

    // MARK: - Private Methods

    /// Find overlap clusters using Union-Find algorithm.
    /// Events in the same cluster overlap with each other (directly or transitively).
    /// This determines which events affect each other's width calculation.
    ///
    /// - Parameter sortedEvents: Events sorted by start time
    /// - Returns: Array of clusters, each containing event IDs that overlap
    private func findOverlapClusters(_ sortedEvents: [TaskItem]) -> [Set<UUID>] {
        // Union-Find parent mapping
        var parent: [UUID: UUID] = [:]
        
        func find(_ id: UUID) -> UUID {
            if parent[id] == nil { parent[id] = id }
            if parent[id] != id {
                parent[id] = find(parent[id]!)  // Path compression
            }
            return parent[id]!
        }
        
        func union(_ a: UUID, _ b: UUID) {
            let rootA = find(a)
            let rootB = find(b)
            if rootA != rootB {
                parent[rootA] = rootB
            }
        }
        
        // Union all overlapping pairs
        for i in 0..<sortedEvents.count {
            for j in (i+1)..<sortedEvents.count {
                if eventsOverlap(sortedEvents[i], sortedEvents[j]) {
                    union(sortedEvents[i].id, sortedEvents[j].id)
                }
                
                // Optimization: if j doesn't overlap i, later events won't either
                // (since sorted by start time)
                let jStart = sortedEvents[j].startTime ?? sortedEvents[j].date
                let iEnd = sortedEvents[i].endTime ?? {
                    let calendar = Calendar.current
                    return calendar.date(byAdding: .hour, value: 1, to: sortedEvents[i].startTime ?? sortedEvents[i].date) ?? sortedEvents[i].date
                }()
                if jStart >= iEnd {
                    break
                }
            }
        }
        
        // Group by root to form clusters
        var clusters: [UUID: Set<UUID>] = [:]
        for event in sortedEvents {
            let root = find(event.id)
            clusters[root, default: Set()].insert(event.id)
        }
        
        return Array(clusters.values)
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

    /// Calculate the height of an event block on the timeline
    /// If no end time is provided, assumes 1-hour duration
    private func calculateEventHeight(for event: TaskItem) -> CGFloat {
        guard let endTime = event.endTime else {
            // No end time: assume 1-hour duration
            let calendar = Calendar.current
            let defaultEnd = calendar.date(byAdding: .hour, value: 1, to: event.startTime ?? event.date) ?? event.date
            return converter.blockHeight(
                start: event.startTime ?? event.date,
                end: defaultEnd
            )
        }
        return converter.blockHeight(start: event.startTime ?? event.date, end: endTime)
    }
}
