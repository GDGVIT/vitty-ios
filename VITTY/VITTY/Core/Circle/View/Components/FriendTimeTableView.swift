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
	@EnvironmentObject private var authState: AuthService
	@Environment(CommunityPageViewModel.self) private var communityPageViewModel
	@State var tabSelected: Int = Date.convertToMondayWeek()

	var body: some View {
		VStack {
			HStack {
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
				Button(action: {
					let url = URL(
						string: "\(APIConstants.base_url)/api/v2/friends/\(friend.username)"
					)!
					var request = URLRequest(url: url)

					request.httpMethod = "DELETE"
					request.addValue(
						"Token \(authState.token)",
						forHTTPHeaderField: "Authorization"
					)

					let task = URLSession.shared.dataTask(with: request) {
						(data, response, error) in
						// Handle the response here
						if let error = error {
							print("Error: \(error.localizedDescription)")
							return
						}
					}

					// Start the URLSession task
					task.resume()
					communityPageViewModel.fetchData(
						from: "\(APIConstants.base_url)/api/v2/friends/\(authState.username)/",
						token: authState.token,
						loading: false
					)
					dismiss()
				}) {
					Image(systemName: "person.fill.badge.minus")
						.foregroundColor(.white)
				}
			}
			.padding(.horizontal)
			ScheduleTabBarView(tabSelected: $tabSelected)
			timeTableView()
		}
		.padding(.top)
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
