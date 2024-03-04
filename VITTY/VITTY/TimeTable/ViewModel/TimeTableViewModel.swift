//
//  TimeTableViewModel.swift
//  VITTY
//
//  Created by Chandram Dutta on 09/02/24.
//

import Foundation
import SwiftData

public enum Stage {
	case loading
	case error
	case data
}

extension TimeTableView {

	@Observable
	class TimeTableViewModel {

		var timeTable: TimeTable?
		var stage: Stage = .loading
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

		func fetchTimeTable(username: String, authToken: String) async {
			do {
				stage = .loading
				let data = try await TimeTableAPIService.shared.getTimeTable(with: username, authToken: authToken)
				timeTable = data
				changeDay()
				stage = .data
			} catch {
				print(error)
				stage = .error
			}
		}
	}
}
