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
    var loadingFreinds = false
    var loadingCircle = false
    var loadingCircleMembers = false
    
    var errorFreinds = false
    var errorCircle = false
    var errorCircleMembers = false
    var circleMembers = [CircleUserTemp]()

    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: CommunityPageViewModel.self)
    )

    func fetchFriendsData(from url: String, token: String, loading: Bool) {
        self.loadingFreinds = loading
        AF.request(url, method: .get, headers: ["Authorization": "Token \(token)"])
            .validate()
            .responseDecodable(of: FriendRaw.self) { response in
               
                switch response.result {
                    case .success(let data):
                        self.friends = data.data
                    self.loadingFreinds = false
                      
                       
                    case .failure(let error):
                        self.logger.error("Error fetching data: \(error)")
                    self.loadingFreinds = false
                    self.errorFreinds.toggle()
                }
            }
    }
    
    //MARK: Circle DATA
    
    func fetchCircleData(from url: String, token: String, loading: Bool) {
        self.loadingCircle = loading
        AF.request(url, method: .get, headers: ["Authorization": "Token \(token)"])
            .validate()
            .responseDecodable(of: CircleResponse.self) { response in
            print("***********")
                print(response)
                switch response.result {
                    case .success(let data):
                        self.circles = data.data
                    self.loadingCircle = false
                    print(data.data)
                        print("Successfully fetched circles:")
                        print(data.data)
                    case .failure(let error):
                        self.logger.error("Error fetching circles: \(error)")
                    self.loadingCircle = false
                    self.errorCircle.toggle()
                }
            }
    }
    //MARK : Circle Members NetwrokCall
    func fetchCircleMemberData(from url: String, token: String, loading: Bool) {
        self.loadingCircleMembers = loading
        
        AF.request(url, method: .get, headers: ["Authorization": "Token \(token)"])
            .validate()
            .responseDecodable(of: CircleUserResponseTemp.self) { response in
            print("***********")
               
                switch response.result {
                    
                    case .success(let data):
                    self.circleMembers = data.data
                    self.loadingCircleMembers = false
                    print(data.data)
                        print("Successfully fetched circles members :")
                        print(data.data)
                    case .failure(let error):
                        self.logger.error("Error fetching circles members: \(error)")
                    self.loadingCircleMembers = false
                        self.errorCircleMembers.toggle()
                }
            }
    }
    //MARK : Circle Leave
    func fetchCircleLeave(from url: String, token: String, loading: Bool) {
        self.loadingCircleMembers = loading
        
        AF.request(url, method: .get, headers: ["Authorization": "Token \(token)"])
            .validate()
            .responseDecodable(of: CircleUserResponseTemp.self) { response in
            print("***********")
               
                switch response.result {
                    
                    case .success(let data):
                    self.circleMembers = data.data
                    self.loadingCircleMembers = false
                    print(data.data)
                        print("Successfully fetched circles members :")
                        print(data.data)
                    case .failure(let error):
                        self.logger.error("Error fetching circles members: \(error)")
                    self.loadingCircleMembers = false
                        self.errorCircleMembers.toggle()
                }
            }
    }
    
    //MARK: leave Circle
    
    func leaveCircle(from url: String, token: String) {
        self.loadingCircleMembers = true
        
        AF.request(url, method: .delete, headers: ["Authorization": "Token \(token)"])
            .validate()
            .response { response in
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any], let detail = json["detail"] as? String {
                        self.logger.info("Success: \(detail)")
                    }
                    self.loadingCircleMembers = false
                
                case .failure(let error):
                    self.logger.error("Error leaving circle: \(error)")
                    self.loadingCircleMembers = false
                    self.errorCircleMembers.toggle()
                }
            }
    }

    
}
