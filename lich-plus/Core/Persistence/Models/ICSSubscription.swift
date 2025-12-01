//
//  ICSSubscription.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 30/11/25.
//

import Foundation
import SwiftData

enum SubscriptionType: String, Codable {
    case user = "user"
    case builtin = "builtin"
}

@Model
final class ICSSubscription {
    @Attribute(.unique) var id: UUID
    var name: String
    var url: String
    var isEnabled: Bool
    var lastSyncDate: Date?
    var colorHex: String
    var createdAt: Date
    var type: String

    init(
        id: UUID = UUID(),
        name: String,
        url: String,
        isEnabled: Bool = true,
        lastSyncDate: Date? = nil,
        colorHex: String = "#C7251D",
        createdAt: Date = Date(),
        type: String = SubscriptionType.user.rawValue
    ) {
        self.id = id
        self.name = name
        self.url = url
        self.isEnabled = isEnabled
        self.lastSyncDate = lastSyncDate
        self.colorHex = colorHex
        self.createdAt = createdAt
        self.type = type
    }

    // Computed property to check if this is a built-in subscription
    var isBuiltIn: Bool {
        type == SubscriptionType.builtin.rawValue
    }

    // Computed property to check if this subscription can be deleted
    var isDeletable: Bool {
        !isBuiltIn
    }

    // Update last sync date to now
    func updateLastSyncDate() {
        self.lastSyncDate = Date()
    }
}
