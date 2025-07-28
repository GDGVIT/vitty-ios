//
//  ScheduleProvider.swift
//  VITTY
//
//  Created by Rujin Devkota on 6/12/25.
//
//

import SwiftUI
import SwiftData
import WidgetKit

struct Provider: TimelineProvider {
    
    private func getSharedContainer() -> ModelContainer? {
        let appGroupContainerID = "\(AppConstants.VITTYappgroup)"
        
      
        let schema = Schema([TimeTable.self, Remainder.self, CreateNoteModel.self, UploadedFile.self])
        
        let config = ModelConfiguration(
            appGroupContainerID,
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )
        
        do {
          
            return try ModelContainer(for: schema, configurations: config)
        } catch {
            print("Failed to create shared container: \(error)")
            return nil
        }
    }

    
    // MARK: - Time Parsing and Validation
    
    private func parseTimeString(_ timeString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        let cleanedTime = timeString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let time = formatter.date(from: cleanedTime) {
            let calendar = Calendar.current
            let now = Date()
            let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
            return calendar.date(bySettingHour: timeComponents.hour ?? 0,
                               minute: timeComponents.minute ?? 0,
                               second: 0,
                               of: now)
        }
        return nil
    }
    
    private func parseClassTime(_ timeRange: String) -> (start: Date?, end: Date?) {
        let components = timeRange.components(separatedBy: " - ")
        guard components.count == 2 else { return (nil, nil) }
        
        let startTime = parseTimeString(components[0])
        let endTime = parseTimeString(components[1])
        
        return (startTime, endTime)
    }
    
    // MARK: - Class Status Determination
    
    private enum ClassStatus {
        case upcoming
        case current
        case completed
    }
    
    private func getClassStatus(_ classItem: Classes, at currentTime: Date = Date()) -> ClassStatus {
        let (startTime, endTime) = parseClassTime(classItem.time)
        
        guard let start = startTime, let end = endTime else {
            return .upcoming
        }
        
        if currentTime < start {
            return .upcoming
        } else if currentTime >= start && currentTime <= end {
            return .current
        } else {
            return .completed
        }
    }
    
    // MARK: - Data Fetching Methods
    
    private func fetchAllTodaysClasses() -> [Classes] {
        guard let container = getSharedContainer() else { return [] }
        let context = ModelContext(container)
        
        let descriptor = FetchDescriptor<TimeTable>()
        guard let timetable = try? context.fetch(descriptor).first else {
            return []
        }
        
        return timetable.classesFor(date: Date())
    }
    
    private func fetchUpcomingClasses() -> [Classes] {
        let allClasses = fetchAllTodaysClasses()
        let currentTime = Date()
        
        return allClasses.filter { classItem in
            getClassStatus(classItem, at: currentTime) == .upcoming
        }
    }
    
    private func fetchCurrentClass() -> Classes? {
        let allClasses = fetchAllTodaysClasses()
        let currentTime = Date()
        
        return allClasses.first { classItem in
            getClassStatus(classItem, at: currentTime) == .current
        }
    }
    
    private func calculateCompletedClassesCount() -> Int {
        let allClasses = fetchAllTodaysClasses()
        let currentTime = Date()
        
        return allClasses.filter { classItem in
            getClassStatus(classItem, at: currentTime) == .completed
        }.count
    }
    
    // MARK: - Widget Size-Specific Content Preparation
    
    private func prepareSmallMediumContent() -> (classes: [Classes], total: Int, completed: Int) {
        let allClasses = fetchAllTodaysClasses()
        let upcomingClasses = fetchUpcomingClasses()
        let currentClass = fetchCurrentClass()
        let completedCount = calculateCompletedClassesCount()
        
        var displayClasses: [Classes] = []
   
        if let current = currentClass {
            displayClasses.append(current)
        }
        
       
        displayClasses.append(contentsOf: upcomingClasses)
        
        return (
            classes: displayClasses,
            total: allClasses.count,
            completed: completedCount
        )
    }
    
    private func prepareLargeContent() -> (classes: [Classes], total: Int, completed: Int) {
        let allClasses = fetchAllTodaysClasses()
        let completedCount = calculateCompletedClassesCount()
        
        // Get all classes sorted by time
        let sortedClasses = getSortedClasses(allClasses)
        
        // Group classes into batches of 4
        let currentGroupClasses = getCurrentGroupOfFour(sortedClasses)
        
        return (
            classes: currentGroupClasses,
            total: allClasses.count,
            completed: completedCount
        )
    }
    
    private func getSortedClasses(_ classes: [Classes]) -> [Classes] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        return classes.sorted { class1, class2 in
            let time1Components = class1.time.components(separatedBy: " - ")
            let time2Components = class2.time.components(separatedBy: " - ")
            
            guard time1Components.count == 2, time2Components.count == 2 else {
                return false
            }
            
            let startTime1Str = time1Components[0].trimmingCharacters(in: .whitespaces)
            let startTime2Str = time2Components[0].trimmingCharacters(in: .whitespaces)
            
            guard let startTime1 = dateFormatter.date(from: startTime1Str),
                  let startTime2 = dateFormatter.date(from: startTime2Str) else {
                return false
            }
            
            return startTime1 < startTime2
        }
    }
    
    private func getCurrentGroupOfFour(_ sortedClasses: [Classes]) -> [Classes] {
        let currentTime = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let calendar = Calendar.current
        
      
        var pivotIndex = 0
        
        for (index, classItem) in sortedClasses.enumerated() {
            let status = getClassStatus(classItem, at: currentTime)
            if status == .current || status == .upcoming {
                pivotIndex = index
                break
            }
        }
        
 
        let groupSize = 4
        let currentGroupIndex = pivotIndex / groupSize
        let startIndex = currentGroupIndex * groupSize
        let endIndex = min(startIndex + groupSize, sortedClasses.count)
        
        return Array(sortedClasses[startIndex..<endIndex])
    }
    
    // MARK: - Timeline Provider Methods
    
    func placeholder(in context: Context) -> ScheduleEntry {
        ScheduleEntry(
            date: Date(),
            total: 7,
            classes: [
                Classes(title: "Software Engineering", time: "4:00 PM - 4:50 PM", slot: "A1 + TA1")
            ],
            completed: 2
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (ScheduleEntry) -> ()) {
        let content: (classes: [Classes], total: Int, completed: Int)
        
       
        switch context.family {
        case .systemLarge:
            content = prepareLargeContent()
        default:
            content = prepareSmallMediumContent()
        }
        
        completion(ScheduleEntry(
            date: Date(),
            total: content.total,
            classes: content.classes,
            completed: content.completed
        ))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<ScheduleEntry>) -> ()) {
        let content: (classes: [Classes], total: Int, completed: Int)
        let currentTime = Date()
        
        
        switch context.family {
        case .systemLarge:
            content = prepareLargeContent()
        default:
            content = prepareSmallMediumContent()
        }
        
        let entry = ScheduleEntry(
            date: currentTime,
            total: content.total,
            classes: content.classes,
            completed: content.completed
        )
        
       
        let nextRefreshTime: Date
        switch context.family {
        case .systemLarge:
            nextRefreshTime = calculateNextGroupRefreshTime(currentTime: currentTime, classes: content.classes)
        default:
            nextRefreshTime = calculateNextRefreshTime(currentTime: currentTime, classes: content.classes)
        }
        
        let timeline = Timeline(entries: [entry], policy: .after(nextRefreshTime))
        completion(timeline)
    }
    
    // MARK: - Smart Refresh Timing
    
    private func calculateNextRefreshTime(currentTime: Date, classes: [Classes]) -> Date {
        let calendar = Calendar.current
        
     
        var nextSignificantTime: Date?
        
        for classItem in classes {
            let (startTime, endTime) = parseClassTime(classItem.time)
            
          
            if let start = startTime, start > currentTime {
                if nextSignificantTime == nil || start < nextSignificantTime! {
                    nextSignificantTime = start
                }
            }
            
           
            if let end = endTime, end > currentTime {
                if nextSignificantTime == nil || end < nextSignificantTime! {
                    nextSignificantTime = end
                }
            }
        }
        
        
        if let significantTime = nextSignificantTime {
            return significantTime
        }
        
        return calendar.date(byAdding: .minute, value: 15, to: currentTime) ?? currentTime
    }
    
    private func calculateNextGroupRefreshTime(currentTime: Date, classes: [Classes]) -> Date {
        let calendar = Calendar.current
        let allClasses = fetchAllTodaysClasses()
        let sortedClasses = getSortedClasses(allClasses)
        
      
        let currentGroupIndex = getCurrentGroupIndex(sortedClasses, currentTime: currentTime)
        let groupSize = 4
        let currentGroupStart = currentGroupIndex * groupSize
        let currentGroupEnd = min(currentGroupStart + groupSize, sortedClasses.count)
        
       
        var nextGroupChangeTime: Date?
        
        
        for i in currentGroupStart..<currentGroupEnd {
            if i < sortedClasses.count {
                let classItem = sortedClasses[i]
                let (_, endTime) = parseClassTime(classItem.time)
                
                if let end = endTime, end > currentTime {
                  
                    if isLastClassInGroup(index: i, groupSize: groupSize, totalClasses: sortedClasses.count) {
                        if nextGroupChangeTime == nil || end < nextGroupChangeTime! {
                            nextGroupChangeTime = end
                        }
                    }
                }
            }
        }
        
      
        if let groupChangeTime = nextGroupChangeTime {
            return groupChangeTime
        }
        
     
        return calculateNextRefreshTime(currentTime: currentTime, classes: classes)
    }
    
    private func getCurrentGroupIndex(_ sortedClasses: [Classes], currentTime: Date) -> Int {
        let groupSize = 4
        

        var pivotIndex = 0
        
        for (index, classItem) in sortedClasses.enumerated() {
            let status = getClassStatus(classItem, at: currentTime)
            if status == .current || status == .upcoming {
                pivotIndex = index
                break
            }
        }
        
        return pivotIndex / groupSize
    }
    
    private func isLastClassInGroup(index: Int, groupSize: Int, totalClasses: Int) -> Bool {
        let groupIndex = index / groupSize
        let groupStart = groupIndex * groupSize
        let groupEnd = min(groupStart + groupSize, totalClasses)
        
        return index == groupEnd - 1
    }
}
