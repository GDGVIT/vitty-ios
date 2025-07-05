import Foundation
import SwiftUI
import UserNotifications

class SettingsViewModel : ObservableObject{
    @Published var notificationsEnabled: Bool = false {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
            if notificationsEnabled {
                if let timetable = self.timetable {
                    self.scheduleAllNotifications(from: timetable)
                }
            } else {
                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                showNotificationDisabledAlert = true
            }
        }
    }

    @Published var timetable: TimeTable?
    @Published var showNotificationDisabledAlert = false

    init(timetable: TimeTable? = nil) {
        self.timetable = timetable
       
        self.notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
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

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                if settings.authorizationStatus == .authorized {
                    if let timetable = self.timetable {
                        self.scheduleAllNotifications(from: timetable)
                    }
                } else {
                    self.notificationsEnabled = false
                }
            }
        }
    }

    func scheduleAllNotifications(from timetable: TimeTable) {
        // Clear existing notifications first
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        let weekdays: [(Int, [Lecture])] = [
            (2, timetable.monday),    // Monday = 2
            (3, timetable.tuesday),   // Tuesday = 3
            (4, timetable.wednesday), // Wednesday = 4
            (5, timetable.thursday),  // Thursday = 5
            (6, timetable.friday),    // Friday = 6
            (7, timetable.saturday),  // Saturday = 7
            (1, timetable.sunday)     // Sunday = 1
        ]

        for (weekday, lectures) in weekdays {
            for lecture in lectures {
                guard let startDate = parseLectureTime(lecture.startTime, weekday: weekday) else {
                    print("Failed to parse time for lecture: \(lecture.name) with time: \(lecture.startTime)")
                    continue
                }

              
                scheduleNotification(for: lecture.name, at: startDate, title: "Class Starting", minutesBefore: 0)
                
               
                scheduleNotification(for: lecture.name, at: startDate, title: "Upcoming Class", minutesBefore: 10)
            }
        }
        
        print("Scheduled notifications for all lectures")
    }

    private func scheduleNotification(for lectureName: String, at date: Date, title: String, minutesBefore: Int) {
        let triggerDate = Calendar.current.date(byAdding: .minute, value: -minutesBefore, to: date) ?? date

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = "\(lectureName) is starting soon."
        content.sound = .default

        let triggerComponents = Calendar.current.dateComponents([.weekday, .hour, .minute], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: true)

        let identifier = "\(lectureName)-\(title)-\(minutesBefore)min-weekday\(triggerComponents.weekday ?? 0)"
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Successfully scheduled notification: \(identifier)")
            }
        }
    }

    
    private func parseLectureTime(_ timeString: String, weekday: Int) -> Date? {
      
        let formattedTimeString = formatTime(time: timeString)
        
       
        if formattedTimeString == "Failed to parse the time string." {
            return nil
        }
       
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        timeFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let timeDate = timeFormatter.date(from: formattedTimeString) else {
            print("Failed to parse formatted time: \(formattedTimeString)")
            return nil
        }
        
     
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: timeDate)
        
        
        let today = Date()
        let currentWeekday = calendar.component(.weekday, from: today)
        
      
        let daysFromToday = weekday - currentWeekday
        let targetDate = calendar.date(byAdding: .day, value: daysFromToday, to: today) ?? today
        
        
        var finalDateComponents = calendar.dateComponents([.year, .month, .day], from: targetDate)
        finalDateComponents.hour = timeComponents.hour
        finalDateComponents.minute = timeComponents.minute
        finalDateComponents.second = 0
        
        guard let lectureDate = calendar.date(from: finalDateComponents) else {
            print("Failed to create lecture date")
            return nil
        }
        
       
        if weekday == currentWeekday && lectureDate < today {
            return calendar.date(byAdding: .weekOfYear, value: 1, to: lectureDate)
        }
        
       
        if lectureDate < today {
            return calendar.date(byAdding: .weekOfYear, value: 1, to: lectureDate)
        }
        
        return lectureDate
    }
    
    // Your existing formatTime function
    private func formatTime(time: String) -> String {
        var timeComponents = time.components(separatedBy: "T").last ?? ""
        timeComponents = timeComponents.components(separatedBy: "+").first ?? ""
        timeComponents = timeComponents.components(separatedBy: "Z").first ?? ""
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        if let date = dateFormatter.date(from: timeComponents) {
            dateFormatter.dateFormat = "h:mm a"
            let formattedTime = dateFormatter.string(from: date)
            return formattedTime
        } else {
            return "Failed to parse the time string."
        }
    }
}
