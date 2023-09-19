//
//  UserResponse.swift
//  VITTY
//
//  Created by Prashanna Rajbhandari on 19/09/2023.
//

import Foundation

import Foundation

// MARK: - Welcome
struct UserResponse: Codable {
    let email, friendStatus: String
    let friendsCount, mutualFriendsCount: Int
    let name: String
    let picture: String
    let timetable: Timetable
    let username: String

    enum CodingKeys: String, CodingKey {
        case email
        case friendStatus = "friend_status"
        case friendsCount = "friends_count"
        case mutualFriendsCount = "mutual_friends_count"
        case name, picture, timetable, username
    }
}

// MARK: - Timetable
struct Timetable: Codable {
    let data: DataClass
}

// MARK: - DataClass
struct DataClass: Codable {
    let friday, monday, thursday, tuesday: [Day]
    let wednesday: [Day]

    enum CodingKeys: String, CodingKey {
        case friday = "Friday"
        case monday = "Monday"
        case thursday = "Thursday"
        case tuesday = "Tuesday"
        case wednesday = "Wednesday"
    }
}

// MARK: - Day
struct Day: Codable {
    let name, code, venue, slot: String
    let type: TypeEnum
    let startTime, endTime: Date

    enum CodingKeys: String, CodingKey {
        case name, code, venue, slot, type
        case startTime = "start_time"
        case endTime = "end_time"
    }
}

enum TypeEnum: String, Codable {
    case lab = "Lab"
    case theory = "Theory"
}
