//
//  LectureItemView.swift
//  VITTY
//
//  Created by Rujin Devkota on 2/27/25.
//

import SwiftUI

struct LectureItemView: View {
    let lecture: Lecture
    var onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(lecture.name)
                .font(Font.custom("Poppins-Bold", size: 18))
                .foregroundColor(.white)
                .padding(.top, 16)
                .padding(.horizontal, 16)
            
            HStack {
                Text("\(formatTime(time: lecture.startTime)) - \(formatTime(time: lecture.endTime))")
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
        .frame(maxWidth:.infinity).frame(height: 128)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("Secondary").opacity(0.9))
        )
    }
    
    private func formatTime(time: String) -> String {
        var timeComponents = time.components(separatedBy: "T").last ?? ""
        timeComponents = timeComponents.components(separatedBy: "Z").first ?? ""

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        if let date = dateFormatter.date(from: timeComponents) {
            dateFormatter.dateFormat = "h:mm a"
            let formattedTime = dateFormatter.string(from: date)
            return formattedTime
        } else {
            return "Failed to parse the time string."
        }
    }
}


#Preview {
    LectureItemView(
        lecture: Lecture(name: "hello", code: "qww", venue: "123", slot: "asd", type: "asad", startTime: "time1", endTime: "time")
                       , onTap: {}
                    )
}

