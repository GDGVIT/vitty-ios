//
//  FriendActivity.swift
//  VITTY
//
//  Created by Prashanna Rajbhandari on 19/06/2023.
//

import SwiftUI

@available(iOS 15.0, *)
struct FriendActivity: View {
    
    @StateObject private var vm = FriendActivityViewModel()
    
    var body: some View {
        ZStack{
            //bg
            Color.theme.darkBG
                .ignoresSafeArea()
            
            VStack{
                ForEach(1...5, id: \.self){_ in
                    FriendRow()
                }
                
                Spacer()
            }
            .padding(.top)
            
            
        }.toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Text("Friend Activity")
                    .font(.custom("Poppins-Medium", size: 22))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Image(systemName: "xmark")
                    .foregroundColor(.white)
                    .padding(.trailing)
            }
        }
        
    }
}

struct FriendActivity_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 16.0, *) {
            NavigationStack{
                FriendActivity()
            }
        }
    }
}
