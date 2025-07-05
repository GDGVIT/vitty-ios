import SwiftUI
import OSLog
import SwiftData




struct UserProfileSidebar: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Binding var isPresented: Bool
    @State private var ghostMode: Bool = false
    @State private var isUpdatingGhostMode: Bool = false
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button {
                isPresented = false
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
                
                Divider().background(Color.clear)
                
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
                
                Divider().background(Color.clear)
                
//                MenuOption(icon: "share", title: "Share")
                MenuOption(icon: "support", title: "Support").onTapGesture {
                    let supportUrl = URL(string: "https://github.com/GDGVIT/vitty-ios/issues/new?template=bug_report.md")
                    UIApplication.shared.open(supportUrl!)
                }
//                MenuOption(icon: "about", title: "About")
                
                Divider().background(Color.clear)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ghost Mode")
                        .font(Font.custom("Poppins-Medium", size: 16))
                        .foregroundColor(.white)
                    Text("(your timetable will be visible only to you)")
                        .font(Font.custom("Poppins-Regular", size: 12))
                        .foregroundColor(.white.opacity(0.7))
                    
                    HStack {
                        Toggle("", isOn: $ghostMode)
                            .labelsHidden()
                            .toggleStyle(SwitchToggleStyle(tint: Color("Accent")))
                            .disabled(isUpdatingGhostMode)
                            .padding(.top, 4)
                            .onChange(of: ghostMode) { oldValue, newValue in
                                updateGhostMode(enabled: newValue)
                            }
                        
                        if isUpdatingGhostMode {
                            ProgressView()
                                .scaleEffect(0.8)
                                .foregroundColor(.white)
                        }
                    }
                }
                
                Spacer()
                
                Button {
                    authViewModel.signOut()
                    do{
                        try modelContext.delete(model:TimeTable.self)
                        try modelContext.delete(model:Remainder.self)
                        try modelContext.delete(model:CreateNoteModel.self)
                        try modelContext.delete(model:UploadedFile.self)
                        try modelContext.save()
                    }catch{
                        print("Failed to load data")
                    }
                } label: {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red)
                        Text("log out")
                            .font(Font.custom("Poppins-Medium", size: 16))
                            .foregroundColor(.red)
                    }
                }
                .padding(.bottom, 32)
            }
            .padding(.horizontal, 24)
            .frame(width: UIScreen.main.bounds.width * 0.75, alignment: .leading)
            .frame(maxHeight: .infinity)
            .background(Color("Background"))
            .transition(.move(edge: .trailing))
        }
        .animation(.easeInOut(duration: 0.3), value: isPresented)
        .onAppear {
            loadGhostModeState()
        }
    }
    
    // MARK: - Ghost Mode Functions
    
    private func loadGhostModeState() {
        
        let username = authViewModel.loggedInBackendUser?.username ?? ""
        ghostMode = UserDefaults.standard.bool(forKey: "ghostMode_\(username)")
    }
    
    private func updateGhostMode(enabled: Bool) {
        guard let username = authViewModel.loggedInBackendUser?.username,
              let token = authViewModel.loggedInBackendUser?.token else {
            return
        }
        
        isUpdatingGhostMode = true
        
       
        let endpoint = enabled ? "ghost" : "alive"
        let urlString = "\(APIConstants.base_url)friends/\(endpoint)/\(username)"
        
        guard let url = URL(string: urlString) else {
            isUpdatingGhostMode = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isUpdatingGhostMode = false
                
                if let error = error {
                    print("Ghost mode update failed: \(error.localizedDescription)")
                    
                    ghostMode = !enabled
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                       
                        UserDefaults.standard.set(enabled, forKey: "ghostMode_\(username)")
                        print("Ghost mode \(enabled ? "enabled" : "disabled") successfully")
                    } else {
                        print("Ghost mode update failed with status code: \(httpResponse.statusCode)")
                      
                        ghostMode = !enabled
                    }
                }
            }
        }.resume()
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
