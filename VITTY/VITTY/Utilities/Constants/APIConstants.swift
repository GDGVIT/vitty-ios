//
//  APIConstants.swift
//  VITTY
//
//  Created by Prashanna Rajbhandari on 09/09/2023.
//


import Foundation


struct APIConstants {
    
    
    
//	static let base_url = "https://visiting-eba-vitty-d61856bb.koyeb.app/api/v2/"
//    
//    static let base_urlv3 = "https://visiting-eba-vitty-d61856bb.koyeb.app/api/v3/"
    
    static let base_url = "http://68.233.117.217:3000/api/v2/"
    
    static let base_urlv3 = "http://68.233.117.217:3000/api/v3/"
    
    
    static let createCircle = "circles/create/"
    static let sendRequest = "circles/sendRequest/"
    static let acceptRequest = "circles/acceptRequest/"
    static let declineRequest = "circles/declineRequest/"
    static let circleRequests = "circles/requests/received"
    static let friends = "friends"
}
