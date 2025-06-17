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
	@State private var authViewModel = AuthViewModel()
    @State private var academicsViewModel = AcademicsViewModel()
    
	var body: some View {
		Group {
			if authViewModel.loggedInFirebaseUser != nil {
				if authViewModel.loggedInBackendUser == nil {
					InstructionView()
				}
				else {
					HomeView()
				}
			}
			else {
				LoginView()
			}
           
		}
		.environment(authViewModel)
		.environment(communityPageViewModel)
		.environment(suggestedFriendsViewModel)
		.environment(friendRequestViewModel)
        .environment(academicsViewModel)
        
	}
}

#Preview {
	ContentView()
}
