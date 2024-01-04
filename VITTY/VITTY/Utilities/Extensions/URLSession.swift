//
//  URLSession.swift
//  VITTY
//
//  Created by Prashanna Rajbhandari on 19/09/2023.
//

import Foundation

enum CustomError: Error {
	case invalidUrl
	case invalidData
}

extension URLSession {

	func request<T: Codable>(
		url: URL?,
		expecting: T.Type,
		completion: @escaping (Result<T, Error>) -> Void
	) {
		guard let url = url else {
			completion(.failure(CustomError.invalidUrl))
			return
		}

		let task = dataTask(with: url) { data, _, error in
			guard let data = data else {
				if let error = error {
					completion(.failure(error))
				}
				else {
					completion(.failure(CustomError.invalidData))
				}

				return
			}

			do {
				let result = try JSONDecoder().decode(expecting.self, from: data)
				completion(.success(result))
			}
			catch {
				completion(.failure(error))
			}
		}

		task.resume()
	}
}
