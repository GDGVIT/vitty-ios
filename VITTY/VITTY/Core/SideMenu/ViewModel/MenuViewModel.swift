//
//  MenuViewModel.swift
//  VITTY
//
//  Created by Prashanna Rajbhandari on 22/08/2023.
//

import Foundation

struct showMenuItemModel: Identifiable{
    let id = UUID().uuidString
    
}

class MenuViewModel : ObservableObject{
    @Published var showProfile : Bool = false
    @Published var showFriendCircle : Bool = false
    @Published var showFriendActivity : Bool = false
    @Published var showSettings : Bool = false
    
    @Published var isGhostModeOn : Bool = false
    
    @Published var username: String = ""
    @Published var name: String = ""
}
