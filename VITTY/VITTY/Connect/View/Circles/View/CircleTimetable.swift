//
//  CircleTimetable.swift
//  VITTY
//
//  Created by Rujin Devkota on 7/18/25.
//

//
//  CircleMemberTimetableView.swift
//  VITTY
//
//  Created by Rujin Devkota on 7/18/25.
//

import OSLog
import SwiftData
import SwiftUI

struct CircleMemberTimetableView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(\.dismiss) private var dismiss
    
    private let daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    @State private var viewModel = CircleMemberTimetableViewModel()
    @State private var selectedLecture: Lecture? = nil
    @State private var isRefreshing = false
    @State private var showingRefreshAlert = false
    
    let member: CircleUserTemp
    let circleId: String
    
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: CircleMemberTimetableView.self)
    )
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()
                VStack {
                    
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(Color("Accent"))
                                .font(.title2)
                        }
                        
                        Spacer()
                        
                        Text("\(member.name)'s Timetable")
                            .font(Font.custom("Poppins-SemiBold", size: 18))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                       
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    
                    switch viewModel.stage {
                    case .loading:
                        VStack {
                            Spacer()
                            ProgressView()
                                .scaleEffect(1.2)
                            Text("Loading \(member.name)'s timetable...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                            Spacer()
                        }
                        
                    case .error:
                        VStack {
                            Spacer()
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 50))
                                .foregroundColor(.orange)
                                .padding(.bottom, 16)
                            
                            Text("Couldn't load timetable")
                                .font(Font.custom("Poppins-Bold", size: 24))
                                .padding(.bottom, 8)
                            
                            Text("Unable to fetch \(member.name)'s timetable")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.bottom, 20)
                            
                            Button(action: {
                                showingRefreshAlert = true
                            }) {
                                HStack {
                                    Image(systemName: "arrow.clockwise")
                                    Text("Try Again")
                                }
                                .foregroundColor(.white)
                                .padding()
                                .background(Color("Accent"))
                                .cornerRadius(10)
                            }
                            .disabled(isRefreshing)
                            
                            Spacer()
                        }
                        
                    case .empty:
                        VStack {
                            Spacer()
                            Image(systemName: "calendar.badge.exclamationmark")
                                .font(.system(size: 50))
                                .foregroundColor(.secondary)
                                .padding(.bottom, 16)
                            
                            Text("No timetable available")
                                .font(Font.custom("Poppins-Bold", size: 24))
                                .padding(.bottom, 8)
                            
                            Text("\(member.name) hasn't shared their timetable yet")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            Spacer()
                        }
                        
                    case .data:
                        VStack(spacing: 0) {
                            // Day selector
                            ScrollViewReader { proxy in
                                ScrollView(.horizontal) {
                                    HStack {
                                        ForEach(daysOfWeek, id: \.self) { day in
                                            Text(day)
                                                .foregroundStyle(daysOfWeek[viewModel.dayNo] == day
                                                    ? Color("Background") : Color("Accent"))
                                                .frame(width: 60, height: 54)
                                                .background(
                                                    daysOfWeek[viewModel.dayNo] == day
                                                    ? Color("Accent") : Color.clear
                                                )
                                                .onTapGesture {
                                                    withAnimation(.easeInOut(duration: 0.2)) {
                                                        viewModel.dayNo = daysOfWeek.firstIndex(of: day)!
                                                        viewModel.changeDay()
                                                        proxy.scrollTo(day, anchor: .center)
                                                    }
                                                }
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                                .id(day)
                                        }
                                    }
                                    .padding(.horizontal, 8)
                                }
                                .scrollIndicators(.hidden)
                                .onAppear {
                                    let currentDay = daysOfWeek[viewModel.dayNo]
                                    proxy.scrollTo(currentDay, anchor: .center)
                                }
                                .onChange(of: viewModel.dayNo) { oldValue, newValue in
                                    let selectedDay = daysOfWeek[newValue]
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        proxy.scrollTo(selectedDay, anchor: .center)
                                    }
                                }
                            }
                            .background(Color("Secondary"))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.horizontal)
                            
                         
                            if viewModel.lectures.isEmpty {
                                Spacer()
                                VStack(spacing: 16) {
                                    Image(systemName: "calendar.badge.exclamationmark")
                                        .font(.system(size: 50))
                                        .foregroundColor(.secondary)
                                    
                                    Text("No classes today!")
                                        .font(Font.custom("Poppins-Bold", size: 24))
                                    
                                    Text("\(member.name) has no classes on \(daysOfWeek[viewModel.dayNo])")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)
                                }
                                Spacer()
                            } else {
                                ScrollView {
                                    VStack(spacing: 12) {
                                        ForEach(viewModel.lectures.sorted()) { lecture in
                                            LectureItemView(
                                                lecture: lecture,
                                                selectedDayIndex: viewModel.dayNo,
                                                allLectures: viewModel.lectures
                                            ) {
                                                selectedLecture = lecture
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                    .padding(.top, 12)
                                    .padding(.bottom, 100)
                                }
                            }
                        }
                    }
                }
            }
        }
        .sheet(item: $selectedLecture) { lecture in
            LectureDetailView(lecture: lecture)
        }
        .alert("Refresh Timetable", isPresented: $showingRefreshAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Refresh", role: .destructive) {
                Task {
                    await refreshTimetable()
                }
            }
        } message: {
            Text("This will fetch fresh data from the server. Continue?")
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            logger.debug("CircleMemberTimetableView appeared for member: \(member.username)")
            loadCircleMemberTimetable()
        }
    }
    
    private func loadCircleMemberTimetable() {
        logger.debug("Loading circle member's timetable from API")
        
       
        let calendar = Calendar.current
        let today = calendar.component(.weekday, from: Date())
        let dayIndex = (today == 1) ? 6 : today - 2
        
        if dayIndex >= 0 && dayIndex < daysOfWeek.count {
            viewModel.dayNo = dayIndex
        } else {
            viewModel.dayNo = 0
        }
        
        Task {
            await viewModel.loadCircleMemberTimetable(
                circleId: circleId,
                memberUsername: member.username,
                authToken: authViewModel.loggedInBackendUser?.token ?? ""
            )
        }
    }
    
    private func refreshTimetable() async {
        await MainActor.run {
            isRefreshing = true
        }
        
        await viewModel.refreshCircleMemberTimetable(
            circleId: circleId,
            memberUsername: member.username,
            authToken: authViewModel.loggedInBackendUser?.token ?? ""
        )
        
        await MainActor.run {
            isRefreshing = false
        }
    }
}

// MARK: - Circle Member Timetable ViewModel
extension CircleMemberTimetableView {
    @Observable
    class CircleMemberTimetableViewModel {
        var timeTable: TimeTable?
        var stage: Stage = .loading
        var lectures = [Lecture]()
        var dayNo = Date.convertToMondayWeek()
        
        private let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: String(describing: CircleMemberTimetableViewModel.self)
        )
        
        func changeDay() {
            guard let timeTable = timeTable else {
                self.lectures = []
                return
            }
            
            switch dayNo {
            case 0: self.lectures = timeTable.monday
            case 1: self.lectures = timeTable.tuesday
            case 2: self.lectures = timeTable.wednesday
            case 3: self.lectures = timeTable.thursday
            case 4: self.lectures = timeTable.friday
            case 5: self.lectures = timeTable.saturday
            case 6: self.lectures = timeTable.sunday
            default: self.lectures = []
            }
        }
        
        @MainActor
        func loadCircleMemberTimetable(
            circleId: String,
            memberUsername: String,
            authToken: String
        ) async {
            logger.info("Loading timetable for circle member: \(memberUsername) in circle: \(circleId)")
            
            stage = .loading
            
            guard !circleId.isEmpty && !memberUsername.isEmpty && !authToken.isEmpty else {
                logger.error("Missing circle ID, member username, or auth token")
                stage = .error
                return
            }
            
            await fetchCircleMemberTimetableFromAPI(
                circleId: circleId,
                memberUsername: memberUsername,
                authToken: authToken
            )
        }
        
        @MainActor
        func refreshCircleMemberTimetable(
            circleId: String,
            memberUsername: String,
            authToken: String
        ) async {
            logger.info("Refreshing timetable for circle member: \(memberUsername) in circle: \(circleId)")
            
            stage = .loading
            
            await fetchCircleMemberTimetableFromAPI(
                circleId: circleId,
                memberUsername: memberUsername,
                authToken: authToken
            )
        }
        
        @MainActor
        private func fetchCircleMemberTimetableFromAPI(
            circleId: String,
            memberUsername: String,
            authToken: String
        ) async {
            do {
                logger.info("Fetching circle member's timetable from API")
                
                let memberTimeTable = try await TimeTableAPIService.shared.getCircleMemberTimeTable(
                    circleId: circleId,
                    memberUsername: memberUsername,
                    authToken: authToken
                )
                
                if isTimeTableEmpty(memberTimeTable) {
                    logger.info("Circle member's timetable is empty")
                    self.timeTable = memberTimeTable
                    self.lectures = []
                    self.stage = .empty
                    return
                }
                
            
                self.timeTable = memberTimeTable
                changeDay()
                stage = .data
                
                logger.info("Successfully fetched circle member's timetable from API")
                
            } catch {
                logger.error("Failed to fetch circle member's timetable: \(error.localizedDescription)")
                stage = .error
            }
        }
        
        private func isTimeTableEmpty(_ timeTable: TimeTable) -> Bool {
            return timeTable.monday.isEmpty &&
                   timeTable.tuesday.isEmpty &&
                   timeTable.wednesday.isEmpty &&
                   timeTable.thursday.isEmpty &&
                   timeTable.friday.isEmpty &&
                   timeTable.saturday.isEmpty &&
                   timeTable.sunday.isEmpty
        }
    }
}
