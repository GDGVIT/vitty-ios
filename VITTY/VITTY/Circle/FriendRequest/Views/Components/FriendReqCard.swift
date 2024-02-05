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
	var body: some View {
		HStack {
			UserImage(url: friend.picture, height: 48, width: 48)
			VStack(alignment: .leading) {
				Text(friend.name)
					.font(Font.custom("Poppins-SemiBold", size: 15))
					.foregroundColor(Color.white)
				Text(friend.username)
					.font(Font.custom("Poppins-Regular", size: 14))
					.foregroundColor(Color.vprimary)
			}
			Spacer()
			if friend.friendStatus == "received" {
				Button(action: {
					let url = URL(
						string:
							"\(APIConstants.base_url)/api/v2/requests/\(friend.username)/accept/"
					)!
					var request = URLRequest(url: url)

					request.httpMethod = "POST"
					request.addValue(
						"Bearer \(authViewModel.appUser?.token ?? "")",
						forHTTPHeaderField: "Authorization"
					)

					let task = URLSession.shared.dataTask(with: request) {
						(data, response, error) in
						// Handle the response here
						if let error = error {
							print("Error: \(error.localizedDescription)")
							return
						}

						if let data = data {
							// Parse the response data if needed
							do {
								let json = try JSONSerialization.jsonObject(with: data, options: [])
								print("Response JSON: \(json)")
							}
							catch {
								print("Error parsing response JSON: \(error.localizedDescription)")
							}
						}
					}

					// Start the URLSession task
					task.resume()

					friendRequestViewModel.fetchFriendRequests(
						from: URL(string: "\(APIConstants.base_url)/api/v2/requests/")!,
						authToken: authViewModel.appUser?.token ?? "",
						loading: false
					)

				}) {
					Text("Accept")
				}
				.buttonStyle(.bordered)
				Button(action: {
					let url = URL(
						string:
							"\(APIConstants.base_url)/api/v2/requests/\(friend.username)/decline/"
					)!
					var request = URLRequest(url: url)

					request.httpMethod = "POST"
					request.addValue(
						"Token \(authViewModel.appUser?.token ?? "")",
						forHTTPHeaderField: "Authorization"
					)

					let task = URLSession.shared.dataTask(with: request) {
						(data, response, error) in
						// Handle the response here
						if let error = error {
							print("Error: \(error.localizedDescription)")
							return
						}

						if let data = data {
							// Parse the response data if needed
							do {
								let json = try JSONSerialization.jsonObject(with: data, options: [])
								print("Response JSON: \(json)")
							}
							catch {
								print("Error parsing response JSON: \(error.localizedDescription)")
							}
						}
					}

					// Start the URLSession task
					task.resume()

					friendRequestViewModel.fetchFriendRequests(
						from: URL(string: "\(APIConstants.base_url)/api/v2/requests/")!,
						authToken: authViewModel.appUser?.token ?? "",
						loading: false
					)
				}) {
					Image(systemName: "person.fill.xmark")
				}
			}
			//			if friend.friendStatus != "sent" {
			//				Button("Send Request") {
			//					let url = URL(string: "\(APIConstants.base_url)/api/v2/requests/\(friend.username)/send")!
			//					var request = URLRequest(url: url)
			//
			//					request.httpMethod = "POST"
			//					request.addValue("Bearer \(authViewModel.appUser?.token ?? "")", forHTTPHeaderField: "Authorization")
			//
			//					let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
			//						// Handle the response here
			//						if let error = error {
			//							print("Error: \(error.localizedDescription)")
			//							return
			//						}
			//
			//						if let data = data {
			//							// Parse the response data if needed
			//							do {
			//								let json = try JSONSerialization.jsonObject(with: data, options: [])
			//								print("Response JSON: \(json)")
			//							} catch {
			//								print("Error parsing response JSON: \(error.localizedDescription)")
			//							}
			//						}
			//					}
			//
			//					// Start the URLSession task
			//					task.resume()
			//
			//					suggestedFriendsViewModel.fetchData(
			//						from: "\(APIConstants.base_url)/api/v2/users/suggested/",
			//						token: authViewModel.appUser?.token ?? "",
			//						loading: false
			//					)
			//				}.buttonStyle(.bordered)
			//					.font(.caption)
			//			} else {
			//				Image(systemName: "person.fill.checkmark")
			//			}
		}
	}
}
