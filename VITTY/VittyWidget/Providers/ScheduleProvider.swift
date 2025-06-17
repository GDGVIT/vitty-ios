//
//  ScheduleProvider.swift
//  VITTY
//
//  Created by Rujin Devkota on 6/12/25.
//
import SwiftUI
import SwiftData
import WidgetKit

struct Provider: TimelineProvider {
    
    private func getSharedContainer() -> ModelContainer? {
          let appGroupContainerID = "group.com.gdscvit.vittyioswidget"
          let config = ModelConfiguration(
            appGroupContainerID)
        
          return try? ModelContainer(for: TimeTable.self, configurations: config)
      }
    
    private func parseTimeString(_ timeString: String) -> Date? {
           let formatter = DateFormatter()
           formatter.dateFormat = "h:mm a"
           
           // Clean the time string (remove extra spaces, etc.)
           let cleanedTime = timeString.trimmingCharacters(in: .whitespacesAndNewlines)
           
           if let time = formatter.date(from: cleanedTime) {
               // Combine with today's date
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
       
    private func fetchTodaysLectures() -> [Classes] {
        guard let container = getSharedContainer() else { return [] }
        let context = ModelContext(container)
        
        // Get current day
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        _ = formatter.string(from: Date())
        
        // Fetch timetable
        let descriptor = FetchDescriptor<TimeTable>()
        guard let timetable = try? context.fetch(descriptor).first else {
            return []
        }
       return  timetable.classesFor(date: Date())
       
    }
    
   
    
          
    func placeholder(in context: Context) -> ScheduleEntry {
        ScheduleEntry(
            date: Date(),
            total: 7,
            classes: [
                Classes(title: "Software Engineering", time: "4:00 PM - 4:50 PM", slot: "A1 + TA1")
            ], completed: 2
        )
    }
    func getSnapshot(in context: Context, completion: @escaping (ScheduleEntry) -> ()) {
        let lectures = fetchTodaysLectures()
        
        completion(ScheduleEntry(date: Date(), total: lectures.count, classes: lectures, completed: 4))
    }
    
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<ScheduleEntry>) -> ()) {
        
        let lectures = fetchTodaysLectures()
        let completed = calculateCompletedClasses(lectures)
        let entry = ScheduleEntry(date: Date(), total: lectures.count, classes: lectures,completed: completed)
        
       

        let nextRefresh = Calendar.current.date(byAdding: .hour, value: 1, to: Date())
        let timeline = Timeline(entries: [entry], policy: .after(nextRefresh ?? Date()))
        completion(timeline)
    }
    private func calculateCompletedClasses(_ classes: [Classes]) -> Int {
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        return classes.filter { classItem in
            let timeComponents = classItem.time.components(separatedBy: " - ")
            guard timeComponents.count == 2,
                  let endTime = dateFormatter.date(from: timeComponents[1]) else {
                return false
            }

            // Set today's date with class end time
            let calendar = Calendar.current
            let endTimeToday = calendar.date(
                bySettingHour: calendar.component(.hour, from: endTime),
                minute: calendar.component(.minute, from: endTime),
                second: 0,
                of: now
            )

            guard let endTimeTodayUnwrapped = endTimeToday else { return false }

            return now > endTimeTodayUnwrapped
        }.count
    }

}
