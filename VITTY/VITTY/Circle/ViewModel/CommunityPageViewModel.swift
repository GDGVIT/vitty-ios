//
//  CommunityPageViewModel.swift
//  VITTY
//
//  Created by Chandram Dutta on 04/01/24.
//

import Alamofire
import Foundation

@Observable
class CommunityPageViewModel {

	var friends = [Friend]()
	var loading = false
	var error = false

	func fetchData(from url: String, token: String, loading: Bool) {
		self.loading = loading
		AF.request(url, method: .get, headers: ["Authorization": "Token \(token)"])
			.validate()
			.responseDecodable(of: FriendRaw.self) { response in
				switch response.result {
					case .success(let data):
						self.friends = data.data
						self.loading = false
					case .failure(let error):
						print("Error fetching data: \(error)")
						self.loading = false
						self.error.toggle()
				}
			}
	}
}
