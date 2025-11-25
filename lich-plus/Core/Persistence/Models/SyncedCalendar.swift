//
//  SyncedCalendar.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 25/11/25.
//

import Foundation
import SwiftData

@Model
final class SyncedCalendar {
    @Attribute(.unique) var calendarIdentifier: String
    var title: String
    var colorHex: String
    var isEnabled: Bool
    var accountName: String?
    var lastSyncDate: Date?

    init(
        calendarIdentifier: String,
        title: String,
        colorHex: String = "#FF0000",
        isEnabled: Bool = true,
        accountName: String? = nil,
        lastSyncDate: Date? = nil
    ) {
        self.calendarIdentifier = calendarIdentifier
        self.title = title
        self.colorHex = colorHex
        self.isEnabled = isEnabled
        self.accountName = accountName
        self.lastSyncDate = lastSyncDate
    }

    // Update last sync date to now
    func updateLastSyncDate() {
        self.lastSyncDate = Date()
    }
}
