//
//  vittywidgetLiveActivity.swift
//  vittywidget
//
//  Created by Chandram Dutta on 04/03/24.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct vittywidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct vittywidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: vittywidgetAttributes.self) { context in
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

extension vittywidgetAttributes {
    fileprivate static var preview: vittywidgetAttributes {
        vittywidgetAttributes(name: "World")
    }
}

extension vittywidgetAttributes.ContentState {
    fileprivate static var smiley: vittywidgetAttributes.ContentState {
        vittywidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: vittywidgetAttributes.ContentState {
         vittywidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: vittywidgetAttributes.preview) {
   vittywidgetLiveActivity()
} contentStates: {
    vittywidgetAttributes.ContentState.smiley
    vittywidgetAttributes.ContentState.starEyes
}
