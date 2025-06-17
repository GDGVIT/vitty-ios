//
//  FriendCard.swift
//  VITTY
//
//  Created by Chandram Dutta on 05/01/24.
//

import SwiftUI

struct FriendCard: View {
	let friend: Friend
	var body: some View {
		HStack {
			UserImage(url: friend.picture, height: 48, width: 48)
			VStack(alignment: .leading) {
				Text(friend.name)
					.font(Font.custom("Poppins-SemiBold", size: 15))
					.foregroundColor(Color.white)
				if friend.currentStatus.status == "free" {
					Text("Not in a class right now")
						.font(Font.custom("Poppins-Regular", size: 14))
						.foregroundColor(Color("Accent"))
				}
				else {
					Text(friend.currentStatus.class ?? "")
						.font(Font.custom("Poppins-Regular", size: 14))
						.foregroundColor(Color("Accent"))
				}
			}
			Spacer()
			VStack {
				Text("NOW")
					.font(Font.custom("Poppins-Regular", size: 14))
				if friend.currentStatus.status == "free" {
					Text(friend.currentStatus.status.capitalized)
						.font(Font.custom("Poppins-SemiBold", size: 16))
				}
				else {
					Text(friend.currentStatus.venue ?? "-")
						.font(Font.custom("Poppins-SemiBold", size: 16))
						.foregroundColor(Color.white)
				}
			}
		}

	}
}

#Preview {
	FriendCard(
		friend: Friend.sampleFriend
	)
	//	.background(Color.theme.secondaryBlue)
}
