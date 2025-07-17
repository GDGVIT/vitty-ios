import Foundation
import Alamofire
import OSLog

extension AppUser: Equatable {
    static func == (lhs: AppUser, rhs: AppUser) -> Bool {
        return lhs.name == rhs.name &&
               lhs.username == rhs.username &&
               lhs.token == rhs.token &&
               lhs.campus == rhs.campus
    }
}

class CampusUpdateService {
    static let shared = CampusUpdateService()
    
    let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!, category: String(describing: CampusUpdateService.self)
    )
    
    private init() {}
    
    func updateCampus(campus: String, token: String) async throws {
        guard let url = URL(string: "\(APIConstants.base_url)users/campus") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = ["campus": campus]
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        print("http status code : \(httpResponse.statusCode)")
        print("information : \(httpResponse.description)")
        
        guard httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
    }
}

// MARK: - Campus Selection Dialog
import SwiftUI

struct CampusSelectionDialog: View {
    @Binding var isPresented: Bool
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var selectedCampus: String = ""
    @State private var isUpdating: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
   
    private let campusOptions = [
        ("VIT Chennai", "chennai"),
        ("VIT Vellore", "vellore"),
        ("VIT Bhopal", "bhopal")
    ]
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
             
                VStack(spacing: 8) {
                    Text("Select Your Campus")
                        .font(.custom("Poppins-Bold", size: 20))
                        .foregroundColor(.primary)
                    
                    Text("Please select your campus to continue")
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundColor(.secondary)
                }
                
             
                VStack(spacing: 12) {
                    ForEach(campusOptions, id: \.0) { campus in
                        Button(action: {
                            selectedCampus = campus.1
                        }) {
                            HStack {
                                Text(campus.0)
                                    .font(.custom("Poppins-Medium", size: 16))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                if selectedCampus == campus.1 {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedCampus == campus.1 ?
                                          Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                            )
                        }
                    }
                }
                
               
                if showError {
                    Text(errorMessage)
                        .font(.custom("Poppins-Regular", size: 12))
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
                
               
                HStack(spacing: 16) {
                    Button("Update") {
                        Task {
                            await updateCampus()
                        }
                    }
                    .disabled(selectedCampus.isEmpty || isUpdating)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(selectedCampus.isEmpty || isUpdating ?
                                  Color.gray.opacity(0.3) : Color.blue)
                    )
                    .foregroundColor(.white)
                    .font(.custom("Poppins-Medium", size: 16))
                }
                
                if isUpdating {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.systemBackground))
            )
            .padding(.horizontal, 40)
        }
    }
    
    private func updateCampus() async {
        guard !selectedCampus.isEmpty,
              let token = authViewModel.loggedInBackendUser?.token else {
            return
        }
        
        isUpdating = true
        showError = false
        
        do {
            try await CampusUpdateService.shared.updateCampus(
                campus: selectedCampus,
                token: token
            )
            
            
            DispatchQueue.main.async {
                authViewModel.updateUserCampus(selectedCampus)
                isPresented = false
            }
            
        } catch {
            DispatchQueue.main.async {
                showError = true
                errorMessage = "Failed to update campus. Please try again."
            }
        }
        
        isUpdating = false
    }
}


extension AuthViewModel {
    
    var shouldShowCampusDialog: Bool {
        guard let backendUser = loggedInBackendUser else { return false }
        return backendUser.campus == nil || backendUser.campus?.isEmpty == true
    }
    
   
    func updateUserCampus(_ newCampus: String) {
        guard let currentUser = loggedInBackendUser else {
           
            return
        }
        
       
        loggedInBackendUser = AppUser(
            name: currentUser.name,
            picture: currentUser.picture,
            role: currentUser.role,
            token: currentUser.token,
            username: currentUser.username,
            campus: newCampus
        )
        
     
        UserDefaults.standard.set(newCampus, forKey: UserDefaultKeys.campusKey)
       
    }
    
    func clearCampusInfo() {
        guard let currentUser = loggedInBackendUser else { return }
        
        loggedInBackendUser = AppUser(
            name: currentUser.name,
            picture: currentUser.picture,
            role: currentUser.role,
            token: currentUser.token,
            username: currentUser.username,
            campus: nil
        )
        
        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.campusKey)
        
        
    }
}



struct HomeView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var selectedPage = 1
    @State private var showProfileSidebar: Bool = false
    @State private var isCreatingGroup = false
    @State private var showCampusDialog = false
    @StateObject private var tipManager = CustomTipManager()
    
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()

                VStack(spacing: 0) {
                    topBar
                    mainContent
                    Spacer()
                    BottomBarView(presentTab: $selectedPage)
                        .padding(.bottom, 24)
                }

                profileSidebar
                CustomTipOverlay(tipManager: tipManager, selectedTab: $selectedPage)
                
               
                if showCampusDialog {
                    CampusSelectionDialog(isPresented: $showCampusDialog)
                }
            }
            .ignoresSafeArea(edges: .bottom)
            .onAppear {
                setupOnboarding()
                checkCampusStatus()
            }
            .onChange(of: selectedPage) { _, newValue in
                handleTabChange(newValue)
            }
            .onChange(of: authViewModel.loggedInBackendUser?.username) { _, _ in
                checkCampusStatus()
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("NavigateToCircles"))) { _ in
                selectedPage = 2
            }
            .onChange(of: navigationCoordinator.shouldNavigateToCircles) { _, shouldNavigate in
                if shouldNavigate {
                    selectedPage = 2
                }
            }
        }
    }
    
    
    private func checkCampusStatus() {
       
        if authViewModel.shouldShowCampusDialog {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showCampusDialog = true
            }
        }
    }
    
 
    private var topBar: some View {
        HStack {
            Text(pageTitle)
                .font(Font.custom("Poppins-Bold", size: 26))

            Spacer()

            if selectedPage != 2 {
                profileButton
            }
        }
        .padding(.horizontal)
        .padding(.top, 20)
        .padding(.bottom, 8)
    }
    
    // MARK: - Page Title
    private var pageTitle: String {
        switch selectedPage {
        case 3: return "Academics"
        case 2: return "Connects"
        default: return "Schedule"
        }
    }
    
   
    private var profileButton: some View {
        ZStack {
            if !showProfileSidebar {
                Button {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        showProfileSidebar = true
                    }
                } label: {
                    UserImage(
                        url: authViewModel.loggedInBackendUser?.picture ?? "",
                        height: 30,
                        width: 40
                    )
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
    }
    

    private var mainContent: some View {
        ZStack {
            switch selectedPage {
            case 1:
                TimeTableView(friend: nil, isFriendsTimeTable: false)
            case 2:
                ConnectPage(isCreatingGroup: $isCreatingGroup)
            case 3:
                Academics()
            default:
                Text("Error")
            }
        }
        .padding(.top, 4)
    }
    
 
    @ViewBuilder
    private var profileSidebar: some View {
        if showProfileSidebar {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .transition(.opacity)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        showProfileSidebar = false
                    }
                }

            HStack {
                Spacer()
                UserProfileSidebar(isPresented: $showProfileSidebar)
                    .frame(width: UIScreen.main.bounds.width * 0.75)
                    .transition(.move(edge: .trailing))
            }
        }
    }
    
    
    private func setupOnboarding() {
        if !tipManager.hasCompletedOnboarding {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                tipManager.startOnboarding()
            }
        }
    }
    
    private func handleTabChange(_ newTab: Int) {
        print("Switched to tab: \(newTab)")
    }
}


extension AppUser {
    func updatingCampus(_ newCampus: String) -> AppUser {
        return AppUser(
            name: self.name,
            picture: self.picture,
            role: self.role,
            token: self.token,
            username: self.username,
            campus: newCampus
        )
    }
}
