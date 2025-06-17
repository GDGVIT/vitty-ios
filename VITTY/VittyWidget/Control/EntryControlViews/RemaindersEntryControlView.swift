//
//  RemaindersEntryControlVIew.swift
//  VITTY
//
//  Created by Rujin Devkota on 6/12/25.
//
import SwiftUI
import SwiftData
import WidgetKit



import SwiftUI
import WidgetKit

struct ReminderWidgetEntryView: View {
    var entry: SmartDueEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        ZStack{
            Color(hex: "#041727")
                          .ignoresSafeArea()
            
            switch family {
            case .systemSmall:
                DueSmallWidgetView(entry: entry)
            case .systemMedium:
                DueMediumWidgetView(entry: entry)
            case .systemLarge:
                LargeDueWidgetView(entry: entry)
           
        
            @unknown default:
                Text("Unsupported size")
            }
        } .containerBackground(for: .widget) { Color(hex: "#041727") }
    }
}


struct RemindersWidget: Widget {
    let kind: String = "RemindersWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: RemindersProvider()) { entry in
            ReminderWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Smart Reminders")
        .description("Intelligently shows due today, due tomorrow, upcoming reminders, or no reminders.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
