//
//  WidgetContent.swift
//  VITTY
//
//  Created by Ananya George on 2/26/22.
//

import Foundation
import WidgetKit

struct VITTYEntry: TimelineEntry {
	var date = Date()
	var dataModel: VITTYWidgetDataModel

	var relevance: TimelineEntryRelevance? {
		TimelineEntryRelevance(score: 50)
	}
}

struct VITTYWidgetDataModel {
	var classInfo: [Classes]
	var classesCompleted: Int
	var error: String?
}
