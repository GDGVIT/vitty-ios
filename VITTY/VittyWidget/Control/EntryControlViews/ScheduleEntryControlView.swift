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
        switch family {
        case .accessoryCircular:
            CircularLockScreenWidgetView(entry: entry)
            
        case .accessoryRectangular:
            RectangularLockScreenWidgetView(entry: entry)
            
        case .accessoryInline:
            InlineLockScreenWidgetView(entry: entry)

        default:
            ZStack {
                Color(hex: "#041727")
                    .ignoresSafeArea()

                switch family {
                case .systemSmall:
                    ScheduleSmallWidgetView(entry: entry)
                case .systemMedium:
                    ScheduleMediumWidgetView(entry: entry)
                case .systemLarge:
                    ScheduleLargeWidgetView(entry: entry)
                default:
                    EmptyView()
                }
            }
            
        }
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
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}
