//
//  SyncState.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 25/11/25.
//

import Foundation

enum SyncStatus: String, Codable {
    case pending = "pending"          // Local change not yet pushed
    case synced = "synced"            // In sync with Apple Calendar
    case deleted = "deleted"          // Marked for deletion
    case localOnly = "localOnly"      // Never synced (user choice)
}

enum EventSource: String, Codable {
    case local = "local"              // Created in this app
    case appleCalendar = "appleCalendar"  // Imported from Apple Calendar
    case googleCalendar = "googleCalendar"  // Imported from Google Calendar
}
