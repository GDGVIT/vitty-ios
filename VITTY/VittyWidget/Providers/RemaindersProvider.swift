//
//  Remainders.swift
//  VITTY
//
//  Created by Rujin Devkota on 6/12/25.
//
import SwiftUI
import WidgetKit
import SwiftData

struct RemindersProvider: TimelineProvider {
    
    private func getSharedContainer() -> ModelContainer? {
        let appGroupContainerID = "group.com.gdscvit.vittyioswidget"
        let config = ModelConfiguration(appGroupContainerID)
        
        return try? ModelContainer(for: TimeTable.self, Remainder.self, configurations: config)
    }
    
    private func fetchRemindersForDate(_ date: Date) -> [Remainder] {
        guard let container = getSharedContainer() else { return [] }
        let context = ModelContext(container)
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? Date()
        
        let predicate = #Predicate<Remainder> { reminder in
            reminder.date >= startOfDay &&
            reminder.date < endOfDay &&
            !reminder.isCompleted
        }
        
        let descriptor = FetchDescriptor<Remainder>(predicate: predicate)
        
        do {
            let reminders = try context.fetch(descriptor)
            return reminders.sorted { $0.startTime < $1.startTime }
        } catch {
            print("Error fetching reminders: \(error)")
            return []
        }
    }
    
    private func fetchUpcomingReminders(startingFrom date: Date, days: Int = 7) -> [Remainder] {
        guard let container = getSharedContainer() else { return [] }
        let context = ModelContext(container)
        
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: date)
        let endDate = calendar.date(byAdding: .day, value: days, to: startDate) ?? Date()
        
        let predicate = #Predicate<Remainder> { reminder in
            reminder.date >= startDate &&
            reminder.date < endDate &&
            !reminder.isCompleted
        }
        
        let descriptor = FetchDescriptor<Remainder>(predicate: predicate)
        
        do {
            let reminders = try context.fetch(descriptor)
            return reminders.sorted { reminder1, reminder2 in
                if reminder1.date == reminder2.date {
                    return reminder1.startTime < reminder2.startTime
                }
                return reminder1.date < reminder2.date
            }
        } catch {
            print("Error fetching upcoming reminders: \(error)")
            return []
        }
    }
    private func getSmartWidgetContent(for family: WidgetFamily = .systemLarge) -> (assignments: [Assignment], title: String, isEmpty: Bool) {
        let calendar = Calendar.current
        let today = Date()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? Date()
        
       
        let todaysReminders = fetchRemindersForDate(today).filter { $0.startTime > Date() }
        let tomorrowsReminders = fetchRemindersForDate(tomorrow)
        let dayAfterTomorrow = calendar.date(byAdding: .day, value: 2, to: today) ?? Date()
        let upcomingReminders = fetchUpcomingReminders(startingFrom: dayAfterTomorrow, days: 5)
        let nextWeekStart = calendar.date(byAdding: .day, value: 7, to: today) ?? Date()
        let nextWeekReminders = fetchUpcomingReminders(startingFrom: nextWeekStart, days: 7)
     
        let todayAssignments = convertRemindersToAssignments(todaysReminders, for: .dueToday)
        let tomorrowAssignments = convertRemindersToAssignments(tomorrowsReminders, for: .dueTomorrow)
        let upcomingAssignments = convertRemindersToAssignments(upcomingReminders, for: .upcoming)
        let nextWeekAssignments = convertRemindersToAssignments(nextWeekReminders, for: .upcoming)
        
        // Handle based on widget family
        if family == .systemMedium {
            // Medium widget: Show only highest priority category
            if !todayAssignments.isEmpty {
                return (assignments: Array(todayAssignments.prefix(2)), title: "Due Today", isEmpty: false)
            } else if !tomorrowAssignments.isEmpty {
                return (assignments: Array(tomorrowAssignments.prefix(2)), title: "Due Tomorrow", isEmpty: false)
            } else if !upcomingAssignments.isEmpty {
                return (assignments: Array(upcomingAssignments.prefix(2)), title: "Upcoming Reminders", isEmpty: false)
            } else if !nextWeekAssignments.isEmpty {
                return (assignments: Array(nextWeekAssignments.prefix(2)), title: "Next Week", isEmpty: false)
            } else {
                return (assignments: [], title: "No Reminders", isEmpty: true)
            }
        } else {
            // Large widget: Show multiple categories with priority
            var combinedAssignments: [Assignment] = []
            var primaryTitle = ""
            
            if !todayAssignments.isEmpty {
                combinedAssignments.append(contentsOf: todayAssignments)
                primaryTitle = "Due Today"
                
               
                combinedAssignments.append(contentsOf: tomorrowAssignments)
                combinedAssignments.append(contentsOf: upcomingAssignments)
                combinedAssignments.append(contentsOf: nextWeekAssignments)
                
            } else if !tomorrowAssignments.isEmpty {
                combinedAssignments.append(contentsOf: tomorrowAssignments)
                primaryTitle = "Due Tomorrow"
                
                combinedAssignments.append(contentsOf: upcomingAssignments)
                combinedAssignments.append(contentsOf: nextWeekAssignments)
                
            } else if !upcomingAssignments.isEmpty {
                combinedAssignments.append(contentsOf: upcomingAssignments)
                primaryTitle = "Upcoming Reminders"
              
                combinedAssignments.append(contentsOf: nextWeekAssignments)
                
            } else if !nextWeekAssignments.isEmpty {
                combinedAssignments.append(contentsOf: nextWeekAssignments)
                primaryTitle = "Next Week"
            } else {
                return (assignments: [], title: "No Reminders", isEmpty: true)
            }
            
            return (assignments: combinedAssignments, title: primaryTitle, isEmpty: false)
        }
    }

    
    func categorizeAssignmentsForLargeWidget(_ assignments: [Assignment], primaryTitle: String) -> (primary: [Assignment], secondary: [Assignment], secondaryTitle: String?) {
        switch primaryTitle {
        case "Due Today":
            let todayAssignments = assignments.filter { $0.category == .dueToday }
            let otherAssignments = assignments.filter { $0.category != .dueToday }
            let secondaryTitle = otherAssignments.isEmpty ? nil : "Tomorrow & Later"
            return (primary: todayAssignments, secondary: otherAssignments, secondaryTitle: secondaryTitle)
            
        case "Due Tomorrow":
            let tomorrowAssignments = assignments.filter { $0.category == .dueTomorrow }
            let otherAssignments = assignments.filter { $0.category != .dueTomorrow }
            let secondaryTitle = otherAssignments.isEmpty ? nil : "Later This Week"
            return (primary: tomorrowAssignments, secondary: otherAssignments, secondaryTitle: secondaryTitle)
            
        case "Upcoming Reminders":
            
            let primaryAssignments = Array(assignments.prefix(3))
            let secondaryAssignments = Array(assignments.dropFirst(3))
            let secondaryTitle = secondaryAssignments.isEmpty ? nil : "Next Week"
            return (primary: primaryAssignments, secondary: secondaryAssignments, secondaryTitle: secondaryTitle)
            
        default:
            return (primary: assignments, secondary: [], secondaryTitle: nil)
        }
    }
    
     func convertRemindersToAssignments(_ reminders: [Remainder], for category: AssignmentCategory) -> [Assignment] {
        return reminders.map { reminder in
            let timeRange = formatTimeRange(start: reminder.startTime, end: reminder.endTime)
            let hoursLeft = calculateHoursLeft(until: reminder.startTime, for: category)
            let priority = calculatePriority(for: reminder, category: category)
            let subject = "\(reminder.subject) - \(reminder.courseCode)"
            
            return Assignment(
                title: reminder.title,
                timeRange: timeRange,
                subject: subject,
                hoursLeft: hoursLeft,
                priority: priority,
                category: category
            )
        }
    }
    
    private func formatTimeRange(start: Date, end: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let startTime = formatter.string(from: start)
        let endTime = formatter.string(from: end)
        return "\(startTime) - \(endTime)"
    }
    
 
    private func calculateHoursLeft(until date: Date, for category: AssignmentCategory) -> String {
        let now = Date()
        let timeInterval = date.timeIntervalSince(now)
        
       
        if timeInterval < 0 && category == .dueToday {
            return "Overdue"
        } else if timeInterval < 0 {
          
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
        
        if timeInterval < 3600 {
            let minutes = max(0, Int(timeInterval / 60))
            return "\(String(format: "%02d", minutes)) mins left"
        } else if timeInterval < 86400 {
            let hours = Int(timeInterval / 3600)
            let minutes = Int((timeInterval.truncatingRemainder(dividingBy: 3600)) / 60)
            return "\(String(format: "%02d", hours)):\(String(format: "%02d", minutes)) hrs left"
        } else {
            let days = Int(timeInterval / 86400)
            let hours = Int((timeInterval.truncatingRemainder(dividingBy: 86400)) / 3600)
            
          
            if category == .upcoming || category == .dueTomorrow {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM d"
                return formatter.string(from: date)
            }
            
            
            if days > 0 {
                return "\(days)d \(hours)h left"
            } else {
                return "\(hours)h left"
            }
        }
    }
    
    
    private func calculatePriority(for reminder: Remainder, category: AssignmentCategory) -> AssignmentPriority {
        let now = Date()
        let timeUntilStart = reminder.startTime.timeIntervalSince(now)
        
        switch category {
        case .dueToday:
            if timeUntilStart < 0 {
                return .high
            } else if timeUntilStart < 3600 {
                return .high
            } else if timeUntilStart < 10800 {
                return .medium
            } else {
                return .medium
            }
        case .dueTomorrow:
          
            if timeUntilStart < 43200 {
                return .medium
            } else {
                return .low
            }
        case .upcoming:
            let daysUntil = timeUntilStart / 86400
            if daysUntil <= 2 {
                return .medium
            } else {
                return .low
            }
        }
    }
    
    func placeholder(in context: Context) -> SmartDueEntry {
        SmartDueEntry(
            date: Date(),
            assignments: [
                Assignment(
                    title: "Submit Assignment",
                    timeRange: "2:00 PM - 4:00 PM",
                    subject: "Software Engineering - CSE3001",
                    hoursLeft: "02:30 hrs left",
                    priority: .high,
                    category: .dueToday
                ),
                Assignment(
                    title: "Lab Report",
                    timeRange: "10:00 AM - 12:00 PM",
                    subject: "Physics Lab - PHY2001",
                    hoursLeft: "Jan 15",
                    priority: .medium,
                    category: .dueTomorrow
                )
            ],
            widgetTitle: "Due Today",
            isEmpty: false
        )
    }
    
  
    func getSnapshot(in context: Context, completion: @escaping (SmartDueEntry) -> Void) {
        let content = getSmartWidgetContent(for: context.family)
        
        let entry = SmartDueEntry(
            date: Date(),
            assignments: content.assignments,
            widgetTitle: content.title,
            isEmpty: content.isEmpty
        )
        
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SmartDueEntry>) -> Void) {
        let content = getSmartWidgetContent(for: context.family)
        
        let entry = SmartDueEntry(
            date: Date(),
            assignments: content.assignments,
            widgetTitle: content.title,
            isEmpty: content.isEmpty
        )
        
        
        let refreshInterval: TimeInterval
        if content.title == "Due Today" {
            refreshInterval = 15 * 60
        } else if content.title == "Due Tomorrow" {
            refreshInterval = 30 * 60 
        } else {
            refreshInterval = 60 * 60
        }
        
        let nextRefresh = Calendar.current.date(byAdding: .second, value: Int(refreshInterval), to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextRefresh))
        completion(timeline)
    }
}

