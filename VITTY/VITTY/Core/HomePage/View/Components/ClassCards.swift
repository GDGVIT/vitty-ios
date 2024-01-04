//
//  ClassCards.swift
//  VITTY
//
//  Created by Ananya George on 12/24/21.
//

import SwiftUI

struct ClassCards: View {
	var classInfo: Classes
	@State var currentClass: Bool = false
	@State var hideDescription: Bool = true

	var body: some View {
		ZStack {
			RoundedRectangle(cornerRadius: 12)
				.fill(Color.theme.secondaryBlue)
				.onTapGesture {
					withAnimation {
						hideDescription.toggle()
					}
				}
			VStack {
				subAndTime()

				if !hideDescription {
					expandedView()
						.padding(.top)
				}
			}
			.padding()
			.foregroundColor(Color.vprimary)
		}
		.padding()

		.frame(height: hideDescription ? 104 : 160)
		.onTapGesture {
			hideDescription.toggle()
		}
	}
}

struct ClassCards_Previews: PreviewProvider {
	static var previews: some View {
		ClassCards(classInfo: StringConstants.sampleClassDate)
	}
}

extension ClassCards {

	private func formatTime(_ date: Date?) -> String {
		guard let date = date else { return "" }

		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "HH:mm"
		dateFormatter.timeZone = TimeZone(identifier: "UTC")  // Set your desired time zone here

		return dateFormatter.string(from: date)
	}

	private func subAndTime() -> some View {
		HStack {
			VStack(alignment: .leading) {
				Text(classInfo.courseName ?? "Course Name")
					.font(Font.custom("Poppins-SemiBold", size: 15))
					.foregroundColor(Color.white)
					.padding(.bottom, 4)

				HStack(spacing: 0) {
					var _: () = print("my start time: ", classInfo.startTime ?? "no start time")

					Text(formatTime(classInfo.startTime))
					Text("-")
					Text(formatTime(classInfo.endTime))

					var _: () = print("my end time: ", classInfo.endTime ?? "no start time")

				}
				.font(Font.custom("Poppins-Regular", size: 14))
			}
			.padding(5)
			Spacer()
		}
	}

	private func expandedView() -> some View {
		HStack {
			Text("\(classInfo.slot ?? "Slot")")
				.font(Font.custom("Poppins-Regular", size: 14))
			Spacer()

			HStack {
				Text("\(classInfo.location ?? "Location")")
					.font(Font.custom("Poppins-Regular", size: 14))
				Image(systemName: "mappin.and.ellipse")
			}
			.padding(5)
			.overlay(
				RoundedRectangle(cornerRadius: 15).stroke(lineWidth: 1)
					.foregroundColor(Color.vprimary)
			)
			.onTapGesture {
				ClassCardViewModel.classCardVM.navigateToClass(at: classInfo.location ?? "SJT")
			}
		}
	}
}
