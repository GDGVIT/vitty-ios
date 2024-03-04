//
//  HomeView.swift
//  VITTY
//
//  Created by Chandram Dutta on 04/01/24.
//

import SwiftUI

struct HomeView: View {
	var body: some View {
		TabView {
			TimeTableView(friend: nil)
				.tabItem {
					Label("Time Table", systemImage: "calendar.day.timeline.left")
				}
			CommunityPage()
				.tabItem {
					Label("Connect", systemImage: "person.2")
				}
		}
	}
}

#Preview {
	HomeView()
}
