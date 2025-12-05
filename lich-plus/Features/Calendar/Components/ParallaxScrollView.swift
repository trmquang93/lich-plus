import SwiftUI

// MARK: - VerticalOnlyScrollView

/// Custom UIScrollView that only responds to vertical pan gestures
class VerticalOnlyScrollView: UIScrollView {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = panGesture.velocity(in: self)
            // Only begin if gesture is primarily vertical
            return abs(velocity.y) > abs(velocity.x)
        }
        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
}

// MARK: - SnapScrollView (UIScrollView Wrapper)

struct SnapScrollView<Content: View>: UIViewRepresentable {
    let content: Content
    let minHeaderHeight: CGFloat
    let maxHeaderHeight: CGFloat
    @Binding var scrollOffset: CGFloat

    func makeUIView(context: Context) -> UIScrollView {
        // Use custom scroll view that only responds to vertical gestures
        let scrollView = VerticalOnlyScrollView()
        scrollView.delegate = context.coordinator
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.contentInsetAdjustmentBehavior = .never

        // No contentInset - using SwiftUI spacer for visual positioning
        // Scroll indicator starts below the header
        scrollView.scrollIndicatorInsets = UIEdgeInsets(top: maxHeaderHeight, left: 0, bottom: 0, right: 0)

        // Store initial offset to apply after layout
        context.coordinator.initialOffset = scrollOffset

        let hostingController = UIHostingController(rootView: content)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.backgroundColor = .clear
        hostingController.safeAreaRegions = []

        scrollView.addSubview(hostingController.view)

        context.coordinator.hostingController = hostingController
        context.coordinator.maxHeaderHeight = maxHeaderHeight

        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            hostingController.view.topAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.topAnchor),
            hostingController.view.bottomAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            hostingController.view.widthAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.widthAnchor),
        ])

        return scrollView
    }

    func updateUIView(_ scrollView: UIScrollView, context: Context) {
        context.coordinator.hostingController?.rootView = content
        context.coordinator.snapRange = maxHeaderHeight - minHeaderHeight
        context.coordinator.maxHeaderHeight = maxHeaderHeight
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(
            scrollOffset: $scrollOffset,
            snapRange: maxHeaderHeight - minHeaderHeight,
            maxHeaderHeight: maxHeaderHeight
        )
    }

    // MARK: - Coordinator

    class Coordinator: NSObject, UIScrollViewDelegate {
        @Binding var scrollOffset: CGFloat
        var snapRange: CGFloat
        var maxHeaderHeight: CGFloat
        var hostingController: UIHostingController<Content>?
        var initialOffset: CGFloat = 0
        private var hasAppliedInitialOffset = false

        // Snap points (no contentInset, using spacer)
        // When expanded: contentOffset.y = 0 (spacer at top)
        // When collapsed: contentOffset.y = snapRange (spacer scrolled up)
        private var expandedOffset: CGFloat { 0 }
        private var collapsedOffset: CGFloat { snapRange }
        private var snapThreshold: CGFloat { snapRange * 0.5 }

        init(scrollOffset: Binding<CGFloat>, snapRange: CGFloat, maxHeaderHeight: CGFloat) {
            self._scrollOffset = scrollOffset
            self.snapRange = snapRange
            self.maxHeaderHeight = maxHeaderHeight
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            // Apply initial offset once content is laid out
            if !hasAppliedInitialOffset && scrollView.contentSize.height > 0 && initialOffset > 0 {
                hasAppliedInitialOffset = true
                DispatchQueue.main.async {
                    scrollView.setContentOffset(CGPoint(x: 0, y: self.initialOffset), animated: false)
                }
                return
            }

            DispatchQueue.main.async {
                self.scrollOffset = scrollView.contentOffset.y
            }
        }

        func scrollViewWillEndDragging(
            _ scrollView: UIScrollView,
            withVelocity velocity: CGPoint,
            targetContentOffset: UnsafeMutablePointer<CGPoint>
        ) {
            let targetY = targetContentOffset.pointee.y

            // Only snap if target is in the transitional range (0 to snapRange)
            guard targetY > expandedOffset && targetY < collapsedOffset else { return }

            // Determine snap target based on predicted destination
            let snapTarget: CGFloat
            if targetY > snapThreshold {
                snapTarget = collapsedOffset
            } else {
                snapTarget = expandedOffset
            }

            targetContentOffset.pointee.y = snapTarget
        }
    }
}

// MARK: - ParallaxScrollView

struct ParallaxScrollView<Header: View, Content: View>: View {
    let minHeaderHeight: CGFloat
    let maxHeaderHeight: CGFloat
    let header: (CGFloat, CGFloat) -> Header
    let content: () -> Content

    @State private var scrollOffset: CGFloat

    init(
        minHeaderHeight: CGFloat,
        maxHeaderHeight: CGFloat,
        @ViewBuilder header: @escaping (CGFloat, CGFloat) -> Header,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.minHeaderHeight = minHeaderHeight
        self.maxHeaderHeight = maxHeaderHeight
        self.header = header
        self.content = content
        // Initialize to expanded state (offset 0 = top of content visible)
        // TODO: Week swipe navigation blocked by UIScrollView gesture conflict
        let initialOffset: CGFloat = 0
        self._scrollOffset = State(initialValue: initialOffset)
    }

    // Convert scroll offset to header height
    // scrollOffset = 0 means fully expanded (header = maxHeaderHeight)
    // scrollOffset = snapRange means fully collapsed (header = minHeaderHeight)
    private var calculatedHeaderHeight: CGFloat {
        if scrollOffset <= 0 {
            return maxHeaderHeight
        } else {
            let collapsed = maxHeaderHeight - scrollOffset
            return max(minHeaderHeight, collapsed)
        }
    }

    private var collapseProgress: CGFloat {
        let range = maxHeaderHeight - minHeaderHeight
        guard range > 0 else { return 0 }
        return min(1, max(0, scrollOffset / range))
    }

    var body: some View {
        ZStack(alignment: .top) {
            // Content with spacer to position below header
            // Note: Extra 20px padding compensates for UIScrollView/UIHostingController
            // coordinate offset when hosting SwiftUI content in UIKit scroll view.
            SnapScrollView(
                content: VStack(spacing: 0) {
                    // Spacer for header area - disabled hit testing so header overlay captures gestures
                    Color.clear
                        .frame(height: maxHeaderHeight + 20)
                        .allowsHitTesting(false)
                    content()
                },
                minHeaderHeight: minHeaderHeight,
                maxHeaderHeight: maxHeaderHeight,
                scrollOffset: $scrollOffset
            )

            header(calculatedHeaderHeight, collapseProgress)
                .frame(height: calculatedHeaderHeight, alignment: .top)
                .background(Color.white)  // Solid background to block gesture pass-through
                .clipped()
                .contentShape(Rectangle())  // Ensure header captures all gestures in its frame
        }
    }
}

// MARK: - Preview

#Preview {
    ParallaxScrollView(
        minHeaderHeight: 100,
        maxHeaderHeight: 300,
        header: { height, progress in
            VStack {
                Text("Parallax Header")
                    .font(.title)
                    .opacity(1.0 - progress)
                Spacer()
                Text("Progress: \(String(format: "%.0f", progress * 100))%")
                    .font(.caption)
                    .opacity(progress)
            }
            .frame(height: height)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.blue.opacity(0.7), .blue.opacity(0.3)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        },
        content: {
            VStack(spacing: 16) {
                ForEach(0..<20, id: \.self) { index in
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Item \(index + 1)")
                            .font(.headline)
                        Text(
                            "This is a content item that demonstrates the parallax scroll view in action."
                        )
                        .font(.body)
                        .lineLimit(2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            .padding()
        }
    )
}
