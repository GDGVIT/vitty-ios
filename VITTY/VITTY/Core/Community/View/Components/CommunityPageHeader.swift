//
//  CommunityPageHeader.swift
//  VITTY
//
//  Created by Chandram Dutta on 04/01/24.
//

import SwiftUI

struct CommunityPageHeader: View {
	var body: some View {
		HStack{
			Text("Community")
			Spacer()
			Button(action: {}) {
				Image(systemName: "person.fill.badge.plus")
			}
		}
		.font(Font.custom("Poppins-Bold", size: 22))
		.foregroundColor(Color.white)
	}
}

#Preview {
	CommunityPageHeader()
}
