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
		with authRequestBody: AuthRequestBody,
		completion: @escaping (Result<AppUser, Error>) -> Void
	) {
		guard let url = URL(string: "\(Constants.url)auth/firebase/") else {
			completion(.failure(AuthAPIServiceError.invalidUrl))
			return
		}
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		do {
			let encoder = JSONEncoder()
			request.httpBody = try encoder.encode(authRequestBody)
		}
		catch {
			completion(.failure(error))
			return
		}
		let task = URLSession.shared.dataTask(with: request) { data, _, error in
			if let error = error {
				completion(.failure(error))
				return
			}
			guard let data = data else {
				completion(.failure(AuthAPIServiceError.invalidUrl))
				return
			}
			
			
			do {
				let decoder = JSONDecoder()
				let appUser = try decoder.decode(AppUser.self, from: data)
				completion(.success(appUser))
				
			} catch {
				completion(.failure(error))
				return
			}
		}
		task.resume()
	}
}
