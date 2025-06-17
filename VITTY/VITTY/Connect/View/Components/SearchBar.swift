//
//  SearchBar.swift
//  VITTY
//
//  Created by Rujin Devkota on 3/25/25.
//
import SwiftUI

struct SearchBar: View {
    @Binding var searchText : String
    var body : some View{
        
         HStack {
             Image(systemName: "magnifyingglass")
                 .foregroundColor(.gray)
             
             TextField("Search", text: $searchText)
                 .foregroundColor(.white)
             
             if !searchText.isEmpty {
                 Button(action: { searchText = "" }) {
                     Image(systemName: "xmark")
                         .foregroundColor(.gray)
                 }
             }
         }
         .padding(10)
         .background(Color("Secondary"))
         .cornerRadius(8)
         .padding(.horizontal)
         .padding(.top, 16)
    }
}

