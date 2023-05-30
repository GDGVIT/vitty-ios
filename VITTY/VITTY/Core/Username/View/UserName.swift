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
            
            //foreground
            VStack(alignment: .leading) {
                headerText()
                textField(text: $vm.usernameTF, tfString: "write something like \"Aryan13\"", height: 75)
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
        VStack(alignment: .leading) {
            Text(vm.isFirstLogin ? "Let's Sign you in." : "Let’s add your user name")
                .font(.custom("Poppins-Medium", size: 32))
                .fontWeight(.semibold)
                .foregroundColor(.white)
            Text("Write a  username? We'll use it to \npersonalise your experience.")
                .font(.custom("Poppins-Medium", size: 16))
                .foregroundColor(Color.theme.primary)
        }.padding(.leading)
    }

    private func continueButton() -> some View {
        Button {
            // action
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
