//
//  NotificationSettings.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 20/12/25.
//

import Foundation
import SwiftData

/// User preferences for local push notifications
/// Manages settings for event reminders, lunar date notifications (Rằm, Mùng 1),
/// and Vietnamese holiday notifications.
@Model
final class NotificationSettings {
    /// Unique identifier for the singleton pattern
    @Attribute(.unique) var id: String = "notification_settings"
    
    // MARK: - Master Control
    
    /// Global toggle for all notifications
    var isEnabled: Bool = false
    
    // MARK: - Event Notifications
    
    /// Enable/disable event reminders
    var eventNotificationsEnabled: Bool = true
    
    /// Default reminder time for new events (in minutes before event start)
    var defaultReminderMinutes: Int = 15
    
    // MARK: - Rằm Notifications (15th Lunar Day)
    
    /// Enable/disable Rằm notifications (opt-out: enabled by default)
    var ramNotificationsEnabled: Bool = true
    
    /// Hour for Rằm notification (0-23)
    var ramNotificationHour: Int = 6
    
    /// Minute for Rằm notification (0-59)
    var ramNotificationMinute: Int = 0
    
    // MARK: - Mùng 1 Notifications (1st Lunar Day)
    
    /// Enable/disable Mùng 1 notifications (opt-out: enabled by default)
    var mung1NotificationsEnabled: Bool = true
    
    /// Hour for Mùng 1 notification (0-23)
    var mung1NotificationHour: Int = 6
    
    /// Minute for Mùng 1 notification (0-59)
    var mung1NotificationMinute: Int = 0
    
    // MARK: - Fixed Event (Vietnamese Holiday) Notifications
    
    /// Enable/disable Vietnamese holiday notifications
    var fixedEventNotificationsEnabled: Bool = false
    
    /// How many days before the holiday to send notification
    var fixedEventReminderDays: Int = 1

    // MARK: - Giỗ (Death Anniversary) Notifications

    /// Enable/disable giỗ reminders from Personal Profile deceased relatives
    var gioNotificationsEnabled: Bool = true

    /// Hour for giỗ notifications (0-23)
    var gioNotificationHour: Int = 8

    /// Minute for giỗ notifications (0-59)
    var gioNotificationMinute: Int = 0

    /// Lead days before giỗ (stored as comma-separated ints, default 7,3,1)
    var gioLeadReminderDaysRaw: String = "7,3,1"

    var gioLeadReminderDays: [Int] {
        get {
            gioLeadReminderDaysRaw
                .split(separator: ",")
                .compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
                .filter { $0 >= 0 && $0 <= 30 }
                .sorted(by: >)
        }
        set {
            gioLeadReminderDaysRaw = newValue.map(String.init).joined(separator: ",")
        }
    }

    // MARK: - Ngày chay (Vegetarian Day) Night-Before Reminders

    /// Remind the evening before Mùng 1 / Rằm to prepare vegetarian meals
    var ngayChayNotificationsEnabled: Bool = false

    /// Hour for ngày chay night-before reminder (0-23)
    var ngayChayNotificationHour: Int = 20

    /// Minute for ngày chay night-before reminder (0-59)
    var ngayChayNotificationMinute: Int = 0
    
    // MARK: - Scheduling State
    
    /// Last date when notifications were scheduled
    var lastScheduledDate: Date?
    
    /// How many months ahead to schedule notifications (rolling window)
    var schedulingHorizonMonths: Int = 3
    
    init() {
        self.id = "notification_settings"
    }
}
