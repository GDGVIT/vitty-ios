import SwiftUI

// MARK: - Unfriend Alert
struct UnfriendAlert: View {
    let friendName: String
    let onCancel: () -> Void
    let onUnfriend: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 12) {
                Text("Unfriend \(friendName)?")
                    .font(.custom("Poppins-SemiBold", size: 18))
                    .foregroundColor(.white)
                
                Text("This action cannot be undone. You'll need to send a new friend request to reconnect.")
                    .font(.custom("Poppins-Regular", size: 14))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 10) {
                    Button(action: onCancel) {
                        Text("Cancel")
                            .font(.custom("Poppins-Regular", size: 14))
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    Button(action: onUnfriend) {
                        Text("Unfriend")
                            .font(.custom("Poppins-Regular", size: 14))
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
            .frame(height: 150)
            .padding(20)
            .background(Color("Background"))
            .cornerRadius(16)
            .padding(.horizontal, 30)
            .transition(.scale.combined(with: .opacity))
            Spacer()
        }
        .background(Color.black.opacity(0.5).edgesIgnoringSafeArea(.all))
    }
}

// MARK: - Action Result Alert
struct ActionResultAlert: View {
    let message: String
    let onDismiss: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 12) {
                Text("Action Result")
                    .font(.custom("Poppins-SemiBold", size: 18))
                    .foregroundColor(.white)
                
                Text(message)
                    .font(.custom("Poppins-Regular", size: 14))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Button(action: {
                    onDismiss()
                }) {
                    Text("OK")
                        .font(.custom("Poppins-Regular", size: 14))
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(Color("Accent"))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .frame(height: 120)
            .padding(20)
            .background(Color("Background"))
            .cornerRadius(16)
            .padding(.horizontal, 30)
            .transition(.scale.combined(with: .opacity))
            Spacer()
        }
        .background(
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                  
                }
        )
    }
}

// MARK: - Menu Button Item
struct MenuButtonItem: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 14, height: 14)
                Text(title)
                    .font(.custom("Poppins-Medium", size: 13))
                    .foregroundColor(color)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.clear)
        }
    }
}

// MARK: - Friend Menu
struct FriendMenu: View {
    let friend: Friend
    let isGhosted: Bool
    let onTimetable: () -> Void
    let onUnfriend: () -> Void
    let onToggleGhost: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            MenuButtonItem(
                icon: "person.badge.minus",
                title: "Unfriend",
                color: .red,
                action: onUnfriend
            )
            
            menuDivider
            
            MenuButtonItem(
                icon: isGhosted ? "eye" : "eye.slash",
                title: isGhosted ? "Show" : "Hide",
                color: .orange,
                action: onToggleGhost
            )
        }
        .frame(width: 140)
        .background(menuBackground)
        .offset(x: -75, y: 0)
        .zIndex(100)
        .transition(menuTransition)
    }
    
    private var menuDivider: some View {
        Divider()
            .background(Color.gray.opacity(0.3))
    }
    
    private var menuBackground: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color(hex: "#1A2B42"))
            .stroke(Color(hex: "#0D1E30"), lineWidth: 1)
            .shadow(color: .black.opacity(0.4), radius: 6, x: -2, y: 2)
    }
    
    private var menuTransition: AnyTransition {
        .asymmetric(
            insertion: .scale(scale: 0.8).combined(with: .opacity),
            removal: .scale(scale: 0.8).combined(with: .opacity)
        )
    }
}

// MARK: - Friend Status View
struct FriendStatusView: View {
    let friend: Friend
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(cleanName(friend.name))
                .font(Font.custom("Poppins-SemiBold", size: 18))
                .foregroundColor(Color.white)
            
            statusIndicator
        }
    }
    
    @ViewBuilder
    private var statusIndicator: some View {
        if friend.currentStatus.status == "free" {
            HStack {
                Image("available")
                    .resizable()
                    .frame(width: 20, height: 20)
                Text("Available")
                    .foregroundStyle(Color("Accent"))
            }
        } else {
            HStack {
                Image("inclass")
                Text(friend.currentStatus.venue ?? "")
                    .font(Font.custom("Poppins-Regular", size: 14))
                    .foregroundColor(Color("Accent"))
            }
        }
    }
    
    private func cleanName(_ fullName: String) -> String {
        let pattern = "\\b\\d{2}[A-Z]+\\d+\\b"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        
        let range = NSRange(location: 0, length: fullName.utf16.count)
        let cleanedName = regex?.stringByReplacingMatches(
            in: fullName,
            options: [],
            range: range,
            withTemplate: ""
        ).trimmingCharacters(in: .whitespaces) ?? fullName
        
        return cleanedName
    }
}


struct FriendRow: View {
    let friend: Friend
    @State private var showingMenu = false
    @State private var isLoading = false
    @State private var navigateToTimetable = false
    
    @Binding var showingUnfriendAlert: Bool
    @Binding var showingActionAlert: Bool
    @Binding var alertMessage: String
    @Binding var selectedFriend: Friend?
    
    @Environment(CommunityPageViewModel.self) private var communityPageViewModel
    @Environment(AuthViewModel.self) private var authViewModel

    var body: some View {
        ZStack {
            hiddenNavigationLink
            
            mainContent
                .overlay(loadingOverlay, alignment: .center)
                .onReceive(NotificationCenter.default.publisher(for: .dismissMenus)) { _ in
                    showingMenu = false
                }
                .onTapGesture {
                    handleTapGesture()
                }
        }
        .animation(.easeInOut(duration: 0.2), value: showingMenu)
    }
    
    private var hiddenNavigationLink: some View {
        NavigationLink(
            destination: FriendsTimeTableView(friend: friend),
            isActive: $navigateToTimetable
        ) {
            EmptyView()
        }
        .hidden()
    }
    
    private var mainContent: some View {
        HStack {
            UserImage(url: friend.picture, height: 48, width: 48)
            
            Spacer()
                .frame(width: 20)
            
            FriendStatusView(friend: friend)
            
            Spacer()
            
            actionButtons
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(rowBackground)
    }
    
    private var actionButtons: some View {
        HStack(spacing: 12) {
            if communityPageViewModel.isGhosted(friend.username) {
                ghostIndicator
            }
            
            menuButton
        }
    }
    
    private var ghostIndicator: some View {
        Image(systemName: "eye.slash.fill")
            .foregroundColor(.orange)
            .font(.system(size: 16))
    }
    
    private var menuButton: some View {
        Button(action: toggleMenu) {
            Image(systemName: "ellipsis")
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .medium))
                .frame(width: 32, height: 32)
                .contentShape(Rectangle())
        }
        .disabled(isLoading)
        .zIndex(2)
        .overlay(menuOverlay, alignment: .center)
    }
    
    @ViewBuilder
    private var menuOverlay: some View {
        if showingMenu {
            FriendMenu(
                friend: friend,
                isGhosted: communityPageViewModel.isGhosted(friend.username),
                onTimetable: handleTimetableAction,
                onUnfriend: handleUnfriendAction,
                onToggleGhost: handleToggleGhostAction
            )
        }
    }
    
    private var rowBackground: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(Color(hex: "#0D1E30"))
            .opacity(communityPageViewModel.isGhosted(friend.username) ? 0.6 : 1.0)
    }
    
    @ViewBuilder
    private var loadingOverlay: some View {
        if isLoading {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    ProgressView()
                        .scaleEffect(0.8)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                )
        }
    }
    
    
    private func toggleMenu() {
        withAnimation(.easeInOut(duration: 0.2)) {
            showingMenu.toggle()
        }
    }
    
    private func handleTapGesture() {
        if showingMenu {
            withAnimation(.easeInOut(duration: 0.2)) {
                showingMenu = false
            }
        } else {
            navigateToTimetable = true
        }
    }
    
    private func handleTimetableAction() {
        showingMenu = false
        navigateToTimetable = true
    }
    
    private func handleUnfriendAction() {
        selectedFriend = friend
        showingUnfriendAlert = true
        showingMenu = false
    }
    
    private func handleToggleGhostAction() {
        toggleGhostMode()
        showingMenu = false
    }

    // MARK: - Helper Functions
    func cleanName(_ fullName: String) -> String {
        let pattern = "\\b\\d{2}[A-Z]+\\d+\\b"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        
        let range = NSRange(location: 0, length: fullName.utf16.count)
        let cleanedName = regex?.stringByReplacingMatches(
            in: fullName,
            options: [],
            range: range,
            withTemplate: ""
        ).trimmingCharacters(in: .whitespaces) ?? fullName
        
        return cleanedName
    }
    
    // MARK: - Action Functions
    func unfriendAction() {
        guard let token = authViewModel.loggedInBackendUser?.token else {
            alertMessage = "Authentication error. Please try again."
            showingActionAlert = true
            return
        }
        
        isLoading = true
        
        communityPageViewModel.unfriendUser(username: friend.username, token: token) { success in
            DispatchQueue.main.async {
                isLoading = false
                
                if success {
                    alertMessage = "Successfully unfriended \(cleanName(friend.name))"
                } else {
                    alertMessage = "Failed to unfriend \(cleanName(friend.name)). Please try again."
                }
                showingActionAlert = true
            }
        }
    }
    
    private func toggleGhostMode() {
        guard let token = authViewModel.loggedInBackendUser?.token else {
            alertMessage = "Authentication error. Please try again."
            showingActionAlert = true
            return
        }
        
        isLoading = true
        let isCurrentlyGhosted = communityPageViewModel.isGhosted(friend.username)
        
        if isCurrentlyGhosted {
            communityPageViewModel.makeAlive(username: friend.username, token: token) { success in
                DispatchQueue.main.async {
                    handleGhostResult(success: success, action: "make alive")
                }
            }
        } else {
            communityPageViewModel.ghostFriend(username: friend.username, token: token) { success in
                DispatchQueue.main.async {
                    handleGhostResult(success: success, action: "ghost")
                }
            }
        }
    }
    
    private func handleGhostResult(success: Bool, action: String) {
        isLoading = false
        
        if success {
            let message = action == "ghost"
                ? "\(cleanName(friend.name)) has been ghosted and won't appear in your active friends"
                : "\(cleanName(friend.name)) is now visible in your friends list"
            alertMessage = message
        } else {
            alertMessage = "Failed to \(action) \(cleanName(friend.name)). Please try again."
        }
        
        showingActionAlert = true
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Notification Extension
extension Notification.Name {
    static let dismissMenus = Notification.Name("dismissMenus")
}
