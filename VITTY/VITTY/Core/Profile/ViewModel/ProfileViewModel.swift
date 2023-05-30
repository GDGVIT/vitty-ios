//
//  ProfileViewModel.swift
//  VITTY
//
//  Created by Prashanna Rajbhandari on 30/05/2023.
//

import Foundation

class ProfileViewModel : ObservableObject{
    @Published var fullName : String = ""
    @Published var userName : String = ""
}
