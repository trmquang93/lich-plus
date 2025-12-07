//
//  Notification+Calendar.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 07/12/25.
//

import Foundation

extension Notification.Name {
    /// Posted when calendar data changes and views need to refresh
    static let calendarDataDidChange = Notification.Name("calendarDataDidChange")
}
