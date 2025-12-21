//
//  NotificationService.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 20/12/25.
//

import Foundation
import SwiftData
import UserNotifications
import Combine

/// Main notification service for managing local push notifications
/// Handles:
/// - Event reminder notifications
/// - Rằm (15th lunar day) notifications
/// - Mùng 1 (1st lunar day) notifications
/// - Vietnamese holiday notifications
///
/// Thread safety: All operations must be called from the main thread
@MainActor
final class NotificationService: ObservableObject {
    // MARK: - Properties
    
    private let center = UNUserNotificationCenter.current()
    private let modelContext: ModelContext
    
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    // MARK: - Notification Identifiers
    
    private static let eventIdentifierPrefix = "event-"
    private static let ramIdentifierPrefix = "ram-"
    private static let mung1IdentifierPrefix = "mung1-"
    private static let fixedEventIdentifierPrefix = "fixed-event-"
    
    // MARK: - Initialization
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        Task {
            await checkAuthorizationStatus()
        }
    }
    
    // MARK: - Authorization
    
    /// Request user authorization for notifications
    /// Returns true if authorization was granted, false otherwise
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound])
            await checkAuthorizationStatus()
            return granted
        } catch {
            print("Error requesting notification authorization: \(error)")
            return false
        }
    }
    
    /// Check current authorization status
    func checkAuthorizationStatus() async {
        let settings = await center.notificationSettings()
        self.authorizationStatus = settings.authorizationStatus
    }
    
    // MARK: - Settings Management
    
    /// Get or create NotificationSettings
    func getSettings() -> NotificationSettings {
        let descriptor = FetchDescriptor<NotificationSettings>(
            predicate: #Predicate { $0.id == "notification_settings" }
        )
        
        do {
            if let settings = try modelContext.fetch(descriptor).first {
                return settings
            }
        } catch {
            print("Error fetching notification settings: \(error)")
        }
        
        // Create default settings
        let defaultSettings = NotificationSettings()
        modelContext.insert(defaultSettings)
        try? modelContext.save()
        return defaultSettings
    }
    
    /// Update notification settings
    func updateSettings(_ settings: NotificationSettings) {
        do {
            try modelContext.save()
        } catch {
            print("Error saving notification settings: \(error)")
        }
    }
    
    // MARK: - Event Notifications
    
    /// Schedule a notification reminder for an event
    /// - Parameter event: The event to schedule a notification for
    func scheduleEventNotification(for event: SyncableEvent) {
        guard let reminderMinutes = event.reminderMinutes, reminderMinutes > 0 else {
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = event.title
        content.body = String(
            format: NSLocalizedString(
                "notification.event.startsIn",
                comment: "Event notification body"
            ),
            reminderMinutes
        )
        content.sound = .default
        
        // Calculate trigger time
        let triggerDate = event.startDate.addingTimeInterval(-Double(reminderMinutes * 60))
        
        // Only schedule if trigger date is in the future
        guard triggerDate > Date() else {
            return
        }
        
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: triggerDate
        )
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let identifier = "\(Self.eventIdentifierPrefix)\(event.id.uuidString)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling event notification: \(error)")
            }
        }
    }
    
    /// Cancel a scheduled event notification
    /// - Parameter eventId: The UUID of the event
    func cancelEventNotification(eventId: UUID) {
        let identifier = "\(Self.eventIdentifierPrefix)\(eventId.uuidString)"
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    // MARK: - Lunar Date Helpers
    
    /// Get upcoming lunar dates for a specific day of the month
    /// - Parameters:
    ///   - day: The lunar day (1 for Mùng 1, 15 for Rằm)
    ///   - months: Number of months to look ahead
    /// - Returns: Array of solar dates for the specified lunar day
    private func getUpcomingLunarDates(day: Int, months: Int) -> [Date] {
        var dates: [Date] = []
        let today = Date()
        let calendar = Calendar.current
        var currentDate = today
        
        for _ in 0..<months {
            let lunar = LunarCalendar.solarToLunar(currentDate)
            
            let solarDate = LunarCalendar.lunarToSolar(
                day: day,
                month: lunar.month,
                year: lunar.year
            )
            
            if solarDate >= today {
                dates.append(solarDate)
            }
            
            // Check for leap month
            let leapInfo = LunarCalendar.getLeapMonthInfo(forSolarYear: calendar.component(.year, from: currentDate))
            if leapInfo.hasLeapMonth, leapInfo.leapMonth == lunar.month {
                let leapSolarDate = LunarCalendar.lunarToSolar(
                    day: day,
                    month: lunar.month,
                    year: lunar.year,
                    isLeapMonth: true
                )
                
                if leapSolarDate >= today {
                    dates.append(leapSolarDate)
                }
            }
            
            // Move to next month
            currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
        }
        
        return dates.sorted()
    }
    
    // MARK: - Rằm Notifications
    
    /// Get upcoming Rằm (15th lunar day) dates
    /// - Parameter months: Number of months to look ahead
    /// - Returns: Array of solar dates for Rằm, including leap months
    func getUpcomingRamDates(months: Int) -> [Date] {
        return getUpcomingLunarDates(day: 15, months: months)
    }
    
    /// Schedule Rằm notifications for the next N months
    func scheduleRamNotifications() async {
        let settings = getSettings()
        guard settings.isEnabled && settings.ramNotificationsEnabled else {
            return
        }
        
        // Remove existing Rằm notifications
        await removeAllRamNotifications()
        
        let ramDates = getUpcomingRamDates(months: settings.schedulingHorizonMonths)
        
        for date in ramDates {
            scheduleRamNotification(for: date, settings: settings)
        }
    }
    
    /// Schedule a single Rằm notification
    private func scheduleRamNotification(for date: Date, settings: NotificationSettings) {
        let lunar = LunarCalendar.solarToLunar(date)
        
        let content = UNMutableNotificationContent()
        content.title = String(
            format: NSLocalizedString(
                "notification.ram.title",
                comment: "Rằm notification title"
            ),
            lunar.month
        )
        content.body = NSLocalizedString(
            "notification.ram.body",
            comment: "Rằm notification body"
        )
        content.sound = .default
        
        // Set notification time to user's preferred time
        var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        components.hour = settings.ramNotificationHour
        components.minute = settings.ramNotificationMinute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let identifier = "\(Self.ramIdentifierPrefix)\(lunar.year)-\(lunar.month)-\(lunar.day)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling Rằm notification: \(error)")
            }
        }
    }
    
    /// Remove all Rằm notifications
    func removeAllRamNotifications() async {
        let requests = await center.pendingNotificationRequests()
        let ramIdentifiers = requests
            .filter { $0.identifier.hasPrefix(Self.ramIdentifierPrefix) }
            .map { $0.identifier }
        if !ramIdentifiers.isEmpty {
            center.removePendingNotificationRequests(withIdentifiers: ramIdentifiers)
        }
    }
    
    // MARK: - Mùng 1 Notifications
    
    /// Get upcoming Mùng 1 (1st lunar day) dates
    /// - Parameter months: Number of months to look ahead
    /// - Returns: Array of solar dates for Mùng 1, including leap months
    func getUpcomingMung1Dates(months: Int) -> [Date] {
        return getUpcomingLunarDates(day: 1, months: months)
    }
    
    /// Schedule Mùng 1 notifications for the next N months
    func scheduleMung1Notifications() async {
        let settings = getSettings()
        guard settings.isEnabled && settings.mung1NotificationsEnabled else {
            return
        }
        
        // Remove existing Mùng 1 notifications
        await removeAllMung1Notifications()
        
        let mung1Dates = getUpcomingMung1Dates(months: settings.schedulingHorizonMonths)
        
        for date in mung1Dates {
            scheduleMung1Notification(for: date, settings: settings)
        }
    }
    
    /// Schedule a single Mùng 1 notification
    private func scheduleMung1Notification(for date: Date, settings: NotificationSettings) {
        let lunar = LunarCalendar.solarToLunar(date)
        
        let content = UNMutableNotificationContent()
        content.title = String(
            format: NSLocalizedString(
                "notification.mung1.title",
                comment: "Mùng 1 notification title"
            ),
            lunar.month
        )
        content.body = NSLocalizedString(
            "notification.mung1.body",
            comment: "Mùng 1 notification body"
        )
        content.sound = .default
        
        // Set notification time to user's preferred time
        var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        components.hour = settings.mung1NotificationHour
        components.minute = settings.mung1NotificationMinute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let identifier = "\(Self.mung1IdentifierPrefix)\(lunar.year)-\(lunar.month)-\(lunar.day)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling Mùng 1 notification: \(error)")
            }
        }
    }
    
    /// Remove all Mùng 1 notifications
    func removeAllMung1Notifications() async {
        let requests = await center.pendingNotificationRequests()
        let mung1Identifiers = requests
            .filter { $0.identifier.hasPrefix(Self.mung1IdentifierPrefix) }
            .map { $0.identifier }
        if !mung1Identifiers.isEmpty {
            center.removePendingNotificationRequests(withIdentifiers: mung1Identifiers)
        }
    }
    
    // MARK: - Fixed Event Notifications
    
    /// Vietnamese holidays to send notifications for
    private let vietnameseHolidays: [(month: Int, day: Int, nameKey: String)] = [
        (1, 1, "notification.holiday.tet"),
        (1, 15, "notification.holiday.nguyenTieu"),
        (3, 3, "notification.holiday.hanThuc"),
        (5, 5, "notification.holiday.doanNgo"),
        (7, 15, "notification.holiday.vuLan"),
        (8, 15, "notification.holiday.trungThu"),
        (10, 10, "notification.holiday.thuongTan"),
    ]
    
    /// Schedule Vietnamese holiday notifications
    func scheduleFixedEventNotifications() async {
        let settings = getSettings()
        guard settings.isEnabled && settings.fixedEventNotificationsEnabled else {
            return
        }
        
        // Remove existing fixed event notifications
        await removeAllFixedEventNotifications()
        
        let today = Date()
        let currentLunar = LunarCalendar.solarToLunar(today)
        
        for holiday in vietnameseHolidays {
            var holidayLunarYear = currentLunar.year
            var solarDate = LunarCalendar.lunarToSolar(
                day: holiday.day,
                month: holiday.month,
                year: holidayLunarYear
            )
            
            // If the holiday has already passed this year, schedule for next year
            if solarDate < today {
                holidayLunarYear += 1
                solarDate = LunarCalendar.lunarToSolar(
                    day: holiday.day,
                    month: holiday.month,
                    year: holidayLunarYear
                )
            }
            
            // Calculate reminder date
            let reminderDate = Calendar.current.date(
                byAdding: .day,
                value: -settings.fixedEventReminderDays,
                to: solarDate
            ) ?? solarDate
            
            // Only schedule if reminder date is in the future
            guard reminderDate > today else {
                continue
            }
            
            scheduleFixedEventNotification(
                holiday: holiday,
                reminderDate: reminderDate,
                settings: settings
            )
        }
    }
    
    /// Schedule a single fixed event notification
    private func scheduleFixedEventNotification(
        holiday: (month: Int, day: Int, nameKey: String),
        reminderDate: Date,
        settings: NotificationSettings
    ) {
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString(holiday.nameKey, comment: "Holiday name")
        content.body = String(
            format: NSLocalizedString(
                "notification.holiday.inDays",
                comment: "Holiday reminder body"
            ),
            settings.fixedEventReminderDays
        )
        content.sound = .default
        
        let components = Calendar.current.dateComponents(
            [.year, .month, .day],
            from: reminderDate
        )
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let identifier = "\(Self.fixedEventIdentifierPrefix)\(holiday.month)-\(holiday.day)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling fixed event notification: \(error)")
            }
        }
    }
    
    /// Remove all fixed event notifications
    func removeAllFixedEventNotifications() async {
        let requests = await center.pendingNotificationRequests()
        let fixedEventIdentifiers = requests
            .filter { $0.identifier.hasPrefix(Self.fixedEventIdentifierPrefix) }
            .map { $0.identifier }
        if !fixedEventIdentifiers.isEmpty {
            center.removePendingNotificationRequests(withIdentifiers: fixedEventIdentifiers)
        }
    }
    
    // MARK: - Reschedule All
    
    /// Reschedule all notifications
    /// Called on app launch to ensure notifications are up to date
    func rescheduleAllNotifications() async {
        await scheduleRamNotifications()
        await scheduleMung1Notifications()
        await scheduleFixedEventNotifications()
        
        // Update last scheduled date
        let settings = getSettings()
        settings.lastScheduledDate = Date()
        updateSettings(settings)
    }
}
