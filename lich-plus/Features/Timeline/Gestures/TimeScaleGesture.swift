import SwiftUI

/// Handler for pinch-to-zoom time scale gestures on the timeline.
///
/// Manages scaling calculations, clamping to valid ranges, and snapping to predefined
/// scale levels. The three scale levels (15-min, 30-min, 1-hour) correspond to
/// hour heights of 120pt, 60pt, and 40pt respectively.
final class TimeScaleGestureHandler {

    // MARK: - Constants

    private let minHeight: CGFloat = 40
    private let maxHeight: CGFloat = 120

    // MARK: - Height Clamping

    /// Clamps a given height value to the valid range [40...120].
    /// - Parameter height: The height value to clamp
    /// - Returns: The clamped height value
    func clampHeight(_ height: CGFloat) -> CGFloat {
        max(minHeight, min(maxHeight, height))
    }

    // MARK: - Scale Calculation

    /// Calculates the appropriate TimeScale for a given height.
    /// - Parameter height: The height in points
    /// - Returns: The nearest TimeScale
    func scaleForHeight(_ height: CGFloat) -> TimelineConfiguration.TimeScale {
        nearestScale(for: height)
    }

    /// Determines the nearest predefined scale level for a given height.
    /// Uses distance-based matching to find the closest scale.
    /// - Parameter height: The height value to match
    /// - Returns: The nearest TimeScale
    func nearestScale(for height: CGFloat) -> TimelineConfiguration.TimeScale {
        let scales = TimelineConfiguration.TimeScale.allCases

        guard let nearest = scales.min(by: { scale1, scale2 in
            abs(scale1.rawValue - height) < abs(scale2.rawValue - height)
        }) else {
            return .thirtyMin // Default fallback
        }

        return nearest
    }

    // MARK: - Scale Delta Calculation

    /// Calculates the scale delta (magnification) from one height to another.
    /// - Parameters:
    ///   - currentHeight: The starting height
    ///   - newHeight: The ending height
    /// - Returns: The delta as a multiplier (e.g., 1.5 means 150% of original)
    func calculateScaleDelta(from currentHeight: CGFloat, to newHeight: CGFloat) -> CGFloat {
        guard currentHeight > 0 else { return 1.0 }
        return newHeight / currentHeight
    }
}

// MARK: - TimeScale ViewModifier

/// ViewModifier that applies pinch-to-zoom gesture handling to a timeline view.
///
/// Allows users to pinch to zoom the timeline between three predefined scales.
/// Includes spring animation and haptic feedback for a polished interaction.
struct TimeScaleGestureModifier: ViewModifier {

    @Binding var configuration: TimelineConfiguration
    @State private var lastScale: CGFloat = 1.0

    private let handler = TimeScaleGestureHandler()

    func body(content: Content) -> some View {
        content
            .gesture(magnificationGesture)
    }

    // MARK: - Gesture Implementation

    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { scale in
                handleScaleChange(scale)
            }
            .onEnded { _ in
                snapToNearestScale()
                lastScale = 1.0
            }
    }

    // MARK: - Gesture Handlers

    private func handleScaleChange(_ scale: CGFloat) {
        let delta = scale / lastScale
        lastScale = scale

        let currentHeight = configuration.hourHeight
        let newHeight = currentHeight * delta

        // Clamp to valid range
        let clampedHeight = handler.clampHeight(newHeight)

        // Update scale based on new height
        configuration.currentScale = handler.scaleForHeight(clampedHeight)
    }

    private func snapToNearestScale() {
        let currentHeight = configuration.hourHeight
        let nearestScale = handler.nearestScale(for: currentHeight)

        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            configuration.currentScale = nearestScale
        }

        // Haptic feedback on snap
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
}

// MARK: - View Extension

extension View {
    /// Applies pinch-to-zoom gesture handling for timeline scale adjustment.
    /// - Parameter configuration: Binding to the TimelineConfiguration
    /// - Returns: A view with time scale gesture support
    func timeScaleGesture(configuration: Binding<TimelineConfiguration>) -> some View {
        modifier(TimeScaleGestureModifier(configuration: configuration))
    }
}

// MARK: - Preview

#Preview {
    struct TimeScaleGesturePreview: View {
        @State private var configuration = TimelineConfiguration()

        var body: some View {
            ZStack {
                Color.gray.opacity(0.1)

                VStack(spacing: 16) {
                    Text("Pinch to Zoom Timeline")
                        .font(.title2)
                        .fontWeight(.semibold)

                    VStack(spacing: 8) {
                        Text("Current Scale: \(configuration.currentScale == .fifteenMin ? "15-min (Zoomed In)" : configuration.currentScale == .thirtyMin ? "30-min (Default)" : "1-hour (Zoomed Out)")")
                            .font(.body)

                        Text("Hour Height: \(Int(configuration.hourHeight))pt")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    // Visual representation of the timeline scale
                    VStack(spacing: 0) {
                        ForEach(0..<6, id: \.self) { hour in
                            HStack {
                                Text("\(hour * 4):00")
                                    .font(.caption2)
                                    .frame(width: 40)

                                Rectangle()
                                    .fill(Color.blue.opacity(0.3))
                                    .frame(height: configuration.hourHeight / 4)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(8)

                    Spacer()
                }
                .padding(16)
            }
            .timeScaleGesture(configuration: $configuration)
        }
    }

    return TimeScaleGesturePreview()
}
