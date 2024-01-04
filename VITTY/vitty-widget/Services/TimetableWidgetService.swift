//
//  TimetableWidgetService.swift
//  VITTY
//
//  Created by Ananya George on 2/26/22.
//

import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

class TimetableWidgetService {
	// steps:
	// 1. check that the timetable exists
	// 2. fetch the timetable for the current day
	// 3. update classes completed
	// 4. remove classes completed
	// 5. return classes left

	private var db = Firestore.firestore()

	func getTimeTableInfo(completion: @escaping (VITTYWidgetDataModel) -> Void) {

		let dayInt = (Calendar.current.dateComponents([.weekday], from: Date()).weekday ?? 1) - 1
		let day: String = StringConstants.firestoreDays[dayInt]

		//        let uid = Auth.auth().currentUser?.uid
		guard let user = try? Auth.auth().getStoredUser(forAccessGroup: AppConstants.VITTYappgroup)
		else {
			print("couldn't get stored user")
			completion(
				VITTYWidgetDataModel(
					classInfo: [],
					classesCompleted: -1,
					error: "Couldn't get the stored user"
				)
			)
			return
		}
		let uid = user.uid
		print(uid)
		guard uid != nil else {
			print("user not authorized")
			completion(
				VITTYWidgetDataModel(classInfo: [], classesCompleted: -1, error: "Please sign in")
			)
			return
		}
		db
			.collection("users")
			.document(uid)
			.getDocument { (document, error) in
				guard error == nil else {
					print("Error fetching user information: \(error.debugDescription)")
					completion(
						VITTYWidgetDataModel(
							classInfo: [],
							classesCompleted: -1,
							error: "Error fetching information"
						)
					)
					return
				}

				let data = try? document?.data(as: TimeTableInformation.self)
				guard data != nil else {
					print("Couldn't decode timetable information")
					completion(
						VITTYWidgetDataModel(
							classInfo: [],
							classesCompleted: -1,
							error: "Error decoding information"
						)
					)
					return
				}

				var classes: [Classes] = []

				if let timetableAvailable = data?.isTimetableAvailable, timetableAvailable {
					self.db
						.collection("users")
						.document(uid)
						.collection("timetable")
						.document(day)
						.collection("periods")
						.getDocuments { (documents, err) in
							guard error != nil else {
								print(
									"error fetching timetable for \(day): \(err.debugDescription)"
								)
								completion(
									VITTYWidgetDataModel(
										classInfo: [],
										classesCompleted: -1,
										error: "Error fetching timetable"
									)
								)
								return
							}

							classes =
								documents?.documents
								.compactMap { doc in
									try? doc.data(as: Classes.self)
								} ?? []

							let classCount = classes.count
							var classesCompleted = 0
							let timeRightNow =
								Calendar.current.date(
									from: Calendar.current.dateComponents(
										[.hour, .minute],
										from: Date()
									)
								) ?? Date()
							for i in (0..<classCount) {
								let endPoint =
									Calendar.current.date(
										from: Calendar.current.dateComponents(
											[.hour, .minute],
											from: classes[i].endTime ?? Date()
										)
									) ?? Date()
								if timeRightNow > endPoint {
									classesCompleted += 1
								}
							}

							completion(
								VITTYWidgetDataModel(
									classInfo: classes,
									classesCompleted: classesCompleted,
									error: nil
								)
							)
						}
				}
			}
	}
}
