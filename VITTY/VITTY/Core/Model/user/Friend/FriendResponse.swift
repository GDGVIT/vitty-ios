//
//  FriendResponse.swift
//  VITTY
//
//  Created by Prashanna Rajbhandari on 08/10/2023.
//

import Foundation

struct FriendResponse: Codable, Hashable {

	let friend_status: String
	let friends_count: Int
	let mutual_friends_count: Int
	let name: String
	let picture: String
	let username: String

}
