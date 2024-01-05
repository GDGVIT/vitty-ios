//
//  AddFriendCard.swift
//  VITTY
//
//  Created by Chandram Dutta on 05/01/24.
//

import SwiftUI

struct AddFriendCard: View {
	let friend: Friend
	var body: some View {
		HStack{
			UserImage(url: friend.picture, height: 48, width: 48)
			VStack(alignment: .leading) {
				Text(friend.name)
					.font(Font.custom("Poppins-SemiBold", size: 15))
					.foregroundColor(Color.white)
				Text(friend.username)
					.font(Font.custom("Poppins-Regular", size: 14))
					.foregroundColor(Color.vprimary)
			}
			Spacer()
			if friend.friendStatus != "sent" {
				Button("Send Request") {
				}.buttonStyle(.bordered)
				
					.font(.caption)
			} else {
				Image(systemName: "person.fill.checkmark")
			}
		}
	}
}

#Preview {
	AddFriendCard(
		friend: Friend.sampleFriend
	)
}
