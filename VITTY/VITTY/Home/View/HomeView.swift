import Foundation
import SwiftUI

struct HomeView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var selectedPage = 1
    @State private var showProfileSidebar: Bool = false
    @State private var isCreatingGroup = false
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
            }
            .ignoresSafeArea(edges: .bottom)
            .onAppear {
                setupOnboarding()
            }
            .onChange(of: selectedPage) { _, newValue in
                handleTabChange(newValue)
            }
            // NEW: Listen for deep link navigation
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("NavigateToCircles"))) { _ in
                selectedPage = 2 // Navigate to Connects tab
            }
            // NEW: Handle navigation coordinator changes
            .onChange(of: navigationCoordinator.shouldNavigateToCircles) { _, shouldNavigate in
                if shouldNavigate {
                    selectedPage = 2
                }
            }
        }
    }
    
    // MARK: - Top Bar
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
    
    // MARK: - Profile Button
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
    
    // MARK: - Main Content
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
    
    // MARK: - Profile Sidebar
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
    
    // MARK: - Setup Functions
    private func setupOnboarding() {
        // Start onboarding if not completed
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
