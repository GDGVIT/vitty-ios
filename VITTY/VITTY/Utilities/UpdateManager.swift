//
//  UpdateManager.swift
//  VITTY
//
//  In-App Update Check Manager
//

import Foundation
import StoreKit
import SwiftUI

// MARK: - Update Manager
class UpdateManager: ObservableObject {
    static let shared = UpdateManager()
    
    @Published var isUpdateAvailable = false
    @Published var updateInfo: AppUpdateInfo?
    @Published var showUpdateAlert = false
    
    private let appStoreURL = "https://apps.apple.com/app/id1611750267"
   
    private let lastUpdateCheckKey = "LastUpdateCheckDate"
    private let skipVersionKey = "SkippedVersion"
    
    // Configuration
    private let checkInterval: TimeInterval = 24 * 60 * 60
    private let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    
    struct AppUpdateInfo {
        let latestVersion: String
        let releaseNotes: String
        let isForced: Bool
        let downloadURL: String
    }
    
    private init() {}
    
    // MARK: - Public Methods
    
    func checkForUpdates(forced: Bool = false) {
       
        if !forced && !shouldCheckForUpdates() {
            return
        }
        
        guard let appID = getAppID() else {
            print("App ID not found")
            return
        }
        
        fetchAppStoreVersion(appID: appID) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let updateInfo):
                    self?.handleUpdateInfo(updateInfo)
                case .failure(let error):
                    print("Update check failed: \(error)")
                }
            }
        }
        
        // Update last check date
        UserDefaults.standard.set(Date(), forKey: lastUpdateCheckKey)
    }
    
    func presentUpdateAlert() {
        showUpdateAlert = true
    }
    
    func skipThisVersion() {
        if let version = updateInfo?.latestVersion {
            UserDefaults.standard.set(version, forKey: skipVersionKey)
        }
        dismissUpdateAlert()
    }
    
    func dismissUpdateAlert() {
        showUpdateAlert = false
    }
    
    func openAppStore() {
        guard let url = URL(string: appStoreURL) else { return }
        UIApplication.shared.open(url)
    }
    
    // MARK: - Private Methods
    
    private func shouldCheckForUpdates() -> Bool {
        guard let lastCheck = UserDefaults.standard.object(forKey: lastUpdateCheckKey) as? Date else {
            return true
        }
        
        return Date().timeIntervalSince(lastCheck) >= checkInterval
    }
    
    private func getAppID() -> String? {
       
        return "1611750267"
    }
    
    private func fetchAppStoreVersion(appID: String, completion: @escaping (Result<AppUpdateInfo, Error>) -> Void) {
        let urlString = "https://itunes.apple.com/lookup?id=\(appID)"
        guard let url = URL(string: urlString) else {
            completion(.failure(UpdateError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(UpdateError.noData))
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                let results = json?["results"] as? [[String: Any]]
                
                guard let appInfo = results?.first else {
                    completion(.failure(UpdateError.noAppInfo))
                    return
                }
                
                let latestVersion = appInfo["version"] as? String ?? "1.0"
                let releaseNotes = appInfo["releaseNotes"] as? String ?? "Bug fixes and improvements"
                let downloadURL = appInfo["trackViewUrl"] as? String ?? self.appStoreURL
                
                let updateInfo = AppUpdateInfo(
                    latestVersion: latestVersion,
                    releaseNotes: releaseNotes,
                    isForced: self.isCriticalUpdate(latestVersion),
                    downloadURL: downloadURL
                )
                
                completion(.success(updateInfo))
                
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    private func handleUpdateInfo(_ updateInfo: AppUpdateInfo) {
        self.updateInfo = updateInfo
        
        // Check if update is available and not skipped
        if isNewerVersion(updateInfo.latestVersion, than: currentVersion) {
            let skippedVersion = UserDefaults.standard.string(forKey: skipVersionKey)
            
            // Show alert if it's a forced update or user hasn't skipped this version
            if updateInfo.isForced || skippedVersion != updateInfo.latestVersion {
                isUpdateAvailable = true
                presentUpdateAlert()
            }
        }
    }
    
    private func isNewerVersion(_ version1: String, than version2: String) -> Bool {
        return version1.compare(version2, options: .numeric) == .orderedDescending
    }
    
    private func isCriticalUpdate(_ version: String) -> Bool {
        // Define logic for critical updates
        // For example, major version changes or security updates
        let currentMajor = currentVersion.components(separatedBy: ".").first ?? "1"
        let latestMajor = version.components(separatedBy: ".").first ?? "1"
        
        return currentMajor != latestMajor
    }
}

// MARK: - Update Error
enum UpdateError: Error, LocalizedError {
    case invalidURL
    case noData
    case noAppInfo
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid App Store URL"
        case .noData:
            return "No data received from App Store"
        case .noAppInfo:
            return "App information not found"
        }
    }
}

// MARK: - Update Alert View
struct UpdateAlertView: View {
    @Environment(\.dismiss) private var dismiss
    let updateInfo: UpdateManager.AppUpdateInfo
    let onUpdate: () -> Void
    let onSkip: (() -> Void)?
    let onLater: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "arrow.down.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.blue)
            
            Text("Update Available")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Version \(updateInfo.latestVersion) is now available")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if !updateInfo.releaseNotes.isEmpty {
                ScrollView {
                    Text("What's New:")
                        .font(.headline)
                        .padding(.bottom, 5)
                    
                    Text(updateInfo.releaseNotes)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxHeight: 150)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
            
            VStack(spacing: 10) {
                Button("Update Now") {
                    onUpdate()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                if !updateInfo.isForced {
                    HStack(spacing: 20) {
                        if let onSkip = onSkip {
                            Button("Skip This Version") {
                                onSkip()
                                dismiss()
                            }
                            .foregroundColor(.secondary)
                        }
                        
                        Button("Later") {
                            onLater()
                            dismiss()
                        }
                        .foregroundColor(.secondary)
                    }
                    .font(.subheadline)
                }
            }
        }
        .padding()
        .frame(maxWidth: 350)
    }
}

