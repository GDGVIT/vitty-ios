//
//  vitty_widget.swift
//  vitty-widget
//
//  Created by Ananya George on 1/28/22.
//

import Firebase
import FirebaseAuth
import SwiftUI
import WidgetKit

struct VITTYProvider: TimelineProvider {
    typealias Entry = VITTYEntry

    func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
       // let date = Date()
        
//        var VITTYSnap = VITTYWidgetDataModel(classInfo: [], classesCompleted: 0, error: nil)
//        for i in 0 ... 7 {
//            VITTYSnap.classInfo.append(Classes(courseType: "Type\(i)", courseCode: "CSE\(i)\(i)\(i)\(i)", courseName: "Internet Programming and Web Technologies", location: "Loc\(i)", slot: "Slot\(i)", startTime: Date(timeInterval: TimeInterval(3600 * i), since: date), endTime: Date(timeInterval: TimeInterval(3600 * i + 2700), since: date)))
//        }
        
        guard let date = Calendar.current.date(byAdding: .hour, value: 48, to: Date()) else {return}
        let VITTYSnap = VITTYWidgetDataModel(classInfo: StringConstants.dummyClassArray,
        classesCompleted: 0,
        error: nil)

        let entry: VITTYEntry = VITTYEntry(date: date, dataModel: VITTYSnap)

        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        // Create a timeline entry for now
        let date = Date()

        // Create a date that's 15 minutes in the future
        let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 15, to: date)!
        // fetch the timetable
        TimetableWidgetService().getTimeTableInfo { dataModel in

            let timetableData: VITTYWidgetDataModel
            timetableData = dataModel

            let entry = VITTYEntry(date: date, dataModel: timetableData)

            // Create the timeline with the entry and a reload policy with the date for the next update
            let timeline = Timeline(
                entries: [entry],
                policy: .after(nextUpdateDate)
            )

            // Call the completion handler to pass the timeline to WidgetKit
            completion(timeline)
        }
    }

    func placeholder(in context: Context) -> VITTYEntry {
        VITTYEntry(date: Date(), dataModel: VITTYWidgetDataModel(classInfo: StringConstants.dummyClassArray, classesCompleted: 2, error: nil))
    }
}

// struct VITTYWidgetEntryView : View {
//    var entry: VITTYProvider.Entry
//
//    var body: some View {
//        Text(entry.date, style: .time)
//    }
// }

@main
struct VITTYWidget: Widget {
    let kind: String = "com.gdscvit.vittyios.vitty-widget"

    init() {
        FirebaseApp.configure()
        do {
            try Auth.auth().useUserAccessGroup(AppConstants.VITTYappgroup)
        } catch let error as NSError {
            print("Error changing user access group: %@", error)
        }
        try? Auth.auth().useUserAccessGroup(AppConstants.VITTYappgroup)
    }

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: VITTYProvider()) { entry in
            VITTYWidgetView(entry: entry)
        }
        .configurationDisplayName("VITTY")
        .description("Shows current and upcoming classes!")
//        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .supportedFamilies([.systemLarge])
    }
}

 struct vitty_widget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LargeWidgetView(widgetData: VITTYWidgetDataModel(classInfo: StringConstants.dummyClassArray,
            classesCompleted: 0,
            error: nil)
            )
            .previewContext(WidgetPreviewContext(family: .systemLarge))
            
            SmallWidgetView(widgetData: VITTYWidgetDataModel(classInfo: StringConstants.dummyClassArray, classesCompleted: 0, error: nil))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            MediumWidgetView(widgetData: VITTYWidgetDataModel(classInfo: StringConstants.dummyClassArray, classesCompleted: 0, error: nil))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
 }
