//
//  ContentView.swift
//  VITTY
//
//  Created by Ananya George on 11/7/21.
//

import SwiftUI
import StoreKit

struct ContentView: View {
    @State private var communityPageViewModel = CommunityPageViewModel()
    @State private var suggestedFriendsViewModel = SuggestedFriendsViewModel()
    @State private var friendRequestViewModel = FriendRequestViewModel()
    @State private var authViewModel = AuthViewModel()
    @State private var requestViewModel = RequestsViewModel()
    @State private var academicsViewModel = AcademicsViewModel()
    
    var body: some View {
        Group {
            if authViewModel.loggedInBackendUser != nil {
                HomeView()
                    .onAppear {
                       
                        ReviewManager.shared.trackAppUsage()
                        ReviewManager.shared.requestReviewIfAppropriate()
                    }
            }
            else if authViewModel.loggedInFirebaseUser != nil {
                InstructionView()
            }
            else {
                LoginView()
            }
        }
        .environment(authViewModel)
        .environment(communityPageViewModel)
        .environment(suggestedFriendsViewModel)
        .environment(friendRequestViewModel)
        .environment(academicsViewModel)
        .environment(requestViewModel).alert("Update Available", isPresented: .constant(UpdateManager.shared.showUpdateAlert)) {
            Button("Update Now") {
                UpdateManager.shared.openAppStore()
                UpdateManager.shared.dismissUpdateAlert()
            }
            
            if let updateInfo = UpdateManager.shared.updateInfo, !updateInfo.isForced {
                Button("Skip This Version") {
                    UpdateManager.shared.skipThisVersion()
                }
                
                Button("Later") {
                    UpdateManager.shared.dismissUpdateAlert()
                }
            }
        } message: {
            if let updateInfo = UpdateManager.shared.updateInfo {
                Text("Version \(updateInfo.latestVersion) is available.\n\n\(updateInfo.releaseNotes)")
            }
        }
    }
}

// MARK: - Review Manager
class ReviewManager: ObservableObject {
    static let shared = ReviewManager()
    
    private let reviewRequestKey = "LastReviewRequestDate"
    private let hasReviewedKey = "HasUserReviewed"
    private let appUsageCountKey = "AppUsageCount"
    private let firstLaunchDateKey = "FirstLaunchDate"
    
    // Configuration
    private let minimumUsageCount = 10 // Minimum number of app uses before review
    private let minimumDaysOfUsage = 7 // Minimum days since first launch
    private let monthsInterval: TimeInterval = 30 * 24 * 60 * 60 // 30 days between requests
    
    private init() {
      
        if UserDefaults.standard.object(forKey: firstLaunchDateKey) == nil {
            UserDefaults.standard.set(Date(), forKey: firstLaunchDateKey)
        }
    }
    
    func trackAppUsage() {
        let currentCount = UserDefaults.standard.integer(forKey: appUsageCountKey)
        UserDefaults.standard.set(currentCount + 1, forKey: appUsageCountKey)
    }
    
    func requestReviewIfAppropriate() {
       
        if UserDefaults.standard.bool(forKey: hasReviewedKey) {
            return
        }
        
       
        guard meetsUsageRequirements() else {
            return
        }
        
     
        guard hasEnoughTimePassed() else {
            return
        }
        
       
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: windowScene)
            }
        }
        
 
        UserDefaults.standard.set(Date(), forKey: reviewRequestKey)
    }
    
    private func meetsUsageRequirements() -> Bool {
        let usageCount = UserDefaults.standard.integer(forKey: appUsageCountKey)
        
        guard let firstLaunchDate = UserDefaults.standard.object(forKey: firstLaunchDateKey) as? Date else {
            return false
        }
        
        let daysSinceFirstLaunch = Calendar.current.dateComponents([.day], from: firstLaunchDate, to: Date()).day ?? 0
        
        return usageCount >= minimumUsageCount && daysSinceFirstLaunch >= minimumDaysOfUsage
    }
    
    private func hasEnoughTimePassed() -> Bool {
        guard let lastRequestDate = UserDefaults.standard.object(forKey: reviewRequestKey) as? Date else {
            return true
        }
        
        let now = Date()
        return now.timeIntervalSince(lastRequestDate) >= monthsInterval
    }
    
    func markAsReviewed() {
        UserDefaults.standard.set(true, forKey: hasReviewedKey)
    }
    
    func resetReviewStatus() {
        UserDefaults.standard.removeObject(forKey: hasReviewedKey)
        UserDefaults.standard.removeObject(forKey: reviewRequestKey)
        UserDefaults.standard.removeObject(forKey: appUsageCountKey)
        UserDefaults.standard.removeObject(forKey: firstLaunchDateKey)
    }
    
    // MARK: - Debug/Testing Methods
    func getCurrentUsageCount() -> Int {
        return UserDefaults.standard.integer(forKey: appUsageCountKey)
    }
    
    func getDaysSinceFirstLaunch() -> Int {
        guard let firstLaunchDate = UserDefaults.standard.object(forKey: firstLaunchDateKey) as? Date else {
            return 0
        }
        return Calendar.current.dateComponents([.day], from: firstLaunchDate, to: Date()).day ?? 0
    }
}
