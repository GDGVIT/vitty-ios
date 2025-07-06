//
//  Freinds.swift
//  VITTY
//
//  Created by Rujin Devkota on 2/27/25.

import SwiftUI

enum SheetType: Identifiable {
    case addCircleOptions
    case createGroup
    case joinGroup
    case groupRequests
    
    var id: Int {
        switch self {
        case .addCircleOptions: return 0
        case .createGroup: return 1
        case .joinGroup: return 2
        case .groupRequests: return 3
        }
    }
}



struct ConnectPage: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(CommunityPageViewModel.self) private var communityPageViewModel
    @Environment(FriendRequestViewModel.self) private var friendRequestViewModel
    @Environment(RequestsViewModel.self) private var requestsViewModel
    @State private var isShowingRequestView = false
    @State var isCircleView = false
    @State private var activeSheet: SheetType?
    @State private var showCircleMenu = false
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator
    @Binding var isCreatingGroup : Bool
    
    @State private var isAddFriendsViewPresented = false
    @State private var selectedTab = 0
    @State private var hasLoadedInitialData = false
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack(spacing: 0) {
                
                HStack {
                    AcademicsTabButton(title: "Friends", isActive: selectedTab == 0) {
                        selectedTab = 0
                        isCircleView = false
                    }
                    AcademicsTabButton(title: "Circles", isActive: selectedTab == 1) {
                        selectedTab = 1
                        isCircleView = true
                    }
                }
                .padding(.top,20)
              
                TabView(selection: $selectedTab) {
                    FriendsView()
                        .tag(0)
                    CirclesView(isCreatingGroup: $isCreatingGroup)
                        .tag(1)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            
            if isCircleView == false {
                Button(action: {
                    isShowingRequestView.toggle()
                }) {
                    ZStack {
                        
                        Image(systemName: requestsViewModel.friendRequests.isEmpty ? "person.fill.badge.plus" : "person.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 18))
                        
           
                        if !requestsViewModel.friendRequests.isEmpty {
                            ZStack {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 20, height: 20)
                                
                                Text("\(min(requestsViewModel.friendRequests.count, 99))")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                            }
                            .offset(x: 12, y: -12)
                        }
                    }
                }
                .navigationDestination(
                    isPresented: $isShowingRequestView,
                    destination: {
                        AddFriendsView()
                    }
                )
                .offset(x: UIScreen.main.bounds.width*0.4228, y: UIScreen.main.bounds.height*0.38901*(-1))
            } else {
                Button(action: {
                    showCircleMenu = true
                }) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.white)
                        .font(.system(size: 18))
                }
                .offset(x: UIScreen.main.bounds.width*0.4228, y: UIScreen.main.bounds.height*0.38901*(-1))
            }
        }
        .overlay(
            Group {
                if showCircleMenu {
                    ConnectCircleMenuView(
                        onCreateGroup: {
                            activeSheet = .createGroup
                        },
                        onJoinGroup: {
                            activeSheet = .joinGroup
                        },
                        onGroupRequests: {
                            activeSheet = .groupRequests
                        },
                        onCancel: {
                            showCircleMenu = false
                        }
                    )
                }
            }
        )
        .sheet(item: $activeSheet) { sheetType in
            switch sheetType {
            case .addCircleOptions:
                AddCircleOptionsView(activeSheet: $activeSheet)
            case .createGroup:
                CreateGroup(groupCode: .constant(""), token:authViewModel.loggedInBackendUser?.token ?? "",username: authViewModel.loggedInBackendUser?.username ?? "" )
            case .joinGroup:
                JoinGroup(groupCode: .constant(""))
            case .groupRequests:
                CircleRequestsView()
            }
        }.onChange(of: navigationCoordinator.shouldNavigateToCircles) { _, shouldNavigate in
            if shouldNavigate {
                selectedTab = 0
            }
            communityPageViewModel.fetchCircleData(
                from: "\(APIConstants.base_url)circles",
                token: authViewModel.loggedInBackendUser?.token ?? "",
                loading: true
            )
        }
        .onAppear {
            if navigationCoordinator.shouldNavigateToCircles {
                            selectedTab = 0
                        }
            let shouldShowLoading = !hasLoadedInitialData
            
        
          requestsViewModel.fetchFriendRequests(
                token: authViewModel.loggedInBackendUser?.token ?? "",
                loading: shouldShowLoading
            )
            
            
            if communityPageViewModel.friends.isEmpty || !hasLoadedInitialData {
                communityPageViewModel.fetchFriendsData(
                    from: "\(APIConstants.base_url)friends/\(authViewModel.loggedInBackendUser?.username ?? "")/",
                    token: authViewModel.loggedInBackendUser?.token ?? "",
                    loading: shouldShowLoading
                )
            }
            
            if communityPageViewModel.circles.isEmpty || !hasLoadedInitialData {
                communityPageViewModel.fetchCircleData(
                    from: "\(APIConstants.base_url)circles",
                    token: authViewModel.loggedInBackendUser?.token ?? "",
                    loading: shouldShowLoading
                )
            }
            
            if communityPageViewModel.circleRequests.isEmpty || !hasLoadedInitialData {
                friendRequestViewModel.fetchFriendRequests(
                    from: URL(string: "\(APIConstants.base_url)requests/")!,
                    authToken: authViewModel.loggedInBackendUser?.token ?? "",
                    loading: shouldShowLoading
                )
            }
            
            hasLoadedInitialData = true
        }
    }
}
struct ConnectCircleMenuView: View {
    let onCreateGroup: () -> Void
    let onJoinGroup: () -> Void
    let onGroupRequests: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 0) {
                Button(action: {
                    onCancel()
                    onCreateGroup()
                }) {
                    HStack {
                        Image("creategroup")
                            .resizable()
                            .frame(width: 24, height: 24)
                        Text("Create Group")
                            .font(.custom("Poppins-Regular", size: 16))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding()
                    .background(Color("Background"))
                }
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                
                Button(action: {
                    onCancel()
                    onJoinGroup()
                }) {
                    HStack {
                        Image("joingroup")
                            .resizable()
                            .frame(width: 24, height: 24)
                        Text("Join Group")
                            .font(.custom("Poppins-Regular", size: 16))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding()
                    .background(Color("Background"))
                }
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                
                Button(action: {
                    onCancel()
                    onGroupRequests()
                }) {
                    HStack {
                        Image(systemName: "person.badge.plus")
                            .foregroundColor(.white)
                        Text("Group Requests")
                            .font(.custom("Poppins-Regular", size: 16))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding()
                    .background(Color("Background"))
                }
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                
                Button(action: onCancel) {
                    Text("Cancel")
                        .font(.custom("Poppins-Regular", size: 16))
                        .foregroundColor(.gray)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color("Background"))
                }
            }
            .background(Color("Background"))
            .cornerRadius(16)
            .padding(.horizontal, 30)
            .transition(.scale.combined(with: .opacity))
            Spacer()
        }
        .background(Color.black.opacity(0.5).edgesIgnoringSafeArea(.all))
    }
}

struct AddCircleOptionsView: View {
    @Binding var activeSheet: SheetType?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color("Background")
            HStack(spacing: 40) {
                Button(action: {
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        activeSheet = .joinGroup
                    }
                }) {
                    VStack {
                        Image("joingroup")
                            .resizable()
                            .frame(width: 55, height: 55)
                        Text("Join Group")
                            .font(.system(size: 15))
                            .foregroundStyle(Color.white)
                    }
                }
                
                Button(action: {
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        activeSheet = .createGroup
                    }
                }) {
                    VStack {
                        Image("creategroup")
                            .resizable()
                            .frame(width: 55, height: 55)
                        Text("Create Group")
                            .font(.system(size: 15))
                            .foregroundStyle(Color.white)
                    }
                }
            }
            .padding(.top, 10)
        }
        .background(Color("Background"))
        .presentationDetents([.height(150)])
    }
}

struct FilterPill: View {
    let title: String
    let isSelected: Bool

    var body: some View {
        Text(title)
            .font(Font.custom("Poppins-Regular", size: 14))
            .foregroundColor(isSelected ? .white : .gray)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .stroke(Color("Accent"), lineWidth: isSelected ? 2 : 0)
                    .background(
                        Capsule()
                            .fill(Color("Secondary").opacity(0.5))
                    )
            )
    }
}
