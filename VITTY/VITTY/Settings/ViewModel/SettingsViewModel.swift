import Foundation
import SwiftUI
import UserNotifications

class SettingsViewModel: ObservableObject {
    @Published var notificationsEnabled: Bool = UserDefaults.standard.bool(forKey: "notificationsEnabled") {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
            if notificationsEnabled {
               
                requestPermissionAndSchedule()
            } else {
                
                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                print("All pending notifications have been cleared (notifications disabled).")
                showNotificationDisabledAlert = true
            }
        }
    }

    @Published var timetable: TimeTable? {
        didSet {
           
            if notificationsEnabled, let timetable = timetable {
                
                UNUserNotificationCenter.current().getNotificationSettings { settings in
                    DispatchQueue.main.async {
                        if settings.authorizationStatus == .authorized {
                            self.scheduleAllNotifications(from: timetable)
                        }
                    }
                }
            }
        }
    }
    @Published var showNotificationDisabledAlert = false

    init(timetable: TimeTable? = nil) {
        self.timetable = timetable
        
        checkNotificationAuthorization()
        
       
        if notificationsEnabled, let timetable = timetable {
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                DispatchQueue.main.async {
                    if settings.authorizationStatus == .authorized {
                        self.scheduleAllNotifications(from: timetable)
                    }
                }
            }
        }
    }

  
    func checkNotificationAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                if settings.authorizationStatus != .authorized {
                    self.notificationsEnabled = false
                }
            }
        }
    }

 
    func requestPermissionAndSchedule() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("Notification permission granted.")
                    if let timetable = self.timetable {
                        self.scheduleAllNotifications(from: timetable)
                    }
                } else {
                    print("Notification permission denied.")
                   
                    self.notificationsEnabled = false
                }
            }
        }
    }

  
    func scheduleAllNotifications(from timetable: TimeTable) {
        
        guard notificationsEnabled else {
            print("Notifications are disabled. Skipping scheduling.")
            return
        }
      
        
        removeClassNotifications()

        let weekdays: [(Int, [Lecture])] = [
            (1, timetable.sunday), (2, timetable.monday), (3, timetable.tuesday),
            (4, timetable.wednesday), (5, timetable.thursday), (6, timetable.friday),
            (7, timetable.saturday)
        ]

        for (weekday, lectures) in weekdays {
            for lecture in lectures {
                scheduleRecurringNotification(lecture: lecture, weekday: weekday)
            }
        }
        print("Scheduled all recurring weekly notifications.")
    }
    
    /// Remove only class notifications, preserving reminder notifications
    private func removeClassNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let classNotificationIdentifiers = requests
                .filter { request in
                    
                    let identifier = request.identifier
                    return !identifier.hasPrefix("reminder-") && 
                           (identifier.contains("-reminder-") || identifier.contains("-start-"))
                }
                .map { $0.identifier }
            
            if !classNotificationIdentifiers.isEmpty {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: classNotificationIdentifiers)
                print("Removed \(classNotificationIdentifiers.count) class notification(s)")
            }
        }
    }

  
    private func scheduleRecurringNotification(lecture: Lecture, weekday: Int) {
        guard let time = parseTime(from: lecture.startTime) else { return }

        let hour = Calendar.current.component(.hour, from: time)
        let minute = Calendar.current.component(.minute, from: time)
        

        var reminderComponents = DateComponents()
        reminderComponents.weekday = weekday
        

        if minute >= 10 {
            reminderComponents.hour = hour
            reminderComponents.minute = minute - 10
        } else {
           
            reminderComponents.hour = hour > 0 ? hour - 1 : 23
            reminderComponents.minute = 60 + minute - 10
        }
        
      
        var startComponents = DateComponents()
        startComponents.weekday = weekday
        startComponents.hour = hour
        startComponents.minute = minute
        
        scheduleWeeklyNotification(
            lectureName: lecture.name,
            components: reminderComponents,
            title: "Upcoming Class",
            body: "\(lecture.name) starts in 10 minutes.",
            identifier: "\(lecture.name)-reminder-\(weekday)"
        )
        
        scheduleWeeklyNotification(
            lectureName: lecture.name,
            components: startComponents,
            title: "Class Starting!",
            body: "\(lecture.name) is starting now.",
            identifier: "\(lecture.name)-start-\(weekday)"
        )
    }
    
    
    private func scheduleWeeklyNotification(
        lectureName: String,
        components: DateComponents,
        title: String,
        body: String,
        identifier: String
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
       
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling recurring notification for \(lectureName): \(error.localizedDescription)")
            } else {
                print("Successfully scheduled recurring notification: '\(title)' for \(lectureName) on weekday \(components.weekday ?? 0)")
            }
        }
    }

 
    private func parseTime(from timeString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
       
        if let timePart = timeString.components(separatedBy: "T").last?.components(separatedBy: "+").first {
            return formatter.date(from: timePart)
        }
        return nil
    }
}
