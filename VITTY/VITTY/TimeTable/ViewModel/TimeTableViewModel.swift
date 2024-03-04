//
//  TimeTableViewModel.swift
//  VITTY
//
//  Created by Chandram Dutta on 09/02/24.
//

import Foundation
import SwiftData

extension TimeTableView {

	@Observable
	class TimeTableViewModel {

		var timeTable: TimeTable?
		var isLoading: Bool = false
		var error: String?
		var lectures = [Lecture]()
		var dayNo = Date.convertToMondayWeek()

		func changeDay() {
			switch dayNo {
				case 0:
					self.lectures = timeTable?.monday ?? []
				case 1:
					self.lectures = timeTable?.tuesday ?? []
				case 2:
					self.lectures = timeTable?.wednesday ?? []
				case 3:
					self.lectures = timeTable?.thursday ?? []
				case 4:
					self.lectures = timeTable?.friday ?? []
				case 5:
					self.lectures = timeTable?.saturday ?? []
				case 6:
					self.lectures = timeTable?.sunday ?? []
				default:
					self.lectures = []
			}
		}

		func fetchTimeTable(username: String, authToken: String) {
			TimeTableAPIService.shared.getTimeTable(with: username, authToken: authToken) {
				[weak self] result in
				switch result {
					case let .success(response):
						self?.timeTable = response
						self?.changeDay()
					case let .failure(response):
						print("Error: \(response)")
				}
			}
		}
	}
}
