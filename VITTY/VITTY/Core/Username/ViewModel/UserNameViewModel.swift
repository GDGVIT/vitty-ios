//
//  UserNameViewModel.swift
//  VITTY
//
//  Created by Prashanna Rajbhandari on 20/05/2023.
//

import Foundation

class UserNameViewModel: ObservableObject {
    @Published var isFirstLogin: Bool = false
    @Published var usernameTF: String = ""
    @Published var regNoTF: String = ""
    
    @Published var isRegNoInvalid: Bool = false

    func isRegistrationNumberValid() -> Bool {
        let regex = try! NSRegularExpression(pattern: #"^\d{2}[A-Za-z]{3}\d{4}$"#)
        let range = NSRange(location: 0, length: regNoTF.utf16.count)
        return regex.firstMatch(in: regNoTF, options: [], range: range) != nil
    }
}
