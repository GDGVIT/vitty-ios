//
//  FriendsView.swift
//  VITTY
//
//  Created by Prashanna Rajbhandari on 22/08/2023.
//

import SwiftUI

struct FriendsView: View {
    var body: some View {
        ZStack {
            Color.theme.blueBG
                .ignoresSafeArea()
            VStack(alignment: .leading){
                Text("Friends")
                    .font(.custom("Poppins", size: 16))
                    .foregroundColor(Color.theme.tfBlueLight)
                    .padding(.leading)
                
                ForEach(1 ... 3, id: \.self) { _ in
                    UserDetailsRow(name: "requests.from.name", username: "requests.from.username", url: "requests.from.picture", token: "authState.token", isSuggestionOrSendReq: false, wasReqSent: false, isRequestView: false, isFriendsView: true)
                }
                Spacer()
            }
            .padding(.top)
            .background(Color.theme.blueBG)
        .ignoresSafeArea()
        }
    }
}

struct FriendsView_Previews: PreviewProvider {
    static var previews: some View {
        FriendsView()
    }
}
