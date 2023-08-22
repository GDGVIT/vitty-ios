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
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            // bg
            Color.theme.blueBG
                .ignoresSafeArea()

            VStack {
                toolBarItems()
                
                ForEach(1 ... 5, id: \.self) { _ in
                    FriendRow()
                }

                Spacer()
            }
            .padding(.top)
        }
    }
}

struct FriendActivity_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                FriendActivity()
            }
        }
    }
}


extension FriendActivity{
    private func toolBarItems() -> some View{
        HStack {
            Text("Friend Activity")
                .font(.custom("Poppins-Medium", size: 22))
                .fontWeight(.semibold)
                .foregroundColor(.white)
            Spacer()
            Image(systemName: "xmark")
                .foregroundColor(.white)
                .padding(.trailing)
                .onTapGesture {
                    presentationMode.wrappedValue.dismiss()
                }
        }
        .padding(.horizontal)
    }
}
