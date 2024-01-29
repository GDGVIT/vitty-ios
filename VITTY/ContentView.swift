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
	@StateObject var authState: AuthService = AuthService()
	@StateObject var timeTableVM: TimetableViewModel = TimetableViewModel()
//	@StateObject var localNotificationsManager = NotificationsManager()
//	@StateObject var notifVM = NotificationsViewModel()
	var body: some View {
		NavigationView {
			if authState.loggedInUser != nil {
				InstructionsView()
					.navigationTitle("")
					.navigationBarHidden(true)
					.animation(.default, value: UUID())
				//                    .animation(.default)
			}
			else {
				SplashScreen()
					.navigationTitle("")
					.navigationBarHidden(true)
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
		.environmentObject(authState)
		.environmentObject(timeTableVM)
//		.environmentObject(notifVM)
		.environment(communityPageViewModel)
		.environment(suggestedFriendsViewModel)
		.environment(friendRequestViewModel)
	}
}

#Preview {
	ContentView(authState: AuthService())
}

//
//struct ContentView_Previews: PreviewProvider {
//	static var previews: some View {
//		ContentView(authState: AuthService())
//	}
//}
