//
//  SuggestedFriendsView.swift
//  VITTY
//
//  Created by Chandram Dutta on 05/01/24.
//

import SwiftUI

struct SuggestedFriendsView: View {

	@Environment(AuthViewModel.self) private var authViewModel
	@Environment(SuggestedFriendsViewModel.self) private var suggestedFriendsViewModel

	var body: some View {
		VStack(alignment: .center) {
			if suggestedFriendsViewModel.loading {
				Spacer()
				ProgressView()
				Spacer()
			}
			else {
				List(suggestedFriendsViewModel.suggestedFriends, id: \.username) { friend in
					AddFriendCard(friend: friend)
						.padding(.bottom)
						.listRowBackground(
							RoundedRectangle(cornerRadius: 15).fill(Color("Secondary"))
								.padding(.bottom)
						)
						.listRowSeparator(.hidden)

				}
				.listStyle(.plain)
				.scrollContentBackground(.hidden)
				.refreshable {
					suggestedFriendsViewModel.fetchData(
						from: "\(APIConstants.base_url)users/suggested/",
						token: authViewModel.loggedInBackendUser?.token ?? "",
						loading: false
					)
				}
				Spacer()
			}

		}
	}
}
