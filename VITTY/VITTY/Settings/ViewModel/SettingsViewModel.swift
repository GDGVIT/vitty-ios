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
                print("All pending notifications have been cleared.")
                showNotificationDisabledAlert = true
            }
        }
    }

    @Published var timetable: TimeTable?
    @Published var showNotificationDisabledAlert = false

    init(timetable: TimeTable? = nil) {
        self.timetable = timetable
        
        checkNotificationAuthorization()
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
      
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        let weekdays: [(Int, [Lecture])] = [
            (1, timetable.sunday), (2, timetable.monday), (3, timetable.tuesday),
            (4, timetable.wednesday), (5, timetable.thursday), (6, timetable.friday),
            (7, timetable.saturday)
        ]

        for (weekday, lectures) in weekdays {
            for lecture in lectures {
              
                scheduleNotificationForNextOccurence(lecture: lecture, weekday: weekday)
            }
        }
        print("Scheduled all notifications for the next 7 days.")
    }

  
    private func scheduleNotificationForNextOccurence(lecture: Lecture, weekday: Int) {
        guard let time = parseTime(from: lecture.startTime) else { return }

        var dateComponents = DateComponents()
        dateComponents.hour = Calendar.current.component(.hour, from: time)
        dateComponents.minute = Calendar.current.component(.minute, from: time)
        dateComponents.weekday = weekday
        
        
        guard let nextTriggerDate = Calendar.current.nextDate(after: Date(), matching: dateComponents, matchingPolicy: .nextTime) else { return }

     
        scheduleNotification(
            lectureName: lecture.name,
            date: nextTriggerDate,
            title: "Upcoming Class",
            body: "\(lecture.name) starts in 10 minutes.",
            minutesBefore: 10
        )
        
      
        scheduleNotification(
            lectureName: lecture.name,
            date: nextTriggerDate,
            title: "Class Starting!",
            body: "\(lecture.name) is starting now.",
            minutesBefore: 0
        )
    }
    
    
    private func scheduleNotification(lectureName: String, date: Date, title: String, body: String, minutesBefore: Int) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

       
        guard let triggerDate = Calendar.current.date(byAdding: .minute, value: -minutesBefore, to: date) else { return }
        let triggerComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: triggerDate)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)

        let identifier = "\(lectureName)-\(title)-\(triggerDate.timeIntervalSince1970)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification for \(lectureName): \(error.localizedDescription)")
            } else {
                print("Successfully scheduled notification: '\(title)' for \(lectureName)")
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
