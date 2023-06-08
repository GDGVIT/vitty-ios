//
//  CustomNotificationButton.swift
//  VITTY
//
//  Created by Ananya George on 1/25/22.
//

import SwiftUI

struct CustomNotificationButton: View {
    @Binding var enabled: Bool
    var dayoftheweek: Int
    var timetable: [String:[Classes]]
    var period: Int
    var body: some View {
        Button(action: {
            print("notif button for \(dayoftheweek) \(period)")
            print(enabled)
           enabled.toggle()
        }, label: {
            CustomNotificationsLabel(dayoftheweek: dayoftheweek, timetable: timetable, period: period)
        })
    }
}

//struct CustomNotificationButton_Previews: PreviewProvider {
//    static var previews: some View {
//        CustomNotificationButton()
//    }
//}
