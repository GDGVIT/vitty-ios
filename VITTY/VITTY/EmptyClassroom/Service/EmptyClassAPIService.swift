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
        let url = URL(string: "\(APIConstants.base_url)timetable/emptyClassRooms?slot=\(slot)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        print(authToken)
        request.setValue("Token \(authToken)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

       
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        
        if httpResponse.statusCode != 200 {
            let errorMessage = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            let detailMessage = errorMessage?["detail"] as? String ?? "Unknown error"
            print("API Error: \(detailMessage)")
            throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: detailMessage])
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
