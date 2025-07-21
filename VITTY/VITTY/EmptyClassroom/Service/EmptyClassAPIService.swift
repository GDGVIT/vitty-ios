//
//  EmptyClassAPIService.swift
//  VITTY
//
//  Created by Rujin Devkota on 2/27/25.
//
import Foundation

class EmptyClassRoomAPIService {
    static let shared = EmptyClassRoomAPIService()

    func getEmptyClassrooms(
        slot: String,
        authToken: String
    ) async throws -> [String] {
        let url = URL(string: "\(APIConstants.base_urlv3)users/emptyClassRooms?slot=\(slot)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        print(authToken)
        request.setValue("Token \(authToken)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

       
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        
        if httpResponse.statusCode != 200 {
            // Try to parse error response
            do {
                let errorResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                
                // Check for the specific "error" field first
                if let errorMessage = errorResponse?["error"] as? String {
                    print("API Error: \(errorMessage)")
                    throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                }
                
                // Fallback to "detail" field
                if let detailMessage = errorResponse?["detail"] as? String {
                    print("API Error: \(detailMessage)")
                    throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: detailMessage])
                }
            } catch {
                // If JSON parsing fails, create a generic error message
                print("Failed to parse error response")
            }
            
            // Generic error if no specific message found
            throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error (Status: \(httpResponse.statusCode))"])
        }

        let decoder = JSONDecoder()

        do {
            let responseDict = try decoder.decode([String: [String]].self, from: data)

            
            print("API Response: \(responseDict)")

            return responseDict[slot] ?? []
        } catch {
            print("Decoding error: \(error)")
            throw error
        }
    }
}
