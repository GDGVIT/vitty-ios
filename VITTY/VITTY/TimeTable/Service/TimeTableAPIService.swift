//
//  TimeTableAPIService.swift
//  VITTY
//
//  Created by Chandram Dutta on 09/02/24.
//

import Foundation

class TimeTableAPIService {
	static let shared = TimeTableAPIService()

	func getTimeTable(
		with username: String,
		authToken: String
	)   async throws -> TimeTable {
		
		let url = URL(string: "\(Constants.url)timetable/\(username)")!
		var request = URLRequest(url: url)
		request.httpMethod = "GET"
		request.setValue("Token \(authToken)", forHTTPHeaderField: "Authorization")
		let data = try await URLSession.shared.data(for: request)
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		let timeTableRaw = try decoder.decode(TimeTableRaw.self, from: data.0)
		return timeTableRaw.data
	}
}
