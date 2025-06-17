import SwiftUI
import WidgetKit

struct ScheduleMediumWidgetView: View {
    var entry: ScheduleEntry

    var body: some View {
        HStack(alignment: .top) {
            Spacer().frame(width: 2)
            VStack(alignment: .leading, spacing: 10) {
                WidgetTitle(title: "Today's Schedule", fontSize: 15)
                Spacer().frame(height: 1)
                
                HStack(alignment: .top, spacing: 10) {
                    if entry.classes.isEmpty {
                        VStack {
                            Text("No classes today! Time to\n relax and recharge!")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                            Spacer().frame(height: 20)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    else if entry.completed == entry.total {
                      
                        CircleProgressView(
                            progress: entry.completed,
                            total: entry.total,
                            circleSize: 50,
                            lineWidth: 10,
                            fontSize: 14
                        )
                        .frame(width: 60, height: 60)
                        
                        Image("allclassesline").resizable().frame(width: 10, height: 85)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Spacer().frame(height: 10)
                            Text("You're all set for the day.")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)

                            Text("Time to relax.")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)

                    } else {
                     
                        CircleProgressView(
                            progress: entry.completed,
                            total: entry.total,
                            circleSize: 50,
                            lineWidth: 10,
                            fontSize: 14
                        )
                        .frame(width: 60, height: 60)
                        
                        Image("twoclassline").resizable().frame(width: 10, height: 85)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            let upcomingClasses = entry.classes.filter {
                                classItem in
                                let timeComponents = classItem.time.components(separatedBy: " - ")
                                guard timeComponents.count == 2 else { return false }

                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "h:mm a"
                                dateFormatter.locale = Locale(identifier: "en_US_POSIX")

                                guard let endTime = dateFormatter.date(from: timeComponents[1]) else { return false }

                              
                                let calendar = Calendar.current
                                if let todayEnd = calendar.date(
                                    bySettingHour: calendar.component(.hour, from: endTime),
                                    minute: calendar.component(.minute, from: endTime),
                                    second: 0,
                                    of: Date()
                                ) {
                                    return Date() <= todayEnd
                                }
                                return false
                            }

                            ForEach(upcomingClasses.prefix(2), id: \.title) { classItem in
                                ScheduleItemView(
                                    title: classItem.title,
                                    time: "\(classItem.time) | \(classItem.slot ?? "")"
                                )
                            }

                            if upcomingClasses.count > 2 {
                                Text("+\(upcomingClasses.count - 2) More")
                                    .foregroundColor(.white)
                                    .font(.system(size: 14))
                            }

                        }
                    }
                }
            }
            Spacer()
        }
    }
}




struct DueMediumWidgetView: View {
    var entry: SmartDueEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
          
            Spacer().frame(height: 5)
            WidgetTitle(title: entry.widgetTitle, fontSize: 12.0)
          
            
            if entry.isEmpty {
                VStack(spacing: 6) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                    
                    Text("No reminders")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack(spacing: 6) {
                 
                    ForEach(Array(entry.assignments.prefix(2).enumerated()), id: \.offset) { index, assignment in
                        AssignmentRow(
                            assignment: assignment,
                            titleFont: 14,
                            subjectFont: 10,
                            hoursLeft: 10
                        )
                    }
                }
                Spacer()
            }
        }
        .padding(12)
    }
}




struct ScheduleItemView: View {
    var title: String
    var time: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)

            Text(time)
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "#BBE7FF"))
        }
    }
}

//#Preview("Medium Schedule Widget", as: .systemMedium) {
//    VittyWidget()
//} timeline: {
//    ScheduleEntry(
//        date: Date(),
//        total: 5,
//        classes: [
//            Classes(title: "Software Engineering", time: "4:00 PM - 4:50 PM", slot: "A1 + TA1"),
//                Classes(title: "Java Programming", time: "5:00 PM - 5:50 PM", slot: "A1 + TA1"),
//            Classes(title: "Machine Learning", time: "6:00 PM - 6:50 PM", slot: "B2 + TB2")
//        ]
//    )
//}
