//
//  CustomNotificationsView.swift
//  VITTY
//
//  Created by Ananya George on 1/24/22.
//

import SwiftUI

struct CustomNotificationsLabel: View {
    var dayoftheweek: Int
    var timetable: [String:[Classes]]
    var period: Int
    var body: some View {
        
        VStack(alignment: .leading) {
            Text(timetable[TimetableViewModel.daysOfTheWeek[dayoftheweek]]?[period].courseName ?? "Course Name")
                .foregroundColor(.white)
            HStack {
                Text(timetable[TimetableViewModel.daysOfTheWeek[dayoftheweek]]?[period].courseCode ?? "Course Code")
                Text(timetable[TimetableViewModel.daysOfTheWeek[dayoftheweek]]?[period].courseType ?? "Type")
            }
            Text(timetable[TimetableViewModel.daysOfTheWeek[dayoftheweek]]?[period].startTime ?? Date(), style: .time)
        }
        .padding(.horizontal)
        .font(.custom("Poppins-Regular", size: 14))
        .foregroundColor(Color.vprimary)
    }
}

//struct CustomNotificationsView_Previews: PreviewProvider {
//    static var previews: some View {
//        CustomNotificationsView()
//    }
//}
