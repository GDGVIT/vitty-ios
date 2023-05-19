//
//  Classes.swift
//  VITTY
//
//  Created by Ananya George on 1/7/22.
//

import Foundation

struct Classes: Hashable, Codable {
    var courseType: String?
    var courseCode: String?
    var courseName: String?
    var location: String?
    var slot: String?
    var startTime: Date?
    var endTime: Date?

    private enum CodingKeys: String, CodingKey {
        
        case courseType = "Course_type"
        case courseName = "courseName"
        case courseCode = "courseCode"
        case endTime = "endTime"
        case startTime = "startTime"
        case location = "location"
        case slot = "slot"
    }
    
}

extension Date {
    func utcToLocal() -> Date {
        let timezone = TimeZone.current
        let seconds = TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
}
