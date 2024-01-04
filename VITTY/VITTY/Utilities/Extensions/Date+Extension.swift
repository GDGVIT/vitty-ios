//
//  Date+Extension.swift
//  VITTY
//
//  Created by Ananya George on 3/3/22.
//

import Foundation

extension Date {
	static func convertToMondayWeek() -> Int {
		let hashMap = [
			1: 6,
			2: 0,
			3: 1,
			4: 2,
			5: 3,
			6: 4,
			7: 5,
		]
		let today = Calendar.current.dateComponents([.weekday], from: Date()).weekday ?? 1
		return hashMap[today] ?? 0
	}
}
