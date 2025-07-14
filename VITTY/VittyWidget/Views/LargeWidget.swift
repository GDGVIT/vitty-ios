//
//  LargeWidget.swift
//  VITTY
//
//  Created by Rujin Devkota on 2/25/25.
//
import SwiftUI
import WidgetKit


struct LargeDueWidgetView: View {
    var entry: SmartDueEntry
    private let provider = RemindersProvider()

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            WidgetTitle(title: entry.widgetTitle, fontSize: 16.0)

            if !entry.isEmpty {
                let categorizedAssignments = provider.categorizeAssignmentsForLargeWidget(entry.assignments, primaryTitle: entry.widgetTitle)
                
      
                VStack(alignment: .leading, spacing: 6) {
                    Spacer().frame(height: 3)
                    
                    VStack(spacing: 6) {
                        ForEach(Array(categorizedAssignments.primary.prefix(3).enumerated()), id: \.offset) { index, assignment in
                            AssignmentRow(assignment: assignment, titleFont: 15, subjectFont: 13, hoursLeft: 13)
                        }
                    }
                }
                
         
                if !categorizedAssignments.secondary.isEmpty, let secondaryTitle = categorizedAssignments.secondaryTitle {
                    Spacer().frame(height: 5)
                    VStack(alignment: .leading, spacing: 6) {
                        Text(secondaryTitle)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)

                        VStack(spacing: 6) {
                            ForEach(Array(categorizedAssignments.secondary.prefix(3).enumerated()), id: \.offset) { index, assignment in
                                AssignmentRow(assignment: assignment, titleFont: 14, subjectFont: 12, hoursLeft: 12)
                            }
                        }
                    }
                }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: 28))
                        .foregroundColor(.gray)
                    
                    Text("No reminders found")
                        .foregroundColor(.gray)
                        .font(.system(size: 16, weight: .medium))
                    
                    Text("Check back later for updates")
                        .foregroundColor(.gray)
                        .font(.system(size: 14))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            Spacer()
        }
        .padding([.leading,.vertical], 12).padding([.top], 8).padding([.bottom], 10)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct ScheduleLargeWidgetView: View {
    var entry: ScheduleEntry

    var body: some View {
        HStack(alignment: .top) {
            Spacer().frame(width: 2)
            VStack(alignment: .leading, spacing: 15) {
                Spacer().frame(height: 5)
                WidgetTitle(title: "Today's Schedule", fontSize: 18)
                Spacer().frame(height: 5)
                
                HStack(alignment: .top, spacing: 15) {
                    if entry.classes.isEmpty {
                        VStack {
                            Text("No classes today! Time to\n relax and recharge!")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                            Spacer().frame(height: 30)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    else if entry.completed == entry.total {
                       
                        VStack {
                            Spacer()
                            CircleProgressView(
                                progress: entry.completed,
                                total: entry.total,
                                circleSize: 60,
                                lineWidth: 12,
                                fontSize: 16
                            )
                            .frame(width: 70, height: 70)
                            Spacer()
                        }
                        .frame(width: 70)
                        
                        Image("allclassesline")
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Spacer().frame(height: 15)
                            Text("You're all set for the day.")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)

                            Text("Time to relax.")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                      
                        VStack {
                            Spacer()
                            CircleProgressView(
                                progress: entry.completed,
                                total: entry.total,
                                circleSize: 60,
                                lineWidth: 12,
                                fontSize: 16
                            )
                            .frame(width: 70, height: 70)
                            Spacer()
                        }
                        .frame(width: 70)
                        
                        Image("fourclassesline")
                        
                        VStack(alignment: .leading, spacing: 20) {
                            let displayClasses = getDisplayClasses()
                            
                            ForEach(displayClasses, id: \.title) { classItem in
                                ScheduleItemView(
                                    title: classItem.title,
                                    time: "\(classItem.time) | \(classItem.slot ?? "")"
                                )
                            }
                            
                            let remainingCount = getUpcomingClasses().count - displayClasses.count
                            if remainingCount > 0 {
                                Text("+\(remainingCount) More")
                                    .foregroundColor(.white.opacity(0.6))
                                    .font(.system(size: 14))
                            }
                        }
                    }
                }
                Spacer()
            }
            Spacer()
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 6).ignoresSafeArea()
    }
    
    private func getUpcomingClasses() -> [Classes] {
        let currentTime = Date()
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
      
        let sortedClasses = entry.classes.sorted { class1, class2 in
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
        
       
        let now = Date()
        let upcomingClasses = sortedClasses.filter { classItem in
            let timeComponents = classItem.time.components(separatedBy: " - ")
            guard timeComponents.count == 2 else { return true }
            
            let endTimeStr = timeComponents[1].trimmingCharacters(in: .whitespaces)
            guard let endTime = dateFormatter.date(from: endTimeStr) else { return true }
            
            
            let todayEnd = calendar.date(
                bySettingHour: calendar.component(.hour, from: endTime),
                minute: calendar.component(.minute, from: endTime),
                second: 0,
                of: now
            )
            
        
            if let todayEnd = todayEnd {
                return now <= todayEnd
            }
            
            return true
        }
        
        return upcomingClasses
    }
    
    private func getDisplayClasses() -> [Classes] {
        let upcomingClasses = getUpcomingClasses()
        
      
        let maxDisplay = min(4, upcomingClasses.count)
        return Array(upcomingClasses.prefix(maxDisplay))
    }
}
