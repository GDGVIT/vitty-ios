//
//  VittyWidgetBundle.swift
//  VittyWidget
//
//  Created by Rujin Devkota on 2/25/25.
//

import WidgetKit
import SwiftUI

@main
struct VittyWidgetBundle: WidgetBundle {
    var body: some Widget {
        VittyWidget()
        RemindersWidget()
        VittyWidgetControl()
        VittyWidgetLiveActivity()
    }
}
