//
//  Colors.swift
//  VITTY
//
//  Created by Ananya George on 12/22/21.
//

import SwiftUI

extension Color {
	static let darkbg = Color(UIColor(named: ColorConstants.darkbg.rawValue)!)
	static let vprimary = Color(UIColor(named: ColorConstants.vprimary.rawValue)!)
	static let sec = Color(UIColor(named: ColorConstants.sec.rawValue)!)
	static let widgbg = Color(UIColor(named: ColorConstants.widgetBG.rawValue)!)
	static let secondaryGradEnd = Color(UIColor(named: ColorConstants.secGradEnd.rawValue)!)
	static let secondaryGradStart = Color(UIColor(named: ColorConstants.secGradStart.rawValue)!)

	enum ColorConstants: String {
		case darkbg = "DarkBG"
		case vprimary = "Primary"
		case sec = "Secondary"
		case secGradEnd = "SecondaryGradientEnd"
		case secGradStart = "SecondaryGradientStart"
		case widgetBG = "WidgetBG"
	}
}
