//
//  RemoteConfigManager.swift
//  VITTY
//
//  Created by Ananya George on 2/14/22.
//

import Firebase
import Foundation

class RemoteConfigManager: ObservableObject {
	@Published var onlineMode = true

	static let sharedInstance = RemoteConfigManager()

	private init() {
		loadDefaultValues()
		fetchCloudValues()
	}

	func remoteConfSettings() {
		let settings = RemoteConfigSettings()
		// TODO: make this 43200 when releasing
		settings.minimumFetchInterval = 0
		RemoteConfig.remoteConfig().configSettings = settings
	}

	func loadDefaultValues() {
		let appRCDefaults: [String: Any?] = [
			"online_college_mode": false
		]
		RemoteConfig.remoteConfig().setDefaults(appRCDefaults as? [String: NSObject])
	}

	func fetchCloudValues() {

		remoteConfSettings()

		RemoteConfig.remoteConfig()
			.fetch { [weak self] _, error in
				guard error == nil else {
					print(
						"Something went wrong while fetching the remote configuration: \(error.debugDescription)"
					)
					return
				}

				print("Activating remote config values")
				RemoteConfig.remoteConfig()
					.activate { _, err in
						guard error == nil else {
							print(
								"Something went wrong while activating the remote configuration: \(err.debugDescription)"
							)
							return
						}
						print("Values retrieved from the cloud")
						let value = RemoteConfig.remoteConfig()
							.configValue(forKey: "online_college_mode").boolValue
						self?.updateUI(newUI: value)
					}
			}

	}

	func updateUI(newUI: Bool) {
		DispatchQueue.main.async {
			if newUI {
				self.onlineMode = true
			}
			else {
				self.onlineMode = false
			}
		}
	}
}
