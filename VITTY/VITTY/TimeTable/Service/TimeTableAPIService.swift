//
//  TimeTableAPIService.swift
//  VITTY
//
//  Created by Chandram Dutta on 09/02/24.
//

import Foundation

enum TimeTableAPIServiceError: Error {
	case invalidUrl
}

class TimeTableAPIService {
	static let shared = TimeTableAPIService()

	func getTimeTable(
		with username: String,
		authToken: String,
		completion: @escaping (Result<TimeTable, Error>) -> Void
	) {
		guard let url = URL(string: "\(Constants.url)timetable/\(username)") else {
			completion(.failure(TimeTableAPIServiceError.invalidUrl))
			return
		}
		var request = URLRequest(url: url)
		request.httpMethod = "GET"
		request.setValue("Token \(authToken)", forHTTPHeaderField: "Authorization")
		let task = URLSession.shared.dataTask(with: request) { data, _, error in
			if let error = error {
				completion(.failure(error))
				return
			}
			guard let data = data else {
				completion(.failure(TimeTableAPIServiceError.invalidUrl))
				return
			}
			do {
				let decoder = JSONDecoder()
				decoder.dateDecodingStrategy = .iso8601
				let timetableRaw = try decoder.decode(TimeTableRaw.self, from: data)
				completion(.success(timetableRaw.data))
			}
			catch {
				completion(.failure(error))
				return
			}
		}
		task.resume()
	}
}
