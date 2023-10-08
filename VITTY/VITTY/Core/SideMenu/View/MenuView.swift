//
//  MenuView.swift
//  VITTY
//
//  Created by Prashanna Rajbhandari on 10/08/2023.
//

import SwiftUI

struct MenuView: View {
    @EnvironmentObject var authVM: AuthService
    @EnvironmentObject var ttVM: TimetableViewModel
    @EnvironmentObject var notifVM: NotificationsViewModel

    @StateObject private var vm = MenuViewModel()

    var body: some View {
        NavigationView {
            ZStack(alignment: .leading) {
                // background
                Color.theme.secondaryBlue
                    .ignoresSafeArea()

                // Foreground
                VStack(alignment: .leading) {

                    userDetails()

                    Divider()
                        .padding(.top, 32)

                    updateYoutStatus()

                    Group {
                        profile()

                        friendCircle()

                        friendActivity()

                        Divider()
                    }

                    settings()

                    Group {
                        ghostMode()
                    }
                    .padding(.leading)

                    Spacer()
                    
                    Button {
                        authVM.signOut()
                    } label: {
                        logoutBtn()
                    }

                    
                }
                .padding(.horizontal)
            }
            .onAppear{
                authVM.username = UserDefaults.standard.string(forKey: AuthService.userKey) ?? "username"
                authVM.name = UserDefaults.standard.string(forKey: AuthService.nameKey) ?? "Full Name"
                authVM.image = UserDefaults.standard.string(forKey: AuthService.imageKey) ?? "Image"
            }
        }
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
            .environmentObject(AuthService())
            .environmentObject(TimetableViewModel())
            .environmentObject(NotificationsViewModel())
    }
}

extension MenuView {
    // MARK: User

    private func userDetails() -> some View {
        VStack(alignment: .leading) {
            AsyncImage(url: URL(string: authVM.image))
                .frame(width: 50, height: 50)
                .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                

            Text(authVM.name)
                .font(.custom("Poppins", size: 16))
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.top)

            Text("@\(authVM.username)")
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
        }.onTapGesture {
            vm.showProfile.toggle()
        }
        .fullScreenCover(isPresented: $vm.showProfile) {
            Profile()
                .environmentObject(authVM)
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
        }.onTapGesture {
            vm.showFriendCircle.toggle()
        }
        .fullScreenCover(isPresented: $vm.showFriendCircle) {
            FriendCircle()
        }
    }

    // MARK: FriendActivity

    private func friendActivity() -> some View {
        HStack {
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
        .onTapGesture {
            vm.showFriendActivity.toggle()
        }
        .fullScreenCover(isPresented: $vm.showFriendActivity) {
            FriendActivity()
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
        }.onTapGesture {
            vm.showSettings.toggle()
        }
        .fullScreenCover(isPresented: $vm.showSettings) {
            SettingsView()
                .environmentObject(authVM)
                .environmentObject(ttVM)
                .environmentObject(notifVM)
        }
    }

    // MARK: Ghost Mode

    private func ghostMode() -> some View {
        VStack(alignment: .leading) {
            Text("If you want your friends will not be \nable to view your activity. use ")
                .font(.custom("Poppins", size: 14))
                .foregroundColor(Color.theme.primary)
                +
                Text("ghost \nmode")
                .font(.custom("Poppins-Bold", size: 14))
                .foregroundColor(Color.theme.primary)

            ToggleView(isOn: $vm.isGhostModeOn) {
                Color.theme.secondaryBlue
            }.frame(width: 60, height: 30)
        }
    }

    // MARK: Logout

    private func logoutBtn() -> some View {
        HStack {
            Image("logout")
                .resizable()
                .scaledToFit()
                .frame(width: 25, height: 25)
                .padding(.leading)

            Text("log out")
                .font(.custom("Poppins-Medium", size: 16))
                .foregroundColor(Color.white)
        }
    }
}
