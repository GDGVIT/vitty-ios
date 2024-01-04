//
//  NotificationsManager.swift
//  VITTY
//
//  Created by Ananya George on 1/23/22.
//

import Firebase
import FirebaseMessaging
import Foundation
import UIKit
import UserNotifications

class NotificationsManager: NSObject, ObservableObject {

	static let shared = NotificationsManager()

	var isPushEnabled: Bool = false

	//    @Published var authStatus: Bool = false
	@Published var authStatus: UNAuthorizationStatus?

	func requestPermission() {
		let center = UNUserNotificationCenter.current()

		center.requestAuthorization(options: [.sound, .alert, .badge]) { (granted, error) in

			guard error == nil else {
				print("There was an error when requesting permission for local notifications")
				return
			}

			if granted {
				print("Local notifications permission granted: \(granted)")
			}
			else {
				print("Local notifications permission not granted")
			}

			DispatchQueue.main.async {
				self.authStatus = granted ? .authorized : .denied

				// TODO: add push notifications request

			}
		}
	}

	func getNotificationSettings() {
		UNUserNotificationCenter.current()
			.getNotificationSettings { settings in
				DispatchQueue.main.async {
					self.authStatus = settings.authorizationStatus
				}
			}
	}

	func addNotifications(
		id: String,
		date: Date,
		day: Int,
		courseCode: String,
		courseName: String,
		location: String
	) {

		let notifTime =
			Calendar.current.date(byAdding: .minute, value: -5, to: date ?? Date()) ?? Date()

		let components = Calendar.current.dateComponents([.hour, .minute], from: notifTime)
		let hour = components.hour ?? 0
		let minute = components.minute ?? 0

		print(
			"Creating notification for hour: \(hour), minute: \(minute), day: \(day), courseCode: \(courseCode) and name: \(courseName)"
		)

		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .none
		dateFormatter.timeStyle = .short

		var dateComponents = DateComponents()
		dateComponents.hour = hour
		dateComponents.minute = minute
		dateComponents.weekday = day

		let content = UNMutableNotificationContent()
		content.title = StringConstants.notificationTitle
		content.body = "You have \(courseCode) \(courseName) at \(dateFormatter.string(from: date))"
		content.sound = .default
		content.categoryIdentifier = "vitty-category"
		content.userInfo = ["location": location]

		let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

		let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

		UNUserNotificationCenter.current()
			.add(request) { error in
				guard error == nil else {
					print(
						"An error occurred while creating the notification: \(error?.localizedDescription)"
					)
					return
				}

				print("Notification created!")
			}
	}

	func removeAllNotificationRequests() {
		let center = UNUserNotificationCenter.current()
		print("removing pending notification requests")
		center.removeAllPendingNotificationRequests()
		print("removing delivered notifications")
		center.removeAllDeliveredNotifications()
		center.getPendingNotificationRequests { notifreqs in
			for notifreq in notifreqs {
				print(notifreq.identifier)
			}
		}
	}

	func getAllNotificationRequests() {
		let center = UNUserNotificationCenter.current()
		center.getPendingNotificationRequests { notifreqs in
			for notifreq in notifreqs {
				print(notifreq.identifier)
			}
		}
	}

	/** Handle notification when app is in background */
	func userNotificationCenter(
		_ center: UNUserNotificationCenter,
		didReceive response:
			UNNotificationResponse,
		withCompletionHandler completionHandler: @escaping () -> Void
	) {

		if response.actionIdentifier == "navigateToClass" {
			let userInfo = response.notification.request.content.userInfo
			let location = userInfo["location"] as? String
			ClassCardViewModel.classCardVM.navigateToClass(at: location ?? "location")
		}
		else if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
			NotificationsViewModel.shared.notificationTapped.toggle()
		}
		completionHandler()
	}

}

extension NotificationsManager: UNUserNotificationCenterDelegate, MessagingDelegate {
	func registerForPushNotifications() {
		UIApplication.shared.registerForRemoteNotifications()
		let center = UNUserNotificationCenter.current()
		center.delegate = self
		Messaging.messaging().delegate = self
		center.getNotificationSettings(completionHandler: { (settings) in
			switch settings.authorizationStatus {
				case .authorized, .provisional:
					self.isPushEnabled = true
					DispatchQueue.main.async {
						UIApplication.shared.registerForRemoteNotifications()
					}
				case .denied, .ephemeral:
					break
				case .notDetermined:
					center.requestAuthorization(options: [.alert, .sound, .badge]) {
						(granted, error) in
						if granted && error == nil {
							self.isPushEnabled = true
							DispatchQueue.main.async {
								UIApplication.shared.registerForRemoteNotifications()
							}
						}
						else {
						}
					}
				@unknown default:
					break
			}
		})
	}

	func didRegisterForRemoteNotifications(_ tokenData: Data) {
		Messaging.messaging().apnsToken = tokenData
	}

	func messaging(
		_ messaging: Messaging,
		didReceiveRegistrationToken fcmToken: String?
	) {
		print("Firebase registration token: \(String(describing: fcmToken))")
		let tokenDict = ["token": fcmToken ?? ""]
		NotificationCenter.default.post(
			name: Notification.Name("FCMToken"),
			object: nil,
			userInfo: tokenDict
		)
	}

}
