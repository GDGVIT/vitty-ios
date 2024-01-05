//
//  CommunityPageHeader.swift
//  VITTY
//
//  Created by Chandram Dutta on 04/01/24.
//

import SwiftUI

struct CommunityPageHeader: View {
	@State private var isAddFriendsViewPresented = false

	var body: some View {
		HStack {
			Text("Community")
			Spacer()
			Button(action: {
				isAddFriendsViewPresented.toggle()
			}) {
				Image(systemName: "person.fill.badge.plus")
			}
		}
		.font(Font.custom("Poppins-Bold", size: 22))
		.foregroundColor(Color.white)
		.fullScreenCover(isPresented: $isAddFriendsViewPresented, content: AddFriendsView.init)
	}
}

#Preview {
	CommunityPageHeader()
}
