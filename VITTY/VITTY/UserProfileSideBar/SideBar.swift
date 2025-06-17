import SwiftUI

struct UserProfileSidebar: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Binding var isPresented: Bool
    @State private var ghostMode: Bool = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            
            Button {
                withAnimation {
                    isPresented = false
                }
            } label: {
                Image(systemName: "xmark")
                    .foregroundColor(.white)
                    .padding()
            }
            
            VStack(alignment: .leading, spacing: 24) {
               
                VStack(alignment: .leading, spacing: 8) {
                    UserImage(
                        url: authViewModel.loggedInBackendUser?.picture ?? "",
                        height: 60,
                        width: 60
                    )
                    
                    Text(authViewModel.loggedInBackendUser?.name ?? "User")
                        .font(Font.custom("Poppins-Bold", size: 18))
                        .foregroundColor(.white)
                    
                    Text("@\(authViewModel.loggedInBackendUser?.username ?? "")")
                        .font(Font.custom("Poppins-Regular", size: 14))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.top, 40)
                
                Divider()
                    .background(Color.clear)
                
                NavigationLink {
                    EmptyClassRoom()
                } label: {
                    MenuOption(icon: "emptyclassroom", title: "Find Empty Classroom")
                }
                
                NavigationLink {
                    SettingsView()
                } label: {
                    MenuOption(icon: "settings", title: "Settings")
                }
                
                Divider()
                    .background(Color.clear)
                
                MenuOption(icon: "share", title: "Share")
                
                MenuOption(icon: "support", title: "Support")
                
                MenuOption(icon: "about", title: "About")
                
                Divider()
                    .background(Color.clear)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ghost Mode")
                        .font(Font.custom("Poppins-Medium", size: 16))
                        .foregroundColor(.white)
                    
                    Text("(your timetable will be visible only to you)")
                        .font(Font.custom("Poppins-Regular", size: 12))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Toggle("", isOn: $ghostMode)
                        .labelsHidden()
                        .toggleStyle(SwitchToggleStyle(tint: Color("Accent")))
                        .padding(.top, 4)
                }
                
                Spacer()
                
                // Logout button
                Button {
                    authViewModel.signOut()
                } label: {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(Color.red)
                        Text("log out")
                            .font(Font.custom("Poppins-Medium", size: 16))
                            .foregroundColor(Color.red)
                    }
                }
                .padding(.bottom, 32)
            }
            .padding(.horizontal, 24)
            .frame(width: UIScreen.main.bounds.width * 0.75, alignment: .leading)
            .frame(maxHeight: .infinity)
            .background(Color("Background"))
            
        }
    }
}

struct MenuOption: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(icon)
                .foregroundColor(.white)
                .frame(width: 24)
            
            Text(title)
                .font(Font.custom("Poppins-Medium", size: 16))
                .foregroundColor(.white)
        }
    }
}

