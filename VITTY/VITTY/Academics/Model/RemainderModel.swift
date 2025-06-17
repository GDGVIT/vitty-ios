//
//  Remainder.swift
//  VITTY
//
//  Created by Rujin Devkota on 6/11/25.
//

import Foundation
import SwiftData

import Foundation
@Model
class Remainder: Codable {
    var title: String
    var subject: String
    var slot: String
    var courseCode: String
    var date: Date
    var subjectDescription: String?
    var isCompleted: Bool

    var startTime: Date
    var endTime: Date

    init(title: String, subject: String, slot: String, courseCode: String, date: Date, isCompleted: Bool, subjectDescription: String?, startTime: Date, endTime: Date) {
        self.title = title
        self.subject = subject
        self.slot = slot
        self.courseCode = courseCode
        self.date = date
        self.isCompleted = isCompleted
        self.subjectDescription = subjectDescription
        self.startTime = startTime
        self.endTime = endTime
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.subject = try container.decode(String.self, forKey: .subject)
        self.slot = try container.decode(String.self, forKey: .slot)
        self.courseCode = try container.decode(String.self, forKey: .courseCode)
        self.date = try container.decode(Date.self, forKey: .date)
        self.isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        self.subjectDescription = try container.decodeIfPresent(String.self, forKey: .subjectDescription)
        self.startTime = try container.decode(Date.self, forKey: .startTime)
        self.endTime = try container.decode(Date.self, forKey: .endTime)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.title, forKey: .title)
        try container.encode(self.subject, forKey: .subject)
        try container.encode(self.slot, forKey: .slot)
        try container.encode(self.courseCode, forKey: .courseCode)
        try container.encode(self.date, forKey: .date)
        try container.encode(self.isCompleted, forKey: .isCompleted)
        try container.encodeIfPresent(self.subjectDescription, forKey: .subjectDescription)
        try container.encode(self.startTime, forKey: .startTime)
        try container.encode(self.endTime, forKey: .endTime)
    }

    private enum CodingKeys: String, CodingKey {
        case title, subject, slot, courseCode, date, isCompleted, subjectDescription, startTime, endTime
    }
}
