//
//  VITTYApp.swift
//  VITTY
//
//  Created by Ananya George on 11/7/21.
//

import SwiftUI
import Firebase
import GoogleSignIn

@main
struct VITTYApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    let notifCenter = UNUserNotificationCenter.current()
    

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        configureUserNotifications()
        FirebaseApp.configure()
        _ = RemoteConfigManager.sharedInstance
        return true
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any])
      -> Bool {
      return GIDSignIn.sharedInstance.handle(url)
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    private func configureUserNotifications() {
        UNUserNotificationCenter.current().delegate = self
        
        let dismissAction = UNNotificationAction(
        identifier: "dismiss",
        title: "Dismiss",
        options: []
        )
        
        let navigateToClass = UNNotificationAction(
        identifier: "navigateToClass",
        title: "Navigate",
        options: []
        )
        
        let category = UNNotificationCategory(
        identifier: "vitty-category",
        actions: [dismissAction, navigateToClass],
        intentIdentifiers: [],
        options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
}
