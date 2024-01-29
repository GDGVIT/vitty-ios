//
//  AuthResponse.swift
//  VITTY
//
//  Created by Prashanna Rajbhandari on 19/09/2023.
//

import Foundation

struct AuthResponse: Codable {
	let name: String
	let picture: String
	let role: String
	let token: String
	let username: String
}
