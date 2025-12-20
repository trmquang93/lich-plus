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
        DispatchQueue.main.async {
            self.authorizationStatus = settings.authorizationStatus
        }
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
    
    // MARK: - Rằm Notifications
    
    /// Get upcoming Rằm (15th lunar day) dates
    /// - Parameter months: Number of months to look ahead
    /// - Returns: Array of solar dates for Rằm, including leap months
    func getUpcomingRamDates(months: Int) -> [Date] {
        var dates: [Date] = []
        let today = Date()
        let calendar = Calendar.current
        var currentDate = today
        
        for _ in 0..<months {
            let lunar = LunarCalendar.solarToLunar(currentDate)
            
            // Schedule for regular month occurrence
            let ramSolarDate = LunarCalendar.lunarToSolar(
                day: 15,
                month: lunar.month,
                year: lunar.year
            )
            
            if ramSolarDate >= today {
                dates.append(ramSolarDate)
            }
            
            // Check for leap month and schedule if exists
            let leapInfo = LunarCalendar.getLeapMonthInfo(forSolarYear: calendar.component(.year, from: currentDate))
            if leapInfo.hasLeapMonth, leapInfo.leapMonth == lunar.month {
                let ramLeapSolarDate = LunarCalendar.lunarToSolar(
                    day: 15,
                    month: lunar.month,
                    year: lunar.year,
                    isLeapMonth: true
                )
                
                if ramLeapSolarDate >= today {
                    dates.append(ramLeapSolarDate)
                }
            }
            
            // Move to next month
            currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
        }
        
        return dates.sorted()
    }
    
    /// Schedule Rằm notifications for the next N months
    func scheduleRamNotifications() {
        let settings = getSettings()
        guard settings.isEnabled && settings.ramNotificationsEnabled else {
            return
        }
        
        // Remove existing Rằm notifications
        removeAllRamNotifications()
        
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
    private func removeAllRamNotifications() {
        center.getPendingNotificationRequests { requests in
            let ramIdentifiers = requests
                .filter { $0.identifier.hasPrefix(Self.ramIdentifierPrefix) }
                .map { $0.identifier }
            self.center.removePendingNotificationRequests(withIdentifiers: ramIdentifiers)
        }
    }
    
    // MARK: - Mùng 1 Notifications
    
    /// Get upcoming Mùng 1 (1st lunar day) dates
    /// - Parameter months: Number of months to look ahead
    /// - Returns: Array of solar dates for Mùng 1, including leap months
    func getUpcomingMung1Dates(months: Int) -> [Date] {
        var dates: [Date] = []
        let today = Date()
        let calendar = Calendar.current
        var currentDate = today
        
        for _ in 0..<months {
            let lunar = LunarCalendar.solarToLunar(currentDate)
            
            // Schedule for regular month occurrence
            let mung1SolarDate = LunarCalendar.lunarToSolar(
                day: 1,
                month: lunar.month,
                year: lunar.year
            )
            
            if mung1SolarDate >= today {
                dates.append(mung1SolarDate)
            }
            
            // Check for leap month and schedule if exists
            let leapInfo = LunarCalendar.getLeapMonthInfo(forSolarYear: calendar.component(.year, from: currentDate))
            if leapInfo.hasLeapMonth, leapInfo.leapMonth == lunar.month {
                let mung1LeapSolarDate = LunarCalendar.lunarToSolar(
                    day: 1,
                    month: lunar.month,
                    year: lunar.year,
                    isLeapMonth: true
                )
                
                if mung1LeapSolarDate >= today {
                    dates.append(mung1LeapSolarDate)
                }
            }
            
            // Move to next month
            currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
        }
        
        return dates.sorted()
    }
    
    /// Schedule Mùng 1 notifications for the next N months
    func scheduleMung1Notifications() {
        let settings = getSettings()
        guard settings.isEnabled && settings.mung1NotificationsEnabled else {
            return
        }
        
        // Remove existing Mùng 1 notifications
        removeAllMung1Notifications()
        
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
    private func removeAllMung1Notifications() {
        center.getPendingNotificationRequests { requests in
            let mung1Identifiers = requests
                .filter { $0.identifier.hasPrefix(Self.mung1IdentifierPrefix) }
                .map { $0.identifier }
            self.center.removePendingNotificationRequests(withIdentifiers: mung1Identifiers)
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
    func scheduleFixedEventNotifications() {
        let settings = getSettings()
        guard settings.isEnabled && settings.fixedEventNotificationsEnabled else {
            return
        }
        
        // Remove existing fixed event notifications
        removeAllFixedEventNotifications()
        
        let lunar = LunarCalendar.solarToLunar(Date())
        let today = Date()
        
        for holiday in vietnameseHolidays {
            let solarDate = LunarCalendar.lunarToSolar(
                day: holiday.day,
                month: holiday.month,
                year: lunar.year
            )
            
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
    private func removeAllFixedEventNotifications() {
        center.getPendingNotificationRequests { requests in
            let fixedEventIdentifiers = requests
                .filter { $0.identifier.hasPrefix(Self.fixedEventIdentifierPrefix) }
                .map { $0.identifier }
            self.center.removePendingNotificationRequests(withIdentifiers: fixedEventIdentifiers)
        }
    }
    
    // MARK: - Reschedule All
    
    /// Reschedule all notifications
    /// Called on app launch to ensure notifications are up to date
    func rescheduleAllNotifications() {
        scheduleRamNotifications()
        scheduleMung1Notifications()
        scheduleFixedEventNotifications()
        
        // Update last scheduled date
        let settings = getSettings()
        settings.lastScheduledDate = Date()
        updateSettings(settings)
    }
}
