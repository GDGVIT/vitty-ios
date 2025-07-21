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
        self.saturdaySourceDay = saturdaySourceDay 
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
                slot: $0.venue
            )
        }

       
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
                slot: $0.venue 
            )
        }
    }

    private func formatTime(time: String) -> String {
      
        if let formattedTime = parseWithISO8601(time: time) {
            return formattedTime
        } else if let formattedTime = parseWithCustomFormat(time: time) {
            return formattedTime
        } else {
         
            return parseTimeOnlyFallback(time: time)
        }
    }
    
    private func parseWithISO8601(time: String) -> String? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withTimeZone]
        
        if let date = formatter.date(from: time) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "h:mm a"
            displayFormatter.locale = Locale(identifier: "en_US_POSIX")
            return displayFormatter.string(from: date)
        }
        
        return nil
    }
    
    private func parseWithCustomFormat(time: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        if let date = dateFormatter.date(from: time) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "h:mm a"
            displayFormatter.locale = Locale(identifier: "en_US_POSIX")
            return displayFormatter.string(from: date)
        }
        
        return nil
    }
    
    private func parseTimeOnlyFallback(time: String) -> String {
       
        var timeComponents = time.components(separatedBy: "T").last ?? time
        
      
        if timeComponents.contains("+") {
            timeComponents = timeComponents.components(separatedBy: "+").first ?? timeComponents
        }
        if timeComponents.contains("Z") {
            timeComponents = timeComponents.components(separatedBy: "Z").first ?? timeComponents
        }
        if timeComponents.contains("-") && timeComponents.count > 8 {
            let parts = timeComponents.components(separatedBy: "-")
            if parts.count > 1 && parts[0].count >= 8 {
                timeComponents = parts[0]
            }
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "HH:mm:ss"
        
        if let date = dateFormatter.date(from: timeComponents) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "h:mm a"
            displayFormatter.locale = Locale(identifier: "en_US_POSIX")
            return displayFormatter.string(from: date)
        }
        
      
        let timePattern = "\\d{2}:\\d{2}"
        if let range = timeComponents.range(of: timePattern, options: .regularExpression) {
            let timeOnly = String(timeComponents[range])
            dateFormatter.dateFormat = "HH:mm"
            
            if let date = dateFormatter.date(from: timeOnly) {
                let displayFormatter = DateFormatter()
                displayFormatter.dateFormat = "h:mm a"
                displayFormatter.locale = Locale(identifier: "en_US_POSIX")
                return displayFormatter.string(from: date)
            }
        }
        
        return "Invalid Time"
    }
    

    
    private func parseTime(_ timeString: String) -> Int? {
       
        if let minutes = parseTimeWithISO8601(timeString) {
            return minutes
        }
        
   
        return parseTimeCustom(timeString)
    }
    
    private func parseTimeWithISO8601(_ timeString: String) -> Int? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withTimeZone]
        
        if let date = formatter.date(from: timeString) {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute], from: date)
            if let hour = components.hour, let minute = components.minute {
                return hour * 60 + minute
            }
        }
        
        return nil
    }
    
    private func parseTimeCustom(_ timeString: String) -> Int? {
        var timeComponents = timeString.components(separatedBy: "T").last ?? timeString
        
       
        if timeComponents.contains("+") {
            timeComponents = timeComponents.components(separatedBy: "+").first ?? timeComponents
        }
        if timeComponents.contains("Z") {
            timeComponents = timeComponents.components(separatedBy: "Z").first ?? timeComponents
        }
        if timeComponents.contains("-") && timeComponents.count > 8 {
            let parts = timeComponents.components(separatedBy: "-")
            if parts.count > 1 && parts[0].count >= 8 {
                timeComponents = parts[0]
            }
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "HH:mm:ss"
        
        if let date = dateFormatter.date(from: timeComponents) {
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: date)
            let minute = calendar.component(.minute, from: date)
            return hour * 60 + minute
        }
        
        return nil
    }
    

    
    private func parseTimeToDate(_ timeString: String) -> Date? {
       
        if let date = parseTimeToDateISO8601(timeString) {
            return date
        }
        
  
        return parseTimeToDateCustom(timeString)
    }
    
    private func parseTimeToDateISO8601(_ timeString: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withTimeZone]
        
        if let originalDate = formatter.date(from: timeString) {
            let calendar = Calendar.current
            let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: originalDate)
            let todayComponents = calendar.dateComponents([.year, .month, .day], from: Date())
            
            var combinedComponents = DateComponents()
            combinedComponents.year = todayComponents.year
            combinedComponents.month = todayComponents.month
            combinedComponents.day = todayComponents.day
            combinedComponents.hour = timeComponents.hour
            combinedComponents.minute = timeComponents.minute
            combinedComponents.second = timeComponents.second
            
            return calendar.date(from: combinedComponents)
        }
        
        return nil
    }
    
    private func parseTimeToDateCustom(_ timeString: String) -> Date? {
        var timeComponents = timeString.components(separatedBy: "T").last ?? timeString
        
        
        if timeComponents.contains("+") {
            timeComponents = timeComponents.components(separatedBy: "+").first ?? timeComponents
        }
        if timeComponents.contains("Z") {
            timeComponents = timeComponents.components(separatedBy: "Z").first ?? timeComponents
        }
        if timeComponents.contains("-") && timeComponents.count > 8 {
            let parts = timeComponents.components(separatedBy: "-")
            if parts.count > 1 && parts[0].count >= 8 {
                timeComponents = parts[0]
            }
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "HH:mm:ss"
        
        if let time = dateFormatter.date(from: timeComponents) {
            let calendar = Calendar.current
            let now = Date()
            
            let todayComponents = calendar.dateComponents([.year, .month, .day], from: now)
            let timeComps = calendar.dateComponents([.hour, .minute, .second], from: time)
            
            var combinedComponents = DateComponents()
            combinedComponents.year = todayComponents.year
            combinedComponents.month = todayComponents.month
            combinedComponents.day = todayComponents.day
            combinedComponents.hour = timeComps.hour
            combinedComponents.minute = timeComps.minute
            combinedComponents.second = timeComps.second
            
            return calendar.date(from: combinedComponents)
        }
        
        return nil
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
