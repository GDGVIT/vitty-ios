//
//  VITTYApp.swift
//  VITTY
//
//  Created by Ananya George on 11/7/21.
//

import Firebase
import GoogleSignIn
import SwiftData
import SwiftUI

/**
 `NOTE FOR FUTURE/NEW DEVS:`

 - always use the latest and greatest apple tools, don't use something that's been replaced by apple (start watching WWDC to stay updated)
 for eg: use SwiftData and not CoreData. use @Observable and not ObservableObject and u don't want to use UIKit instead of SwiftUI. trust me on this.
 reason: it makes the code more future proof and incase there's no activity on the development for a year, the app wont be outdated.
 downside: minimum deployment target has to be raised which hurts adoption but apple doesn't care about this either so we don't too.

 `personal experience, we have had issues when this app would just crash for iOS 16+ because the code were not updated.`
 `we lost a lot of users and our ratings dropped to 3.`

 - continuation to the first point, pls replace parts of the app that uses these old tech as soon as you can.

 - focus on keeping the package dependencies on latest versions

 - use `swift-format` to format the code before pushing. it's already configured for the project. double click on VITTY on left panel and click on format code.

 - use `tabs` and `not` spaces  pls.

 - try to focus on subtle animations and transitions. it makes the app feel more polished. `withAnimation{ }` is the greatest tool ever made by apple.

 - try to use haptics wherever possible. users love to feel those and apple makes it easier for us to implement

 - try to stick to Apple HIG as much as possible. ik it's difficult considering the UI we have now but it's worth it.

 - use // MARK: <title> when u create a function, it helps to navigate.
 */

@main
struct VITTYApp: App {
	//	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	//	let notifCenter = UNUserNotificationCenter.current()

	init() {
		setupFirebase()
	}

	var body: some Scene {
		WindowGroup {
			ContentView()
				.preferredColorScheme(.dark)
			//				.modelContainer(for: TimeTable.self)
			//				.modelContainer(for: Lecture.self)
		}
		//		.modelContainer(for: TimeTable.self)
		//		.modelContainer(for: Lecture.self)
	}
}

extension VITTYApp {
	private func setupFirebase() {
		FirebaseApp.configure()
	}
}

//class AppDelegate: NSObject, UIApplicationDelegate {
//	func application(
//		_ application: UIApplication,
//		didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
//	) -> Bool {
//		configureUserNotifications()
//		FirebaseApp.configure()
//		_ = RemoteConfigManager.sharedInstance
//		return true
//	}
//
//	@available(iOS 9.0, *)
//	func application(
//		_ application: UIApplication,
//		open url: URL,
//		options: [UIApplication.OpenURLOptionsKey: Any]
//	)
//		-> Bool
//	{
//		return GIDSignIn.sharedInstance.handle(url)
//	}
//}
//
//extension AppDelegate: UNUserNotificationCenterDelegate {
//
//	private func configureUserNotifications() {
//		UNUserNotificationCenter.current().delegate = self
//
//		let dismissAction = UNNotificationAction(
//			identifier: "dismiss",
//			title: "Dismiss",
//			options: []
//		)
//
//		let navigateToClass = UNNotificationAction(
//			identifier: "navigateToClass",
//			title: "Navigate",
//			options: []
//		)
//
//		let category = UNNotificationCategory(
//			identifier: "vitty-category",
//			actions: [dismissAction, navigateToClass],
//			intentIdentifiers: [],
//			options: []
//		)
//
//		UNUserNotificationCenter.current().setNotificationCategories([category])
//	}
//}
