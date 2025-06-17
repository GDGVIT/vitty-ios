//
//  AcademicsViewModel.swift
//  VITTY
//
//  Created by Rujin Devkota on 3/27/25.
//

import SwiftUI
import OSLog
import Alamofire


@Observable class AcademicsViewModel {
    
    
    var notes = [CreateNoteModel]()
       var loading = false
       var error = false

       private let logger = Logger(
           subsystem: Bundle.main.bundleIdentifier!,
           category: String(describing: AcademicsViewModel.self)
       )

    func createNote(at url: URL, authToken: String, note: CreateNoteModel) {
           self.loading = true
           
           let headers: HTTPHeaders = [
               "Authorization": "Bearer \(authToken)",
               "Content-Type": "application/json"
           ]
           
           do {
               let jsonData = try JSONEncoder().encode(note)
               
               AF.request(url, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: headers)
                   .responseData { response in
                       switch response.result {
                       case .success:
                           DispatchQueue.main.async {
                               self.notes.append(note)
                               self.loading = false
                           }
                       case .failure(let error):
                           self.logger.error("Error creating note: \(error.localizedDescription)")
                           self.error = true
                           self.loading = false
                       }
                   }
           } catch {
               self.logger.error("Error encoding JSON: \(error)")
               self.error = true
               self.loading = false
           }
       }
    
    
    
    
}
