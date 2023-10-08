//
//  FriendCircleViewModel.swift
//  VITTY
//
//  Created by Prashanna Rajbhandari on 21/08/2023.
//

import Foundation

class FriendCircleViewModel: ObservableObject {
    @Published var searchedUsers: [FriendResponse] = []
    @Published var getFriendRequests: [GetFriendReqResponse] = []

    // MARK: generic

    func downloadData(fromURLRequest urlReq: URLRequest, completionHandler: @escaping (_ data: Data?) -> Void) {
        URLSession.shared.dataTask(with: urlReq) { data, response, error in
            guard let data = data,
                  error == nil,
                  let response = response as? HTTPURLResponse,
                  response.statusCode >= 200 && response.statusCode < 300 else {
                print("error downloading data")
                completionHandler(nil)
                return
            }
            completionHandler(data)

        }.resume()
    }

    // MARK: Search User

    func searchUsers(token: String, query: String) {
        guard let url = URL(string: "\(APIConstants.base_url)/api/v2/users/search?query=\(query)") else {
            return
        }

        var request = URLRequest(url: url, timeoutInterval: Double.infinity)

        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"

        downloadData(fromURLRequest: request) { returnedData in
            if let data = returnedData {
                do {
                    let users = try JSONDecoder().decode([FriendResponse].self, from: data)

                    DispatchQueue.main.async { [weak self] in
                        self?.searchedUsers = users
                        print("searched users", self?.searchedUsers ?? [])
                    }
                } catch {
                    print("Error decoding JSON: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: Send Request

    func sendFriendRequest(token: String, username: String) {
        guard let url = URL(string: "\(APIConstants.base_url)/api/v2/requests/\(username)/send") else {
            return
        }

        var request = URLRequest(url: url, timeoutInterval: Double.infinity)

        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        print("response from ", url)
        downloadData(fromURLRequest: request) { returnedData in
            if let data = returnedData {
                do {
                    let result = try JSONDecoder().decode(FriendReqResponse.self, from: data)
                    print("success", result)
                } catch {
                    print("error sending request", error)
                }
            }
        }
    }

    // MARK: Get friend request
    func getFriendRequest(token: String) {
        guard let url = URL(string: "\(APIConstants.base_url)/api/v2/requests/") else {
            return
        }

        var request = URLRequest(url: url, timeoutInterval: Double.infinity)

        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"

        print("response from ", url)
        downloadData(fromURLRequest: request) { returnedData in
            if let data = returnedData {
                do {
                    let requests = try JSONDecoder().decode([GetFriendReqResponse].self, from: data)
                    
                    DispatchQueue.main.async {[weak self] in
                        self?.getFriendRequests = requests
                        print("my friend requests ", self?.getFriendRequests ?? "no friend requests")
                    }
                    
                } catch {
                    print("error getting friend requests ", error)
                }
            }
        }
    }
}
