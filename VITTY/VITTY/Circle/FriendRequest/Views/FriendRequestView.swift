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
		VStack(alignment: .center) {
			if friendRequestViewModel.loading {
				Spacer()
				ProgressView()
				Spacer()
			}
			else {
				List(friendRequestViewModel.requests, id: \.username) { friend in
					FriendReqCard(friend: friend)
						.padding(.bottom)
						.listRowBackground(
							RoundedRectangle(cornerRadius: 15).fill(Color.theme.secondaryBlue)
								.padding(.bottom)
						)
						.listRowSeparator(.hidden)
				}
				.listStyle(.plain)
				.scrollContentBackground(.hidden)
				.refreshable {
					friendRequestViewModel.fetchFriendRequests(
						from: URL(string: "\(APIConstants.base_url)/api/v2/requests/")!,
						authToken: authViewModel.appUser?.token ?? "",
						loading: false
					)

				}
				Spacer()
			}

		}
	}
}
