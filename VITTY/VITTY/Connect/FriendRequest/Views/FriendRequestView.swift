//
//  FriendRequestView.swift
//  VITTY
//
//  Created by Chandram Dutta on 07/01/24.
//

import SwiftUI

struct FriendRequestView: View {

	@Environment(AuthViewModel.self) private var authViewModel
	@Environment(FriendRequestViewModel.self) private var friendRequestViewModel

	var body: some View {
		NavigationStack {
			ZStack {
				BackgroundView()
				VStack(alignment: .leading) {
					if !friendRequestViewModel.loading {
						List(friendRequestViewModel.requests, id: \.username) { friend in
							FriendReqCard(friend: friend)
								.padding(.bottom)
								.listRowBackground(
									RoundedRectangle(cornerRadius: 15)
										.fill(Color("Secondary"))
										.padding(.bottom)
								)
								.listRowSeparator(.hidden)
						}
						.listStyle(.plain)
						.scrollContentBackground(.hidden)
						.refreshable {
							friendRequestViewModel.fetchFriendRequests(
								from: URL(string: "\(APIConstants.base_url)requests/")!,
								authToken: authViewModel.loggedInBackendUser?.token ?? "",
								loading: false
							)
						}
					}

				}
				.padding(.horizontal)
			}
			.navigationTitle("Friend Requests")
		}
	}
}
