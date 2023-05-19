//
//  UserNameViewModel.swift
//  VITTY
//
//  Created by Prashanna Rajbhandari on 20/05/2023.
//

import Foundation

class UserNameViewModel : ObservableObject{
    @Published var isFirstLogin : Bool = false
    @Published var usernameTF : String = ""
}
