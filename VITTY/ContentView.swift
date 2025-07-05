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
    @State private var requestViewModel = RequestsViewModel()
   
    @State private var academicsViewModel = AcademicsViewModel()
    
    var body: some View {
        Group {
            // Check if backend user exists first
            if authViewModel.loggedInBackendUser != nil {
                HomeView()
            }
            // If no backend user but Firebase user exists, show instruction
            else if authViewModel.loggedInFirebaseUser != nil {
                InstructionView()
            }
            // If neither exists, show login
            else {
                LoginView()
            }
        }
        .environment(authViewModel)
        .environment(communityPageViewModel)
        .environment(suggestedFriendsViewModel)
        .environment(friendRequestViewModel)
        .environment(academicsViewModel)
        .environment(requestViewModel)
       
        
    }
}
