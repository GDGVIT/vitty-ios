//
//  UserResponse.swift
//  VITTY
//
//  Created by Prashanna Rajbhandari on 19/09/2023.
//

import Foundation

struct UserResponse: Codable{
    let email: String
    let friend_status: String
    let friends_count: Int
    let mutual_friends_count: Int
    let name: String
    let picture: String
    let timetable: TimetableModel
}

