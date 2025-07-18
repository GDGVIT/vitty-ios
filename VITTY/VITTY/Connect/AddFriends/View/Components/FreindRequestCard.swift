//
//  FreindRequestCard.swift
//  VITTY
//
//  Created by Rujin Devkota on 7/4/25.
//

import SwiftUI
import OSLog

struct FriendRequestCard: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(RequestsViewModel.self) private var friendRequestsViewModel
    @Environment(SuggestedFriendsViewModel.self) private var suggestedFriendsViewModel
    @Environment(CommunityPageViewModel.self) private var communityViewModel
    
    let request: FriendRequest
    @State private var isAccepting = false
    @State private var isDeclining = false
    @State private var isProcessed = false
    
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: FriendRequestCard.self)
    )
    
    var body: some View {
        if !isProcessed {
            HStack {
                
                UserImage(url: request.from.picture, height: 48, width: 48)
                
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(request.from.name)
                        .font(Font.custom("Poppins-SemiBold", size: 15))
                        .foregroundColor(Color.white)
                    
                    Text("@\(request.from.username)")
                        .font(Font.custom("Poppins-Regular", size: 14))
                        .foregroundColor(Color("Accent"))
                    
                    if request.from.mutualFriendsCount > 0 {
                        Text("\(request.from.mutualFriendsCount) mutual friends")
                            .font(Font.custom("Poppins-Regular", size: 12))
                            .foregroundColor(Color.white.opacity(0.7))
                    }
                }
                
                Spacer()
                
            
                HStack(spacing: 12) {
                    
                    Button(action: {
                        declineRequest()
                    }) {
                        if isDeclining {
                            ProgressView()
                                .scaleEffect(0.8)
                                .frame(width: 24, height: 24)
                        } else {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .medium))
                        }
                    }
                    .frame(width: 36, height: 36)
                    .background(Color.red.opacity(0.2))
                    .foregroundColor(.red)
                    .cornerRadius(18)
                    .disabled(isDeclining || isAccepting)
                    
                  
                    Button(action: {
                        acceptRequest()
                    }) {
                        if isAccepting {
                            ProgressView()
                                .scaleEffect(0.8)
                                .frame(width: 24, height: 24)
                        } else {
                            Image(systemName: "checkmark")
                                .font(.system(size: 16, weight: .medium))
                        }
                    }
                    .frame(width: 36, height: 36)
                    .background(Color("Accent").opacity(0.2))
                    .foregroundColor(Color("Accent"))
                    .cornerRadius(18)
                    .disabled(isAccepting || isDeclining)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
        }
    }
    
    private func acceptRequest() {
        guard !isAccepting else { return }
        
        isAccepting = true
        
        Task {
            let success = await friendRequestsViewModel.acceptFriendRequest(
                username: request.from.username,
                token: authViewModel.loggedInBackendUser?.token ?? ""
            )
            
            await MainActor.run {
                if success {
                    isProcessed = true
                    logger.info("Friend request accepted successfully")
                    
                  
                    suggestedFriendsViewModel.fetchData(
                        from: "\(APIConstants.base_url)users/suggested/",
                        token: authViewModel.loggedInBackendUser?.token ?? "",
                        loading: false
                    )
                } else {
                    logger.error("Failed to accept friend request")
                }
                isAccepting = false
            }
            communityViewModel.fetchFriendsData(from: "\(APIConstants.base_url)friends/\(authViewModel.loggedInBackendUser?.username ?? "")/", token: authViewModel.loggedInBackendUser?.token ?? "")
        }
    }
    
    private func declineRequest() {
        guard !isDeclining else { return }
        
        isDeclining = true
        
        Task {
            let success = await friendRequestsViewModel.declineFriendRequest(
                username: request.from.username,
                token: authViewModel.loggedInBackendUser?.token ?? ""
            )
            
            await MainActor.run {
                if success {
                    isProcessed = true
                    logger.info("Friend request declined successfully")
                } else {
                    logger.error("Failed to decline friend request")
                }
                isDeclining = false
            }
        }
    }
}
