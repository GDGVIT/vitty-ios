//
//  LectureItemView.swift
//  VITTY
//
//  Created by Rujin Devkota on 2/27/25.
//

import SwiftUI

struct LectureItemView: View {
    let lecture: Lecture
    let selectedDayIndex: Int
    let allLectures: [Lecture]
    var onTap: () -> Void
    
    @State private var currentTime = Date()
    @State private var timer: Timer?
    
    private var currentDayIndex: Int {
        let calendar = Calendar.current
        let today = calendar.component(.weekday, from: currentTime)
        
        switch today {
        case 2: return 0
        case 3: return 1
        case 4: return 2
        case 5: return 3
        case 6: return 4
        case 7: return 5
        case 1: return 6
        default: return 0
        }
    }
    
    private var isCurrentClass: Bool {
        let calendar = Calendar.current
        
        guard selectedDayIndex == currentDayIndex else {
            return false
        }
        
        let currentHour = calendar.component(.hour, from: currentTime)
        let currentMinute = calendar.component(.minute, from: currentTime)
        let currentTimeInMinutes = currentHour * 60 + currentMinute
        
        guard let startTime = parseTime(lecture.startTime),
              let endTime = parseTime(lecture.endTime) else {
            return false
        }
        
        return currentTimeInMinutes >= startTime && currentTimeInMinutes < endTime
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(lecture.name)
                .font(Font.custom("Poppins-Bold", size: 18))
                .foregroundColor(.white)
                .padding(.top, 16)
                .padding(.horizontal, 16)
            
            HStack {
                Text("\(formatTime(time: lecture.startTime)) - \(formatTime(time: lecture.endTime)) | \(lecture.slot)")
                    .font(Font.custom("Poppins-Regular", size: 14))
                    .foregroundColor(Color("Accent"))
                
                Spacer()
                
                if !lecture.venue.isEmpty {
                    Button(action: onTap) {
                        HStack {
                            Image("compass")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 15, height: 15)
                            
                            Text(lecture.venue)
                                .font(Font.custom("Poppins-Regular", size: 14))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 22)
                                .stroke(Color("Accent"), lineWidth: 1)
                        )
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 128)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("Secondary").opacity(0.9))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color("Accent"), lineWidth: isCurrentClass ? 1 : 0)
        )
        .animation(.easeInOut(duration: 0.3), value: isCurrentClass)
        .onAppear {
            startSmartTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    // MARK: - Smart Timer Implementation
    
    private func startSmartTimer() {
        currentTime = Date()
        scheduleNextUpdate()
    }
    
    private func scheduleNextUpdate() {
        timer?.invalidate()
        
        guard let nextUpdateTime = calculateNextUpdateTime() else {
            // No more updates needed today, schedule for tomorrow
            scheduleEndOfDayUpdate()
            return
        }
        
        let timeInterval = nextUpdateTime.timeIntervalSince(currentTime)
        
        // Ensure we don't schedule negative or zero intervals
        let safeInterval = max(timeInterval, 1.0)
        
        timer = Timer.scheduledTimer(withTimeInterval: safeInterval, repeats: false) { _ in
            currentTime = Date()
            scheduleNextUpdate() // Schedule the next update
        }
    }
    
    private func calculateNextUpdateTime() -> Date? {
        let calendar = Calendar.current
        let now = currentTime
        
        // Only calculate for current day
        guard selectedDayIndex == currentDayIndex else {
            return nil
        }
        
        // Get all relevant times for today
        var relevantTimes: [Date] = []
        
        // Add start and end times for all lectures today
        for lecture in allLectures {
            if let startTime = parseTimeToDate(lecture.startTime) {
                relevantTimes.append(startTime)
            }
            
            if let endTime = parseTimeToDate(lecture.endTime) {
                // Add 10 minutes after end time for final update
                let tenMinutesAfter = calendar.date(byAdding: .minute, value: 10, to: endTime)
                if let finalTime = tenMinutesAfter {
                    relevantTimes.append(finalTime)
                }
            }
        }
        
        // Sort times and find the next one after current time
        let sortedTimes = relevantTimes.sorted()
        
        for time in sortedTimes {
            if time > now {
                return time
            }
        }
        
        return nil // No more updates needed today
    }
    
    private func scheduleEndOfDayUpdate() {
        // Schedule update for next day at midnight + 1 minute
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: currentTime)!
        let nextMidnight = calendar.startOfDay(for: tomorrow)
        let nextUpdate = calendar.date(byAdding: .minute, value: 1, to: nextMidnight)!
        
        let timeInterval = nextUpdate.timeIntervalSince(currentTime)
        
        if timeInterval > 0 {
            timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { _ in
                currentTime = Date()
                scheduleNextUpdate()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Helper Functions
    
   
    
    
    
    
        
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
}
