//
//  ContentView.swift
//  VITTY
//
//  Created by Ananya George on 11/7/21.
//

import SwiftUI

struct ContentView: View {

	@State private var communityPageViewModel = CommunityPageViewModel()
	@State private var suggestedFriendsViewModel = SuggestedFriendsViewModel()
	@State private var friendRequestViewModel = FriendRequestViewModel()
	@State var authViewModel: AuthViewModel = AuthViewModel()
	@StateObject var timeTableVM: TimetableViewModel = TimetableViewModel()
	//	@StateObject var localNotificationsManager = NotificationsManager()
	//	@StateObject var notifVM = NotificationsViewModel()
	var body: some View {
		NavigationView {
			if authViewModel.loggedInFirebaseUser != nil {
				if authViewModel.appUser == nil {
					InstructionView()
				} else {
					HomeView()
				}
			}
			else {
				LoginView()
			}
		}
		//        .animation(.default)
		//		.onAppear(perform: NotificationsManager.shared.getNotificationSettings)
		//		.onChange(of: NotificationsManager.shared.authStatus) { authorizationStat in
		//			switch authorizationStat {
		//				case .notDetermined:
		//					NotificationsManager.shared.requestPermission()
		//					break
		//				default:
		//					break
		//			}
		//		}
		//		.onReceive(
		//			NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
		//		) { _ in
		//			NotificationsManager.shared.getNotificationSettings()
		//		}
		.environment(authViewModel)
		.environmentObject(timeTableVM)
		//		.environmentObject(notifVM)
		.environment(communityPageViewModel)
		.environment(suggestedFriendsViewModel)
		.environment(friendRequestViewModel)
	}
}

#Preview {
	ContentView()
}
