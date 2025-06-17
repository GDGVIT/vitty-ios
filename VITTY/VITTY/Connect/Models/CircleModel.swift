//
//  Circle.swift
//  VITTY
//
//  Created by Rujin Devkota on 3/25/25.
//

import Foundation

struct CircleModel: Decodable {
    let circleID: String
    let circleName: String
    let circleRole: String
    
    enum CodingKeys: String, CodingKey {
        case circleID = "circle_id"
        case circleName = "circle_name"
        case circleRole = "circle_role"
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

import Foundation


// TEMP beacuse the endpoint has to contain the status and venue need to update the db

struct CircleUserTemp: Codable{
   
    let email: String
    let name: String
    let picture: String
    let username: String
        
    enum CodingKeys: String, CodingKey {
        case email, name, picture, username

    }
}


struct CircleUserResponseTemp: Codable {
    let data: [CircleUserTemp]
    
    enum CodingKeys: String , CodingKey{
        case data
    }
}
