//
//  HomePage.swift
//  VITTY
//
//  Created by Ananya George on 12/23/21.
//

import SwiftUI

struct HomePage: View {

    @State var tabSelected: Int = Date.convertToMondayWeek()
    @State var goToSettings: Bool = false
    @State var showLogout: Bool = false
    
    @EnvironmentObject var timetableViewModel: TimetableViewModel
    @EnvironmentObject var authVM: AuthService
    @EnvironmentObject var notifVM: NotificationsViewModel
    
    @StateObject var homePageVM =  HomePageViewModel()
    
    @StateObject var RemoteConf = RemoteConfigManager.sharedInstance
    @AppStorage("examMode") var examModeOn: Bool = false
    @AppStorage(AuthService.notifsSetupKey) var notifsSetup = false
    
    var body: some View {
        Group {
            ZStack {
                VStack {
                    navBarItems()
                    
                    List{
                        ForEach(timetableViewModel.timetable.keys.sorted(), id: \.self){day in
                            Section(header: Text(day).foregroundStyle(Color.white)) {
                                ForEach(timetableViewModel.timetable[day] ?? [], id: \.self){classes in

                                    ClassCards(classInfo: classes)
                                        .listRowBackground(Color.clear)
                                        .listRowSeparator(.hidden)
                                    
                                    
                                }
                            }
                            
                        }
                    }
                    .background(content: {
                        Color.clear
                    })
                    
                    .listStyle(.plain)
                    
//                    daysRow()
//                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    
                    
                    NavigationLink(destination: SettingsView().environmentObject(timetableViewModel).environmentObject(authVM).environmentObject(notifVM), isActive: $goToSettings) {
                        EmptyView()
                    }
                    if examModeOn {
                        ExamHolidayMode()
                    }
                }
                .blur(radius: showLogout ? 10 : 0)
                .onAppear {
                    tabSelected = Date.convertToMondayWeek()
                }
                if showLogout {
                    LogoutPopup(showLogout: $showLogout).environmentObject(authVM)
                }
            }

            .padding(.top)
            .background(Image(timetableViewModel.timetable[TimetableViewModel.daysOfTheWeek[tabSelected]]?.isEmpty ?? false ? "HomeNoClassesBG" : "HomeBG").resizable().scaledToFill().edgesIgnoringSafeArea(.all))
            .onAppear {
                timetableViewModel.getTimeTable(token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6InByYXNoYW5uYS5yYWpiaGFuZGFyaTNAZ21haWwuY29tIiwicm9sZSI6Im5vcm1hbCIsInVzZXJuYW1lIjoicHJhc2hhbm5hdGVzdCJ9.JULv80sjDUdC2SAgpepRcBBZHTsDjisN1xtNZp7-jVs", username: "prashannatest")
                
                
//                timetableViewModel.getData {
//                    if !notifsSetup {
//                        notifVM.setupNotificationPreferences(timetable: timetableViewModel.timetable)
//                        print("Notifications set up")
//                    }
//                    
//                }
                print("tabSelected: \(tabSelected)")
                //            LocalNotificationsManager.shared.getAllNotificationRequests()
                print("calling update notifs from homepage")
                notifVM.updateNotifs(timetable: timetableViewModel.timetable)
                timetableViewModel.updateClassCompleted()
                notifVM.getNotifPrefs()
                
                print(goToSettings)
                print("remote config settings \(RemoteConf.onlineMode)")
            }
        .animation(.default)
        }
        .slideInView(isActive: $homePageVM.isPresented, edge: .trailing, content: {
            MenuView()
                .environmentObject(authVM)
                .environmentObject(timetableViewModel)
                .environmentObject(notifVM)
        })
    }
}

struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage()
            .environmentObject(AuthService())
            .environmentObject(TimetableViewModel())
            .environmentObject(NotificationsViewModel())
    }
}

//MARK: Extension
extension HomePage{
    private func navBarItems() -> some View{
        VStack(alignment:.leading) {
            HomePageHeader(goToSettings: $goToSettings, showLogout: $showLogout)
                .environmentObject(homePageVM)
                .padding()
            HomeTabBarView(tabSelected: $tabSelected)
        }
    }
    
    private func daysRow() -> some View{
        return TabView(selection: $tabSelected) {
            ForEach(0..<7) { tabSel in
                if let selectedTT = timetableViewModel.timetable[TimetableViewModel.daysOfTheWeek[tabSel]] {
                    TimeTableScrollView(selectedTT: selectedTT, tabSelected: $tabSelected).environmentObject(timetableViewModel)
                    
                }
                
            }
        }
    }
}
