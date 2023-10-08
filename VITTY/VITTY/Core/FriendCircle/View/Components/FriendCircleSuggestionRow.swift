//
//  FriendCircleRow.swift
//  VITTY
//
//  Created by Prashanna Rajbhandari on 20/08/2023.
//

import SwiftUI

struct FriendCircleSuggestionRow: View {
    let name: String
    let username: String
    let url: String
    let token: String
    @State var wasReqSent: Bool = false
    
    @EnvironmentObject private var vm: FriendCircleViewModel

    var body: some View {
        ZStack {
            Color.theme.blueBG
            HStack {
                UserImage(url: url, height: 40, width: 40)

                VStack(alignment: .leading) {
                    Text(name)
                        .font(.custom("Poppins-Bold", size: 15))
                        .foregroundColor(.white)

                    Text("@\(username)")
                        .font(.custom("Poppins", size: 15))
                        .foregroundColor(Color.theme.secTextColor)
                }

                Spacer()

                Button(action: {
                    vm.sendFriendRequest(token: token, username: username)
                    withAnimation(.default) {
                        wasReqSent = true
                    }
                }, label: {
                    RoundedRectangle(cornerRadius: 20)
                        .frame(width: 78, height: 32)
                        .foregroundColor(Color.theme.tfBlue)
                        .overlay {
                            Text(wasReqSent ? "Sent" : "Add")
                                .font(.custom("Poppins-Medium", size: 14))
                                .foregroundColor(.white)
                        }
                })
            }

        }.frame(maxWidth: .infinity)
            .frame(height: 50)
            .padding()
    }
}

struct FriendCircleSuggestionRow_Previews: PreviewProvider {
    static var previews: some View {
        FriendCircleSuggestionRow(name: "Name", username: "username", url: "https://lh3.googleusercontent.com/a/ACg8ocKkpuFa18qaZcxW3-_XnEBgkUkMAi--U1Db69zeJLXVDZRZ=s96-c", token: "")
    }
}
