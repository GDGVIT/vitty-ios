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
