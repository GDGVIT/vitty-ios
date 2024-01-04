//
//  Gradient.swift
//  VITTY
//
//  Created by Ananya George on 12/24/21.
//

import SwiftUI

extension LinearGradient {
	static let secGrad = LinearGradient(
		colors: [Color.secondaryGradStart, Color.secondaryGradEnd],
		startPoint: .bottomLeading,
		endPoint: .topTrailing
	)
}
