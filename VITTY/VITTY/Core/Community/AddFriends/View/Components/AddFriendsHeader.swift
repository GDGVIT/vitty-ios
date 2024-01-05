//
//  AddFriendsHeader.swift
//  VITTY
//
//  Created by Chandram Dutta on 04/01/24.
//

import SwiftUI

struct AddFriendsHeader: View {
	@Environment(\.dismiss) var dismiss
	var body: some View {
		HStack {
			Button(action: {
				dismiss()
			}) {
				Image(systemName: "xmark")
					.foregroundColor(.white)
					.padding(.horizontal)
			}
			Text("Add Friends")
				.font(.custom("Poppins-Medium", size: 22))
				.fontWeight(.semibold)
				.foregroundColor(.white)

			Spacer()
			Button(action: {
			}) {
				Image(systemName: "magnifyingglass")
					.foregroundColor(.white)
					.padding(.horizontal)
			}
		}
	}
}

#Preview {
	AddFriendsHeader()
}
