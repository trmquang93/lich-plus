import SwiftUI

// MARK: - Swipe Action Types

/// Represents the type of swipe action detected on a timeline event.
enum SwipeAction: String, CaseIterable, Identifiable {
    case delete = "delete"
    case complete = "complete"
    case none = "none"

    var id: String { rawValue }
}

// MARK: - Event Interaction Handler

/// Handler for tap, swipe, and long-press interactions on timeline events.
///
/// Manages gesture detection, swipe translations, and offset calculations for
/// delete and complete actions. Provides haptic feedback and animations for
/// a polished user experience.
final class EventInteractionGestureHandler {

    // MARK: - Constants

    let swipeDeleteThreshold: CGFloat = 80
    let swipeCompleteThreshold: CGFloat = 80
    private let minHorizontalRatio = 0.5 // Require more horizontal than vertical motion

    // MARK: - Swipe Detection

    /// Determines the swipe action based on translation distance and item type.
    /// - Parameters:
    ///   - translation: The horizontal translation in points (negative = left, positive = right)
    ///   - itemType: The type of item (task or event)
    /// - Returns: The detected SwipeAction
    func detectSwipeAction(for translation: CGFloat, itemType: ItemType) -> SwipeAction {
        if translation <= -swipeDeleteThreshold {
            return .delete
        } else if translation >= swipeCompleteThreshold && itemType == .task {
            return .complete
        } else {
            return .none
        }
    }

    /// Calculates the offset for the event card during swipe gesture.
    /// - Parameter translation: The horizontal translation distance
    /// - Returns: The offset to apply to the view
    func calculateOffset(for translation: CGFloat) -> CGFloat {
        translation
    }

    /// Returns the reset offset (0) for cancelling a swipe.
    /// - Returns: Zero offset for animation
    func resetOffset() -> CGFloat {
        0
    }

    /// Returns the off-screen offset for animating an event out of view after deletion.
    /// - Returns: The negative offset to move event off-screen to the left
    func offScreenOffset() -> CGFloat {
        -300
    }

    // MARK: - Motion Detection

    /// Determines if a drag motion is primarily horizontal.
    /// - Parameter translation: The CGSize of the drag translation
    /// - Returns: True if motion is more horizontal than vertical
    func isHorizontalSwipe(_ translation: CGSize) -> Bool {
        let horizontalDistance = abs(translation.width)
        let verticalDistance = abs(translation.height)
        // Require more horizontal than vertical motion (with some tolerance for rounding)
        return horizontalDistance > verticalDistance
    }
}

// MARK: - Event Interaction ViewModifier

/// ViewModifier that applies tap, swipe, and context menu gestures to event cards.
///
/// Handles the following interactions:
/// - **Tap**: Opens event detail view
/// - **Swipe left**: Deletes the event (animates off-screen)
/// - **Swipe right**: Marks task complete (tasks only)
/// - **Long press**: Shows context menu with edit/delete options
/// - **Context menu**: Provides quick actions (edit, complete, delete)
struct EventInteractionModifier: ViewModifier {

    let event: TaskItem
    let onTap: () -> Void
    let onDelete: () -> Void
    let onComplete: () -> Void
    let onEdit: () -> Void

    @State private var offset: CGFloat = 0
    @State private var isBeingDeleted = false

    private let handler = EventInteractionGestureHandler()

    func body(content: Content) -> some View {
        ZStack(alignment: .trailing) {
            // Swipe action indicators in the background
            if offset < -20 {
                SwipeActionIndicator(isDelete: true, progress: min(1.0, abs(offset) / 80))
            } else if offset > 20 && event.itemType == .task {
                SwipeActionIndicator(isDelete: false, progress: min(1.0, offset / 80))
            }

            content
                .offset(x: offset)
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: offset)
                .opacity(isBeingDeleted ? 0 : 1)
                .animation(.easeOut(duration: 0.2), value: isBeingDeleted)
        }
        .gesture(swipeGesture)
        .simultaneousGesture(tapGesture)
        .contextMenu { contextMenuContent }
    }

    // MARK: - Gesture Implementation

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 10)
            .onChanged { value in
                if handler.isHorizontalSwipe(value.translation) {
                    offset = value.translation.width
                }
            }
            .onEnded { value in
                handleSwipeEnd(value.translation.width)
            }
    }

    private var tapGesture: some Gesture {
        TapGesture()
            .onEnded {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                onTap()
            }
    }

    // MARK: - Event Handlers

    private func handleSwipeEnd(_ translation: CGFloat) {
        let action = handler.detectSwipeAction(for: translation, itemType: event.itemType)

        switch action {
        case .delete:
            handleDelete()
        case .complete:
            handleComplete()
        case .none:
            // Bounce back to center
            withAnimation {
                offset = 0
            }
        }
    }

    private func handleDelete() {
        // Provide haptic feedback
        UINotificationFeedbackGenerator().notificationOccurred(.warning)

        // Animate off-screen
        withAnimation {
            offset = handler.offScreenOffset()
            isBeingDeleted = true
        }

        // Call delete callback after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            onDelete()
        }
    }

    private func handleComplete() {
        // Provide haptic feedback
        UINotificationFeedbackGenerator().notificationOccurred(.success)

        // Reset offset and call complete callback
        onComplete()

        withAnimation {
            offset = handler.resetOffset()
        }
    }

    // MARK: - Context Menu

    @ViewBuilder
    private var contextMenuContent: some View {
        Button(action: onEdit) {
            Label("Edit", systemImage: "pencil")
        }

        if event.itemType == .task {
            Button(action: onComplete) {
                Label(
                    event.isCompleted ? "Mark Incomplete" : "Mark Complete",
                    systemImage: event.isCompleted ? "circle" : "checkmark.circle"
                )
            }
        }

        Divider()

        Button(role: .destructive, action: onDelete) {
            Label("Delete", systemImage: "trash")
        }
    }
}

// MARK: - Swipe Action Indicator

/// Visual indicator displayed behind an event card during swipe gesture.
struct SwipeActionIndicator: View {

    let isDelete: Bool
    let progress: CGFloat

    var body: some View {
        ZStack {
            Rectangle()
                .fill(isDelete ? Color.red : Color.green)

            Image(systemName: isDelete ? "trash" : "checkmark")
                .font(.title2)
                .foregroundColor(.white)
                .scaleEffect(min(1.0, progress * 2))
        }
    }
}

// MARK: - View Extension

extension View {
    /// Applies event interaction gestures (tap, swipe, context menu) to the view.
    ///
    /// Enables the following interactions:
    /// - Tap to open event detail
    /// - Swipe left to delete (with haptic feedback)
    /// - Swipe right to complete (tasks only)
    /// - Long press for context menu
    ///
    /// - Parameters:
    ///   - event: The TaskItem associated with this view
    ///   - onTap: Callback when the event is tapped
    ///   - onDelete: Callback when delete action is triggered
    ///   - onComplete: Callback when complete action is triggered
    ///   - onEdit: Callback when edit action is triggered
    /// - Returns: A view with event interaction support
    func eventInteractions(
        event: TaskItem,
        onTap: @escaping () -> Void,
        onDelete: @escaping () -> Void,
        onComplete: @escaping () -> Void,
        onEdit: @escaping () -> Void
    ) -> some View {
        modifier(EventInteractionModifier(
            event: event,
            onTap: onTap,
            onDelete: onDelete,
            onComplete: onComplete,
            onEdit: onEdit
        ))
    }
}

// MARK: - Preview

#Preview {
    struct EventInteractionPreview: View {
        @State private var showDeleteAlert = false
        @State private var showEditSheet = false
        @State private var showCompleteAlert = false

        let sampleTask = TaskItem(
            title: "Team Meeting",
            date: Date(),
            startTime: Date().addingTimeInterval(3600),
            endTime: Date().addingTimeInterval(5400),
            category: .meeting,
            itemType: .task
        )

        var body: some View {
            VStack(spacing: 16) {
                Text("Swipe Gestures Demo")
                    .font(.title2)
                    .fontWeight(.semibold)

                VStack(spacing: 12) {
                    Text("Swipe left to delete")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("Swipe right to complete")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("Long press for more options")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(12)
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)

                Spacer()

                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(sampleTask.title)
                                .font(.body)
                                .fontWeight(.semibold)

                            if let startTime = sampleTask.startTime {
                                Text(startTime.formatted(date: .omitted, time: .shortened))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }

                        Spacer()

                        Image(systemName: "calendar")
                            .foregroundColor(sampleTask.category.colorValue)
                    }
                    .padding(12)
                }
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .eventInteractions(
                    event: sampleTask,
                    onTap: {
                        // Handle tap
                    },
                    onDelete: {
                        showDeleteAlert = true
                    },
                    onComplete: {
                        showCompleteAlert = true
                    },
                    onEdit: {
                        showEditSheet = true
                    }
                )

                Spacer()
            }
            .padding(16)
            .alert("Task Deleted", isPresented: $showDeleteAlert) {
                Button("OK") { }
            }
            .alert("Task Completed", isPresented: $showCompleteAlert) {
                Button("OK") { }
            }
        }
    }

    return EventInteractionPreview()
}
