//
//  SearchView.swift
//  VITTY
//
//  Created by Chandram Dutta on 07/01/24.
//

import SwiftUI

struct SearchView: View {
	@State private var searchText = ""
	@State private var searchedFriends = [Friend]()
	@State private var loading = false
	@EnvironmentObject private var authState: AuthService
	@Environment(\.dismiss) var dismiss
	var body: some View {
		Group {
			VStack(alignment: .center) {
				HStack {
					Button(action: {
						dismiss()
					}) {
						Image(systemName: "xmark")
							.foregroundColor(.white)
					}
					VStack {
						RoundedRectangle(cornerRadius: 20)
							.foregroundColor(Color.theme.tfBlue)
							.frame(maxWidth: .infinity)
							.frame(height: 64)
							.padding()
							.overlay(
								RoundedRectangle(cornerRadius: 20)
									.stroke(Color.theme.tfBlueLight, lineWidth: 1)
									.frame(maxWidth: .infinity)
									.frame(height: 64)
									.padding()
									.overlay(alignment: .leading) {
										TextField(text: $searchText) {
											Text("Search Friends")
												.foregroundColor(Color.theme.tfBlueLight)
										}
										.onChange(of: searchText) {
											search()
										}
										.padding(.horizontal, 42)
										.foregroundColor(.white)
										.foregroundColor(Color.theme.tfBlue)
									}
							)

					}

				}
				.padding(.vertical)
				if loading {
					Spacer()
					ProgressView()
				}
				else {

					ForEach(searchedFriends, id: \.username) { friend in
						AddFriendCard(friend: friend)
					}
				}
				Spacer()
			}
			.padding()
			.background(
				Image(
					"HomeBG"
				)
				.resizable()
				.scaledToFill()
				.edgesIgnoringSafeArea(.all)
			)
		}
	}

	func search() {
		loading = true
		let url = URL(string: "\(APIConstants.base_url)/api/v2/users/search?query=\(searchText)")!
		var request = URLRequest(url: url)
		let session = URLSession.shared
		request.httpMethod = "GET"
		request.addValue("Bearer \(authState.token)", forHTTPHeaderField: "Authorization")
		if searchText.isEmpty {
			searchedFriends = []
		}
		else {
			let task = session.dataTask(with: request) { (data, response, error) in
				guard let data = data else {
					print("No data received")
					return
				}
				do {
					// Decode the JSON data into an array of UserInfo structs
					let users = try JSONDecoder().decode([Friend].self, from: data)
						.filter { $0.username != authState.username }
					searchedFriends = users
				}
				catch {
					print("Error decoding JSON: \(error)")
				}
			}
			task.resume()
		}
		loading = false
	}

}
#Preview {
	SearchView()
}
