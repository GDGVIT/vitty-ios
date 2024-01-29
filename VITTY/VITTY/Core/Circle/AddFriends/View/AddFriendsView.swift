//
//  AddFriendsView.swift
//  VITTY
//
//  Created by Chandram Dutta on 04/01/24.
//

import SwiftUI

struct AddFriendsView: View {

	@EnvironmentObject private var authState: AuthViewModel
	@Environment(SuggestedFriendsViewModel.self) private var suggestedFriendsViewModel
	@Environment(FriendRequestViewModel.self) private var friendRequestViewModel

	var body: some View {
		Group {
			ZStack {
				VStack(alignment: .center) {
					AddFriendsHeader()
					if !suggestedFriendsViewModel.suggestedFriends.isEmpty
						|| !friendRequestViewModel.requests.isEmpty
					{
						VStack(alignment: .leading) {
							if !friendRequestViewModel.requests.isEmpty {
								Text("Friend Requests")
									.font(Font.custom("Poppins-Regular", size: 14))
									.foregroundColor(Color.vprimary)
									.padding(.top)
									.padding(.horizontal)
								FriendRequestView()
									.padding(.horizontal)
							}
							if !suggestedFriendsViewModel.suggestedFriends.isEmpty {
								Text("Suggested Friends")
									.font(Font.custom("Poppins-Regular", size: 14))
									.foregroundColor(Color.vprimary)
									.padding(.top)
									.padding(.horizontal)
								SuggestedFriendsView()
									.padding(.horizontal)

							}
							Spacer()
						}
					}
					else {
						Spacer()
						Text("Request and Suggestions")
							.multilineTextAlignment(.center)
							.font(Font.custom("Poppins-SemiBold", size: 18))
							.foregroundColor(Color.white)
						Text("Your friend requests and suggested friends will be shown here")
							.multilineTextAlignment(.center)
							.font(Font.custom("Poppins-Regular", size: 12))
							.foregroundColor(Color.white)
						Spacer()
					}
				}
				.padding()
			}
			.padding(.top)
			.background(
				Image(
					suggestedFriendsViewModel.suggestedFriends.isEmpty
						&& friendRequestViewModel.requests.isEmpty ? "HomeNoClassesBG" : "HomeBG"
				)
				.resizable()
				.scaledToFill()
				.edgesIgnoringSafeArea(.all)
			)
		}
		.onAppear {
			suggestedFriendsViewModel.fetchData(
				from: "\(APIConstants.base_url)/api/v2/users/suggested/",
				token: authState.token,
				loading: true
			)
		}
	}
}
