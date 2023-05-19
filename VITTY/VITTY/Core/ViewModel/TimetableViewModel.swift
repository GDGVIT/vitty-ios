//
//  InstructionsViewModel.swift
//  VITTY
//
//  Created by Ananya George on 1/8/22.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseFirestoreSwift

class TimetableViewModel: ObservableObject {
    
    @Published var timetable: [String:[Classes]] = [:]
    @Published var goToHomeScreen: Bool = false
    
    @Published var classesCompleted: Int = 0
    
    var components = Calendar.current.dateComponents([.weekday], from: Date())
    
    private let authenticationServices = AuthService()
    
    var versionChanged: Bool = false
    
    static let daysOfTheWeek = [
        "monday",
        "tuesday",
        "wednesday",
        "thursday",
        "friday",
        "saturday",
        "sunday",
    ]
    
    static let timetableVersionKey: String = "timetableVersionKey"
    
    var timetableInfo = TimeTableInformation()
    
    private var db = Firestore.firestore()
    
//    TODO: when switching to prod, uncomment lines 37, 48 and 88
        
//    private let uid = Confidential.uid
    
    func fetchInfo(onCompletion: @escaping ()->Void){
        let uid = Auth.auth().currentUser?.uid
        var timetableVersion = UserDefaults.standard.object(forKey: TimetableViewModel.timetableVersionKey)
        print(uid)
        print("fetching user-timetable information")
        guard uid != nil else {
            print("error with uid")
            return
        }
        db.collection("users")
            .document(uid!)
//            .document(uid)
            .getDocument { (document, error) in
                if let error = error  {
                    print("error fetching user information: \(error.localizedDescription)")
                    return
                }
                
                let data = try? document?.data(as: TimeTableInformation.self)
                guard data != nil else {
                    print("couldn't decode timetable information")
                    return
                }
//                if self.timetableInfo.timetableVersion != nil {
//                    if data?.timetableVersion != self.timetableInfo.timetableVersion {
//                        self.versionChanged = true
//                    }
//                }
                if data?.timetableVersion != nil {
                    if data?.timetableVersion != (timetableVersion as? Int) {
                        self.versionChanged = true
                        UserDefaults.standard.set(data?.timetableVersion, forKey: TimetableViewModel.timetableVersionKey)
                        UserDefaults.standard.set(false, forKey: AuthService.notifsSetupKey)
                    }
                }
                self.timetableInfo = data ?? TimeTableInformation(isTimetableAvailable: nil, isUpdated: nil, timetableVersion: nil)
                print("fetched timetable info into self.timetableInfo as: \(self.timetableInfo)")
                onCompletion()
            }
    }
    
    func fetchTimetable(onCompletion: @escaping ()->Void){
        let uid = Auth.auth().currentUser?.uid
        print("fetching timetable")
        var countt = 0
        guard uid != nil else {
            print("error with uid")
            return
        }
        for i in (0..<7) {
            db.collection("users")
                .document(uid!)
//                .document(uid)
                .collection("timetable")
                .document(TimetableViewModel.daysOfTheWeek[i])
                .collection("periods")
                .getDocuments { (documents, error) in
                    
                    countt += 1
                    if let error = error {
                        print("error fetching timetable: \(error.localizedDescription)")
                        return
                    }
                    print("day: \(TimetableViewModel.daysOfTheWeek[i])")
                    self.timetable[TimetableViewModel.daysOfTheWeek[i]] = documents?.documents.compactMap { document in
                        try? document.data(as: Classes.self)
                    } ?? []
                    
                    print("timetable now: \(self.timetable)")
                    if countt == 7 {
                        print("Notif completion handler")
                        onCompletion()
                    }
                }
        }
        
    }
    
    func getData(onCompletion: @escaping ()->Void){
        self.fetchInfo {
            if self.timetable.isEmpty || self.versionChanged {
                self.timetable = [:]
                self.fetchTimetable {
                    onCompletion()
                }
                self.versionChanged = false
                print("version changed?: \(self.versionChanged)")
            }
        }
    }
}

extension TimetableViewModel {
    func updateClassCompleted(){
        let today_i = Date.convertToMondayWeek()
        let todayDay = TimetableViewModel.daysOfTheWeek[today_i]
        let todaysTT = self.timetable[todayDay]
        let todayClassCount = todaysTT?.count ?? 0
        self.classesCompleted = 0
        let currentPoint = Calendar.current.date(from: Calendar.current.dateComponents([.hour,.minute], from: Date())) ?? Date()
        for i in (0..<todayClassCount) {
            let endPoint = Calendar.current.date(from: Calendar.current.dateComponents([.hour,.minute], from: todaysTT?[i].endTime ?? Date())) ?? Date()
            if currentPoint > endPoint {
                self.classesCompleted += 1
            }
        }
    }
}
