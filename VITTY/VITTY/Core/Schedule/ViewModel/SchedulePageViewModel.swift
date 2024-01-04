//
//  HomePageViewModel.swift
//  VITTY
//
//  Created by Prashanna Rajbhandari on 18/08/2023.
//

import Foundation
import SwiftUI

class SchedulePageViewModel: ObservableObject {

	@Published var isPresented: Bool = false

	func sideMenu() {
		print("side menu bar pressed")
		isPresented.toggle()
	}

}
