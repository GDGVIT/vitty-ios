//
//  FriendCircleRow.swift
//  VITTY
//
//  Created by Prashanna Rajbhandari on 20/08/2023.
//

import SwiftUI

struct UserDetailsRow: View {
    let name: String
    let username: String
    let url: String
    let token: String
    
    //for sending req and suggestion
    @State var isSuggestionOrSendReq: Bool = true
    @State var wasReqSent: Bool = false
    
    
    //for requests
    @State var isRequestView: Bool = false
    
    //for friends
    @State var isFriendsView: Bool = false
    
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
                
                if isSuggestionOrSendReq{
                    Button(action: {
                        vm.sendFriendRequest(token: token, username: username)
                        withAnimation(.easeIn) {
                            wasReqSent = true
                        }
                        
                        isRequestView = false
                        isFriendsView = false
                        
                    }, label: {
                        CustomPill(title: wasReqSent ? "Sent" : "Add")
                    })
                }else if isRequestView{
                    Button(action: {
                        
                    }, label: {
                        HStack{
                            CustomPill(title: "Accept")
                        }
                    })
                }


                
                
            }

        }.frame(maxWidth: .infinity)
            .frame(height: 50)
            .padding()
    }
}

struct FriendCircleSuggestionRow_Previews: PreviewProvider {
    static var previews: some View {
        UserDetailsRow(name: "Name", username: "username", url: "https://lh3.googleusercontent.com/a/ACg8ocKkpuFa18qaZcxW3-_XnEBgkUkMAi--U1Db69zeJLXVDZRZ=s96-c", token: "")
    }
}

//MARK: Extension
extension UserDetailsRow{
    private func CustomPill(title: String) -> some View{
        RoundedRectangle(cornerRadius: 20)
            .frame(width: 78, height: 32)
            .foregroundColor(Color.theme.tfBlue)
            .overlay {
                Text(title)
                    .font(.custom("Poppins-Medium", size: 14))
                    .foregroundColor(.white)
            }
    }
}
