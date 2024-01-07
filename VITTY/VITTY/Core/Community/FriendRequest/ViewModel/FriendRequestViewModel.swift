import Alamofire
//
//  FriendRequestViewModel.swift
//  VITTY
//
//  Created by Chandram Dutta on 07/01/24.
//
import Foundation

@Observable
class FriendRequestViewModel {

	var requests = [Friend]()
	var loading = false
	var error = false

	func fetchFriendRequests(from url: URL, authToken: String, loading: Bool) {
		self.loading = loading

		self.requests = []

		let headers: HTTPHeaders = [
			"Authorization": "Bearer \(authToken)"
		]

		AF.request(url, headers: headers)
			.responseData { response in
				switch response.result {
					case .success(let data):
						do {
							let friendRequests = try JSONSerialization.jsonObject(
								with: data,
								options: []
							)
							if let jsonArray = friendRequests as? [[String: Any]] {
								for j in jsonArray {
									if let from = j["from"] as? [String: Any],
										let name = from["name"] as? String,
										let username = from["username"] as? String,
										let friendStatus = from["friend_status"] as? String,
										let friendsCount = from["friends_count"] as? Int,
										let mutualFriendsCount = from["mutual_friends_count"]
											as? Int,
										let currentStatus = from["current_status"]
											as? [String: Any],
										let currentStatusValue = currentStatus["status"] as? String,
										let picture = from["picture"] as? String
									{

										let req = Friend(
											currentStatus: Friend.CurrentStatus(
												status: currentStatusValue
											),
											friendStatus: friendStatus,
											friendsCount: friendsCount,
											mutualFriendsCount: mutualFriendsCount,
											name: name,
											picture: picture,
											username: username
										)

										self.requests.append(req)
									}
								}
							}
							self.loading = false
						}
						catch {
							print("Error decoding JSON: \(error)")
							self.error = true
							self.loading = false
						}

					case .failure(let error):
						print("Error fetching data: \(error.localizedDescription)")
						self.error = true
						self.loading = false
				}
			}
	}
}
