//
//  WidgetSnapshotCoordinator.swift
//  lich-plus
//

import Foundation
import SwiftData
import WidgetKit

@MainActor
final class WidgetSnapshotCoordinator {
    static let shared = WidgetSnapshotCoordinator()

    private init() {}

    func refresh(modelContext: ModelContext) {
        WidgetSnapshotWriter.refresh(modelContext: modelContext)
        WidgetCenter.shared.reloadAllTimelines()
        FestivalLiveActivityManager.shared.refresh()
    }

    func startObserving(modelContext: ModelContext) {
        NotificationCenter.default.addObserver(
            forName: .calendarDataDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.refresh(modelContext: modelContext)
            }
        }
    }
}
