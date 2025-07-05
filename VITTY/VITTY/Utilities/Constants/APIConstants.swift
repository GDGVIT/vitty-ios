//
//  APIConstants.swift
//  VITTY
//
//  Created by Prashanna Rajbhandari on 09/09/2023.
//


import Foundation


struct APIConstants {
	static let base_url = "http://localhost:80/api/v2/"
    static let createCircle = "circles/create/"
    static let sendRequest = "circles/sendRequest/"
    static let acceptRequest = "circles/acceptRequest/"
    static let declineRequest = "circles/declineRequest/"
    static let circleRequests = "circles/requests/received"
    static let friends = "friends"
}
