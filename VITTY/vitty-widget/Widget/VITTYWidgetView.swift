//
//  VITTYWidgetView.swift
//  VITTY
//
//  Created by Ananya George on 2/26/22.
//

import SwiftUI
import WidgetKit

struct VITTYWidgetView: View {

	@Environment(\.widgetFamily) var family: WidgetFamily
	var entry: VITTYEntry

	@ViewBuilder
	var body: some View {
		switch family {
			case .systemSmall:
				SmallWidgetView(widgetData: entry.dataModel)
			case .systemMedium:
				MediumWidgetView(widgetData: entry.dataModel)
			case .systemLarge:
				LargeWidgetView(widgetData: entry.dataModel)
			default:
				NoDetailsAvailableView()
		}
	}
}

//struct VITTYWidgetView_Previews: PreviewProvider {
//    static var previews: some View {
//        VITTYWidgetView()
//    }
//}
