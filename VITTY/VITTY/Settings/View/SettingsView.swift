//
//  SettingsView.swift
//  VITTY
//
//  Created by Ananya George on 12/24/21.
//

import SwiftUI

struct SettingsView: View {
//	@AppStorage("examMode") var examModeOn: Bool = false

	var githubURL = URL(string: "https://github.com/GDGVIT/vitty-ios")
	var gdscURL = URL(string: "https://dscvit.com/")

	@Environment(AuthViewModel.self) private var authState
	@EnvironmentObject var ttVM: TimetableViewModel
//	@EnvironmentObject var notifVM: NotificationsViewModel

	@Environment(\.presentationMode) var presentationMode

	var body: some View {
		VStack(alignment: .leading) {

			HStack {
				Spacer()
				Image(systemName: "xmark")
					.foregroundColor(.white)
					.padding(.trailing)
					.onTapGesture {
						presentationMode.wrappedValue.dismiss()
					}
			}

//			turnOffNotificationsToggle()
//				.padding(.vertical)

			aboutSection()

			Spacer()
		}
		.padding()
		.font(.custom("Poppins-Regular", size: 16))
		.foregroundColor(.white)
		.background(Image("HomeBG").resizable().scaledToFill().edgesIgnoringSafeArea(.all))
		.navigationTitle("Settings")
		.navigationBarTitleDisplayMode(.inline)
//		.onChange(of: examModeOn) { examMode in
//			if examMode {
//				print("exam mode is on")
//				NotificationsManager.shared.removeAllNotificationRequests()
//			}
//			else {
//				notifVM.updateNotifs(timetable: ttVM.timetable)
//			}
//		}
//		.onAppear {
//			notifVM.updateNotifs(timetable: ttVM.timetable)
//		}
	}
}

struct SettingsView_Previews: PreviewProvider {
	static var previews: some View {
		SettingsView()
			.environment(AuthViewModel())
			.environmentObject(TimetableViewModel())
//			.environmentObject(NotificationsViewModel())
	}
}

extension SettingsView {
	// MARK: Notification Toggle

	private func turnOffNotificationsToggle() -> some View {
		VStack(alignment: .leading) {
			Text("Notifications")
				.font(.custom("Poppins-SemiBold", size: 18))

			if NotificationsManager.shared.authStatus == .denied {
				HStack {
					VStack(alignment: .leading) {
						Text("Notifications turned off")
							.font(.custom("Poppins-Medium", size: 16))
						Text("Go to Settings to enable notifications!")
							.font(.custom("Poppins-Regular", size: 14))
							.foregroundColor(Color.vprimary)
					}
					Spacer()
					Image(systemName: "chevron.right")
				}
				.onTapGesture {
					if let url = URL(string: UIApplication.openSettingsURLString),
						UIApplication.shared.canOpenURL(url)
					{
						UIApplication.shared.open(url, options: [:], completionHandler: nil)
					}
				}
			}
//			Toggle(isOn: $examModeOn) {
//				VStack(alignment: .leading) {
//					Text("Exam/Holiday Mode")
//						.font(.custom("Poppins-Medium", size: 16))
//					Text("Turns off class notifications")
//						.font(.custom("Poppins-Regular", size: 14))
//						.foregroundColor(Color.vprimary)
//				}
//			}
		}
	}

	// MARK: About

	private func aboutSection() -> some View {
		VStack(alignment: .leading) {
			Text("About")
				.font(.custom("Poppins-SemiBold", size: 18))

			HStack(spacing: 5) {
				Image("github-icon")
					.resizable()
					.scaledToFit()
				Text("GitHub Repository")
			}
			.frame(height: 35)
			.onTapGesture {
				if let url = githubURL {
					UIApplication.shared.open(url)
				}
			}
			HStack(spacing: 5) {
				Image("gdsc-logo")
					.resizable()
					.scaledToFit()
					.frame(width: 35)

				Text("GDSC VIT")
					.padding(.leading, 10)
			}
			.padding(.leading, 10)
			.frame(height: 35)
			.onTapGesture {
				if let url = gdscURL {
					UIApplication.shared.open(url)
				}
			}
		}
	}
}
