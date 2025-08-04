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
                            .scrollIndicators(.hidden)
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
                stage = .empty
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
                
                let friendResponse = try await TimeTableAPIService.shared.getFriendResponse(
                    username: friendUsername,
                    authToken: authToken
                )
                
                // Extract the timetable from the response
                let friendTimeTable = friendResponse.timetable.data
               
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
                
               
                stage = .empty
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
    }
}

enum APIError: Error {
    case serverError(code: String, message: String)
    case networkError
    case decodingError
    case unauthorized
}

// MARK: - Friend Response Models
struct FriendResponse: Codable {
    let campus: String
    let email: String
    let friendStatus: String
    let friendsCount: Int
    let mutualFriendsCount: Int
    let name: String
    let picture: String
    let timetable: FriendTimetableWrapper
    let username: String
    
    enum CodingKeys: String, CodingKey {
        case campus, email, name, picture, timetable, username
        case friendStatus = "friend_status"
        case friendsCount = "friends_count"
        case mutualFriendsCount = "mutual_friends_count"
    }
}

struct FriendTimetableWrapper: Codable {
    let data: TimeTable
}


struct TimeTableFromAPI: Codable {
    let monday: [Lecture]
    let tuesday: [Lecture]
    let wednesday: [Lecture]
    let thursday: [Lecture]
    let friday: [Lecture]
    let saturday: [Lecture]
    let sunday: [Lecture]
    
    enum CodingKeys: String, CodingKey {
        case monday = "Monday"
        case tuesday = "Tuesday"
        case wednesday = "Wednesday"
        case thursday = "Thursday"
        case friday = "Friday"
        case saturday = "Saturday"
        case sunday = "Sunday"
    }
}

extension TimeTableAPIService {
    func getFriendResponse(username: String, authToken: String) async throws -> FriendResponse {
        guard let url = URL(string: "\(APIConstants.base_urlv3)users/\(username)") else {
            throw APIError.networkError
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
           
            guard httpResponse.statusCode != 500 else {
                throw APIError.serverError(code: "500", message: "Server error")
            }
            
            guard httpResponse.statusCode == 200 else {
                throw APIError.serverError(code: "UNKNOWN", message: "HTTP \(httpResponse.statusCode)")
            }
        }
        
        let decoder = JSONDecoder()
        
       
        var friendResponse = try decoder.decode(FriendResponse.self, from: data)
        
        
        let apiTimeTable = try JSONDecoder().decode(TimeTableFromAPI.self, from:
            try JSONEncoder().encode(friendResponse.timetable.data))
        
        let convertedTimeTable = TimeTable(
            monday: apiTimeTable.monday,
            tuesday: apiTimeTable.tuesday,
            wednesday: apiTimeTable.wednesday,
            thursday: apiTimeTable.thursday,
            friday: apiTimeTable.friday,
            saturday: apiTimeTable.saturday,
            sunday: apiTimeTable.sunday
        )
        
        
        friendResponse = FriendResponse(
            campus: friendResponse.campus,
            email: friendResponse.email,
            friendStatus: friendResponse.friendStatus,
            friendsCount: friendResponse.friendsCount,
            mutualFriendsCount: friendResponse.mutualFriendsCount,
            name: friendResponse.name,
            picture: friendResponse.picture,
            timetable: FriendTimetableWrapper(data: convertedTimeTable),
            username: friendResponse.username
        )
        
        return friendResponse
    }
}

struct ErrorResponse: Codable {
    let code: String
    let error: String
}
