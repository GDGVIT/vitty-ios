//
//  VITTYApp.swift
//  VITTY
//
//  Created by Ananya George on 11/7/21.
//

import Firebase
import OSLog
import SwiftUI
import SwiftData
import TipKit

@main
struct VITTYApp: App {

    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(
            describing: VITTYApp.self
        )
    )

    @State private var deepLinkURL: URL?
    @State private var showJoinCircleAlert = false
    @State private var pendingCircleInvite: (code: String, circleName: String?)?
    
    
    @State private var isProcessingDeepLink = false
    
 
    @StateObject private var navigationCoordinator = NavigationCoordinator()
    
   
    @StateObject private var toastManager = ToastManager()

    init() {
        setupFirebase()
        NotificationManager.shared.requestAuthorization()
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .preferredColorScheme(.dark)
                    .environmentObject(navigationCoordinator)
                    .task {
                        try? Tips.configure([.displayFrequency(.immediate), .datastoreLocation(.applicationDefault)])
                    }
                    .onOpenURL { url in
                        handleDeepLink(url)
                    }
                    .alert("Join Circle", isPresented: $showJoinCircleAlert) {
                        Button("Cancel", role: .cancel) {
                            pendingCircleInvite = nil
                            isProcessingDeepLink = false
                        }
                        Button("Join") {
                            if let invite = pendingCircleInvite {
                                handleCircleInvite(invite)
                            }
                        }
                    } message: {
                        if let invite = pendingCircleInvite {
                            Text("Do you want to join the circle with code '\(invite.code)'?")
                        }
                    }
                
               
                if toastManager.isShowing {
                    CircleToastView(
                        message: toastManager.message,
                        isError: toastManager.isError,
                        isShowing: $toastManager.isShowing
                    )
                    .animation(.easeInOut(duration: 0.3), value: toastManager.isShowing)
                    .zIndex(1000)
                }
            }
            .environmentObject(toastManager)
        }
        .modelContainer(sharedModelContainer)
    }

    var sharedModelContainer: ModelContainer {
        let schema = Schema([TimeTable.self, Remainder.self, CreateNoteModel.self, UploadedFile.self])
        let config = ModelConfiguration(
            "group.com.gdscvit.vittyioswidget"
        )
        return try! ModelContainer(for: schema, configurations: config)
    }
}

// MARK: - Toast Manager
class ToastManager: ObservableObject {
    @Published var isShowing = false
    @Published var message = ""
    @Published var isError = false
    
    private var hideTimer: Timer?
    
    init() {
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(showToastNotification),
            name: Notification.Name("ShowToast"),
            object: nil
        )
    }
    
    @objc private func showToastNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let message = userInfo["message"] as? String,
              let isError = userInfo["isError"] as? Bool else {
            return
        }
        
        showToast(message: message, isError: isError)
    }
    
    func showToast(message: String, isError: Bool) {
        DispatchQueue.main.async {
            self.message = message
            self.isError = isError
            self.isShowing = true
            
          
            self.hideTimer?.invalidate()
            self.hideTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
                self.hideToast()
            }
        }
    }
    
    func hideToast() {
        DispatchQueue.main.async {
            self.isShowing = false
            self.hideTimer?.invalidate()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        hideTimer?.invalidate()
    }
}

// MARK: - Toast View
struct CircleToastView: View {
    let message: String
    let isError: Bool
    @Binding var isShowing: Bool
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Image(systemName: isError ? "xmark.circle.fill" : "checkmark.circle.fill")
                    .foregroundColor(isError ? .red : .green)
                    .font(.system(size: 20))
                
                Text(message)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.9))
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .onTapGesture {
            isShowing = false
        }
    }
}

// MARK: - Navigation Coordinator
class NavigationCoordinator: ObservableObject {
    @Published var shouldNavigateToCircles = false
    @Published var pendingCircleInvite: (code: String, circleName: String?)?
    
    func navigateToCirclesForInvite(code: String, circleName: String?) {
        pendingCircleInvite = (code: code, circleName: circleName)
        shouldNavigateToCircles = true
    }
    
    func resetNavigation() {
        shouldNavigateToCircles = false
        pendingCircleInvite = nil
    }
}

// MARK: - Deep Link Handling
extension VITTYApp {
    
    private func handleDeepLink(_ url: URL) {
        logger.info("Deep link received: \(url.absoluteString)")
        
       
        guard !isProcessingDeepLink else {
            logger.info("Already processing a deep link, ignoring")
            return
        }
        
        isProcessingDeepLink = true
        
        if url.absoluteString.contains("vitty://join") {
            handleJoinCircleURL(url)
        } else {
            logger.info("Unhandled deep link type: \(url.absoluteString)")
            isProcessingDeepLink = false
        }
    }

    private func handleJoinCircleURL(_ url: URL) {
        logger.info("Handling join circle URL")
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            logger.error("Failed to parse URL components")
            isProcessingDeepLink = false
            return
        }
        
        guard let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
            logger.error("No code found in URL")
            showToast(message: "Error: Invalid invitation link", isError: true)
            isProcessingDeepLink = false
            return
        }
        
        let circleName = components.queryItems?.first(where: { $0.name == "circleName" })?.value
        
        logger.info("Parsed circle code: \(code)")
        if let name = circleName {
            logger.info("Parsed circle name: \(name)")
        }
        
       
        navigationCoordinator.navigateToCirclesForInvite(code: code, circleName: circleName)
        
        let invite = (code: code, circleName: circleName)
        
     
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.pendingCircleInvite = invite
            self.showJoinCircleAlert = true
        }
        
        logger.info("Circle join alert prepared for code: \(code)")
    }
    
    private func handleCircleInvite(_ invite: (code: String, circleName: String?)) {
        
        guard let token = UserDefaults.standard.string(forKey: UserDefaultKeys.tokenKey),
              !token.isEmpty else {
            logger.error("No token found in UserDefaults")
            showToast(message: "Error: Unable to get user information", isError: true)
            cleanup()
            return
        }
        
        if invite.code.count < 3 {
            showToast(message: "Error: Circle code must be at least 3 characters", isError: true)
            cleanup()
            return
        }
        
        let urlString = "\(APIConstants.base_urlv3)circles/join?code=\(invite.code)"
        guard let url = URL(string: urlString) else {
            logger.error("Invalid URL: \(urlString)")
            showToast(message: "Error: Invalid URL", isError: true)
            cleanup()
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        
        logger.info("Joining circle with code: \(invite.code)")
        logger.info("Request URL: \(urlString)")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                
                if let error = error {
                    self.logger.error("Network error: \(error.localizedDescription)")
                    self.showToast(message: "Network error: \(error.localizedDescription)", isError: true)
                    self.cleanup()
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self.showToast(message: "Error: Invalid response", isError: true)
                    self.cleanup()
                    return
                }
                
                self.logger.info("Response status code: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                    self.showToast(message: "Successfully joined the circle! 🎉", isError: false)
                    
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    
                  
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        NotificationCenter.default.post(
                            name: Notification.Name("CircleJoinedSuccessfully"),
                            object: nil,
                            userInfo: ["code": invite.code]
                        )
                    }
                    
                    self.logger.info("Successfully joined circle with code: \(invite.code)")
                } else {
                    
                    if let data = data {
                        self.logger.error("Error response data: \(String(data: data, encoding: .utf8) ?? "No data")")
                        
                        if let errorResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let message = errorResponse["message"] as? String {
                            self.showToast(message: "Error: \(message)", isError: true)
                        } else {
                            self.handleHTTPError(statusCode: httpResponse.statusCode)
                        }
                    } else {
                        self.handleHTTPError(statusCode: httpResponse.statusCode)
                    }
                }
                
                self.cleanup()
            }
        }.resume()
    }

    // MARK: - Helper Methods
    
    
    private func cleanup() {
        pendingCircleInvite = nil
        isProcessingDeepLink = false
        navigationCoordinator.resetNavigation()
    }
    
    private func handleHTTPError(statusCode: Int) {
        switch statusCode {
        case 400:
            showToast(message: "Error: Bad request", isError: true)
        case 401:
            showToast(message: "Error: Unauthorized", isError: true)
        case 403:
            showToast(message: "Error: Forbidden", isError: true)
        case 404:
            showToast(message: "Error: Circle not found", isError: true)
        case 409:
            showToast(message: "Error: Already a member of this circle", isError: true)
        case 500:
            showToast(message: "Error: Server error", isError: true)
        default:
            showToast(message: "Error: Something went wrong", isError: true)
        }
    }
    
    private func showToast(message: String, isError: Bool) {
        // NEW: Use ToastManager directly
        toastManager.showToast(message: message, isError: isError)
        
        if isError {
            logger.error("Toast Error: \(message)")
        } else {
            logger.info("Toast Success: \(message)")
        }
    }
}

// MARK: - Firebase Setup
extension VITTYApp {
    private func setupFirebase() {
        self.logger.info("Configuring Firebase Started")
        FirebaseApp.configure()
        self.logger.info("Configuring Firebase Ended")
    }
}
