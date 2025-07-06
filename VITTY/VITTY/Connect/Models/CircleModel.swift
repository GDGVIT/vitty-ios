//
//  Circle.swift
//  VITTY
//
//  Created by Rujin Devkota on 3/25/25.
//

//TODO: the Circle doesnt have image in the endpoint



import Foundation

struct CircleModel: Decodable {
    let circleID: String
    let circleName: String
    let circleRole: String
    let circleJoinCode: String
    
    enum CodingKeys: String, CodingKey {
        case circleID = "circle_id"
        case circleName = "circle_name"
        case circleRole = "circle_role"
        case circleJoinCode = "circle_join_code"
        
        
        
    }
}

struct CircleResponse: Decodable {
    let data: [CircleModel]
}

struct CircleMember: Identifiable {
    let id = UUID()
    let picture: String
    let name: String
    let status: String
    let venue: String?
}

// MARK: - Current Status Model
struct CurrentStatus: Codable {
    let className: String?
    let slot: String?
    let status: String
    let venue: String?
    
    enum CodingKeys: String, CodingKey {
        case className = "class"
        case slot, status, venue
    }
}

// MARK: - Updated CircleUserTemp Model
struct CircleUserTemp: Codable {
    let email: String
    let name: String
    let picture: String
    let username: String
    let currentStatus: CurrentStatus?
    
    enum CodingKeys: String, CodingKey {
        case email, name, picture, username
        case currentStatus = "current_status"
    }
    
   
    var status: String {
        return currentStatus?.status ?? "free"
    }
    
    var venue: String? {
        return currentStatus?.venue
    }
    
    var className: String? {
        return currentStatus?.className
    }
    
    var slot: String? {
        return currentStatus?.slot
    }
}

struct CircleUserResponseTemp: Codable {
    let data: [CircleUserTemp]
    
    enum CodingKeys: String, CodingKey {
        case data
    }
}

// MARK: - Request Models
struct CircleRequest: Codable, Identifiable {
    let id = UUID()
    let circle_id: String
    let circle_name: String
    let from_username: String
    let to_username: String
    
    enum CodingKeys: String, CodingKey {
        case circle_id, circle_name, from_username, to_username
    }
}
struct CircleRequestResponse: Codable {
    let data: [CircleRequest]
}
