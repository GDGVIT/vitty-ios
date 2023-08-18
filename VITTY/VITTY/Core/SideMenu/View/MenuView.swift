//
//  MenuView.swift
//  VITTY
//
//  Created by Prashanna Rajbhandari on 10/08/2023.
//

import SwiftUI

struct MenuView: View {
    var body: some View {
        ZStack(alignment: .leading) {
            // background
            Color.theme.secondaryBlue
                .ignoresSafeArea()

            // Foreground
            VStack(alignment: .leading) {
                // TODO: Fix Assets

                userDetails()

                Divider()
                    .padding(.top, 32)

                updateYoutStatus()

                profile()

                friendCircle()

                friendActivity()

                Divider()

                settings()

                Spacer()

                logout()
            }
            .padding()
        }
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}

extension MenuView {
    // MARK: User

    private func userDetails() -> some View {
        VStack(alignment: .leading) {
            Circle()
                .frame(width: 50, height: 40)

            Text("Swayam Sharma")
                .font(.custom("Poppins", size: 16))
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.top)

            Text("@swayam.s")
                .font(.custom("Poppins-Light", size: 14))
                .foregroundColor(Color.theme.primary)
        }
    }

    private func Divider() -> some View {
        VStack {
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color.theme.primary)
        }
    }

    private func updateYoutStatus() -> some View {
        VStack {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.theme.primary, lineWidth: 0.3)
                .frame(height: 44)
                .overlay(alignment: .leading, content: {
                    HStack {
                        Image("smile")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                            .padding()

                        Text("Update Your Status")
                            .font(.custom("Poppins-Regular", size: 14))
                            .foregroundColor(Color.theme.tfBlueLight)
                    }
                })
                .padding(.top)
        }
    }

    // MARK: Profile

    private func profile() -> some View {
        HStack {
            Image("profile")
                .resizable()
                .scaledToFit()
                .frame(width: 25, height: 25)
                .padding()

            Text("Profile")
                .font(.custom("Poppins-Medium", size: 16))
                .foregroundColor(Color.white)
        }
    }

    // MARK: FriendCircle

    private func friendCircle() -> some View {
        HStack {
            Image("friend-circle")
                .resizable()
                .scaledToFit()
                .frame(width: 25, height: 25)
                .padding()

            Text("Friend Circle")
                .font(.custom("Poppins-Medium", size: 16))
                .foregroundColor(Color.white)
        }
    }

    // MARK: FriendActivity

    private func friendActivity() -> some View {
        HStack {
            Image("friend-activity")
                .resizable()
                .scaledToFit()
                .frame(width: 25, height: 25)
                .padding()

            Text("Friend Activity")
                .font(.custom("Poppins-Medium", size: 16))
                .foregroundColor(Color.white)
        }
    }

    // MARK: Settings

    private func settings() -> some View {
        HStack {
            Image("settings")
                .resizable()
                .scaledToFit()
                .frame(width: 25, height: 25)
                .padding()

            Text("Settings")
                .font(.custom("Poppins-Medium", size: 16))
                .foregroundColor(Color.white)
        }
    }

    // MARK: Logout

    private func logout() -> some View {
        HStack {
            Image("logout")
                .resizable()
                .scaledToFit()
                .frame(width: 25, height: 25)
                .padding()

            Text("Logout")
                .font(.custom("Poppins-Medium", size: 16))
                .foregroundColor(Color.white)
        }
    }
}
