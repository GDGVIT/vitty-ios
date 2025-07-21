//
//  LectureDetailView.swift
//  VITTY
//
//  Created by Chandram Dutta on 17/02/24.
//

import MapKit
import SwiftUI

struct LectureDetailView: View {
	let lecture: Lecture
	@Environment(\.dismiss) var dismiss

	var body: some View {
		ZStack(alignment: .topLeading) {
			VStack(alignment: .leading) {
				Map {
					Marker(lecture.venue, coordinate: determineCoordinates(venue: lecture.venue))
				}
				.mapStyle(.standard)
				VStack(alignment: .leading) {
					HStack {
						Text(lecture.name)
							.font(.headline)
							.bold()
						Spacer()
						Text(lecture.slot).font(.caption)
							.foregroundColor(Color("Accent"))
					}
					HStack {
						Text(lecture.code)
							.bold()
						Spacer()
						Text(
							"\(formatTime(time: lecture.startTime)) - \(formatTime(time: lecture.endTime))"
						)
						.foregroundColor(Color("Accent"))
						.font(.caption)
					}
				}
				.padding()
			}
			.background(Color("Background"))
			Button(action: {
				dismiss()
			}) {
				Image(systemName: "xmark")
					.padding()
			}
			.foregroundColor(Color("Background"))
			.background(.white)
			.frame(width: 40, height: 40)
			.clipShape(RoundedRectangle(cornerRadius: 10))
			.padding()
		}
	}

	private func determineCoordinates(venue: String) -> CLLocationCoordinate2D {
		if venue.starts(with: "TT") {
			return CLLocationCoordinate2D(latitude: 12.97061, longitude: 79.15962)
		}
		else if venue.starts(with: "SJT") {
			return CLLocationCoordinate2D(latitude: 12.97103, longitude: 79.16395)
		}
		else if venue.starts(with: "CDMM") {
			return CLLocationCoordinate2D(latitude: 12.96915, longitude: 79.15494)
		}
		else if venue.starts(with: "MB") {
			return CLLocationCoordinate2D(latitude: 12.96919, longitude: 79.15596)
		}
		else if venue.starts(with: "MGB") {
			return CLLocationCoordinate2D(latitude: 12.97217, longitude: 79.16792)
		}
		else if venue.starts(with: "SMV") {
			return CLLocationCoordinate2D(latitude: 12.96923, longitude: 79.15775)
		}
		else if venue.starts(with: "PRP") {
			return CLLocationCoordinate2D(latitude: 12.97106, longitude: 79.16639)
		}
		else if venue.starts(with: "CBMR") {
			return CLLocationCoordinate2D(latitude: 12.96917, longitude: 79.15498)
		}
		else if venue.starts(with: "GDN") {
			return CLLocationCoordinate2D(latitude: 12.96988, longitude: 79.15487)
		}
		else {
			return CLLocationCoordinate2D(latitude: 12.96972, longitude: 79.15658)
		}
	}
    
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
