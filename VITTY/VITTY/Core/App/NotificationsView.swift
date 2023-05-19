//
//  NotificationsView.swift
//  VITTY
//
//  Created by Ananya George on 1/21/22.
//

// TODO: fix custom notifications

import SwiftUI

struct NotificationsView: View {
    @EnvironmentObject var authVM: AuthService
    @EnvironmentObject var ttVM: TimetableViewModel
//    @StateObject var notifVM = NotificationsViewModel.shared
    @Binding var notifPrefs: [NotificationsSettingsModel]
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                ForEach(0..<7, id: \.self) { day in
                    if !ttVM.timetable[TimetableViewModel.daysOfTheWeek[day]]!.isEmpty {
                        VStack(alignment: .leading) {
                            Text(TimetableViewModel.daysOfTheWeek[day].capitalized)
                                .font(.custom("Poppins-Semibold", size: 16))
                            CustomNotifsListView(notifPrefs: $notifPrefs, timetable: ttVM.timetable, day: day)
                        }
                    }
                }
            }
        }
        
        .padding()
        .font(.custom("Poppins-Regular", size: 16))
        .foregroundColor(.white)
        .background(Image("HomeBG").resizable().scaledToFill().edgesIgnoringSafeArea(.all))
        //        .navigationBarHidden(true)
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("")
//        .onDisappear {
//            NotificationsViewModel.shared.updateNotifs(timetable: ttVM.timetable)
//        }
        
    }
}


//struct NotificationsView_Previews: PreviewProvider {
//    static var previews: some View {
//        NotificationsView()
//    }
//}
