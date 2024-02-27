//
//  LectureDetailView.swift
//  VITTY
//
//  Created by Chandram Dutta on 17/02/24.
//

import SwiftUI
import MapKit

struct LectureDetailView: View {
	let lecture: Lecture
	@Environment(\.dismiss) var dismiss
	
	
	var body: some View {
		ZStack(alignment: .topLeading) {
			VStack{
				Map {
					Marker(lecture.venue, coordinate: determineCoordinates(venue: lecture.venue))
				}.mapStyle(.hybrid)
				Text(lecture.name)
					.font(.title)
					.bold()
					.padding()
			}
			Button (action: {
				dismiss()
			}) {
				Image(systemName: "xmark")
					.padding()
			}
			.foregroundColor(.white)
			.background(Color("Secondary"))
			.frame(width: 40, height: 40)
			.clipShape(RoundedRectangle(cornerRadius: 10))
			.padding()
		}
	}
	
	private func determineCoordinates(venue: String) -> CLLocationCoordinate2D {
		if venue.starts(with: "TT") {
			return CLLocationCoordinate2D(latitude: 12.97061, longitude: 79.15962)
		} else if venue.starts(with: "SJT") {
			return CLLocationCoordinate2D(latitude: 12.97103, longitude:  79.16395)
		} else if venue.starts(with: "CDMM") {
			return CLLocationCoordinate2D(latitude: 12.96915, longitude: 79.15494)
		} else if venue.starts(with: "MB") {
			return CLLocationCoordinate2D(latitude: 12.96919, longitude: 79.15596)
		} else if venue.starts(with: "MGB") {
			return CLLocationCoordinate2D(latitude: 12.97217, longitude: 79.16792)
		} else if venue.starts(with: "SMV") {
			return CLLocationCoordinate2D(latitude: 12.96923, longitude: 79.15775)
		} else if venue.starts(with: "PRP") {
			return CLLocationCoordinate2D(latitude: 12.97106, longitude: 79.16639)
		} else if venue.starts(with: "CBMR") {
			return CLLocationCoordinate2D(latitude: 12.96917, longitude: 79.15498)
		} else if venue.starts(with: "GDN") {
			return CLLocationCoordinate2D(latitude: 12.96988, longitude: 79.15487)
		} else {
			return CLLocationCoordinate2D(latitude: 12.96972, longitude: 79.15658)
		}
	}
}
//
//#Preview {
//    LectureDetailView()
//}
