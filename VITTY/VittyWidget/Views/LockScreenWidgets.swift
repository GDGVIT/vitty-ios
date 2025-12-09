//
//  LockScreenWidgets.swift
//  VittyWidget
//
//  Created on 6/12/25.
//

import SwiftUI
import WidgetKit


struct CircularLockScreenWidgetView: View {
    var entry: ScheduleEntry
    
    var body: some View {
        ZStack {
            
            Circle()
                .stroke(.white.opacity(0.2), lineWidth: 4.5)
            
     
            if entry.total > 0 {
                let progress = CGFloat(entry.completed) / CGFloat(entry.total)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        .tint,
                        style: StrokeStyle(lineWidth: 4.5, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
            }
            
           
            VStack(spacing: 1) {
                if let nextClass = entry.classes.first {
                
                    Text(formatTime(nextClass.time))
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    
                
                    if entry.total > 0 {
                        Text("\(entry.completed)/\(entry.total)")
                            .font(.system(size: 7, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                } else if entry.completed == entry.total && entry.total > 0 {
                   
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.tint)
                    
                    Text("Done")
                        .font(.system(size: 7, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                } else {
                    
                    Image(systemName: "calendar")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    private func formatTime(_ timeString: String) -> String {
        let components = timeString.components(separatedBy: " - ")
        guard let startTime = components.first else { return "" }
        return startTime
    }
}

// MARK: - Rectangular Lock Screen Widget
struct RectangularLockScreenWidgetView: View {
    var entry: ScheduleEntry
    
    var body: some View {
        HStack(spacing: 10) {
            
            VStack(spacing: 1) {
                if entry.total > 0 {
                    ZStack {
                        
                        Circle()
                            .stroke(.white.opacity(0.15), lineWidth: 3.5)
                            .frame(width: 26, height: 26)
                        
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(entry.completed) / CGFloat(entry.total))
                            .stroke(
                                .tint,
                                style: StrokeStyle(lineWidth: 3.5, lineCap: .round)
                            )
                            .frame(width: 26, height: 26)
                            .rotationEffect(.degrees(-90))
                        
                 
                        Text("\(entry.completed)")
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                    }
                    
         
                    Text("/\(entry.total)")
                        .font(.system(size: 7, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                } else {
                    Image(systemName: "calendar")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 32)
            
           
            VStack(alignment: .leading, spacing: 3) {
                if let currentClass = getCurrentClass() {
                    
                    HStack(spacing: 5) {
                        Circle()
                            .fill(.tint)
                            .frame(width: 5, height: 5)
                        
                        Text("Now: \(currentClass.title)")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                    }
                    
                    if let nextClass = getNextUpcomingClass() {
                        Text("Next: \(nextClass.title) • \(formatTime(nextClass.time))")
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    } else {
                        Text("\(formatTime(currentClass.time))")
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                } else if let nextClass = entry.classes.first {
                    
                    Text(nextClass.title)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 8))
                        Text("\(formatTime(nextClass.time))")
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                    }
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                } else if entry.completed == entry.total && entry.total > 0 {
                    
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 10))
                        Text("All \(entry.total) classes completed")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                    }
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    
                    Text("Great work today! 🎉")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                } else {
                    // No classes
                    HStack(spacing: 4) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 10))
                        Text("No classes today")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                    }
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 6)
    }
    
    private func getCurrentClass() -> Classes? {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let calendar = Calendar.current
        let now = Date()
        
        return entry.classes.first { classItem in
            let components = classItem.time.components(separatedBy: " - ")
            guard components.count == 2,
                  let startTime = formatter.date(from: components[0]),
                  let endTime = formatter.date(from: components[1]) else {
                return false
            }
            
            let startToday = calendar.date(
                bySettingHour: calendar.component(.hour, from: startTime),
                minute: calendar.component(.minute, from: startTime),
                second: 0,
                of: now
            )
            
            let endToday = calendar.date(
                bySettingHour: calendar.component(.hour, from: endTime),
                minute: calendar.component(.minute, from: endTime),
                second: 0,
                of: now
            )
            
            guard let start = startToday, let end = endToday else { return false }
            return now >= start && now <= end
        }
    }
    
    private func getNextUpcomingClass() -> Classes? {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let calendar = Calendar.current
        let now = Date()
        
        let upcoming = entry.classes.filter { classItem in
            let components = classItem.time.components(separatedBy: " - ")
            guard components.count == 2,
                  let endTime = formatter.date(from: components[1]) else {
                return false
            }
            
            let endToday = calendar.date(
                bySettingHour: calendar.component(.hour, from: endTime),
                minute: calendar.component(.minute, from: endTime),
                second: 0,
                of: now
            )
            
            guard let end = endToday else { return false }
            return now < end
        }
        
        return upcoming.first
    }
    
    private func formatTime(_ timeString: String) -> String {
        let components = timeString.components(separatedBy: " - ")
        guard let startTime = components.first else { return "" }
        return startTime
    }
}

// MARK: - Inline Lock Screen Widget
struct InlineLockScreenWidgetView: View {
    var entry: ScheduleEntry
    
    var body: some View {
        HStack(spacing: 5) {
            if let currentClass = getCurrentClass() {
                Image(systemName: "clock.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(.tint)
                Text("\(currentClass.title) • \(formatTime(currentClass.time))")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
            } else if let nextClass = entry.classes.first {
                Image(systemName: "calendar")
                    .font(.system(size: 10))
                    .foregroundStyle(.tint)
                Text("Next: \(nextClass.title) at \(formatTime(nextClass.time))")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
            } else if entry.completed == entry.total && entry.total > 0 {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(.tint)
                Text("All \(entry.total) classes completed")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
            } else {
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                Text("No classes today")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }
    
    private func getCurrentClass() -> Classes? {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let calendar = Calendar.current
        let now = Date()
        
        return entry.classes.first { classItem in
            let components = classItem.time.components(separatedBy: " - ")
            guard components.count == 2,
                  let startTime = formatter.date(from: components[0]),
                  let endTime = formatter.date(from: components[1]) else {
                return false
            }
            
            let startToday = calendar.date(
                bySettingHour: calendar.component(.hour, from: startTime),
                minute: calendar.component(.minute, from: startTime),
                second: 0,
                of: now
            )
            
            let endToday = calendar.date(
                bySettingHour: calendar.component(.hour, from: endTime),
                minute: calendar.component(.minute, from: endTime),
                second: 0,
                of: now
            )
            
            guard let start = startToday, let end = endToday else { return false }
            return now >= start && now <= end
        }
    }
    
    private func formatTime(_ timeString: String) -> String {
        let components = timeString.components(separatedBy: " - ")
        guard let startTime = components.first else { return "" }
        return startTime
    }
}

