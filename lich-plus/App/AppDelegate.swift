//
//  AppDelegate.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 20/12/25.
//

import UIKit
import UserNotifications

/// Application delegate for handling notification-related events
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Set notification delegate to handle notifications when app is in foreground
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    /// Handle notification tap when app is in foreground or backgrounded
    /// For now, we just let the app open (no special navigation)
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        // App opens automatically when notification is tapped
        // No special action needed - user just sees the app open
        print("Notification tapped: \(response.notification.request.identifier)")
    }
    
    /// Handle notification presentation when app is in foreground
    /// Show the notification even when app is active
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        // Show notification banner and play sound even when app is in foreground
        return [.banner, .sound]
    }
}
