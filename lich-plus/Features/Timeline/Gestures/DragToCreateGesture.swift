import SwiftUI

/// A gesture modifier that enables drag-to-create event functionality on the timeline.
///
/// Allows users to long-press and drag on a timeline to create events with specific start and end times.
/// Features:
/// - Long press (0.5s) triggers drag mode with haptic feedback
/// - Vertical drag updates event preview block
/// - 15-minute grid snapping for start and end times
/// - Haptic feedback on 15-minute boundaries during drag
/// - Success notification on event creation
struct DragToCreateGesture: ViewModifier {
    let hourHeight: CGFloat
    let referenceDate: Date
    let onCreateEvent: (Date, Date) -> Void

    @State private var isDragging = false
    @State private var dragStartY: CGFloat = 0
    @State private var dragCurrentY: CGFloat = 0
    @State private var feedbackGenerator = UISelectionFeedbackGenerator()
    @State private var lastSnappedMinute: Int = -1

    func body(content: Content) -> some View {
        content
            .overlay(dragPreviewOverlay)
            .gesture(createGesture)
    }

    // MARK: - Drag Preview Overlay

    @ViewBuilder
    private var dragPreviewOverlay: some View {
        if isDragging {
            DragPreviewBlock(
                startY: min(dragStartY, dragCurrentY),
                height: abs(dragCurrentY - dragStartY),
                startTime: dragStartTime,
                endTime: dragEndTime
            )
        }
    }

    // MARK: - Gesture Implementation

    private var createGesture: some Gesture {
        LongPressGesture(minimumDuration: 0.5)
            .sequenced(before: DragGesture(minimumDistance: 0))
            .onChanged { value in
                handleGestureChange(value)
            }
            .onEnded { value in
                handleGestureEnd(value)
            }
    }

    private func handleGestureChange(
        _ value: SequenceGesture<LongPressGesture, DragGesture>.Value
    ) {
        switch value {
        case .first(true):
            // Long press recognized - prepare for drag
            startDrag()
        case .second(true, let drag):
            // Dragging - update preview
            if let drag = drag {
                updateDrag(drag)
            }
        default:
            break
        }
    }

    private func handleGestureEnd(
        _ value: SequenceGesture<LongPressGesture, DragGesture>.Value
    ) {
        switch value {
        case .second(true, let drag):
            // Successfully completed drag gesture
            if isDragging && drag != nil {
                endDrag()
            }
        default:
            // Long press without drag - cancel
            if isDragging {
                cancelDrag()
            }
        }
    }

    // MARK: - Drag Lifecycle

    private func startDrag() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        isDragging = true
        feedbackGenerator.prepare()
        lastSnappedMinute = -1
    }

    private func updateDrag(_ drag: DragGesture.Value) {
        // Store the initial Y position for the start of the event
        if dragStartY == 0 {
            dragStartY = drag.location.y
        }

        dragCurrentY = drag.location.y

        // Trigger haptic feedback on 15-minute boundary crossings
        let minutes = minutesFromY(dragCurrentY)
        let snappedMinutes = (minutes / 15) * 15

        if lastSnappedMinute >= 0 && snappedMinutes != lastSnappedMinute {
            feedbackGenerator.selectionChanged()
        }
        lastSnappedMinute = snappedMinutes
    }

    private func endDrag() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)

        // Calculate final times with snapping
        let snapHelper = DragToCreateSnapHelper(calendar: Calendar.current)
        let start = snapHelper.snapToNearestFifteenMinutes(dragStartTime)
        let end = snapHelper.snapToNearestFifteenMinutes(dragEndTime)

        // Enforce minimum duration: 15 minutes
        let finalEnd = enforceMinimumDuration(startTime: start, endTime: end, minimumMinutes: 15)

        onCreateEvent(start, finalEnd)
        isDragging = false
    }

    private func cancelDrag() {
        isDragging = false
    }

    // MARK: - Time Calculation

    private var dragStartTime: Date {
        let converter = TimeToPixelConverter(hourHeight: hourHeight)
        return converter.date(from: min(dragStartY, dragCurrentY), referenceDate: referenceDate)
    }

    private var dragEndTime: Date {
        let converter = TimeToPixelConverter(hourHeight: hourHeight)
        return converter.date(from: max(dragStartY, dragCurrentY), referenceDate: referenceDate)
    }

    private func minutesFromY(_ yPosition: CGFloat) -> Int {
        let converter = TimeToPixelConverter(hourHeight: hourHeight)
        let date = converter.date(from: yPosition, referenceDate: referenceDate)
        let calendar = Calendar.current
        let components = calendar.dateComponents([.minute], from: date)
        return components.minute ?? 0
    }

    // MARK: - Duration Enforcement

    private func enforceMinimumDuration(
        startTime: Date,
        endTime: Date,
        minimumMinutes: Int
    ) -> Date {
        let duration = endTime.timeIntervalSince(startTime)
        let minimumDuration = TimeInterval(minimumMinutes * 60)

        if duration < minimumDuration {
            return startTime.addingTimeInterval(minimumDuration)
        }
        return endTime
    }
}

// MARK: - Drag Preview Block

/// Visual preview of the event being created during drag gesture.
struct DragPreviewBlock: View {
    let startY: CGFloat
    let height: CGFloat
    let startTime: Date
    let endTime: Date

    private let minimumHeight: CGFloat = 30

    var body: some View {
        VStack(spacing: 0) {
            // Start time label
            Text(timeFormatter.string(from: startTime))
                .font(.caption)
                .foregroundColor(AppColors.primary)
                .padding(.top, 8)

            Spacer()

            // End time label
            Text(timeFormatter.string(from: endTime))
                .font(.caption)
                .foregroundColor(AppColors.primary)
                .padding(.bottom, 8)
        }
        .frame(height: max(height, minimumHeight))
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                .stroke(AppColors.primary, style: StrokeStyle(lineWidth: 2, dash: [4, 4]))
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                        .fill(AppColors.primary.opacity(0.1))
                )
        )
        .frame(maxWidth: .infinity)
        .position(x: UIScreen.main.bounds.midX, y: startY + max(height, minimumHeight) / 2)
    }

    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
}

// MARK: - Helper Classes for Time Snapping

/// Helper for snapping times to 15-minute grid intervals.
class DragToCreateSnapHelper {
    private let calendar: Calendar

    init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    func snapToNearestFifteenMinutes(_ date: Date) -> Date {
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let minute = components.minute ?? 0

        // Round to nearest 15-minute boundary
        let snappedMinute = (minute + 7) / 15 * 15

        return calendar.date(
            bySettingHour: components.hour ?? 0,
            minute: snappedMinute % 60,
            second: 0,
            of: date
        ) ?? date
    }
}

// MARK: - View Extension

extension View {
    /// Applies drag-to-create event functionality to a timeline view.
    ///
    /// Enables users to long-press and drag on a timeline to create events with specific
    /// start and end times. The gesture provides:
    /// - Visual preview block during drag
    /// - Haptic feedback on 15-minute boundaries
    /// - Automatic snapping to 15-minute grid intervals
    /// - Minimum 15-minute event duration
    ///
    /// - Parameters:
    ///   - hourHeight: Height in points of one hour on the timeline
    ///   - referenceDate: The date for which events are being created
    ///   - onCreate: Callback with start and end times when event creation is confirmed
    /// - Returns: A view with drag-to-create gesture support
    func dragToCreateEvent(
        hourHeight: CGFloat,
        referenceDate: Date,
        onCreate: @escaping (Date, Date) -> Void
    ) -> some View {
        modifier(DragToCreateGesture(
            hourHeight: hourHeight,
            referenceDate: referenceDate,
            onCreateEvent: onCreate
        ))
    }
}

// MARK: - Preview

#Preview("Drag to Create Event Gesture") {
    VStack(spacing: 0) {
        // Simple timeline grid
        VStack(spacing: 0) {
            ForEach(0..<12, id: \.self) { hour in
                HStack(spacing: 0) {
                    Text(String(format: "%02d:00", hour + 8))
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                        .frame(width: 40)

                    Rectangle()
                        .stroke(AppColors.timelineGridLine, lineWidth: 0.5)
                }
                .frame(height: 60)
            }
        }
        .background(AppColors.background)

        Spacer()
    }
    .frame(maxHeight: 12 * 60)
    .safeAreaInset(edge: .top) {
        VStack(alignment: .leading) {
            Text("Long-press and drag to create event")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(12)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.1))
    }
}
