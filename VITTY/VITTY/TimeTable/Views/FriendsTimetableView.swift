//  FriendsTimetableView.swift
//  VITTY
//
//  Created by Rujin Devkota on 7/17/25.
//

import OSLog
import SwiftData
import SwiftUI

struct FriendsTimeTableView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(\.dismiss) private var dismiss
    
    private let daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    @State private var viewModel = FriendsTimeTableViewModel()
    @State private var selectedLecture: Lecture? = nil
    @State private var isRefreshing = false
    @State private var showingRefreshAlert = false
    
    let friend: Friend
    
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: FriendsTimeTableView.self)
    )
    
    var body: some View {
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
                    
                    Text("\(friend.name)'s Timetable")
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
                        Text("Loading \(friend.name ?? friend.username)'s timetable...")
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
                        
                        Text("Can't show timetable right now")
                            .font(Font.custom("Poppins-Bold", size: 24))
                            .padding(.bottom, 8)
                        
                        Text("Unable to display \(friend.name ?? friend.username)'s timetable at the moment")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                        
                        Button(action: {
                           
                        }) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("Try Again")
                            }
                            .foregroundColor(.black)
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
                        
                        Text("\(friend.name ?? friend.username) hasn't shared their timetable yet")
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
                                
                                Text("Your friend has no classes on \(daysOfWeek[viewModel.dayNo])")
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
        .sheet(item: $selectedLecture) { lecture in
            LectureDetailView(lecture: lecture)
        }
       
        .navigationBarHidden(true)
        .onAppear {
            logger.debug("FriendsTimeTableView appeared for friend: \(friend.username)")
            loadFriendsTimetable()
        }
    }
    
    private func loadFriendsTimetable() {
        logger.debug("Loading friend's timetable from API")
        
       
        let calendar = Calendar.current
        let today = calendar.component(.weekday, from: Date())
        let dayIndex = (today == 1) ? 6 : today - 2
        
        if dayIndex >= 0 && dayIndex < daysOfWeek.count {
            viewModel.dayNo = dayIndex
        } else {
            viewModel.dayNo = 0
        }
        
        Task {
            await viewModel.loadFriendsTimetable(
                friendUsername: friend.username,
                authToken: authViewModel.loggedInBackendUser?.token ?? ""
            )
        }
    }
    
    private func refreshTimetable() async {
        await MainActor.run {
            isRefreshing = true
        }
        
        await viewModel.refreshFriendsTimetable(
            friendUsername: friend.username,
            authToken: authViewModel.loggedInBackendUser?.token ?? ""
        )
        
        await MainActor.run {
            isRefreshing = false
        }
    }
}

// MARK: - Friends Timetable ViewModel
extension FriendsTimeTableView {
    @Observable
    class FriendsTimeTableViewModel {
        var timeTable: TimeTable?
        var stage: Stage = .loading
        var lectures = [Lecture]()
        var dayNo = Date.convertToMondayWeek()
        
        private let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: String(describing: FriendsTimeTableViewModel.self)
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
        func loadFriendsTimetable(
            friendUsername: String,
            authToken: String
        ) async {
            logger.info("Loading timetable for friend: \(friendUsername)")
            
            stage = .loading
            
            guard !friendUsername.isEmpty && !authToken.isEmpty else {
                logger.error("Missing friend username or auth token")
                stage = .error
                return
            }
            
            await fetchFriendsTimetableFromAPI(
                friendUsername: friendUsername,
                authToken: authToken
            )
        }
        
        @MainActor
        func refreshFriendsTimetable(
            friendUsername: String,
            authToken: String
        ) async {
            logger.info("Refreshing timetable for friend: \(friendUsername)")
            
            stage = .loading
            
            await fetchFriendsTimetableFromAPI(
                friendUsername: friendUsername,
                authToken: authToken
            )
        }
        
        @MainActor
        private func fetchFriendsTimetableFromAPI(
            friendUsername: String,
            authToken: String
        ) async {
            do {
                logger.info("Fetching friend's timetable from API using /users/\(friendUsername) endpoint")
                
              
                let friendTimeTable = try await TimeTableAPIService.shared.getFriendTimeTable(
                    username: friendUsername,
                    authToken: authToken
                )
               
                if isTimeTableEmpty(friendTimeTable) {
                    logger.info("Friend's timetable is empty")
                    self.timeTable = friendTimeTable
                    self.lectures = []
                    self.stage = .empty
                    return
                }
                
                self.timeTable = friendTimeTable
                changeDay()
                stage = .data
                
                logger.info("Successfully fetched friend's timetable from API")
                
            } catch {
                logger.error("Failed to fetch friend's timetable: \(error.localizedDescription)")
                
               
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


extension FriendsTimeTableView {
    enum Stage {
        case loading
        case data
        case empty
        case error
    }
}


enum APIError: Error {
    case serverError(code: String, message: String)
    case networkError
    case decodingError
    case unauthorized
   
}


extension TimeTableAPIService {
    func getFriendTimeTable(username: String, authToken: String) async throws -> TimeTable {
        guard let url = URL(string: "\(APIConstants.base_urlv3)users/\(username)") else {
            throw APIError.networkError
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 500 {
              
                if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data),
                   errorResponse.code == "1811" {
                    throw APIError.serverError(code: errorResponse.code, message: errorResponse.error)
                }
            }
            
            guard httpResponse.statusCode == 200 else {
                throw APIError.serverError(code: "UNKNOWN", message: "HTTP \(httpResponse.statusCode)")
            }
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(TimeTable.self, from: data)
    }
}


struct ErrorResponse: Codable {
    let code: String
    let error: String
}
