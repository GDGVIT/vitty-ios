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
                
                let filteredFriends = communityPageViewModel.friends.filter { friend in
                   
                    let matchesSearch: Bool
                    if searchText.isEmpty {
                        matchesSearch = true
                    } else {
                        matchesSearch = friend.username.localizedCaseInsensitiveContains(searchText) ||
                        (friend.name.localizedCaseInsensitiveContains(searchText) ?? false)
                    }
                    
                    
                    let matchesFilter: Bool
                    switch selectedFilterOption {
                    case 0:
                        matchesFilter = friend.currentStatus.status == "free"
                    case 1:
                        matchesFilter = true
                    default:
                        matchesFilter = true
                    }
                    
                    return matchesSearch && matchesFilter
                }
                
                if filteredFriends.isEmpty {
                    Spacer()
                    VStack(spacing: 5) {
                        if selectedFilterOption == 0 && !searchText.isEmpty {
                            Text("No available friends match your search")
                        } else if selectedFilterOption == 0 {
                            Text("No friends are currently available")
                        } else if !searchText.isEmpty {
                            Text("No friends match your search")
                        } else {
                            Text("You don't have any friends yet")
                        }
                    }
                    .font(Font.custom("Poppins-Regular", size: 16))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(filteredFriends, id: \.username) { friend in
                                NavigationLink(destination: TimeTableView(friend: friend,isFriendsTimeTable: true)) {
                                    FriendRow(friend: friend)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .safeAreaPadding(.bottom, 100)
                }
            }
        }
        .refreshable {
            
            communityPageViewModel.fetchFriendsData(
                from: "\(APIConstants.base_url)friends/\(authViewModel.loggedInBackendUser?.username ?? "")/",
                token: authViewModel.loggedInBackendUser?.token ?? "",
                loading: true
            )
        }
    }
}
