//
//  SearchView.swift
//  VITTY
//
//  Created by Chandram Dutta on 07/01/24.
//

import OSLog
import SwiftUI
import Alamofire

struct SearchView: View {
    @State private var searchText = ""
    @State private var searchedFriends = [SearchFriend]()
    @State private var loading = false
    @State private var hasSearched = false
    @State private var searchDebouncer: Timer?
    @State private var rotationAngle: Double = 0
    @State private var currentSearchTask: DataRequest?
    
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: SearchView.self)
    )
    
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(\.dismiss) var dismiss
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()
                VStack(alignment: .leading, spacing: 0) {
                    headerView
                    
                    searchBar
                    
                    if loading && !searchText.isEmpty {
                        VStack(spacing: 20) {
                            Spacer()
                            
                            ZStack {
                                Circle()
                                    .stroke(Color("Accent").opacity(0.2), lineWidth: 2)
                                    .frame(width: 20, height: 20)
                                
                                Circle()
                                    .trim(from: 0, to: 0.7)
                                    .stroke(Color("Accent"), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                    .frame(width: 20, height: 20)
                                    .rotationEffect(.degrees(rotationAngle))
                                    .onAppear {
                                        withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                                            rotationAngle = 360
                                        }
                                    }
                            }
                            
                            Text("Searching for '\(searchText)'...")
                                .font(Font.custom("Poppins-Regular", size: 16))
                                .foregroundColor(Color.white)
                                .multilineTextAlignment(.center)
                            
                            Button(action: {
                                cancelSearch()
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "xmark.circle.fill")
                                    Text("Cancel")
                                        .font(Font.custom("Poppins-Medium", size: 14))
                                }
                                .foregroundColor(Color("Accent"))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color("Accent"), lineWidth: 1)
                                        .background(Color("Secondary"))
                                )
                            }
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if !hasSearched {
                        
                    
                        HStack {
                            Spacer()
                            VStack(spacing: 20) {
                                Image(systemName: "magnifyingglass.circle")
                                    .font(.system(size: 60))
                                    .foregroundColor(Color("Accent"))
                                
                                Text("Search for Friends")
                                    .font(Font.custom("Poppins-SemiBold", size: 20))
                                    .foregroundColor(Color.white)
                                
                                Text("Enter a username or name to find friends on VITTY")
                                    .multilineTextAlignment(.center)
                                    .font(Font.custom("Poppins-Regular", size: 14))
                                    .foregroundColor(Color.white.opacity(0.8))
                                    .padding(.horizontal, 40)
                            }
                            Spacer()
                        }
                        .frame(maxHeight: .infinity)
                        
                    } else if searchedFriends.isEmpty && !searchText.isEmpty {
                       
                        HStack {
                            Spacer()
                            VStack(spacing: 20) {
                                Image(systemName: "person.crop.circle.badge.questionmark")
                                    .font(.system(size: 60))
                                    .foregroundColor(Color("Accent"))
                                
                                Text("No Results Found")
                                    .font(Font.custom("Poppins-SemiBold", size: 20))
                                    .foregroundColor(Color.white)
                                
                                Text("No users found for '\(searchText)'. Try a different search term.")
                                    .multilineTextAlignment(.center)
                                    .font(Font.custom("Poppins-Regular", size: 14))
                                    .foregroundColor(Color.white.opacity(0.8))
                                    .padding(.horizontal, 40)
                            }
                            Spacer()
                        }
                        .frame(maxHeight: .infinity)
                        
                    } else {
                        List($searchedFriends, id: \.username) { searchfriend in
                            AddFriendCardSearch(friend: searchfriend , search: searchText)
                                .listRowBackground(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color("Secondary"))
                                        .padding(.bottom, 4)
                                )
                                .listRowSeparator(.hidden)
                        }
                        .scrollContentBackground(.hidden)
                        .padding(.top, 8)
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
        }
    }
    
    private var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(Color("Accent"))
                    .font(.title2)
            }
            Spacer()
            Text("Search")
                .foregroundColor(.white)
                .font(.system(size: 22, weight: .bold))
            Spacer()
            
           
//            if !searchText.isEmpty && !loading {
//                Button(action: {
//                    clearSearch()
//                }) {
//                    Image(systemName: "xmark.circle.fill")
//                        .foregroundColor(Color("Accent"))
//                        .font(.title3)
//                }
//            } else {
//
//                Image(systemName: "xmark.circle.fill")
//                    .foregroundColor(.clear)
//                    .font(.title3)
//            }
        }
        .padding()
    }
    
    private var searchBar: some View {
        HStack {
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(Color("Secondary"))
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(searchText.isEmpty ? Color("Accent").opacity(0.3) : Color("Accent"), lineWidth: 1)
                )
                .overlay(alignment: .leading) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color("Accent"))
                            .padding(.leading, 16)
                        
                        TextField("Search friends...", text: $searchText)
                            .foregroundColor(.white)
                            .font(Font.custom("Poppins-Regular", size: 16))
                            .onChange(of: searchText) { _, newValue in
                                debouncedSearch(newValue)
                            }
                            .submitLabel(.search)
                            .onSubmit {
                                search()
                            }
                        
                        if !searchText.isEmpty && !loading {
                            Button(action: {
                                clearSearch()
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(Color("Accent").opacity(0.6))
                                    .padding(.trailing, 16)
                            }
                        }
                    }
                }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
    
    func clearSearch() {
        
        cancelSearch()
        
      
        searchText = ""
        searchedFriends = []
        hasSearched = false
        loading = false
        rotationAngle = 0
    }
    
    func debouncedSearch(_ query: String) {
        searchDebouncer?.invalidate()
        
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            cancelSearch()
            searchedFriends = []
            hasSearched = false
            loading = false
            return
        }
        
        searchDebouncer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            search()
        }
    }
    
    func search() {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
       
        guard !query.isEmpty else {
            logger.warning("Search query is empty, skipping search")
            return
        }
        
       
        cancelSearch()
        
      
        loading = true
        hasSearched = true
        
     
        logger.info("Starting search for query: \(query)")
        
       
        let baseURL = "\(APIConstants.base_url)users/search"
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "\(baseURL)?query=\(encodedQuery)"
        
        let token = authViewModel.loggedInBackendUser?.token ?? ""
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        
       
        currentSearchTask = AF.request(
            urlString,
            method: .get,
            headers: headers
        )
        .validate(statusCode: 200..<300)
        .responseDecodable(of: [SearchUserResponse].self) { response in
            Task { @MainActor in
              
                self.loading = false
                self.currentSearchTask = nil
                
                switch response.result {
                case .success(let searchResults):
                    self.logger.info("Search successful, found \(searchResults.count) results")
                    
         
                    self.searchedFriends = searchResults.map { searchResult in
                        SearchFriend(
                            username: searchResult.username,
                            name: searchResult.name,
                            picture: searchResult.picture,
                            friendStatus: searchResult.friendStatus,
                            currentStatus: searchResult.currentStatus.status,
                            friendsCount: searchResult.friendsCount,
                            mutualFriendsCount: searchResult.mutualFriendsCount
                        )
                    }
                    
                case .failure(let error):
                    self.logger.error("Search failed with error: \(error.localizedDescription)")
                    
                 
                    if let afError = error.asAFError {
                        switch afError {
                        case .responseValidationFailed(reason: .unacceptableStatusCode(code: let statusCode)):
                            if statusCode == 404 {
                              
                                self.searchedFriends = []
                            } else {
                                self.logger.error("API returned status code: \(statusCode)")
                                self.searchedFriends = []
                            }
                        default:
                            self.logger.error("Network error: \(afError.localizedDescription)")
                            self.searchedFriends = []
                        }
                    } else {
                        self.logger.error("Unknown error occurred during search")
                        self.searchedFriends = []
                    }
                }
            }
        }
    }

    
    func cancelSearch() {
        currentSearchTask?.cancel()
        currentSearchTask = nil
        loading = false
        rotationAngle = 0
        searchDebouncer?.invalidate()
    }
}

// MARK: - Search Response Models
struct SearchUserResponse: Codable {
    let currentStatus: SearchCurrentStatus
    let friendStatus: String
    let friendsCount: Int
    let mutualFriendsCount: Int
    let name: String
    let picture: String
    let username: String
    
    enum CodingKeys: String, CodingKey {
        case currentStatus = "current_status"
        case friendStatus = "friend_status"
        case friendsCount = "friends_count"
        case mutualFriendsCount = "mutual_friends_count"
        case name, picture, username
    }
}

struct SearchCurrentStatus: Codable {
    let status: String
}
struct SearchFriend:Codable {
    var username: String
    var name: String
    var picture: String
    var friendStatus: String
    var currentStatus: String
    var  friendsCount: Int
    var mutualFriendsCount: Int
}
