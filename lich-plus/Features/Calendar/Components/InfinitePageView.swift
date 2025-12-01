import SwiftUI
import UIKit

// MARK: - PageIndex Protocol

protocol PageIndex: Equatable, Comparable {
    func next() -> Self
    func previous() -> Self
}

// MARK: - PageIndex Conformances

extension Int: PageIndex {
    func next() -> Int {
        self + 1
    }

    func previous() -> Int {
        self - 1
    }
}

extension Date: PageIndex {
    func next() -> Date {
        Calendar.current.date(byAdding: .day, value: 1, to: self) ?? self
    }

    func previous() -> Date {
        Calendar.current.date(byAdding: .day, value: -1, to: self) ?? self
    }
}

// MARK: - InfinitePageView

struct InfinitePageView<Index: PageIndex, Content: View>: UIViewControllerRepresentable {
    let initialIndex: Index
    let currentValue: Index
    let content: (Index) -> Content
    let onPageChanged: (Index) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self, initialValue: currentValue)
    }

    func makeUIViewController(context: Context) -> UIPageViewController {
        let pageVC = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: [.interPageSpacing: 0]
        )
        pageVC.dataSource = context.coordinator
        pageVC.delegate = context.coordinator

        let initialVC = context.coordinator.makeHostingController(for: initialIndex)
        pageVC.setViewControllers([initialVC], direction: .forward, animated: false)

        return pageVC
    }

    func updateUIViewController(_ pageVC: UIPageViewController, context: Context) {
        // Check if currentValue changed - refresh current page to update selection UI
        if context.coordinator.lastIndex != currentValue {
            context.coordinator.lastIndex = currentValue
            if let currentVC = pageVC.viewControllers?.first as? IndexedHostingController<Index, Content> {
                let newVC = context.coordinator.makeHostingController(for: currentVC.pageIndex)
                pageVC.setViewControllers([newVC], direction: .forward, animated: false)
            }
            return
        }

        // Update content when parent needs to programmatically change page
        guard let currentVC = pageVC.viewControllers?.first as? IndexedHostingController<Index, Content>,
              currentVC.pageIndex != initialIndex else { return }

        let direction: UIPageViewController.NavigationDirection = initialIndex > currentVC.pageIndex ? .forward : .reverse
        let newVC = context.coordinator.makeHostingController(for: initialIndex)
        pageVC.setViewControllers([newVC], direction: direction, animated: false)
    }

    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        var parent: InfinitePageView
        var lastIndex: Index

        init(_ parent: InfinitePageView, initialValue: Index) {
            self.parent = parent
            self.lastIndex = initialValue
        }

        func makeHostingController(for index: Index) -> IndexedHostingController<Index, Content> {
            let controller = IndexedHostingController<Index, Content>(rootView: parent.content(index))
            controller.pageIndex = index
            return controller
        }

        // MARK: - DataSource (infinite - always return prev/next)

        func pageViewController(_ pageVC: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
            guard let indexed = viewController as? IndexedHostingController<Index, Content> else { return nil }
            return makeHostingController(for: indexed.pageIndex.previous())
        }

        func pageViewController(_ pageVC: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            guard let indexed = viewController as? IndexedHostingController<Index, Content> else { return nil }
            return makeHostingController(for: indexed.pageIndex.next())
        }

        // MARK: - Delegate (fires ONLY when animation completes)

        func pageViewController(
            _ pageVC: UIPageViewController,
            didFinishAnimating finished: Bool,
            previousViewControllers: [UIViewController],
            transitionCompleted completed: Bool
        ) {
            guard completed,
                  let currentVC = pageVC.viewControllers?.first as? IndexedHostingController<Index, Content> else { return }
            parent.onPageChanged(currentVC.pageIndex)
        }
    }
}

// MARK: - IndexedHostingController

class IndexedHostingController<Index: PageIndex, Content: View>: UIHostingController<Content> {
    var pageIndex: Index!
}
