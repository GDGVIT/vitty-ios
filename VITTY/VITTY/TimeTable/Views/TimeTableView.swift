//
//  TimeTableView.swift
//  VITTY
//
//  Created by Chandram Dutta on 09/02/24.
//

import SwiftUI
import SwiftData

struct TimeTableView: View {
	@Environment(AuthViewModel.self) private var authViewModel
	private let daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
	
	@State private var showingSheet = false
	
	@State private var viewModel = TimeTableViewModel()
	
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
					List(viewModel.lectures.sorted(), id: \.startTime) { lecture in
						Button (action: {
							showingSheet.toggle()}){
								VStack(alignment: .leading){
									Text(lecture.name)
										.font(.headline)
									HStack{
										Text("\(formatTime(time:lecture.startTime)) - \(formatTime(time:lecture.endTime))")
										Spacer()
										Text("\(lecture.venue)")
									}
									.foregroundColor(Color.vprimary)
									.font(.caption)
								}
							}
//							.sheet(isPresented: $showingSheet) {
//								LectureDetailView(lecture: lecture)
//							}
							.listRowBackground(Color("DarkBG"))
					}
					.sheet(item: viewModel.lectures) {lecture in
						LectureDetailView(lecture: lecture)
						
					}
					.scrollContentBackground(.hidden)
					Spacer()
				}
			}
			.navigationTitle(Text("Schedule"))
			.toolbar {
				UserImage(url: authViewModel.appUser?.picture ?? "", height: 30, width: 40)
				//					.onTapGesture {
				//						viewModel.sideMenu()
				//					}
			}
		}
		.task {
			viewModel.fetchTimeTable(username: authViewModel.appUser?.username ?? "", authToken: authViewModel.appUser?.token ?? "")
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
			return(formattedTime)
		} else {
			return("Failed to parse the time string.")
		}
		
	}
}
//
//#Preview {
//	TimeTableView()
//		.preferredColorScheme(.dark)
//		.environment(AuthViewModel())
//		.modelContainer(for: TimeTable.self)
//}
