//
//  CommunityView.swift
//  VITTY
//
//  Created by Chandram Dutta on 04/01/24.
//

import SwiftUI

struct CommunityPage: View {

	@Environment(AuthViewModel.self) private var authViewModel
//	@EnvironmentObject private var timeTableViewModel: TimetableViewModel
	@Environment(CommunityPageViewModel.self) private var communityPageViewModel

	@State private var isShowingRequestView = false

	var body: some View {
		NavigationStack {
			ZStack {
				VStack(alignment: .center) {
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
								NavigationLink {
									TimeTableView(friend: friend)
								} label: {
									HStack {
										UserImage(url: friend.picture, height: 48, width: 48)
										VStack(alignment: .leading) {
											Text(friend.name)
												.font(Font.custom("Poppins-SemiBold", size: 15))
												.foregroundColor(Color.white)
											if friend.currentStatus.status == "free" {
												Text("Not in a class right now")
													.font(Font.custom("Poppins-Regular", size: 14))
													.foregroundColor(Color.vprimary)
											}
											else {
												Text(friend.currentStatus.class ?? "")
													.font(Font.custom("Poppins-Regular", size: 14))
													.foregroundColor(Color.vprimary)
											}
										}
										Spacer()
										VStack {
											Text("NOW")
												.font(Font.custom("Poppins-Regular", size: 14))
												.foregroundColor(Color.vprimary)
											if friend.currentStatus.status == "free" {
												Text(friend.currentStatus.status.capitalized)
													.font(Font.custom("Poppins-SemiBold", size: 16))
													.foregroundColor(Color.white)
											}
											else {
												Text(friend.currentStatus.venue ?? "-")
													.font(Font.custom("Poppins-SemiBold", size: 16))
													.foregroundColor(Color.white)
											}
										}
										.padding(.trailing, 4)
									}
								}
								.listRowBackground(Color("DarkBG"))
							}
							.scrollContentBackground(.hidden)
							.refreshable {
								communityPageViewModel.fetchData(
									from:
										"\(APIConstants.base_url)/api/v2/friends/\(authViewModel.appUser?.username ?? "")/",
									token: authViewModel.appUser?.token ?? "",
									loading: false
								)
							}
							Spacer()
						}
					}
				}
			}
			.background(
				Image(communityPageViewModel.error ? "HomeNoClassesBG" : "HomeBG")
					.resizable()
					.scaledToFill()
					.edgesIgnoringSafeArea(.all)
			)
			.toolbar {
				NavigationLink(destination: AddFriendsView(), isActive: $isShowingRequestView) {
					EmptyView()
				}
				Button(action: {
					isShowingRequestView.toggle()

				}) {
					Image(systemName: "person.fill.badge.plus")
						.foregroundColor(.white)
				}

			}
			.navigationTitle("Connect")
		}
		.onAppear {
			communityPageViewModel.fetchData(
				from:
					"\(APIConstants.base_url)/api/v2/friends/\(authViewModel.appUser?.username ?? "")/",
				token: authViewModel.appUser?.token ?? "",
				loading: true
			)
		}
	}
}
