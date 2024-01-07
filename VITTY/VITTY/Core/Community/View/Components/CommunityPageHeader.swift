//
//  CommunityPageHeader.swift
//  VITTY
//
//  Created by Chandram Dutta on 04/01/24.
//

import SwiftUI

struct CommunityPageHeader: View {
	@State private var isAddFriendsViewPresented = false
	@EnvironmentObject private var authState: AuthService
	@Environment(FriendRequestViewModel.self) private var friendRequestViewModel
	@Environment(CommunityPageViewModel.self) private var communityPageViewModel

	var body: some View {
		HStack {
			Text("Community")
			Spacer()
			if !(friendRequestViewModel.error) && !(friendRequestViewModel.loading) {

				Text("\(friendRequestViewModel.requests.count) req")
					.font(Font.custom("Poppins-Regular", size: 12))
					.padding(4)
					.foregroundStyle(.white)
					.background(.red)
					.clipShape(Capsule())
					.onTapGesture {
						isAddFriendsViewPresented.toggle()
					}

			}
			Button(action: {
				isAddFriendsViewPresented.toggle()
			}) {
				Image(systemName: "person.fill.badge.plus")
			}
		}
		.onAppear {
			friendRequestViewModel.fetchFriendRequests(
				from: URL(string: "\(APIConstants.base_url)/api/v2/requests/")!,
				authToken: authState.token,
				loading: true
			)
		}
		.font(Font.custom("Poppins-Bold", size: 22))
		.foregroundColor(Color.white)
		.fullScreenCover(
			isPresented: $isAddFriendsViewPresented,
			onDismiss: {
				communityPageViewModel.fetchData(
					from: "\(APIConstants.base_url)/api/v2/friends/\(authState.username)/",
					token: authState.token,
					loading: true
				)
			},
			content: AddFriendsView.init
		)
	}
}

#Preview {
	CommunityPageHeader()
}
