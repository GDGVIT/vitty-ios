//
//  UserName.swift
//  VITTY
//
//  Created by Prashanna Rajbhandari on 20/05/2023.
//

import SwiftUI

struct UserName: View {
    @StateObject private var vm = UserNameViewModel()

    var body: some View {
        ZStack {
            // background
            Color.theme.blueBG
                .ignoresSafeArea()

            VStack(alignment: .leading) {
                headerText()
                textField()
                Spacer()
                continueButton()
            }

        }.toolbar {
            ToolbarItem(placement: vm.isFirstLogin ? .navigationBarLeading : .navigationBarTrailing) {
                Image(systemName: vm.isFirstLogin ? "chevron.left" : "xmark")
                    .foregroundColor(.white)
            }
        }
    }
}

struct UserName_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                UserName()
            }
        } else {
            // Fallback on earlier versions
            NavigationView {
                UserName()
            }
        }
    }
}

// MARK: Extension

extension UserName {
    private func headerText() -> some View {
        VStack {
            Text(vm.isFirstLogin ? "Let's Sign you in." : "Let’s add you’r user name")
                .font(.custom("Poppins-Medium", size: 32))
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.bottom, 8)
            Text("Write a  username? We'll use it to         personalise your experience.")
                .multilineTextAlignment(.leading)
                .font(.custom("Poppins-Regular", size: 16))
                .foregroundColor(Color.theme.primary)
                .padding(.leading)
        }
    }
    
    private func textField() -> some View{
        VStack{
            if #available(iOS 15.0, *) {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(Color.theme.tfBlue)
                    .frame(maxWidth: .infinity)
                    .frame(height: 75)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.theme.tfBlueLight, lineWidth: 1)
                            .frame(maxWidth: .infinity)
                            .frame(height: 75)
                            .padding()
                            .overlay(alignment: .leading) {
                                TextField(text: $vm.usernameTF) {
                                    Text("write something like Aryan13")
                                        .foregroundColor(Color.theme.tfBlueLight)
                                }
                                .padding(.horizontal, 42)
                                .foregroundColor(.white)
                                .foregroundColor(Color.theme.tfBlue)
                            }
                    )

            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundColor(Color.blue)
                        .frame(maxWidth: .infinity)
                        .frame(height: 75)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gray, lineWidth: 1)
                                .frame(maxWidth: .infinity)
                                .frame(height: 75)
                                .padding()
                        )
                    
                    HStack {
                        TextField("write something like Aryan13", text: $vm.usernameTF)
                            .padding(.horizontal, 42)
                            .foregroundColor(.white)
                            .foregroundColor(Color.blue)
                    }
                    .padding(.leading, 20)
                }
            }
        }
    }
    
    private func continueButton() -> some View{
        Button {
            //action
        } label: {
            Text("Continue")
                .font(.custom("Poppins-Bold", size: 18))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 65)
                .background(Color.theme.brightBlue)
                .cornerRadius(10)
                .padding()
                
        }
    }
}
