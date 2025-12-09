//
//  ReminderNotifcationManager.swift
//  VITTY
//
//  Created by Rujin Devkota on 6/18/25.
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification authorization error: \(error)")
            } else {
                print("Notification permission granted: \(granted)")
            }
        }
    }

    func scheduleNotification(title: String, body: String, date: Date, identifier: String) {
        // Check if notifications are enabled
        guard UserDefaults.standard.bool(forKey: "notificationsEnabled") else {
            print("Notifications are disabled. Skipping reminder notification scheduling.")
            return
        }
        
        // Check if date is in the past
        guard date > Date() else {
            print("Cannot schedule notification for past date: \(date)")
            return
        }
        
        // Check notification authorization
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else {
                print("Notification authorization not granted. Cannot schedule reminder.")
                return
            }
            
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .default

            let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Failed to schedule notification: \(error)")
                } else {
                    print("Successfully scheduled reminder notification: '\(title)' at \(date)")
                }
            }
        }
    }

    func scheduleReminderNotifications(title: String, date: Date, subject: String) {
        // Check if notifications are enabled
        guard UserDefaults.standard.bool(forKey: "notificationsEnabled") else {
            print("Notifications are disabled. Skipping reminder notification scheduling.")
            return
        }
        
        // Check if date is in the past
        guard date > Date() else {
            print("Cannot schedule reminder notifications for past date: \(date)")
            return
        }
        
        // Create unique identifier using title, subject, and timestamp
        let timestamp = Int(date.timeIntervalSince1970)
        let baseIdentifier = "reminder-\(subject)-\(title)-\(timestamp)"
        
        // Schedule exact time notification
        scheduleNotification(
            title: "\(subject): \(title)",
            body: "Your scheduled reminder is now.",
            date: date,
            identifier: "\(baseIdentifier)-exact"
        )

        // Calculate 10 minutes before, handling edge cases safely
        guard let tenMinutesBefore = Calendar.current.date(byAdding: .minute, value: -10, to: date),
              tenMinutesBefore > Date() else {
            print("Cannot schedule 10-minute reminder notification (too close to current time or in the past)")
            // Still schedule the exact time notification
            return
        }
        
        scheduleNotification(
            title: "Upcoming Reminder: \(title)",
            body: "Your reminder is in 10 minutes.",
            date: tenMinutesBefore,
            identifier: "\(baseIdentifier)-early"
        )
    }
    
    /// Cancel notifications for a specific reminder
    func cancelReminderNotifications(title: String, date: Date, subject: String) {
        let timestamp = Int(date.timeIntervalSince1970)
        let baseIdentifier = "reminder-\(subject)-\(title)-\(timestamp)"
        
        let identifiers = [
            "\(baseIdentifier)-exact",
            "\(baseIdentifier)-early"
        ]
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        print("Cancelled reminder notifications for: \(title)")
    }
}
