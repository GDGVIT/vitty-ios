//
//  Color.swift
//  VITTY
//
//  Created by Prashanna Rajbhandari on 20/05/2023.
//

import Foundation
import SwiftUI

extension Color {
	static let theme = ColorTheme()
}

struct ColorTheme {
	let darkBG = Color("DarkBG")
	let blueBG = Color("blueBG")
	let primary = Color("Primary")
	let tfBlue = Color("tfBlue")
	let tfBlueLight = Color("tfBlueLight")
	let brightBlue = Color("brightBlue")
	let gray = Color("Gray")
	let secTextColor = Color("SecondaryTextColor")
	let secondaryBlue = Color("SecondaryBlue")
	let selectedTabColor = Color("selectedTabColor")
	let secondary = Color("Secondary")
}
