import Combine
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

// MARK: - ScrollProgressHolder

/// Observable object that holds scroll progress for efficient updates
/// CalendarGridView observes this to update its offset without expensive view recreation
@MainActor
class ScrollProgressHolder: ObservableObject {
    @Published var progress: CGFloat = 0
    @Published var headerHeight: CGFloat = 0
}

// MARK: - ParallaxScrollView (UIKit-Driven)

struct ParallaxScrollView<Header: View, Content: View>: View {
    let minHeaderHeight: CGFloat
    let maxHeaderHeight: CGFloat
    let header: (CGFloat, CGFloat) -> Header
    let content: () -> Content

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
    }

    var body: some View {
        ParallaxContainerRepresentable(
            minHeaderHeight: minHeaderHeight,
            maxHeaderHeight: maxHeaderHeight,
            header: header,
            content: content
        )
    }
}

// MARK: - ParallaxContainerRepresentable

struct ParallaxContainerRepresentable<Header: View, Content: View>: UIViewControllerRepresentable {
    let minHeaderHeight: CGFloat
    let maxHeaderHeight: CGFloat
    let header: (CGFloat, CGFloat) -> Header
    let content: () -> Content

    func makeUIViewController(context: Context) -> ParallaxContainerViewController<Header, Content> {
        ParallaxContainerViewController(
            minHeaderHeight: minHeaderHeight,
            maxHeaderHeight: maxHeaderHeight,
            header: header,
            content: content
        )
    }

    func updateUIViewController(_ controller: ParallaxContainerViewController<Header, Content>, context: Context) {
        // Update content hosting controller
        controller.updateContent(content)
        // Update header closure for future updates
        controller.headerBuilder = header
        // Refresh header view with new closure (for month/date changes)
        controller.updateHeader()
    }
}

// MARK: - ParallaxContainerViewController

class ParallaxContainerViewController<Header: View, Content: View>: UIViewController, UIScrollViewDelegate {
    // Configuration
    private let minHeaderHeight: CGFloat
    private let maxHeaderHeight: CGFloat
    var headerBuilder: (CGFloat, CGFloat) -> Header

    // UI Components
    private var scrollView: VerticalOnlyScrollView!
    private var headerContainerView: UIView!
    private var headerHostingController: UIHostingController<AnyView>!
    private var contentHostingController: UIHostingController<AnyView>!

    // Constraints
    private var headerHeightConstraint: NSLayoutConstraint!

    // State
    private var currentHeaderHeight: CGFloat
    private var currentProgress: CGFloat = 0

    // Progress holder for efficient scroll updates
    let progressHolder = ScrollProgressHolder()

    // Snap behavior
    private var snapRange: CGFloat { maxHeaderHeight - minHeaderHeight }
    private var snapThreshold: CGFloat { snapRange * 0.5 }

    init(
        minHeaderHeight: CGFloat,
        maxHeaderHeight: CGFloat,
        header: @escaping (CGFloat, CGFloat) -> Header,
        content: () -> Content
    ) {
        self.minHeaderHeight = minHeaderHeight
        self.maxHeaderHeight = maxHeaderHeight
        self.headerBuilder = header
        self.currentHeaderHeight = maxHeaderHeight
        super.init(nibName: nil, bundle: nil)

        // Initialize progress holder
        progressHolder.headerHeight = maxHeaderHeight
        progressHolder.progress = 0

        setupUI(content: content)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI(content: () -> Content) {
        view.backgroundColor = .white

        // Create scroll view
        scrollView = VerticalOnlyScrollView()
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        // Create header container (UIKit view with constraint-controlled height)
        headerContainerView = UIView()
        headerContainerView.backgroundColor = .white
        headerContainerView.translatesAutoresizingMaskIntoConstraints = false
        headerContainerView.clipsToBounds = true
        view.addSubview(headerContainerView)

        // Create header hosting controller with progress holder injected
        let initialHeaderView = AnyView(
            headerBuilder(maxHeaderHeight, 0)
                .environmentObject(progressHolder)
        )
        headerHostingController = UIHostingController(rootView: initialHeaderView)
        headerHostingController.view.translatesAutoresizingMaskIntoConstraints = false
        headerHostingController.view.backgroundColor = .clear
        addChild(headerHostingController)
        headerContainerView.addSubview(headerHostingController.view)
        headerHostingController.didMove(toParent: self)

        // Create content with spacer
        let contentWithSpacer = AnyView(
            VStack(spacing: 0) {
                Color.clear
                    .frame(height: maxHeaderHeight + 20)
                    .allowsHitTesting(false)
                content()
            }
        )
        contentHostingController = UIHostingController(rootView: contentWithSpacer)
        contentHostingController.view.translatesAutoresizingMaskIntoConstraints = false
        contentHostingController.view.backgroundColor = .clear
        contentHostingController.safeAreaRegions = []
        scrollView.addSubview(contentHostingController.view)

        // Setup constraints
        setupConstraints()
    }

    private func setupConstraints() {
        // Scroll view fills the entire view
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Content constraints within scroll view
        NSLayoutConstraint.activate([
            contentHostingController.view.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentHostingController.view.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentHostingController.view.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentHostingController.view.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentHostingController.view.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        // Header container at top with controllable height
        headerHeightConstraint = headerContainerView.heightAnchor.constraint(equalToConstant: maxHeaderHeight)
        NSLayoutConstraint.activate([
            headerContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerHeightConstraint
        ])

        // Header hosting controller fills header container
        NSLayoutConstraint.activate([
            headerHostingController.view.topAnchor.constraint(equalTo: headerContainerView.topAnchor),
            headerHostingController.view.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor),
            headerHostingController.view.trailingAnchor.constraint(equalTo: headerContainerView.trailingAnchor),
            headerHostingController.view.bottomAnchor.constraint(equalTo: headerContainerView.bottomAnchor)
        ])

        // Scroll indicator insets
        scrollView.scrollIndicatorInsets = UIEdgeInsets(top: maxHeaderHeight, left: 0, bottom: 0, right: 0)
    }

    func updateContent(_ content: () -> Content) {
        let contentWithSpacer = AnyView(
            VStack(spacing: 0) {
                Color.clear
                    .frame(height: maxHeaderHeight + 20)
                    .allowsHitTesting(false)
                content()
            }
        )
        contentHostingController.rootView = contentWithSpacer
    }

    /// Refresh header view with current header builder closure
    /// Called when parent view updates (month change, date selection, etc.)
    func updateHeader() {
        let updatedHeader = AnyView(
            headerBuilder(currentHeaderHeight, currentProgress)
                .environmentObject(progressHolder)
        )
        headerHostingController.rootView = updatedHeader
    }

    // MARK: - UIScrollViewDelegate

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y

        // Calculate new header height directly - NO SwiftUI state involved
        let newHeight: CGFloat
        if offset <= 0 {
            newHeight = maxHeaderHeight
        } else {
            newHeight = max(minHeaderHeight, maxHeaderHeight - offset)
        }

        // Calculate progress
        let newProgress = min(1, max(0, offset / snapRange))

        // Update constraint if height changed significantly
        let heightChanged = abs(newHeight - currentHeaderHeight) > 0.5
        if heightChanged {
            currentHeaderHeight = newHeight
            headerHeightConstraint.constant = newHeight
        }

        // Update progress holder directly - CalendarGridView observes this
        // This is much more efficient than rebuilding the entire header
        let progressChanged = abs(newProgress - currentProgress) > 0.001
        if progressChanged {
            currentProgress = newProgress
            progressHolder.progress = newProgress
            progressHolder.headerHeight = newHeight
        }
    }

    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        let targetY = targetContentOffset.pointee.y

        // Only snap if target is in the transitional range (0 to snapRange)
        guard targetY > 0 && targetY < snapRange else { return }

        // Determine snap target based on predicted destination
        let snapTarget: CGFloat
        if targetY > snapThreshold {
            snapTarget = snapRange
        } else {
            snapTarget = 0
        }

        targetContentOffset.pointee.y = snapTarget
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
