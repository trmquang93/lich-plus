import SwiftUI
import UIKit

enum NavigationUnit {
    case month
    case week
}

struct InfinitePageView<Content: View>: UIViewControllerRepresentable {
    let initialPage: Int
    let selectedDate: Date
    let navigationUnit: NavigationUnit
    let content: (Int, NavigationUnit) -> Content
    let onPageChanged: (Int) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self, initialSelectedDate: selectedDate)
    }

    func makeUIViewController(context: Context) -> UIPageViewController {
        let pageVC = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: [.interPageSpacing: 0]
        )
        pageVC.dataSource = context.coordinator
        pageVC.delegate = context.coordinator

        let initialVC = context.coordinator.makeHostingController(for: initialPage)
        pageVC.setViewControllers([initialVC], direction: .forward, animated: false)

        return pageVC
    }

    func updateUIViewController(_ pageVC: UIPageViewController, context: Context) {
        // Check if selectedDate changed - refresh current page to update selection UI
        if context.coordinator.lastSelectedDate != selectedDate {
            context.coordinator.lastSelectedDate = selectedDate
            if let currentVC = pageVC.viewControllers?.first as? IndexedHostingController<Content> {
                let newVC = context.coordinator.makeHostingController(for: currentVC.pageIndex)
                pageVC.setViewControllers([newVC], direction: .forward, animated: false)
            }
            return
        }

        // Update content when parent needs to programmatically change page
        guard let currentVC = pageVC.viewControllers?.first as? IndexedHostingController<Content>,
              currentVC.pageIndex != initialPage else { return }

        let direction: UIPageViewController.NavigationDirection = initialPage > currentVC.pageIndex ? .forward : .reverse
        let newVC = context.coordinator.makeHostingController(for: initialPage)
        pageVC.setViewControllers([newVC], direction: direction, animated: false)
    }

    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        var parent: InfinitePageView
        var lastSelectedDate: Date

        init(_ parent: InfinitePageView, initialSelectedDate: Date) {
            self.parent = parent
            self.lastSelectedDate = initialSelectedDate
        }

        func makeHostingController(for index: Int) -> IndexedHostingController<Content> {
            let controller = IndexedHostingController(rootView: parent.content(index, parent.navigationUnit))
            controller.pageIndex = index
            return controller
        }

        // MARK: - DataSource (infinite - always return prev/next)

        func pageViewController(_ pageVC: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
            guard let indexed = viewController as? IndexedHostingController<Content> else { return nil }
            return makeHostingController(for: indexed.pageIndex - 1)
        }

        func pageViewController(_ pageVC: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            guard let indexed = viewController as? IndexedHostingController<Content> else { return nil }
            return makeHostingController(for: indexed.pageIndex + 1)
        }

        // MARK: - Delegate (fires ONLY when animation completes)

        func pageViewController(
            _ pageVC: UIPageViewController,
            didFinishAnimating finished: Bool,
            previousViewControllers: [UIViewController],
            transitionCompleted completed: Bool
        ) {
            guard completed,
                  let currentVC = pageVC.viewControllers?.first as? IndexedHostingController<Content> else { return }
            parent.onPageChanged(currentVC.pageIndex)
        }
    }
}

class IndexedHostingController<Content: View>: UIHostingController<Content> {
    var pageIndex: Int = 0
}
