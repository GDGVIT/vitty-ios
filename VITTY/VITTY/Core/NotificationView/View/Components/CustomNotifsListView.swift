//
//  CustomNotifsListView.swift
//  VITTY
//
//  Created by Ananya George on 1/25/22.
//

import SwiftUI

struct CustomNotifsListView: View {
//    @EnvironmentObject var notifVM: NotificationsViewModel
    @Binding var notifPrefs: [NotificationsSettingsModel]
    var timetable: [String:[Classes]]
    var day: Int
    var body: some View {
        ForEach($notifPrefs, id: \.id) { $notifsetting in
            if $notifsetting.wrappedValue.day == self.day+1 {
//                CustomNotificationButton(enabled: $notifsetting.enabled, dayoftheweek: day, timetable: timetable, period: $notifsetting.wrappedValue.period)
                
            
            
                            Toggle(isOn: $notifsetting.enabled, label: {
                                CustomNotificationsLabel(dayoftheweek: day, timetable: timetable, period: $notifsetting.wrappedValue.period)})
            }
        }
    }
}

//struct CustomNotifsListView_Previews: PreviewProvider {
//    static var previews: some View {
//        CustomNotifsListView()
//    }
//}
