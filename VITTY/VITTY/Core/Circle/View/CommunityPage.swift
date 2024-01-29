//
//  CommunityView.swift
//  VITTY
//
//  Created by Chandram Dutta on 04/01/24.
//

import SwiftUI

struct CommunityPage: View {

	@EnvironmentObject private var authState: AuthViewModel
	@EnvironmentObject private var timeTableViewModel: TimetableViewModel
	@Environment(CommunityPageViewModel.self) private var communityPageViewModel
	@State private var friend: Friend? = nil

	@State private var isFriendViewPresented = false

	var body: some View {
		Group {
			ZStack {
				VStack(alignment: .center) {
					CommunityPageHeader()
					if communityPageViewModel.error {
						Spacer()
						Text("No Friends?")
							.multilineTextAlignment(.center)
							.font(Font.custom("Poppins-SemiBold", size: 18))
							.foregroundColor(Color.white)
						Text("Add your friends and see their timetable")
							.multilineTextAlignment(.center)
							.font(Font.custom("Poppins-Regular", size: 12))
							.foregroundColor(Color.white)
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
									.listRowBackground(
										RoundedRectangle(cornerRadius: 15)
											.fill(Color.theme.secondaryBlue).padding(.bottom)
									)
									.listRowSeparator(.hidden)
									.onTapGesture {
										self.friend = friend
										timeTableViewModel.getTimeTable(
											token: authState.token,
											username: friend.username
										)
										isFriendViewPresented.toggle()
									}
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
				Image(communityPageViewModel.error ? "HomeNoClassesBG" : "HomeBG")
					.resizable()
					.scaledToFill()
					.edgesIgnoringSafeArea(.all)
			)
		}
		.fullScreenCover(
			isPresented: $isFriendViewPresented,
			onDismiss: {
				communityPageViewModel.fetchData(
					from: "\(APIConstants.base_url)/api/v2/friends/\(authState.username)/",
					token: authState.token,
					loading: true
				)
			}
		) {
			FriendTimeTableView(friend: friend ?? Friend.sampleFriend)
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
