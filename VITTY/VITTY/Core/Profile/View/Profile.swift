//
//  Profike.swift
//  VITTY
//
//  Created by Prashanna Rajbhandari on 30/05/2023.
//

import SwiftUI

struct Profile: View {
    
    @StateObject private var vm = ProfileViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            // background
            Color.theme.blueBG
                .ignoresSafeArea()

            VStack(alignment: .leading) {
                userProfileImage()

                nameInputs()

                button()
            }
            .padding()

        }.toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Text("Profile")
                    .font(.custom("Poppins-Medium", size: 22))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Image(systemName: "xmark")
                    .foregroundColor(.white)
                    .padding(.trailing)
                    .onTapGesture {
                        presentationMode.wrappedValue.dismiss()
                    }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct Profile_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                Profile()
            }
        } else {
            NavigationView {
                Profile()
            }
        }
    }
}

extension Profile {
    private func userProfileImage() -> some View {
        RoundedRectangle(cornerRadius: 10)
            .frame(height: 315)
            .padding()
    }

    private func nameInputs() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Full Name")
                .font(.custom("Poppins-Medium", size: 16))
                .foregroundColor(Color.theme.primary)
                .padding(.leading)
            textField(text: $vm.fullName, tfString: "Prashanna Rajbhandari", height: 55)

            Text("User Name")
                .font(.custom("Poppins-Medium", size: 16))
                .foregroundColor(Color.theme.primary)
                .padding(.leading)
            textField(text: $vm.userName, tfString: "PrashannaR", height: 55)
        }
        .padding(.bottom, 55)
    }

    private func button() -> some View {
        Button {
            // action
        } label: {
            Text("Save")
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
