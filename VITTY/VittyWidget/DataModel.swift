//
//  DataModel.swift
//  VITTY
//
//  Created by Rujin Devkota on 2/25/25.
//

import SwiftUI
import WidgetKit

struct ScheduleEntry: TimelineEntry {
    var date: Date
    var total: Int
    var classes: [Classes]
    var completed: Int
}

struct Classes {
    let title: String
    let time: String
    var slot: String?
}


struct DueEntry: TimelineEntry {
    let date: Date
    let assignments: [Assignment]
    
    
    
    func dueTodayAssignments() -> [Assignment] {
        return assignments.filter { $0.category == .dueToday }
    }
    
    func upcomingAssignments() -> [Assignment] {
        return assignments.filter { $0.category == .upcoming }
    }
}

struct SmartDueEntry: TimelineEntry {
    let date: Date
    let assignments: [Assignment]
    let widgetTitle: String
    let isEmpty: Bool
}


struct Assignment {
    let title: String
    let timeRange: String
    let subject: String
    let hoursLeft: String
    let priority: AssignmentPriority
    let category: AssignmentCategory?
}

enum AssignmentCategory {
    case dueToday
    case dueTomorrow
    case upcoming
}


enum AssignmentPriority {
    case high, medium, low
    
    var color: Color {
        switch self {
        case .high:
            return .red
        case .medium:
            return .yellow
        case .low:
            return .green
        }
    }
}
