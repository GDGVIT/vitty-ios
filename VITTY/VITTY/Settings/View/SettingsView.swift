//
//  SettingsView.swift
//  VITTY
//
//  Created by Ananya George on 12/24/21.
//

import SwiftUI

struct SettingsView: View {
	let githubURL = URL(string: "https://github.com/GDGVIT/vitty-ios")
	let gdscURL = URL(string: "https://dscvit.com/")
	var body: some View {
		ZStack {
			Image("HomeBG")
				.resizable()
				.ignoresSafeArea()
			List {
				Section(header: Text("About")) {
					HStack {
						Image("github-icon")
							.resizable()
							.scaledToFit()
							.frame(width: 35, height: 35)
						Text("GitHub Repository")
					}
					.frame(height: 35)
					.listRowBackground(Color("DarkBG"))
					.onTapGesture {
						if let url = githubURL {
							UIApplication.shared.open(url)
						}
					}
					HStack {
						Image("gdsc-logo")
							.resizable()
							.scaledToFit()
							.frame(width: 30, height: 30)
						Text("GDSC VIT")
					}
					.frame(height: 35)
					.listRowBackground(Color("DarkBG"))
					.onTapGesture {
						if let url = gdscURL {
							UIApplication.shared.open(url)
						}
					}
				}
			}
			.scrollContentBackground(.hidden)
		}
		.navigationTitle("Settings")
	}
}
