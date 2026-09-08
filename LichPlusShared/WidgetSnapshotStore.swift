//
//  WidgetSnapshotStore.swift
//  LichPlusShared
//

import Foundation

enum WidgetSnapshotStore {
    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    static func save(_ snapshot: WidgetTimelineSnapshot) {
        guard let defaults = WidgetAppGroup.sharedDefaults else { return }
        guard let data = try? encoder.encode(snapshot) else { return }
        defaults.set(data, forKey: WidgetAppGroup.snapshotKey)
    }

    static func load() -> WidgetTimelineSnapshot? {
        guard let defaults = WidgetAppGroup.sharedDefaults,
              let data = defaults.data(forKey: WidgetAppGroup.snapshotKey) else {
            return nil
        }
        return try? decoder.decode(WidgetTimelineSnapshot.self, from: data)
    }

    static func readLanguageCode(fallback: String = "vi") -> String {
        guard let defaults = WidgetAppGroup.sharedDefaults else { return fallback }
        return defaults.string(forKey: WidgetAppGroup.languageKey) ?? fallback
    }
}
