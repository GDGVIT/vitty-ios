//
//  BottomBarView.swift
//  VITTY
//
//  Created by Chandram Dutta on 07/07/24.
//

import SwiftUI

struct BottomBarView: View {
	
	@Binding var presentTab: Int
	@Namespace var bottomBarAnimation
	
	var body: some View {
		HStack {
            TabButtonView(value: $presentTab, name: "Academics", image: "bookmark.fill", tabNo: 3, namespace: bottomBarAnimation)
			TabButtonView(value: $presentTab, name: "Schedule", image: "calendar.badge.clock", tabNo: 1, namespace: bottomBarAnimation)
			TabButtonView(value: $presentTab, name: "Connect", image: "person.2.fill", tabNo: 2, namespace: bottomBarAnimation)
         
            
		}
		.padding()
		.frame(height: 84)
		.background(
			RoundedRectangle(cornerRadius: 120)
				.stroke(Color("Secondary"), lineWidth: 2)
				.fill(Color("Background"))
		)
		.gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
			.onEnded({ value in
				if value.translation.width < 0 {
					if presentTab == 1 {
						return
					}
					withAnimation (.bouncy(extraBounce: 0.1)) {
						presentTab -= 1
					}
				}
				if value.translation.width > 0 {
					if presentTab == 2 {
						return
					}
					withAnimation (.interactiveSpring(duration: 0.50, extraBounce: 0.3)) {
						presentTab += 1
					}
				}
			}))
	}
}

struct TabButtonView: View {
	
	@Binding var value: Int
	
	let name: String
	let image: String
	let tabNo: Int
	let namespace: Namespace.ID
	
	var body: some View {
		HStack {
			Image(systemName: image)
				.symbolEffect(.bounce, value: value == tabNo)
			if value == tabNo {
				Text(name)
			}
		}
		.padding()
		.background {
			if value == tabNo {
				RoundedRectangle(cornerRadius: 120)
					.fill(Color("Secondary"))
					.matchedGeometryEffect(id: "selectedTab", in: namespace)
			}
		}
		.onTapGesture {
			withAnimation (.interactiveSpring(duration: 0.50, extraBounce: 0.3)) {
				value = tabNo
			}
		}
	}
}
