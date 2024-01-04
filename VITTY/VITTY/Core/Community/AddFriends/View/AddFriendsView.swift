//
//  AddFriendsView.swift
//  VITTY
//
//  Created by Chandram Dutta on 04/01/24.
//

import SwiftUI

struct AddFriendsView: View {
	var body: some View {
		Group {
			ZStack {
				VStack(alignment: .leading) {
					AddFriendsHeader()
					Spacer()
					EmptyView()
				}
			}
			.padding(.top)
			.background(
				Image(
					"HomeNoClassesBG"
				)
				.resizable()
				.scaledToFill()
				.edgesIgnoringSafeArea(.all)
			)
		}
	}
}

#Preview {
	AddFriendsView()
}
