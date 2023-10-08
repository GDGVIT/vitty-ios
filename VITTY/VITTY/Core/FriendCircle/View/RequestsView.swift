//
//  RequestsView.swift
//  VITTY
//
//  Created by Prashanna Rajbhandari on 22/08/2023.
//

import SwiftUI

struct RequestsView: View {
    var body: some View {
        ZStack {
            Color.theme.blueBG
                .ignoresSafeArea()
            VStack(alignment: .leading){
                Text("Requests")
                    .font(.custom("Poppins", size: 16))
                    .foregroundColor(Color.theme.tfBlueLight)
                    .padding(.leading)
                
                ForEach(1 ... 3, id: \.self) { _ in
                    FriendCircleSuggestionRow(name: "name", username: "username", url: "")
                }
                Spacer()
            }
            .padding(.top)
            .background(Color.theme.blueBG)
        .ignoresSafeArea()
        }
    }
}

struct RequestsView_Previews: PreviewProvider {
    static var previews: some View {
        RequestsView()
    }
}
