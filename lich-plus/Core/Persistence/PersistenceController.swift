//
//  PersistenceController.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 25/11/25.
//

import Foundation
import SwiftData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: ModelContainer

    init() {
        let schema = Schema([
            SyncableEvent.self,
            SyncedCalendar.self,
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            self.container = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }

    // Preview container for SwiftUI previews
    static let preview: PersistenceController = {
        let schema = Schema([
            SyncableEvent.self,
            SyncedCalendar.self,
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )

        do {
            let container = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            return PersistenceController(container: container)
        } catch {
            fatalError("Could not initialize preview ModelContainer: \(error)")
        }
    }()

    // Initializer for dependency injection
    init(container: ModelContainer) {
        self.container = container
    }
}
