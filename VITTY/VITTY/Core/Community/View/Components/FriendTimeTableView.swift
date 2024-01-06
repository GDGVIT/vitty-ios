//
//  FriendTimeTableView.swift
//  VITTY
//
//  Created by Chandram Dutta on 06/01/24.
//

import SwiftUI

struct FriendTimeTableView: View {
	
	let friend: Friend
	
	@Environment(\.dismiss) var dismiss
	@EnvironmentObject var timetableViewModel: TimetableViewModel
	@State var tabSelected: Int = Date.convertToMondayWeek()
	
	var body: some View {
		VStack{
			HStack{
				Button(action: {
					dismiss()
				}) {
					Image(systemName: "xmark")
						.foregroundColor(.white)
				}
				.padding(.trailing)
				UserImage(url: friend.picture, height: 48, width: 48)
				Text(friend.name)
					.font(.custom("Poppins-SemiBold", size: 16))
				Spacer()
				Button(action: {}) {
					Image(systemName: "person.fill.badge.minus")
						.foregroundColor(.white)
				}
			}.padding(.horizontal)
			ScheduleTabBarView(tabSelected: $tabSelected)
			timeTableView()
		}.padding(.top)
			.background(
				Image(
					timetableViewModel.timetable[TimetableViewModel.daysOfTheWeek[tabSelected]]?
						.isEmpty ?? false ? "HomeNoClassesBG" : "HomeBG"
				)
				.resizable().scaledToFill().edgesIgnoringSafeArea(.all)
			)
			.onAppear {
				timetableViewModel.updateClassCompleted()
			}
	}
}

extension FriendTimeTableView {
	func timeTableView() -> some View {
		ScrollView {
			ForEach(timetableViewModel.timetable.keys.sorted(), id: \.self) { day in
				ForEach(timetableViewModel.timetable[day] ?? [], id: \.self) { classes in
					
					if day.description.lowercased() == TimetableViewModel.daysOfTheWeek[tabSelected]
					{
					ClassCards(classInfo: classes)
						.listRowBackground(Color.clear)
						.listRowSeparator(.hidden)
					}
				}
			}
		}
	}
}
