//
//  CommunityPageViewModel.swift
//  VITTY
//
//  Created by Chandram Dutta on 04/01/24.
//

import Foundation
import Alamofire
import OSLog

@Observable
class CommunityPageViewModel {
    var friends = [Friend]()
    var circles = [CircleModel]()
    var circleRequests = [CircleRequest]()
    
    var loadingFreinds = false
    var loadingCircle = false
    var loadingCircleMembers = false
    var loadingCircleRequests = false
    var loadingRequestAction = false
    
    var errorFreinds = false
    var errorCircle = false
    var errorCircleMembers = false
    var errorCircleRequests = false
    
    var circleMembers = [CircleUserTemp]()
    
    var circleMembersDict: [String: [CircleUserTemp]] = [:]
    var loadingCircleMembersDict: [String: Bool] = [:]
    
    // MARK: - New Member Timetable Properties
    var memberTimetable: TimeTable?
    var loadingMemberTimetable = false
    var errorMemberTimetable = false
    
    //MARK: ghost mode
    var ghostedFriends = Set<String>()
    var activeFriends = Set<String>()
    var loadingGhostAction = false

    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: CommunityPageViewModel.self)
    )
    
    var hasInitialActiveFriendsFetch = false

    func fetchFriendsData(from url: String, token: String, loading: Bool = false) {
        if loading || friends.isEmpty {
            self.loadingFreinds = true
        }
        
        self.errorFreinds = false
        print("This is the token used in the app \(token)")
        print("this is the url used for the endpoint \(url)")
        
        AF.request(url, method: .get, headers: ["Authorization": "Token \(token)"])
            .validate()
            .responseDecodable(of: FriendRaw.self) { response in
                DispatchQueue.main.async {
                    self.loadingFreinds = false
                    
                    switch response.result {
                    case .success(let data):
                        self.friends = data.data
                        self.errorFreinds = false
                        
                      
                        self.syncGhostStatusWithFriends()
                        
                    case .failure(let error):
                        self.logger.error("Error fetching friends: \(error)")
                        if self.friends.isEmpty {
                            self.errorFreinds = true
                        }
                    }
                }
            }
    }

    
    //MARK: Circle DATA
    
    func fetchCircleData(from url: String, token: String, loading: Bool = false) {
        if loading || circles.isEmpty {
            self.loadingCircle = true
        }
        
        self.errorCircle = false
        
        AF.request(url, method: .get, headers: ["Authorization": "Token \(token)"])
            .validate()
            .responseDecodable(of: CircleResponse.self) { response in
                DispatchQueue.main.async {
                    self.loadingCircle = false
                    
                    switch response.result {
                    case .success(let data):
                        self.circles = data.data
                        self.errorCircle = false
                        print("Successfully fetched circles: \(data.data)")
                        
                       
                        self.fetchAllCircleMemberData(token: token)
                        
                    case .failure(let error):
                        self.logger.error("Error fetching circles: \(error)")
                        if self.circles.isEmpty {
                            self.errorCircle = true
                        }
                    }
                }
            }
    }
    
    // MARK: - Fetch all circle member data
    
    private func fetchAllCircleMemberData(token: String) {
        let dispatchGroup = DispatchGroup()
        
        for circle in circles {
            dispatchGroup.enter()
            
            let url = "\(APIConstants.base_urlv3)circles/\(circle.circleID)"
            
            AF.request(url, method: .get, headers: ["Authorization": "Token \(token)"])
                .validate()
                .responseDecodable(of: CircleUserResponseTemp.self) { response in
                    DispatchQueue.main.async {
                        switch response.result {
                        case .success(let data):
                            self.circleMembersDict[circle.circleID] = data.data
                            print("Successfully fetched members for circle \(circle.circleID): \(data.data)")
                            
                        case .failure(let error):
                            self.logger.error("Error fetching members for circle \(circle.circleID): \(error)")
                            self.circleMembersDict[circle.circleID] = []
                        }
                        
                        dispatchGroup.leave()
                    }
                }
        }
        
        dispatchGroup.notify(queue: .main) {
            print("Finished fetching all circle member data")
        }
    }
    
    // MARK: - New Member Timetable Function
    
    func fetchMemberTimetable(circleId: String, username: String, token: String, loading: Bool = true) {
        if loading {
            self.loadingMemberTimetable = true
        }
        
        self.errorMemberTimetable = false
        
        let url = "\(APIConstants.base_urlv3)circles/\(circleId)/\(username)"
        
        print("Fetching member timetable from: \(url)")
        
        AF.request(url, method: .get, headers: ["Authorization": "Token \(token)"])
            .validate()
            .responseDecodable(of: TimeTableRaw.self) { response in
                DispatchQueue.main.async {
                    self.loadingMemberTimetable = false
                    
                    switch response.result {
                    case .success(let data):
                        self.memberTimetable = data.data
                        self.errorMemberTimetable = false
                        self.logger.info("Successfully fetched member timetable for \(username)")
                        
                    case .failure(let error):
                        self.logger.error("Error fetching member timetable for \(username): \(error)")
                        self.errorMemberTimetable = true
                        self.memberTimetable = nil
                    }
                }
            }
    }
    
    // MARK: - Clear Member Timetable
    
    func clearMemberTimetable() {
        self.memberTimetable = nil
        self.loadingMemberTimetable = false
        self.errorMemberTimetable = false
    }
    
    // MARK: - Circle Requests
    
    func fetchCircleRequests(token: String, loading: Bool = false) {
        if loading || circleRequests.isEmpty {
            self.loadingCircleRequests = true
        }
        
        self.errorCircleRequests = false
        
        let url = "\(APIConstants.base_urlv3)circles/requests/received"
        
        AF.request(url, method: .get, headers: ["Authorization": "Token \(token)"])
            .validate()
            .responseData { response in
                DispatchQueue.main.async {
                    self.loadingCircleRequests = false
                    
                    switch response.result {
                    case .success(let data):
                        do {
                            let decodedResponse = try JSONDecoder().decode(CircleRequestResponse.self, from: data)
                            self.circleRequests = decodedResponse.data
                            self.errorCircleRequests = false
                            self.logger.info("Successfully fetched circle requests: \(decodedResponse.data.count) requests")
                        } catch {
                            self.logger.error("Error decoding circle requests: \(error)")
                            
                            if let jsonString = String(data: data, encoding: .utf8) {
                                self.logger.info("Raw response: \(jsonString)")
                            }
                            
                            self.circleRequests = []
                            self.errorCircleRequests = false
                        }
                        
                    case .failure(let error):
                        self.logger.error("Error fetching circle requests: \(error)")
                        if self.circleRequests.isEmpty {
                            self.errorCircleRequests = true
                        }
                    }
                }
            }
    }
    
    func acceptCircleRequest(circleId: String, token: String, completion: @escaping (Bool) -> Void) {
        self.loadingRequestAction = true
        
        let url = "\(APIConstants.base_urlv3)circles/acceptRequest/\(circleId)"
        
       
        logger.info("Attempting to accept circle request with URL: \(url)")
        logger.info("Circle ID: \(circleId)")
        logger.info("Token: \(token.prefix(10))...")
        
        AF.request(url, method: .post, headers: ["Authorization": "Token \(token)"])
            .validate()
            .responseData { response in
                DispatchQueue.main.async {
                    self.loadingRequestAction = false
                    
                    switch response.result {
                    case .success(let data):
                        self.logger.info("Successfully accepted circle request for circle: \(circleId)")
                        
                      
                        if let responseString = String(data: data, encoding: .utf8) {
                            self.logger.info("Response: \(responseString)")
                        }
                        
                      
                        self.circleRequests.removeAll { $0.circle_id == circleId }
                        
                    
                        self.fetchCircleData(
                            from: "\(APIConstants.base_urlv3)circles",
                            token: token,
                            loading: false
                        )
                        
                        completion(true)
                        
                    case .failure(let error):
                        self.logger.error("Error accepting circle request: \(error)")
                        
                      
                        if let data = response.data, let errorString = String(data: data, encoding: .utf8) {
                            self.logger.error("Error response: \(errorString)")
                        }
                        
                        if let httpResponse = response.response {
                            self.logger.error("HTTP Status Code: \(httpResponse.statusCode)")
                        }
                        
                        completion(false)
                    }
                }
            }
    }
    
    func declineCircleRequest(circleId: String, token: String, completion: @escaping (Bool) -> Void) {
        self.loadingRequestAction = true
        
        let url = "\(APIConstants.base_urlv3)circles/declineRequest/\(circleId)"
        
        AF.request(url, method: .post, headers: ["Authorization": "Token \(token)"])
            .validate()
            .response { response in
                DispatchQueue.main.async {
                    self.loadingRequestAction = false
                    
                    switch response.result {
                    case .success:
                        self.logger.info("Successfully declined circle request for circle: \(circleId)")
                        self.circleRequests.removeAll { $0.circle_id == circleId }
                        completion(true)
                        
                    case .failure(let error):
                        self.logger.error("Error declining circle request: \(error)")
                        completion(false)
                    }
                }
            }
    }
  
    func fetchCircleMemberData(from url: String, token: String, loading: Bool = false, circleID: String? = nil) {
        if let circleID = circleID {
            if loading || circleMembersDict[circleID]?.isEmpty != false {
                self.loadingCircleMembersDict[circleID] = true
            }
        } else {
            if loading || circleMembers.isEmpty {
                self.loadingCircleMembers = true
            }
        }
        
        AF.request(url, method: .get, headers: ["Authorization": "Token \(token)"])
            .validate()
            .responseDecodable(of: CircleUserResponseTemp.self) { response in
                DispatchQueue.main.async {
                    switch response.result {
                    case .success(let data):
                        if let circleID = circleID {
                            self.circleMembersDict[circleID] = data.data
                            self.loadingCircleMembersDict[circleID] = false
                        } else {
                            self.circleMembers = data.data
                            self.loadingCircleMembers = false
                        }
                        print("Successfully fetched circle members: \(data.data)")
                        
                    case .failure(let error):
                        self.logger.error("Error fetching circle members: \(error)")
                        
                        if let circleID = circleID {
                            self.loadingCircleMembersDict[circleID] = false
                        } else {
                            self.loadingCircleMembers = false
                            if self.circleMembers.isEmpty {
                                self.errorCircleMembers = true
                            }
                        }
                    }
                }
            }
    }
    
    //MARK : Circle Leave
    func fetchCircleLeave(from url: String, token: String, loading: Bool = false) {
        if loading {
            self.loadingCircleMembers = true
        }
        
        AF.request(url, method: .get, headers: ["Authorization": "Token \(token)"])
            .validate()
            .responseDecodable(of: CircleUserResponseTemp.self) { response in
                DispatchQueue.main.async {
                    self.loadingCircleMembers = false
                    
                    switch response.result {
                    case .success(let data):
                        self.circleMembers = data.data
                        print("Successfully fetched circle members after leave: \(data.data)")
                        
                    case .failure(let error):
                        self.logger.error("Error fetching circle members: \(error)")
                        if self.circleMembers.isEmpty {
                            self.errorCircleMembers = true
                        }
                    }
                }
            }
    }
    
    //MARK: leave Circle
    
    func leaveCircle(from url: String, token: String) {
        self.loadingCircleMembers = true
        
        AF.request(url, method: .delete, headers: ["Authorization": "Token \(token)"])
            .validate()
            .response { response in
                DispatchQueue.main.async {
                    self.loadingCircleMembers = false
                    
                    switch response.result {
                    case .success:
                        self.logger.info("Successfully left circle")
                       
                        
                    case .failure(let error):
                        self.logger.error("Error leaving circle: \(error)")
                        self.errorCircleMembers = true
                    }
                }
                
                
            }
        
    }
    
    //MARK: Delete Circle
    
    func deleteCircle(from url: String, token: String) {
        self.loadingCircleMembers = true
        
        AF.request(url, method: .delete, headers: ["Authorization": "Token \(token)"])
            .validate()
            .response { response in
                DispatchQueue.main.async {
                    self.loadingCircleMembers = false
                    
                    switch response.result {
                    case .success:
                        self.logger.info("Successfully deleted circle")
                        
                     
                        self.fetchCircleData(
                            from: "\(APIConstants.base_urlv3)circles",
                            token: token,
                            loading: false
                        )
                        
                    case .failure(let error):
                        self.logger.error("Error deleting circle: \(error)")
                        self.errorCircleMembers = true
                    }
                }
            }
    }
    
    // MARK: Helper methods for circle members
    
    func circleMembers(for circleID: String) -> [CircleUserTemp] {
        return circleMembersDict[circleID] ?? []
    }
    
    func isLoadingCircleMembers(for circleID: String) -> Bool {
        return loadingCircleMembersDict[circleID] ?? false
    }
    
    func clearCircleMembers(for circleID: String) {
        circleMembersDict.removeValue(forKey: circleID)
        loadingCircleMembersDict.removeValue(forKey: circleID)
    }
    
    // MARK: - Group Creation
    
  
    struct CreateCircleResponse: Codable {
        let detail: String
    }
    
   
    func createCircle(name: String, token: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        guard let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            let error = NSError(domain: "CreateCircleError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid circle name"])
            completion(.failure(error))
            return
        }
        
        let url = "\(APIConstants.base_urlv3)circles/create/\(encodedName)"
        
        AF.request(url, method: .post, headers: ["Authorization": "Token \(token)"])
            .validate()
            .responseDecodable(of: CreateCircleResponse.self) { response in
                DispatchQueue.main.async {
                    switch response.result {
                    case .success(let data):
                        if data.detail.lowercased().contains("successfully") {
                            self.logger.info("Successfully created circle: \(name)")
                            
                          
                            self.fetchCircleDataWithCompletion(
                                from: "\(APIConstants.base_urlv3)circles",
                                token: token,
                                circleName: name,
                                completion: completion
                            )
                            
                        } else {
                            let error = NSError(domain: "CreateCircleError", code: 1, userInfo: [NSLocalizedDescriptionKey: data.detail])
                            self.logger.error("Error creating circle: \(data.detail)")
                            completion(.failure(error))
                        }
                        
                    case .failure(let error):
                        self.logger.error("Error creating circle: \(error)")
                        completion(.failure(error))
                    }
                }
            }
    }

   
    private func fetchCircleDataWithCompletion(from url: String, token: String, circleName: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        AF.request(url, method: .get, headers: ["Authorization": "Token \(token)"])
            .validate()
            .responseDecodable(of: CircleResponse.self) { response in
                DispatchQueue.main.async {
                    switch response.result {
                    case .success(let data):
                        self.circles = data.data
                        self.errorCircle = false
                        print("Successfully fetched circles after creation: \(data.data)")
                        
                       
                        self.fetchAllCircleMemberData(token: token)
                        
                        if let createdCircle = self.circles.first(where: { $0.circleName == circleName }) {
                            print("Found created circle with ID: \(createdCircle.circleID)")
                            completion(.success(createdCircle.circleID))
                        } else {
                            let error = NSError(domain: "CreateCircleError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Could not find created circle in updated data"])
                            self.logger.error("Could not find created circle: \(circleName)")
                            completion(.failure(error))
                        }
                        
                    case .failure(let error):
                        self.logger.error("Error fetching circles after creation: \(error)")
                        completion(.failure(error))
                    }
                }
            }
    }
    
   
   
    func sendCircleInvitation(circleId: String, username: String, token: String, completion: @escaping (Bool) -> Void) {
        
        let url = "\(APIConstants.base_urlv3)circles/sendRequest/\(circleId)/\(username)"
        print("this is the endpoint \(url)")
        
        AF.request(url, method: .post, headers: ["Authorization": "Token \(token)"])
            .validate()
            .response { response in
                DispatchQueue.main.async {
                    switch response.result {
                    case .success:
                        self.logger.info("Successfully sent invitation to \(username) for circle \(circleId)")
                        completion(true)
                        
                    case .failure(let error):
                        self.logger.error("Error sending invitation to \(username): \(error)")
                        completion(false)
                    }
                }
            }
    }
    
   
    
    struct SendInvitationsRequest: Codable {
        let usernames: [String]
    }
    
    struct SendInvitationsResponse: Codable {
        let data: [InvitationResult]?
        let detail: String?
        let message: String?
    }
    struct InvitationResult: Codable {
        let request_status: String
        let username: String
    }
    
    func sendMultipleInvitations(circleId: String, usernames: [String], token: String, completion: @escaping ([String: Bool]) -> Void) {
        guard !usernames.isEmpty else {
            completion([:])
            return
        }
        
        let url = "\(APIConstants.base_urlv3)circles/sendRequest/\(circleId)"
        let requestBody = SendInvitationsRequest(usernames: usernames)
        
        print("Sending multiple invitations to endpoint: \(url)")
        print("Usernames: \(usernames)")
        
        AF.request(
            url,
            method: .post,
            parameters: requestBody,
            encoder: JSONParameterEncoder.default,
            headers: ["Authorization": "Token \(token)", "Content-Type": "application/json"]
        )
        .validate()
        .responseData { response in
            DispatchQueue.main.async {
                var results: [String: Bool] = [:]
                
                
                for username in usernames {
                    results[username] = false
                }
                
                switch response.result {
                case .success(let data):
                    self.logger.info("Multiple invitations response received")
                    
                  
                    do {
                        let decodedResponse = try JSONDecoder().decode(SendInvitationsResponse.self, from: data)
                        
                        if let invitationResults = decodedResponse.data {
                            for result in invitationResults {
                              
                                results[result.username] = (result.request_status == "added")
                                self.logger.info("User \(result.username): \(result.request_status)")
                            }
                        }
                        
                    } catch {
                        self.logger.error("Error decoding multiple invitations response: \(error)")
                        
                        
                        if let responseString = String(data: data, encoding: .utf8) {
                            self.logger.info("Raw response: \(responseString)")
                        }
                        
              
                       
                        return
                    }
                    
                    completion(results)
                    
                case .failure(let error):
                    self.logger.error("Error sending multiple invitations: \(error)")
                    
                  
                }
            }
        }
    }

    // MARK: - Refresh Methods
    
    func refreshAllData(token: String, username: String) {
        fetchFriendsData(
            from: "\(APIConstants.base_urlv3)friends/\(username)/",
            token: token,
            loading: false
        )
        
        fetchCircleData(
            from: "\(APIConstants.base_urlv3)circles",
            token: token,
            loading: false
        )
        
        fetchCircleRequests(token: token, loading: false)
    }
    

    struct JoinCodeResponse: Codable {
        
        let joinCode: String?
        let detail: String?
        
        enum CodingKeys: String, CodingKey {
            case joinCode = "join_code"
            case detail
        }
    }
    
    func generateJoinCode(circleId: String, token: String, completion: @escaping (Result<String, Error>) -> Void) {
        let url = "\(APIConstants.base_urlv3)circles/\(circleId)/generateJoinCode"
        
        print("Generating join code for circle: \(circleId)")
        print("Request URL: \(url)")
        
        AF.request(url, method: .post, headers: ["Authorization": "Token \(token)"])
            .validate()
            .responseDecodable(of: JoinCodeResponse.self) { response in
                DispatchQueue.main.async {
                    switch response.result {
                    case .success(let data):
                        if let joinCode = data.joinCode {
                            print("Successfully generated join code: \(joinCode)")
                            completion(.success(joinCode))
                        } else if let detail = data.detail {
                            print("Error generating join code: \(detail)")
                            let error = NSError(domain: "GenerateJoinCodeError", code: 1, userInfo: [NSLocalizedDescriptionKey: detail])
                            completion(.failure(error))
                        } else {
                            print("Unexpected response format")
                            let error = NSError(domain: "GenerateJoinCodeError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
                            completion(.failure(error))
                        }
                        
                    case .failure(let error):
                        print("Network error generating join code: \(error)")
                        completion(.failure(error))
                    }
                }
            }
        }
    
    // MARK: unfreind a user
    func unfriendUser(username: String, token: String, completion: @escaping (Bool) -> Void) {
        let url = "\(APIConstants.base_url)friends/\(username)/"
        
        AF.request(url, method: .delete, headers: ["Authorization": "Token \(token)"])
            .validate()
            .responseDecodable(of: APIResponse.self) { response in
                DispatchQueue.main.async {
                    switch response.result {
                    case .success(let data):
                        self.logger.info("Successfully unfriended: \(username) - \(data.data)")
                        
                     
                        self.friends.removeAll { $0.username == username }
                        self.removeFromGhosted(username)
                        self.activeFriends.remove(username)
                        self.saveGhostStateToUserDefaults()
                        
                        completion(true)
                        
                    case .failure(let error):
                        self.logger.error("Error unfriending \(username): \(error)")
                        completion(false)
                    }
                }
            }
    }
    
    // MARK: ghost mode funcs
    
    func fetchActiveFriends(token: String, forceRefresh: Bool = false, completion: @escaping (Bool) -> Void = { _ in }) {
        
        guard forceRefresh || !hasInitialActiveFriendsFetch else {
            completion(true)
            return
        }
        
        let url = "\(APIConstants.base_url)friends/active"
        
        AF.request(url, method: .get, headers: ["Authorization": "Token \(token)"])
            .validate()
            .responseDecodable(of: ActiveFriendsResponse.self) { response in
                DispatchQueue.main.async {
                    switch response.result {
                    case .success(let data):
                        self.activeFriends = Set(data.data)
                        self.hasInitialActiveFriendsFetch = true
                        self.logger.info("Successfully fetched active friends: \(data.data)")
                        
                      
                        if !self.friends.isEmpty {
                            let allFriendUsernames = Set(self.friends.map { $0.username })
                            let activeSet = Set(data.data)
                            let friendsToGhost = allFriendUsernames.subtracting(activeSet)
                            
                            
                            self.ghostedFriends.formUnion(friendsToGhost)
                            self.saveGhostStateToUserDefaults()
                            
                            self.logger.info("Active friends: \(data.data)")
                            self.logger.info("Ghosted friends: \(Array(self.ghostedFriends))")
                        }
                        
                        completion(true)
                        
                    case .failure(let error):
                        self.logger.error("Error fetching active friends: \(error)")
                       
                        self.loadGhostStateFromUserDefaults()
                        completion(false)
                    }
                }
            }
    }
    
    private func syncGhostStatusWithFriends() {
        guard !friends.isEmpty && !activeFriends.isEmpty else { return }
        
        let allFriendUsernames = Set(friends.map { $0.username })
        let friendsToGhost = allFriendUsernames.subtracting(activeFriends)
        
       
        ghostedFriends.formUnion(friendsToGhost)
        saveGhostStateToUserDefaults()
    }


    func ghostFriend(username: String, token: String, completion: @escaping (Bool) -> Void) {
        let url = "\(APIConstants.base_url)friends/ghost/\(username)"
        self.loadingGhostAction = true
        
        AF.request(url, method: .post, headers: ["Authorization": "Token \(token)"])
            .validate()
            .responseDecodable(of: APIResponse.self) { response in
                DispatchQueue.main.async {
                    self.loadingGhostAction = false
                    
                    switch response.result {
                    case .success(let data):
                        self.logger.info("Successfully ghosted: \(username) - \(data.data)")
                        
                       
                        self.ghostedFriends.insert(username)
                        self.activeFriends.remove(username)
                        self.saveGhostStateToUserDefaults()
                        
                        completion(true)
                        
                    case .failure(let error):
                        self.logger.error("Error ghosting \(username): \(error)")
                        completion(false)
                    }
                }
            }
    }
    func makeAlive(username: String, token: String, completion: @escaping (Bool) -> Void) {
        let url = "\(APIConstants.base_url)friends/alive/\(username)"
        self.loadingGhostAction = true
        
        AF.request(url, method: .post, headers: ["Authorization": "Token \(token)"])
            .validate()
            .responseDecodable(of: APIResponse.self) { response in
                DispatchQueue.main.async {
                    self.loadingGhostAction = false
                    
                    switch response.result {
                    case .success(let data):
                        self.logger.info("Successfully made alive: \(username) - \(data.data)")
                        
                        
                        self.ghostedFriends.remove(username)
                        self.activeFriends.insert(username)
                        self.saveGhostStateToUserDefaults()
                        
                        completion(true)
                        
                    case .failure(let error):
                        self.logger.error("Error making alive \(username): \(error)")
                        completion(false)
                    }
                }
            }
    }

    func isGhosted(_ username: String) -> Bool {
        return ghostedFriends.contains(username)
    }

    func isActive(_ username: String) -> Bool {
        return activeFriends.contains(username) && !ghostedFriends.contains(username)
    }

    private func removeFromGhosted(_ username: String) {
        ghostedFriends.remove(username)
    }


    private func saveGhostStateToUserDefaults() {
        UserDefaults.standard.set(Array(ghostedFriends), forKey: "ghostedFriends")
    }

    private func loadGhostStateFromUserDefaults() {
        if let savedGhosted = UserDefaults.standard.array(forKey: "ghostedFriends") as? [String] {
            ghostedFriends = Set(savedGhosted)
        }
    }
    func refreshAllDataWithActiveCheck(token: String, username: String) {
       
        fetchActiveFriends(token: token) { [weak self] success in
            if success {
               
                self?.fetchFriendsData(
                    from: "\(APIConstants.base_url)friends/\(username)/",
                    token: token,
                    loading: false
                )
                
                self?.fetchCircleData(
                    from: "\(APIConstants.base_urlv3)circles",
                    token: token,
                    loading: false
                )
                
                self?.fetchCircleRequests(token: token, loading: false)
            }
        }
    }
    func initializeGhostState() {
        loadGhostStateFromUserDefaults()
    }

    struct ActiveFriendsResponse: Codable {
        let data: [String]
    }

    struct APIResponse: Codable {
        let data: String
    }
    
    
    }

extension CommunityPageViewModel {
    
 
    func dismissAllMenus() {
        NotificationCenter.default.post(name: .dismissMenus, object: nil)
    }
}
