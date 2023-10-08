//
//  FriendCircleViewModel.swift
//  VITTY
//
//  Created by Prashanna Rajbhandari on 21/08/2023.
//

import Foundation

class FriendCircleViewModel: ObservableObject {
    @Published var searchedUsers: [FriendResponse] = []

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
}
