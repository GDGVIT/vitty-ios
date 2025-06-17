//
//  AddFriend.swift
//  VITTY
//
//  Created by Rujin Devkota on 3/3/25.
//


import SwiftUI
struct AddFriend : View{
    let screenHeight = UIScreen.main.bounds.height
    let screenWidth = UIScreen.main.bounds.width
    var body : some View{
        
        VStack{
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search", text: .constant(""))
                    .font(Font.custom("Poppins-Regular", size: 16))
                
                Button(action: {
                    // Clear search field
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color("Secondary").opacity(0.5))
            .cornerRadius(10)
            .padding()
            
            
        } .frame(width: screenWidth, height: screenHeight * 0.65) .background(Color("Secondary"))
    }
    
}
#Preview {
    AddFriend()
}
