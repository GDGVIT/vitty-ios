//
//  AuthAPIService.swift
//  VITTY
//
//  Created by Chandram Dutta on 04/02/24.
//

import Foundation

enum AuthAPIServiceError: Error {
	case invalidUrl
	case invalidData
}

class AuthAPIService {
	static let shared = AuthAPIService()
	
	func signInUser(
		with authRequestBody: AuthRequestBody
	) async throws -> AppUser {
		let url = URL(string: "\(Constants.url)auth/firebase/")!
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		let encoder = JSONEncoder()
		request.httpBody = try encoder.encode(authRequestBody)
		let data = try await URLSession.shared.data(for: request)
		let decoder = JSONDecoder()
		let appUser = try decoder.decode(AppUser.self, from: data.0)
		return appUser
	}
	
	func checkUserExists(with authID: String) async throws -> Bool {
		let url = URL(string: "\(Constants.url)auth/check-user-exists")!
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		let encoder = JSONEncoder()
		request.httpBody = try encoder.encode(["uuid": authID])
		let (data, res) = try await URLSession.shared.data(for: request)
		let httpResponse = res as? HTTPURLResponse
		return httpResponse?.statusCode == 200
	}
}
