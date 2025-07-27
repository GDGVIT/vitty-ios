//
//  Friends.swift
//  VITTY
//
//  Created by Rujin Devkota on 2/27/25.
//
import SwiftUI

struct FriendsView: View {
    @State private var searchText = ""
    @State private var selectedFilterOption = 0
    @State private var showingUnfriendAlert = false
    @State private var showingActionAlert = false
    @State private var alertMessage = ""
    @State private var selectedFriend: Friend?
    
    @Environment(CommunityPageViewModel.self) private var communityPageViewModel
    @Environment(AuthViewModel.self) private var authViewModel

    private let filterOptions = ["All", "Available", "Ghosted"]
    
    var body: some View {
        ZStack {
            VStack(spacing: 12) {
                Spacer().frame(height: 8)
                
                SearchBar(searchText: $searchText)
                Spacer().frame(height: 8)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(0..<filterOptions.count, id: \.self) { index in
                            FilterPill(
                                title: filterOptions[index],
                                isSelected: selectedFilterOption == index
                            )
                            .onTapGesture {
                                selectedFilterOption = index
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
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
                            matchesFilter = true
                        case 1:
                            matchesFilter = friend.currentStatus.status == "free" &&
                                          !communityPageViewModel.isGhosted(friend.username)
                        case 2:
                            matchesFilter = communityPageViewModel.isGhosted(friend.username)
                        default:
                            matchesFilter = true
                        }
                        
                        return matchesSearch && matchesFilter
                    }
                    
                    if filteredFriends.isEmpty {
                        Spacer()
                        VStack(spacing: 5) {
                            Text(getEmptyStateMessage())
                                .font(Font.custom("Poppins-Regular", size: 16))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            
                            if selectedFilterOption == 2 && searchText.isEmpty {
                                Text("Tap on a friend's menu to make them alive again")
                                    .font(Font.custom("Poppins-Regular", size: 12))
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 4)
                            }
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            VStack(spacing: 10) {
                                ForEach(filteredFriends, id: \.username) { friend in
                                    FriendRow(
                                        friend: friend,
                                        showingUnfriendAlert: $showingUnfriendAlert,
                                        showingActionAlert: $showingActionAlert,
                                        alertMessage: $alertMessage,
                                        selectedFriend: $selectedFriend
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                        .safeAreaPadding(.bottom, 100)
                    }
                }
            }
            .onTapGesture {
                communityPageViewModel.dismissAllMenus()
            }
            
            if showingUnfriendAlert, let friend = selectedFriend {
                UnfriendAlert(
                    friendName: cleanName(friend.name),
                    onCancel: {
                        showingUnfriendAlert = false
                        selectedFriend = nil
                    },
                    onUnfriend: {
                        showingUnfriendAlert = false
                        if let selectedFriend = selectedFriend,
                           let friendRow = getFriendRow(for: selectedFriend) {
                            friendRow.unfriendAction()
                        }
                        selectedFriend = nil
                    }
                )
                .transition(.scale.combined(with: .opacity))
                .zIndex(1000)
            }
            
            if showingActionAlert {
                ActionResultAlert(
                    message: alertMessage,
                    onDismiss: {
                        showingActionAlert = false
                        alertMessage = ""
                    }
                )
                .transition(.scale.combined(with: .opacity))
                .zIndex(1000)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showingUnfriendAlert)
        .animation(.easeInOut(duration: 0.3), value: showingActionAlert)
        .refreshable {
            communityPageViewModel.refreshAllDataWithActiveCheck(
                token: authViewModel.loggedInBackendUser?.token ?? "",
                username: authViewModel.loggedInBackendUser?.username ?? ""
            )
        }
        .onAppear {
            communityPageViewModel.initializeGhostState()
            
            if !communityPageViewModel.hasInitialActiveFriendsFetch {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    communityPageViewModel.fetchActiveFriends(
                        token: authViewModel.loggedInBackendUser?.token ?? ""
                    )
                }
            }
        }
    }
    
    private func getEmptyStateMessage() -> String {
        if !searchText.isEmpty {
            switch selectedFilterOption {
            case 0: return "No friends match your search"
            case 1: return "No available friends match your search"
            case 2: return "No ghosted friends match your search"
            default: return "No friends match your search"
            }
        } else {
            switch selectedFilterOption {
            case 0: return "You don't have any friends yet"
            case 1: return "No friends are currently available"
            case 2: return "You haven't ghosted any friends"
            default: return "You don't have any friends yet"
            }
        }
    }

    private func cleanName(_ fullName: String) -> String {
        let pattern = "\\b\\d{2}[A-Z]+\\d+\\b"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        
        let range = NSRange(location: 0, length: fullName.utf16.count)
        let cleanedName = regex?.stringByReplacingMatches(in: fullName, options: [], range: range, withTemplate: "").trimmingCharacters(in: .whitespaces) ?? fullName
        
        return cleanedName
    }

    private func getFriendRow(for friend: Friend) -> FriendRow? {
        return nil
    }
}
