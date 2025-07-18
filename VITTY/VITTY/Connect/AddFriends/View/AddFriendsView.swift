//
//  AddFriendsView.swift
//  VITTY
//
//  Created by Chandram Dutta on 04/01/24.
//
import SwiftUI

struct AddFriendsView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(SuggestedFriendsViewModel.self) private var suggestedFriendsViewModel
    @Environment(RequestsViewModel.self) private var friendRequestsViewModel
    @Environment(CommunityPageViewModel.self) private var communityViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var isSearchViewPresented = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()
                
                VStack(alignment: .leading, spacing: 0) {
                    headerView
                    
                    if !friendRequestsViewModel.friendRequests.isEmpty
                    || !suggestedFriendsViewModel.suggestedFriends.isEmpty {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 20) {
                               
                                if !friendRequestsViewModel.friendRequests.isEmpty {
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("Friend Requests")
                                            .font(Font.custom("Poppins-SemiBold", size: 16))
                                            .foregroundColor(Color("Accent"))
                                            .padding(.horizontal, 20)
                                        
                                        LazyVStack(spacing: 8) {
                                            ForEach(friendRequestsViewModel.friendRequests) { request in
                                                FriendRequestCard(request: request)
                                                    .padding(.horizontal, 4)
                                            }
                                        }
                                    }
                                }
                                
                              
                                if !suggestedFriendsViewModel.suggestedFriends.isEmpty {
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("Suggested Friends")
                                            .font(Font.custom("Poppins-SemiBold", size: 16))
                                            .foregroundColor(Color("Accent"))
                                            .padding(.horizontal, 20)
                                        
                                        SuggestedFriendsView()
                                            .padding(.horizontal, 20)
                                    }
                                }
                            }
                            .padding(.top, 20)
                        }
                    } else {
                       
                        VStack(spacing: 20) {
                            Spacer()
                            
                            Image(systemName: "person.2.badge.plus")
                                .font(.system(size: 30))
                                .foregroundColor(Color("Accent"))
                            
                            Text("Requests and Suggestions")
                                .multilineTextAlignment(.center)
                                .font(Font.custom("Poppins-SemiBold", size: 20))
                                .foregroundColor(Color.white)
                            
                            Text("Your friend requests and suggested friends will appear here. Tap the search icon to find friends manually.")
                                .multilineTextAlignment(.center)
                                .font(Font.custom("Poppins-Regular", size: 14))
                                .foregroundColor(Color.white.opacity(0.8))
                                .padding(.horizontal, 40)
                                .lineLimit(nil)
                            
                            Spacer()
                        }
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
        }
        .onAppear {
           
            friendRequestsViewModel.fetchFriendRequests(
                token: authViewModel.loggedInBackendUser?.token ?? ""
            )
            
           
            suggestedFriendsViewModel.fetchData(
                from: "\(APIConstants.base_url)users/suggested/",
                token: authViewModel.loggedInBackendUser?.token ?? "",
                loading: true
            )
        }
    }
    
    private var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(Color("Accent"))
                    .font(.title2)
            }
            Spacer()
            Text("Add Friends")
                .foregroundColor(.white)
                .font(.system(size: 25, weight: .bold))
            Spacer()
            Button(action: {
                isSearchViewPresented = true
            }) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white)
                    .font(.title2)
            }
            .navigationDestination(
                isPresented: $isSearchViewPresented,
                destination: { SearchView() }
            )
        }
        .padding()
    }
}
