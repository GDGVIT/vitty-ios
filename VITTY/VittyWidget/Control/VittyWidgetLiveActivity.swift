//
//  VittyWidgetLiveActivity.swift
//  VittyWidget
//
//  Created by Rujin Devkota on 2/25/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct VittyWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct VittyWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: VittyWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension VittyWidgetAttributes {
    fileprivate static var preview: VittyWidgetAttributes {
        VittyWidgetAttributes(name: "World")
    }
}

extension VittyWidgetAttributes.ContentState {
    fileprivate static var smiley: VittyWidgetAttributes.ContentState {
        VittyWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: VittyWidgetAttributes.ContentState {
         VittyWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: VittyWidgetAttributes.preview) {
   VittyWidgetLiveActivity()
} contentStates: {
    VittyWidgetAttributes.ContentState.smiley
    VittyWidgetAttributes.ContentState.starEyes
}
