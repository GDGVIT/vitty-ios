//
//  CustomTabBar.swift
//  VITTY
//
//  Created by Prashanna Rajbhandari on 21/08/2023.
//

import SwiftUI

enum Tabs: String, CaseIterable {
	case suggestions = "Suggestions"
	case requests = "Requests"
	case friends = "Friends"
}

struct CustomTabBar: View {
	@Binding var selectedTab: Tabs

	var body: some View {

		VStack {
			HStack {
				ForEach(Tabs.allCases, id: \.rawValue) { tab in

					fillTab(tab: tab.rawValue)
						.onTapGesture {
							withAnimation(.linear(duration: 0.1)) {
								selectedTab = tab
							}
						}
				}
			}
			.frame(maxWidth: UIScreen.main.bounds.width * 0.80)
			.frame(height: 60)
			.background {
				Color.theme.tfBlue
			}
			.cornerRadius(30)
			//.padding()
		}

	}
}

struct CustomTabBar_Previews: PreviewProvider {
	static var previews: some View {
		CustomTabBar(selectedTab: .constant(.suggestions))
	}
}

extension CustomTabBar {
	private func fillTab(tab: String) -> some View {
		let isSelected = selectedTab.rawValue == tab

		return VStack {
			RoundedRectangle(cornerRadius: 20)
				.foregroundColor(isSelected ? Color.theme.selectedTabColor : Color.clear)
				.frame(width: 90, height: 30)

				.overlay {
					Text(tab)
						.font(.custom("Poppins-Medium", size: 12))
						.foregroundColor(Color.white)
				}
		}
	}
}
