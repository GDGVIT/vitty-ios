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

	private let logger = Logger(
		subsystem: Bundle.main.bundleIdentifier!,
		category: String(
			describing: VITTYApp.self
		)
	)

	init() {
		setupFirebase()
	}

	var body: some Scene {
		WindowGroup {
			ContentView()
				.preferredColorScheme(.dark)
        }.modelContainer(sharedModelContainer)
	}
    var sharedModelContainer: ModelContainer {
        let schema = Schema([TimeTable.self,Remainder.self])
            let config = ModelConfiguration(
                "group.com.gdscvit.vittyioswidget"
        
            )
            return try! ModelContainer(for: schema, configurations: config)
        }
}

extension VITTYApp {
	private func setupFirebase() {
		self.logger.info("Configuring Firebase Started")
		FirebaseApp.configure()
		self.logger.info("Configuring Firebase Ended")
	}
}
