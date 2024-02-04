//
//  Friend.swift
//  VITTY
//
//  Created by Chandram Dutta on 05/01/24.
//

import Foundation

struct FriendRaw: Decodable {
	let data: [Friend]
	let friendStatus: String

	enum CodingKeys: String, CodingKey {
		case data
		case friendStatus = "friend_status"
	}
}

struct Friend: Decodable {
	let currentStatus: CurrentStatus
	let friendStatus: String
	let friendsCount: Int
	let mutualFriendsCount: Int
	let name: String
	let picture: String
	let username: String

	struct CurrentStatus: Decodable {
		let status: String
		let `class`: String?
		let slot: String?
		let venue: String?

		init(status: String, slot: String? = nil, venue: String? = nil, `class`: String? = nil) {
			self.status = status
			self.slot = slot
			self.venue = venue
			self.class = `class`
		}
	}

	enum CodingKeys: String, CodingKey {
		case currentStatus = "current_status"
		case friendStatus = "friend_status"
		case friendsCount = "friends_count"
		case mutualFriendsCount = "mutual_friends_count"
		case name
		case picture
		case username
	}
}

extension Friend {
	static var sampleFriend: Friend {
		return Friend(
			currentStatus: CurrentStatus(status: "free"),
			friendStatus: "friends",
			friendsCount: 2,
			mutualFriendsCount: 2,
			name: "Rudrank Basant",
			picture:
				"https://lh3.googleusercontent.com/a/ACg8ocK7g3mh79yuJOyaOWy4iM4WsFk81VYAeDty5W4A8ETrqbw=s96-c",
			username: "rudrank"
		)
	}
}
