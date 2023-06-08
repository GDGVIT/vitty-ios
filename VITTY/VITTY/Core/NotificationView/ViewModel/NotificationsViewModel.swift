//
//  NotificationsViewModel.swift
//  VITTY
//
//  Created by Ananya George on 1/22/22.
//

import Foundation
import UserNotifications

class NotificationsViewModel: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationsViewModel()
    static let notifKey = "notificationsKey"
    
    @Published var notificationTapped: Bool = false
    
    @Published var notifSettings: [NotificationsSettingsModel] = []
    
    func setupNotificationPreferences(timetable: [String:[Classes]]) {
        // this will be called in the completion handler after the timetable is fully populated
        // iterate through each day
        var temporaryArray: [NotificationsSettingsModel] = []
        for day in 0..<7 {
            let currentDay = StringConstants.notificationDays[day]
            var temporaryArr: [NotificationsSettingsModel] = []
            if let currentDayClasses = timetable[currentDay] {
                if !currentDayClasses.isEmpty {
                    for aclass in 0..<currentDayClasses.count {
                        let notifsetting = NotificationsSettingsModel(id: UUID().uuidString, enabled: true, day: (day+1), period: aclass, location: currentDayClasses[aclass].location ?? "location")
                        temporaryArr.append(notifsetting)
                    }
                }
                temporaryArray.append(contentsOf: temporaryArr)
            }
        }
        self.notifSettings = temporaryArray
        print(self.notifSettings)
        saveNotifSettingsToUserDefaults()
        self.setupNotifs(timetable: timetable)
        NotificationsManager.shared.getAllNotificationRequests()
    }
    
    func updateNotifs(timetable: [String:[Classes]]) {
        let examMode = UserDefaults.standard.bool(forKey: "examMode")
        if examMode {
            print("exam mode is on. notifications will not be updated now.")
            NotificationsManager.shared.removeAllNotificationRequests()
            print("all notifications have been removed")
            
        } else {
            print("updating notifications")
            self.saveNotifSettingsToUserDefaults()
            UNUserNotificationCenter.current().getPendingNotificationRequests { allPendingNotifs in
                var idsToRemove: [String] = []
                for notifSetting in self.notifSettings {
                    if !notifSetting.enabled && allPendingNotifs.contains( where: { $0.identifier == notifSetting.id} ) {
                        idsToRemove.append(notifSetting.id ?? "")
                    } else if notifSetting.enabled && !allPendingNotifs.contains(where: { $0.identifier == notifSetting.id} ) {
                        self.addNotif(timetable: timetable, notifInfo: notifSetting)
                    }
                }
                print("removing notifs with ids")
                print(idsToRemove)
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: idsToRemove)
                
            }
        }
    }
    
    func addNotif(timetable: [String:[Classes]], notifInfo: NotificationsSettingsModel) {
        let classs: Classes = timetable[StringConstants.notificationDays[notifInfo.day - 1]]?[notifInfo.period] ?? Classes()
        
        
        NotificationsManager.shared.addNotifications(id: notifInfo.id ?? "",date: classs.startTime ?? Date(), day: notifInfo.day, courseCode: classs.courseCode ?? "Course Code", courseName: classs.courseName  ?? "Course Name", location: classs.location ?? "Location")
    }
    
    
    func setupNotifs(timetable: [String:[Classes]]) {
        // remove all notification requests
        NotificationsManager.shared.removeAllNotificationRequests()
        // save notif preferences to userdefaults
        self.saveNotifSettingsToUserDefaults()
        // iterate through notification preferences
        for period in self.notifSettings {
            
            if period.enabled {
                let currClass = timetable[StringConstants.notificationDays[period.day - 1]]?[period.period]
                //                let components = Calendar.current.dateComponents([.hour, .minute], from: currClass?.startTime ?? Date())
                //                let hour = components.hour ?? 0
                //                let minute = components.minute ?? 0
                NotificationsManager.shared.addNotifications(id: period.id ?? "id", date: currClass?.startTime ?? Date(), day: period.day, courseCode: currClass?.courseCode ?? "Course Code", courseName: currClass?.courseName ?? "Course Name", location: currClass?.location ?? "Location")
            }
            
        }
        NotificationsManager.shared.getAllNotificationRequests()
        UserDefaults.standard.set(true, forKey: AuthService.notifsSetupKey)
        
    }
    
    func saveNotifSettingsToUserDefaults() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self.notifSettings) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: NotificationsViewModel.notifKey)
            print("user defaults for notifs set")
        }
    }
    
    func getNotifPrefs() {
        guard let notifData = UserDefaults.standard.data(forKey: NotificationsViewModel.notifKey) else {
            print("No notification settings stored")
            return
        }
        guard let notifArray = try? JSONDecoder().decode([NotificationsSettingsModel].self, from: notifData) else {
            print("Couldn't decode data")
            return
        }
        self.notifSettings = notifArray
        print("notifs: \(self.notifSettings)")
        print("user defaults: \(notifArray)")
    }
}
