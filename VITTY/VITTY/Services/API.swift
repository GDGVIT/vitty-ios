//
//  API.swift
//  VITTY
//
//  Created by Prashanna Rajbhandari on 15/09/2023.
//

import Foundation


class API {
    static let shared = API()
    
    func getUser(token: String, userName: String){
        print("token to api ", token)
        guard let url = URL(string: "\(APIConstants.base_url)/api/v2/users/\(userName)") else{
            return
        }
        
        var request = URLRequest(url: url, timeoutInterval: Double.infinity)
        
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data,
                  error == nil else{
                return
            }
            do{
                let result = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
                
//                let result = try JSONDecoder().decode(UserResponse.self, from: data)
                print("response from ", url)
                print(result)
                
            }catch{
                print("error from ", url)
                print(error.localizedDescription)
            }
        }
        
        task.resume()
    }
    

}

//MARK: Auth
extension API{
    

    //MARK: Sign in user
    func signInUser(with authReqBody: AuthReqBody, completion: @escaping (Result<AuthResponse, Error>) -> Void) {
        guard let url = URL(string: "\(APIConstants.base_url)/api/v2/auth/firebase/") else {
            completion(.failure(CustomError.invalidUrl))
            return
        }

        var request = URLRequest(url: url)

        request.httpMethod = "POST"

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(authReqBody)
        } catch {
            completion(.failure(error))
            return
        }

        // Send the request
        print("calling the API")
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(CustomError.invalidData))
                return
            }

            do {
                let decoder = JSONDecoder()
                let authResponse = try decoder.decode(AuthResponse.self, from: data)
                print("POST request response from url: \(url)")
                print(authResponse)
                print("END of POST request response")
                completion(.success(authResponse))
            } catch {
                completion(.failure(error))
                return
            }
        }

        task.resume()
    }
    
    //MARK: Check user name
    func checkUsername(with username: String){
        guard let url = URL(string: "\(APIConstants.base_url)/api/v2/auth/check-username") else {
            return
        }
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do{
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(username)
        }catch let error{
            print("error encoding username ", error.localizedDescription)
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            do{
                //let result = try JSONDecoder().decode(UsernameResponse.self, from: data)
                let result = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
                print("POST request response from url: \(url)")
                print(result)
                print("END of POST request response")
            }catch{
                print(error.localizedDescription)
            }
        }
        
        task.resume()
        
    }
}
