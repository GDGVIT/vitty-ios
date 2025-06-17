//
//  ScheduleEntryControlView.swift
//  VITTY
//
//  Created by Rujin Devkota on 6/12/25.
//
import SwiftUI
import SwiftData
import WidgetKit

struct VittyWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        ZStack {
            Color(hex: "#041727")
                .ignoresSafeArea()

            switch family {
            case .systemSmall:
                ScheduleSmallWidgetView(entry: entry)
            case .systemMedium:
                ScheduleMediumWidgetView(entry: entry)

            default:
                Text("Unsupported size")
            }
        }
        .containerBackground(for: .widget) { Color(hex: "#041727") }
    }
}



struct VittyWidget: Widget {
    let kind: String = "VittyWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            VittyWidgetEntryView(entry: entry)
            
        }
        .configurationDisplayName("Vitty Widget")
        .description("Widget with different designs based on size.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
