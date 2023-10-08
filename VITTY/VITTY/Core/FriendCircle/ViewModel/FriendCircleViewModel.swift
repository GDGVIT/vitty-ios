//
//  FriendCircleViewModel.swift
//  VITTY
//
//  Created by Prashanna Rajbhandari on 21/08/2023.
//

import Foundation

class FriendCircleViewModel: ObservableObject {
    
    @Published var searchedUsers: [FriendResponse] = []
    
    func searchUsers(token: String, query: String) {
        
        guard let url = URL(string: "\(APIConstants.base_url)/api/v2/users/search?query=\(query)") else {
            return
        }

        var request = URLRequest(url: url, timeoutInterval: Double.infinity)

        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                print("Invalid response")
                return
            }
            
            print("data from", url)
            print(data)
            
            do {
                let users = try JSONDecoder().decode([FriendResponse].self, from: data)
                
                DispatchQueue.main.async { [weak self] in
                    self?.searchedUsers = users
                    print("searched users", self?.searchedUsers ?? [])
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
            
        }.resume()
    }
}
