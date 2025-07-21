import OSLog
//
//  FriendReqCard.swift
//  VITTY
//
//  Created by Chandram Dutta on 07/01/24.
//
import SwiftUI

struct FriendReqCard: View {

	@Environment(AuthViewModel.self) private var authViewModel
	@Environment(FriendRequestViewModel.self) private var friendRequestViewModel

	let friend: Friend

	private let logger = Logger(
		subsystem: Bundle.main.bundleIdentifier!,
		category: String(
			describing: FriendReqCard.self
		)
	)

	var body: some View {
		HStack {
			UserImage(url: friend.picture, height: 48, width: 48)
			VStack(alignment: .leading) {
				Text(friend.name)
					.font(Font.custom("Poppins-SemiBold", size: 15))
					.foregroundColor(Color.white)
				Text(friend.username)
					.font(Font.custom("Poppins-Regular", size: 14))
					.foregroundColor(Color("Accent"))
			}
			Spacer()
			if friend.friendStatus == "received" {
				Button(action: {
					Task {
						let url = URL(
							string:
								"\(APIConstants.base_url)requests/\(friend.username)/accept/"
						)!
						var request = URLRequest(url: url)

						request.httpMethod = "POST"
						request.addValue(
							"Bearer \(authViewModel.loggedInBackendUser?.token ?? "")",
							forHTTPHeaderField: "Authorization"
						)
						do {
							let (_, _) = try await URLSession.shared.data(for: request)
							friendRequestViewModel.fetchFriendRequests(
								from: URL(string: "\(APIConstants.base_url)requests/")!,
								authToken: authViewModel.loggedInBackendUser?.token ?? "",
								loading: false
							)
						}
						catch {
							return
						}
					}

				}) {
					Text("Accept")
				}
				.buttonStyle(.bordered)
				Button(action: {
					Task {
						let url = URL(
							string:
								"\(APIConstants.base_url)requests/\(friend.username)/decline/"
						)!
						var request = URLRequest(url: url)

						request.httpMethod = "POST"
						request.addValue(
							"Bearer \(authViewModel.loggedInBackendUser?.token ?? "")",
							forHTTPHeaderField: "Authorization"
						)
						do {
							let (_, _) = try await URLSession.shared.data(for: request)
							friendRequestViewModel.fetchFriendRequests(
								from: URL(string: "\(APIConstants.base_url)requests/")!,
								authToken: authViewModel.loggedInBackendUser?.token ?? "",
								loading: false
							)
						}
						catch {
							return
						}
					}
				}) {
					Image(systemName: "person.fill.xmark")
				}
			}
		}
	}
}
