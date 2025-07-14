//
//  TimeTable.swift
//  VITTY
//
//  Created by Chandram Dutta on 09/02/24.
//


import Foundation
import OSLog
import SwiftData

class TimeTableRaw: Codable {
    let data: TimeTable

    enum CodingKeys: String, CodingKey {
        case data
    }
}



@Model
class TimeTable: Codable  {
    var monday: [Lecture]
    var tuesday: [Lecture]
    var wednesday: [Lecture]
    var thursday: [Lecture]
    var friday: [Lecture]
    var  saturday: [Lecture]
    var sunday: [Lecture]
    
    // NEW property
    var saturdaySourceDay: String?
   
    @Transient
    var logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(
            describing: TimeTable.self
        )
    )
    init(
        monday: [Lecture],
        tuesday: [Lecture],
        wednesday: [Lecture],
        thursday: [Lecture],
        friday: [Lecture],
        saturday: [Lecture],
        sunday: [Lecture],
        saturdaySourceDay: String? = nil
    ) {
        self.monday = monday
        self.tuesday = tuesday
        self.wednesday = wednesday
        self.thursday = thursday
        self.friday = friday
        self.saturday = saturday
        self.sunday = sunday
        self.saturdaySourceDay = saturdaySourceDay // Set in initializer
    }

    enum CodingKeys: String, CodingKey,Codable {
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
          
          monday = (try? container.decode([Lecture].self, forKey: .monday)) ?? []
          tuesday = (try? container.decode([Lecture].self, forKey: .tuesday)) ?? []
          wednesday = (try? container.decode([Lecture].self, forKey: .wednesday)) ?? []
          thursday = (try? container.decode([Lecture].self, forKey: .thursday)) ?? []
          friday = (try? container.decode([Lecture].self, forKey: .friday)) ?? []
          saturday = (try? container.decode([Lecture].self, forKey: .saturday)) ?? []
          sunday = (try? container.decode([Lecture].self, forKey: .sunday)) ?? []
          
          self.saturdaySourceDay = nil
      }
    //MARK:  NEW FUNC
    func lectures(forDay day: String) -> [Lecture] {
           switch day {
           case "Monday": return self.monday
           case "Tuesday": return self.tuesday
           case "Wednesday": return self.wednesday
           case "Thursday": return self.thursday
           case "Friday": return self.friday
           default: return []
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

@Model
class Lecture: Codable, Identifiable, Comparable {
    static func == (lhs: Lecture, rhs: Lecture) -> Bool {
        return lhs.name == rhs.name
    }

    static func < (lhs: Lecture, rhs: Lecture) -> Bool {
        return lhs.startTime < rhs.startTime
    }

    var  name: String
    var code: String
    var venue: String
    var slot: String
    var type: String
    var startTime: String
    var endTime: String

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

    enum CodingKeys: String, CodingKey,Codable {
        case name, code, venue, slot, type
        case startTime = "start_time"
        case endTime = "end_time"
    }
    
    func deepCopy() -> Lecture {
           return Lecture(
               name: self.name,
               code: self.code,
               venue: self.venue,
               slot: self.slot,
               type: self.type,
               startTime: self.startTime,
               endTime: self.endTime
           )
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

extension TimeTable {
    var isEmpty: Bool {
        monday.isEmpty && tuesday.isEmpty && wednesday.isEmpty &&
        thursday.isEmpty && friday.isEmpty && saturday.isEmpty && sunday.isEmpty
    }
    
    private func extractStartTime(from lecture: Lecture) -> Date? {
            let formattedTime = formatTime(time: lecture.startTime)
            
            
            guard formattedTime != "Failed to parse the time string." else { return nil }

            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            formatter.locale = Locale(identifier: "en_US_POSIX")

            return formatter.date(from: formattedTime)
        }


    func classesFor(date: Date) -> [Classes] {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)

        let lectures: [Lecture]
        switch weekday {
        case 1: lectures = sunday
        case 2: lectures = monday
        case 3: lectures = tuesday
        case 4: lectures = wednesday
        case 5: lectures = thursday
        case 6: lectures = friday
        case 7: lectures = saturday
        default: lectures = []
        }

        let mapped = lectures.map {
            Classes(
                title: $0.name,
                time: "\(formatTime(time: $0.startTime)) - \(formatTime(time: $0.endTime))",
                slot: $0.venue // NOTE: Passing venue instead of slot for display purposes
            )
        }

        // Sort using the original lecture objects instead of formatted strings
        return lectures.sorted { lecture1, lecture2 in
            guard let time1 = extractStartTime(from: lecture1),
                  let time2 = extractStartTime(from: lecture2) else {
                return false
            }
            return time1 < time2
        }.map {
            Classes(
                title: $0.name,
                time: "\(formatTime(time: $0.startTime)) - \(formatTime(time: $0.endTime))",
                slot: $0.venue // NOTE: Passing venue instead of slot for display purposes
            )
        }
    }

    private func formatTime(time: String) -> String {
            var timeComponents = time.components(separatedBy: "T").last ?? ""
            timeComponents = timeComponents.components(separatedBy: "+").first ?? ""
        timeComponents = timeComponents.components(separatedBy: "Z").first ?? ""

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm:ss"
            if let date = dateFormatter.date(from: timeComponents) {
                dateFormatter.dateFormat = "h:mm a"
                let formattedTime = dateFormatter.string(from: date)
                return (formattedTime)
            }
            else {
                return ("Failed to parse the time string.")
            }
        }
    
    func isDifferentFrom(_ other: TimeTable) -> Bool {
        return monday != other.monday ||
               tuesday != other.tuesday ||
               wednesday != other.wednesday ||
               thursday != other.thursday ||
               friday != other.friday ||
               saturday != other.saturday ||
               sunday != other.sunday
    }
}
