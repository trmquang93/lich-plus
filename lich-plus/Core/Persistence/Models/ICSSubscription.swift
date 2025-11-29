//
//  ICSSubscription.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 30/11/25.
//

import Foundation
import SwiftData

@Model
final class ICSSubscription {
    @Attribute(.unique) var id: UUID
    var name: String
    var url: String
    var isEnabled: Bool
    var lastSyncDate: Date?
    var colorHex: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        url: String,
        isEnabled: Bool = true,
        lastSyncDate: Date? = nil,
        colorHex: String = "#C7251D",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.url = url
        self.isEnabled = isEnabled
        self.lastSyncDate = lastSyncDate
        self.colorHex = colorHex
        self.createdAt = createdAt
    }

    // Update last sync date to now
    func updateLastSyncDate() {
        self.lastSyncDate = Date()
    }
}
