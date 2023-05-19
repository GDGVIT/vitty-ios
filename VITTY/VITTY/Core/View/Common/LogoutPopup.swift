//
//  LogoutPopup.swift
//  VITTY
//
//  Created by Ananya George on 12/24/21.
//

import SwiftUI

struct LogoutPopup: View {
    @EnvironmentObject var authState: AuthService
    @Binding var showLogout: Bool
    var cornerRadius = 3.0
    var fontSizeButton = 14.0
    var body: some View {
        VStack(alignment:.leading) {
            Text("Logout")
                .foregroundColor(Color.white)
                .font(Font.custom("Poppins-SemiBold", size: 20))
            Text("Are you sure?")
                .foregroundColor(Color.vprimary)
                .font(Font.custom("Poppins-Regular", size: 16))
                .padding(.bottom)
            HStack {
                CustomButton(buttonText: "Cancel", fontSize: fontSizeButton, bgroundColor: Color.clear,borderColor: Color.vprimary, borderWidth: 1.0 ,cornerRad: cornerRadius) {
                    showLogout = false
                    
                }
                Spacer()
                // create function to log out
                CustomButton(buttonText: "Logout", fontSize: fontSizeButton, cornerRad: cornerRadius) {
                    print("signing out")
                    authState.signOut()
                }
            }
        }
        .padding()
        .background(Color.darkbg)
        .cornerRadius(12)
        .padding()
    }
}

struct LogoutPopup_Previews: PreviewProvider {
    static var previews: some View {
        LogoutPopup(showLogout: .constant(false))
    }
}
