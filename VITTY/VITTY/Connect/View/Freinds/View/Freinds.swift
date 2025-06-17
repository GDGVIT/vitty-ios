//
//  Freinds.swift
//  VITTY
//
//  Created by Rujin Devkota on 2/27/25.
//
import SwiftUI
struct FriendsView: View {
    @State private var searchText = ""
    @State private var selectedFilterOption = 0
    @Environment(CommunityPageViewModel.self) private var communityPageViewModel
    @Environment(AuthViewModel.self) private var authViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            Spacer().frame(height: 8)
            
            SearchBar(searchText: $searchText)
            Spacer().frame(height: 8)
            // Filter pills - always visible
            HStack {
                FilterPill(title: "Available", isSelected: selectedFilterOption == 0)
                    .onTapGesture {
                        selectedFilterOption = 0
                    }
                FilterPill(title: "View All", isSelected: selectedFilterOption == 1)
                    .onTapGesture {
                        selectedFilterOption = 1
                    }
                Spacer()
            }
            .padding(.horizontal)
            Spacer().frame(height: 7)
            
            // Conditional content based on state
            if communityPageViewModel.errorFreinds {
                Spacer()
                VStack(spacing: 5) {
                    Text("No Friends?")
                        .multilineTextAlignment(.center)
                        .font(Font.custom("Poppins-SemiBold", size: 18))
                        .foregroundColor(Color.white)
                    Text("Add your friends and see their timetable")
                        .multilineTextAlignment(.center)
                        .font(Font.custom("Poppins-Regular", size: 12))
                        .foregroundColor(Color.white)
                }
                Spacer()
            } else if communityPageViewModel.loadingFreinds {
                Spacer()
                ProgressView()
                Spacer()
            } else {
                // Filter friends based on search text
                let filteredFriends = communityPageViewModel.friends.filter { friend in
                    if searchText.isEmpty {
                        return true
                    } else {
                        return friend.username.localizedCaseInsensitiveContains(searchText) ||
                        (friend.name.localizedCaseInsensitiveContains(searchText) ?? false)
                    }
                }
                
                if filteredFriends.isEmpty {
                    Spacer()
                    Text("No friends match your search")
                        .font(Font.custom("Poppins-Regular", size: 16))
                        .foregroundColor(.white)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(filteredFriends, id: \.username) { friend in
                                NavigationLink(destination: TimeTableView(friend: friend)) {
                                    FriendRow(friend: friend)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .safeAreaPadding(.bottom, 100)
                    
                }
            }
        }.refreshable {
            communityPageViewModel.fetchFriendsData(
                from: "\(APIConstants.base_url)friends/\(authViewModel.loggedInBackendUser?.username ?? "")/",
                token: authViewModel.loggedInBackendUser?.token ?? "",
                loading: true
            )
        }
    }
}
