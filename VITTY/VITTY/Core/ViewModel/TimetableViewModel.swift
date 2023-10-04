//
//  InstructionsViewModel.swift
//  VITTY
//
//  Created by Ananya George on 1/8/22.
//

import Combine
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

class TimetableViewModel: ObservableObject {
    @Published var timetable: [String: [Classes]] = [:]
    @Published var goToHomeScreen: Bool = false

    @Published var myTimeTable: TimetableModel?

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

    private var cancellables: Set<AnyCancellable> = []

    func mapToOldModel(newModel: TimetableModel) -> [String: [Classes]] {
        var oldModel: [String: [Classes]] = [:]

        for (key, timetableItems) in newModel.data {
            var classesArray: [Classes] = []

            for timetableItem in timetableItems {
                let classes = Classes(
                    courseType: timetableItem.type,
                    courseCode: timetableItem.code,
                    courseName: timetableItem.name,
                    location: timetableItem.venue,
                    slot: timetableItem.slot,
                    startTime: parseTimeToDate(timetableItem.start_time),
                    endTime: parseTimeToDate(timetableItem.end_time)
                )

                classesArray.append(classes)
            }

            oldModel[key] = classesArray
        }

        return oldModel
    }
    
    func parseTimeToDate(_ dateString: String) -> Date{
        var changedDate = replaceYearIfZero(dateString)
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"

        if let newDate = formatter.date(from: changedDate) {
            return newDate
        } else {
            print("no date was converted")
            return Date()
        }
    }


    
//    func parseTimeToDate(_ timeString: String) -> Date{
//        var date = replaceYearIfZero(timeString)
//        
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
//        
//        if let newDate =  formatter.date(from: date){
//            return newDate
//        }else{
//            print("no date was converted")
//            return Date()
//        }
//    }



    func replaceYearIfZero(_ dateStr: String) -> String {
        if dateStr.hasPrefix("0") {
            let index = dateStr.index(dateStr.startIndex, offsetBy: 4)
            return "2023" + String(dateStr[index...])
        } else {
            return dateStr
        }
    }

    
    

    func getTimeTable(token: String, username: String) {

        
        guard let url = URL(string: "\(APIConstants.base_url)/api/v2/timetable/\(username)") else {
            return
        }

        var request = URLRequest(url: url, timeoutInterval: Double.infinity)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"

        URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: TimetableModel.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] timetable in
                      self?.myTimeTable = timetable

                      if let myTimeTable = self?.myTimeTable {
                          self?.timetable = self?.mapToOldModel(newModel: myTimeTable) ?? [:]
                      }
                
                print("timetable model\n", self?.myTimeTable ?? "no timetable")
                print("----------")
                print("classes model\n", self?.timetable ?? "no classes")

                  })
            .store(in: &cancellables)
    }
    
    
    

    static let timetableVersionKey: String = "timetableVersionKey"

    var timetableInfo = TimeTableInformation()

    private var db = Firestore.firestore()

}

extension TimetableViewModel {
    func updateClassCompleted() {
        let today_i = Date.convertToMondayWeek()
        let todayDay = TimetableViewModel.daysOfTheWeek[today_i]
        let todaysTT = timetable[todayDay]
        let todayClassCount = todaysTT?.count ?? 0
        classesCompleted = 0
        let currentPoint = Calendar.current.date(from: Calendar.current.dateComponents([.hour, .minute], from: Date())) ?? Date()
        for i in 0 ..< todayClassCount {
            let endPoint = Calendar.current.date(from: Calendar.current.dateComponents([.hour, .minute], from: todaysTT?[i].endTime ?? Date())) ?? Date()
            if currentPoint > endPoint {
                classesCompleted += 1
            }
        }
    }
}



/*
     func fetchInfo(onCompletion: @escaping ()->Void){
         let uid = Auth.auth().currentUser?.uid
         let timetableVersion = UserDefaults.standard.object(forKey: TimetableViewModel.timetableVersionKey)
         print(uid!)
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
      */
