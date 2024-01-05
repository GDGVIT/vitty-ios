//
//  CommunityView.swift
//  VITTY
//
//  Created by Chandram Dutta on 04/01/24.
//

import SwiftUI

struct CommunityPage: View {

	@EnvironmentObject private var authState: AuthService
	@Environment(CommunityPageViewModel.self) private var communityPageViewModel

	var body: some View {
		Group {
			ZStack {
				VStack(alignment: .center) {
					CommunityPageHeader()
					if communityPageViewModel.error {
						Spacer()
						Text("Error")
						Spacer()
					}
					else {
						if communityPageViewModel.loading {
							Spacer()
							ProgressView()
							Spacer()
						}
						else {
							List(communityPageViewModel.friends, id: \.username) { friend in
								FriendCard(friend: friend)
									.padding(.bottom)
									.listRowBackground(RoundedRectangle(cornerRadius: 15).fill(Color.theme.secondaryBlue).padding(.bottom))
									.listRowSeparator(.hidden)
							}
							.listStyle(.plain)
							.scrollContentBackground(.hidden)
							.refreshable {
								communityPageViewModel.fetchData(
									from:
										"\(APIConstants.base_url)/api/v2/friends/\(authState.username)/",
									token: authState.token,
									loading: false
								)
							}
							Spacer()
						}
					}
				}
				.padding()
			}
			.padding(.top)
			.background(
				Image("HomeBG")
					.resizable()
					.scaledToFill()
					.edgesIgnoringSafeArea(.all)
			)
		}
		.onAppear {
			communityPageViewModel.fetchData(
				from: "\(APIConstants.base_url)/api/v2/friends/\(authState.username)/",
				token: authState.token,
				loading: true
			)
		}
	}
}
