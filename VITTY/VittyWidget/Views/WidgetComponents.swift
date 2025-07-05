//
//  WidgetComponents.swift
//  VITTY
//
//  Created by Rujin Devkota on 2/25/25.


//

import SwiftUI
import WidgetKit

struct ScheduleRow: View {
    let className: String
    let time: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(className)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(time)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "#BBE7FF"))
            }
            
            Spacer()
        }
        .padding(.vertical, 5)
    }
}


struct AssignmentRow: View {
    var assignment: Assignment
    var titleFont : Double
    var subjectFont : Double
    var hoursLeft : Double
    
    var body: some View {
        VStack(alignment:.leading){
            ZStack {
                Color(.secondaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(assignment.title)
                                .font(.system(size: titleFont, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                           
                           
                        }
                        
                        Text(assignment.subject)
                            .font(.system(size: subjectFont ))
                            .foregroundColor(.accentBlue)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Circle()
                            .fill(assignment.priority.color)
                            .frame(width: 8, height: 8)
                        Spacer()
                        Text(assignment.hoursLeft)
                            .font(.system(size: hoursLeft, weight: .medium))
                            .foregroundColor(.accentBlue)
                    }
                }.padding(10)
               
            }.frame(height: 60)
        }
    }
}


struct WidgetTitle: View {
    let title: String
    let fontSize: Double
    
    var body: some View {
        return HStack {
            Text(title)
                .font(.system(size: fontSize, weight: .heavy))
                .foregroundStyle(Color.white)
            Spacer()
            Image("widgetIcon").resizable().frame(width: 30, height: 15)
        }
    }
}
struct CircleProgressView: View {
    var progress: Int
    var total: Int
    var circleSize: CGFloat
    var lineWidth: CGFloat
    var fontSize: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: 1)
                .stroke(Color(hex: "#BBE7FF").opacity(0.3), lineWidth: lineWidth)
                .frame(width: circleSize, height: circleSize)
            
            Circle()
                .trim(from: 0, to: CGFloat(progress) / CGFloat(total))
                .stroke(
                    Color(hex: "#BBE7FF"),
                    style: StrokeStyle(
                        lineWidth: lineWidth - 1,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
                .frame(width: circleSize, height: circleSize)
                .rotationEffect(.degrees(-90))
            
            Text("\(progress) / \(total)")
                .font(.system(size: fontSize, weight: .bold))
                .foregroundColor(.white)
        }
    }
}
