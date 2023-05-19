//
//  TimeTableInformation.swift
//  VITTY
//
//  Created by Ananya George on 1/8/22.
//

import Foundation

struct TimeTableInformation: Codable {
    var isTimetableAvailable: Bool?
    var isUpdated: Bool?
    var timetableVersion: Int?
}
