//
//  TimeTable.swift
//  VITTY
//
//  Created by Chandram Dutta on 09/02/24.
//

import Foundation

//import SwiftData

class TimeTableRaw: Codable {
	let data: TimeTable

	enum CodingKeys: String, CodingKey {
		case data
	}
}

//@Model
class TimeTable: Codable {
	let monday: [Lecture]
	let tuesday: [Lecture]
	let wednesday: [Lecture]
	let thursday: [Lecture]
	let friday: [Lecture]
	let saturday: [Lecture]
	let sunday: [Lecture]

	init(
		monday: [Lecture],
		tuesday: [Lecture],
		wednesday: [Lecture],
		thursday: [Lecture],
		friday: [Lecture],
		saturday: [Lecture],
		sunday: [Lecture]
	) {
		self.monday = monday
		self.tuesday = tuesday
		self.wednesday = wednesday
		self.thursday = thursday
		self.friday = friday
		self.saturday = saturday
		self.sunday = sunday
	}

	enum CodingKeys: String, CodingKey {
		case monday = "Monday"
		case tuesday = "Tuesday"
		case wednesday = "Wednesday"
		case thursday = "Thursday"
		case friday = "Friday"
		case saturday = "Saturday"
		case sunday = "Sunday"
	}

	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		do {
			monday = try container.decode([Lecture].self, forKey: .monday)
		}
		catch {
			print("Error decoding Monday lectures:", error)
			monday = []
		}

		do {
			tuesday = try container.decode([Lecture].self, forKey: .tuesday)
		}
		catch {
			print("Error decoding Tuesday lectures:", error)
			tuesday = []
		}

		do {
			wednesday = try container.decode([Lecture].self, forKey: .wednesday)
		}
		catch {
			print("Error decoding Wednesday lectures:", error)
			wednesday = []
		}

		do {
			thursday = try container.decode([Lecture].self, forKey: .thursday)
		}
		catch {
			print("Error decoding Thursday lectures:", error)
			thursday = []
		}

		do {
			friday = try container.decode([Lecture].self, forKey: .friday)
		}
		catch {
			print("Error decoding Friday lectures:", error)
			friday = []
		}

		do {
			saturday = try container.decode([Lecture].self, forKey: .saturday)
		}
		catch {
			print("Error decoding Saturday lectures:", error)
			saturday = []
		}

		do {
			sunday = try container.decode([Lecture].self, forKey: .sunday)
		}
		catch {
			print("Error decoding Sunday lectures:", error)
			sunday = []
		}
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(monday, forKey: .monday)
		try container.encode(tuesday, forKey: .tuesday)
		try container.encode(wednesday, forKey: .wednesday)
		try container.encode(thursday, forKey: .thursday)
		try container.encode(friday, forKey: .friday)
		try container.encode(saturday, forKey: .saturday)
		try container.encode(sunday, forKey: .sunday)
	}
}

//@Model
class Lecture: Codable, Identifiable, Comparable {
	static func == (lhs: Lecture, rhs: Lecture) -> Bool {
		return lhs.name == rhs.name
	}

	static func < (lhs: Lecture, rhs: Lecture) -> Bool {
		return lhs.startTime < rhs.startTime
	}

	let name: String
	let code: String
	let venue: String
	let slot: String
	let type: String
	let startTime: String
	let endTime: String

	init(
		name: String,
		code: String,
		venue: String,
		slot: String,
		type: String,
		startTime: String,
		endTime: String
	) {
		self.name = name
		self.code = code
		self.venue = venue
		self.slot = slot
		self.type = type
		self.startTime = startTime
		self.endTime = endTime
	}

	enum CodingKeys: String, CodingKey {
		case name, code, venue, slot, type
		case startTime = "start_time"
		case endTime = "end_time"
	}

	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		name = try container.decode(String.self, forKey: .name)
		code = try container.decode(String.self, forKey: .code)
		venue = try container.decode(String.self, forKey: .venue)
		slot = try container.decode(String.self, forKey: .slot)
		type = try container.decode(String.self, forKey: .type)
		startTime = try container.decode(String.self, forKey: .startTime)
		endTime = try container.decode(String.self, forKey: .endTime)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(name, forKey: .name)
		try container.encode(code, forKey: .code)
		try container.encode(venue, forKey: .venue)
		try container.encode(slot, forKey: .slot)
		try container.encode(type, forKey: .type)
		try container.encode(startTime, forKey: .startTime)
		try container.encode(endTime, forKey: .endTime)
	}
}
