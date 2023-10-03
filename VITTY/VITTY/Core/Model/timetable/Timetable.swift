//
//  Timetable.swift
//  VITTY
//
//  Created by Prashanna Rajbhandari on 28/09/2023.
//

import Foundation

struct TimetableModel: Codable {
    let data: [String: [TimetableItem]]
}

struct TimetableItem: Codable {
    let name: String
    let code: String
    let venue: String
    let slot: String
    let type: String
    let start_time: String
    let end_time: String
}
