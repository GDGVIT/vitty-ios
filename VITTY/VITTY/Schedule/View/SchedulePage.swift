//
//  HomePage.swift
//  VITTY
//
//  Created by Ananya George on 12/23/21.
//

import SwiftUI

struct SchedulePage: View {
	@State var tabSelected: Int = Date.convertToMondayWeek()
	@State var goToSettings: Bool = false
	@State var showLogout: Bool = false

	@EnvironmentObject var timetableViewModel: TimetableViewModel
	@Environment(AuthViewModel.self) private var authViewModel
	//	@EnvironmentObject var notifVM: NotificationsViewModel

	@StateObject var schedulePageVM = SchedulePageViewModel()

	@StateObject var RemoteConf = RemoteConfigManager.sharedInstance
	@AppStorage("examMode") var examModeOn: Bool = false
	//	@AppStorage(AuthViewModel.notifsSetupKey) var notifsSetup = false

	var body: some View {
		Group {
			ZStack {
				VStack {
					navBarItems()

					timeTableView()

					Spacer()

					NavigationLink(
						destination: SettingsView().environmentObject(timetableViewModel)
							.environment(authViewModel),
						//							.environmentObject(notifVM),
						isActive: $goToSettings
					) {
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
					LogoutPopup(showLogout: $showLogout).environment(authViewModel)
				}
			}

			.padding(.top)
			.background(
				Image(
					timetableViewModel.timetable[TimetableViewModel.daysOfTheWeek[tabSelected]]?
						.isEmpty ?? false ? "HomeNoClassesBG" : "HomeBG"
				)
				.resizable().scaledToFill().edgesIgnoringSafeArea(.all)
			)
			.onAppear {

				//				authViewModel.token =
				//					UserDefaults.standard.string(forKey: authViewModel.appUser?.token ?? ""Key) ?? "no token"
				//				authViewModel.username =
				//					UserDefaults.standard.string(forKey: AuthViewModel.userKey) ?? "no username"
				//
				//				var _ = print("token: ", authViewModel.token)
				//				var _ = print("username: ", authViewModel.username)
				//
				//				timetableViewModel.getTimeTable(token: authViewModel.token, username: authViewModel.username)

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
				//				/*notifVM*/.updateNotifs(timetable: timetableViewModel.timetable)
				timetableViewModel.updateClassCompleted()
				//				notifVM.getNotifPrefs()

				print(goToSettings)
				print("remote config settings \(RemoteConf.onlineMode)")
			}
		}
		.onChange(of: tabSelected) { newValue in
			print("Selected tab: \(newValue)")
		}

		.slideInView(
			isActive: $schedulePageVM.isPresented,
			edge: .trailing,
			content: {
				MenuView()
					.environment(authViewModel)
					.environmentObject(timetableViewModel)
				//					.environmentObject(notifVM)
			}
		)
	}
}

struct HomePage_Previews: PreviewProvider {
	static var previews: some View {
		SchedulePage()
			.environment(AuthViewModel())
			.environmentObject(TimetableViewModel())
		//			.environmentObject(NotificationsViewModel())
	}
}

// MARK: Extension

extension SchedulePage {
	private func navBarItems() -> some View {
		VStack(alignment: .leading) {
			SchedulePageHeader(
				goToSettings: $goToSettings,
				showLogout: $showLogout,
				url: authViewModel.appUser?.picture ?? ""
			)
			.environmentObject(schedulePageVM)
			.padding()
			ScheduleTabBarView(tabSelected: $tabSelected)
		}
	}

	func timeTableView() -> some View {
		ScrollView {
			ForEach(timetableViewModel.timetable.keys.sorted(), id: \.self) { day in
				ForEach(timetableViewModel.timetable[day]?.sorted() ?? [], id: \.self) { classes in
					if day.description.lowercased() == TimetableViewModel.daysOfTheWeek[tabSelected]
					{
						ClassCards(classInfo: classes)
							.listRowBackground(Color.clear)
							.listRowSeparator(.hidden)
					}
				}
			}
		}
	}

	private func daysRow() -> some View {
		return TabView(selection: $tabSelected) {
			ForEach(0..<7) { tabSel in
				if let selectedTT = timetableViewModel.timetable[
					TimetableViewModel.daysOfTheWeek[tabSel]
				] {
					TimeTableScrollView(selectedTT: selectedTT, tabSelected: $tabSelected)
						.environmentObject(timetableViewModel)
				}
			}
		}
	}
}
