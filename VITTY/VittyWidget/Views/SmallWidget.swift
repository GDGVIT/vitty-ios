//
//  SmallWidget.swift
//  VITTY
//
//  Created by Rujin Devkota on 2/25/25.
//

//
//  SmallWidget.swift
//  VITTY
//
//  Created by Rujin Devkota on 2/25/25.
//

import WidgetKit
import SwiftUI


struct DueSmallWidgetView: View {
    var entry: SmartDueEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
           
            HStack {
                Text(entry.widgetTitle)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
            }
            
            if entry.isEmpty {
                ZStack {
                    Color(.secondaryBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    VStack(spacing: 4) {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .font(.system(size: 20))
                            .foregroundColor(.gray)
                        
                        Text("No reminders")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)
                    }
                }
            } else if let assignment = entry.assignments.first {
                ZStack {
                    Color(.secondaryBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(assignment.title)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                            Circle()
                                .fill(assignment.priority.color)
                                .frame(width: 8, height: 8)
                        }
                        
                        Text(assignment.timeRange)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(assignment.subject)
                            .font(.system(size: 10))
                            .lineLimit(1)
                            .foregroundColor(.accentBlue)
                        
                        Text(assignment.hoursLeft)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.accentBlue)
                    }.padding(3)
                }
            }
            
            Spacer()
        }
       
    }
}

struct ScheduleSmallWidgetView: View {
    var entry: ScheduleEntry
    
    var body: some View {
        VStack(alignment: .leading) {
            Spacer().frame(height: 10)
            
            WidgetTitle(title: "Schedule", fontSize: 12.0)
            Spacer().frame(height: 15)
            
            CircleProgressView(
                progress: entry.completed,
                total: entry.total,
                circleSize: 45,
                lineWidth: 12,
                fontSize: 12
            )
            .frame(maxWidth: .infinity)
            
            Spacer().frame(height: 20)
            
            if let nextClass = getUpcomingClass(from: entry.classes) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Up Next")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white)
                    
                    Text(nextClass.title)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text(nextClass.time)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color(.accentBlue))
                }
            } else {
                Text("No more classes")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
        
    }
    
    // MARK: - Helper Function
    func getUpcomingClass(from classes: [Classes]) -> Classes? {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let calendar = Calendar.current
        
        let upcoming = classes.filter { classItem in
            let components = classItem.time.components(separatedBy: " - ")
            guard components.count == 2,
                  let endTime = formatter.date(from: components[1]),
                  let endToday = calendar.date(
                      bySettingHour: calendar.component(.hour, from: endTime),
                      minute: calendar.component(.minute, from: endTime),
                      second: 0,
                      of: Date()
                  ) else {
                return false
            }
            return Date() <= endToday
        }
        
        return upcoming.first
    }
}
