//
//  FriendCircle.swift
//  VITTY
//
//  Created by Prashanna Rajbhandari on 18/08/2023.
//

import SwiftUI

struct FriendCircle: View {
    @EnvironmentObject var authState: AuthService
    
    @Environment(\.presentationMode) var presentationMode
    @State var text: String = ""
    @State var selectedTab: Tabs = .suggestions
    
    @StateObject var vm = FriendCircleViewModel()

    init() {
        UITabBar.appearance().isHidden = true
    }

    var body: some View {
        ZStack {
            
            Color.theme.blueBG
                .ignoresSafeArea()

            VStack {
                toolBarItems()

                textField(text: $text, tfString: "search for friends", height: 70)
                    .onSubmit {
                        vm.searchUsers(token: authState.token, query: text)
                        
                    }
                
                ForEach(vm.searchedUsers, id:\.self){user in
                    FriendCircleSuggestionRow(name: user.name, username: user.username, url: user.picture)
                    
                }

                //inviteFriendsCard()

                TabView(selection: $selectedTab) {
                    SuggestionsView()
                        .tag(Tabs.suggestions)
                    RequestsView()
                        .tag(Tabs.requests)
                    FriendsView()
                        .tag(Tabs.friends)
                }

                Spacer()

                CustomTabBar(selectedTab: $selectedTab)
            }
            .padding(.top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

@available(iOS 16.0, *)
struct FriendCircle_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            FriendCircle()
        }
    }
}

extension FriendCircle {
    private func toolBarItems() -> some View{
        HStack {
            Text("Friend Circle")
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
    private func headerText() -> some View {
        VStack(alignment: .leading) {
            Text("search for friends")
                .font(.custom("Poppins-Medium", size: 32))
                .fontWeight(.semibold)
                .foregroundColor(.white)
            Text("Write a  username? We'll use it to \npersonalise your experience.")
                .font(.custom("Poppins-Medium", size: 16))
                .foregroundColor(Color.theme.primary)
        }.padding(.leading)
    }
    
    
    private func inviteFriendsCard() -> some View{
        RoundedRectangle(cornerRadius: 10)
            .foregroundColor(Color.theme.tfBlue)
            .frame(maxWidth: .infinity)
            .frame(height: 75)

            .overlay(alignment: .leading) {
                HStack {
                    Circle()
                        .frame(width: 40, height: 40)

                    VStack(alignment: .leading) {
                        Text("Invite friends on VITTY")
                            .font(.custom("Poppins-Medium", size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        Text("Kraryan")
                            .font(.custom("Poppins", size: 14))
                            .foregroundColor(Color.theme.tfBlueLight)
                    }
                    Spacer()
                    Image("link")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                }
                .padding()
            }
            .padding(.horizontal)
    }
}
