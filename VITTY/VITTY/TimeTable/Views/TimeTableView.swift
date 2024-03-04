//
//  TimeTableView.swift
//  VITTY
//
//  Created by Chandram Dutta on 09/02/24.
//

import SwiftData
import SwiftUI

struct TimeTableView: View {
	@Environment(AuthViewModel.self) private var authViewModel
	private let daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

	@State private var showingSheet = false

	@State private var viewModel = TimeTableViewModel()
	@State private var selectedLecture: Lecture? = nil

	let friend: Friend?

	var body: some View {
		NavigationStack {
			ZStack {
				Image("HomeBG")
					.resizable()
					.ignoresSafeArea()
				VStack {
					ScrollView(.horizontal) {
						HStack {
							ForEach(daysOfWeek, id: \.self) { day in
								Text(day)
									.frame(width: 60, height: 54)
									.background(
										daysOfWeek[viewModel.dayNo] == day
											? Color(Color.theme.secondary) : Color.clear
									)
									.onTapGesture {
										withAnimation {
											viewModel.dayNo = daysOfWeek.firstIndex(of: day)!
											viewModel.changeDay()
										}
									}
									.clipShape(RoundedRectangle(cornerRadius: 10))
							}
						}
					}
					.scrollIndicators(.hidden)
					.background(Color("DarkBG"))
					.clipShape(RoundedRectangle(cornerRadius: 10))
					.padding(.horizontal)
					List(viewModel.lectures.sorted()) { lecture in
						VStack(alignment: .leading) {
							Text(lecture.name)
								.font(.headline)
							HStack {
								Text(
									"\(formatTime(time: lecture.startTime)) - \(formatTime(time: lecture.endTime))"
								)
								Spacer()
								Text("\(lecture.venue)")
							}
							.foregroundColor(Color.vprimary)
							.font(.caption)
						}
						.onTapGesture {
							selectedLecture = lecture
						}
						.listRowBackground(Color("DarkBG"))
					}
					.sheet(item: $selectedLecture) { lecture in
						LectureDetailView(lecture: lecture)
					}
					.scrollContentBackground(.hidden)
					Spacer()
				}
			}
			.navigationTitle(friend?.name ?? "Schedule")
			.toolbar {
					
					Menu {
						if friend == nil {
							NavigationLink {
								SettingsView()
							} label: {
								Label("Settings", systemImage: "gear")
							}
							Button(role: .destructive) {
								authViewModel.signOut()
							} label: {
								Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
							}
						} else {
							Button{
								let url = URL(
									string: "\(APIConstants.base_url)/api/v2/friends/\(friend?.username ?? "")"
								)!
								var request = URLRequest(url: url)

								request.httpMethod = "DELETE"
								request.addValue(
									"Token \(authViewModel.appUser?.token ?? "")",
									forHTTPHeaderField: "Authorization"
								)

								let task = URLSession.shared.dataTask(with: request) {
									(data, response, error) in
									if let error = error {
										print("Error: \(error.localizedDescription)")
										return
									}
								}
								task.resume()
							} label: {
								Label("Unfriend", systemImage: "person.fill.xmark")
							}
						}
					} label: {
						UserImage(
							url: friend?.picture ?? (authViewModel.appUser?.picture ?? ""),
							height: 30,
							width: 40
						)
					}

				
			}
		}
		.task {
			viewModel.fetchTimeTable(
				username: friend?.username ?? (authViewModel.appUser?.username ?? ""),
				authToken: authViewModel.appUser?.token ?? ""
			)
		}
	}

	private func formatTime(time: String) -> String {
		var timeComponents = time.components(separatedBy: "T").last ?? ""
		timeComponents = timeComponents.components(separatedBy: "Z").first ?? ""

		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "HH:mm:ss"
		if let date = dateFormatter.date(from: timeComponents) {
			dateFormatter.dateFormat = "h:mm a"
			let formattedTime = dateFormatter.string(from: date)
			return (formattedTime)
		}
		else {
			return ("Failed to parse the time string.")
		}
	}
}
