//
//  RequestsView.swift
//  VITTY
//
//  Created by Prashanna Rajbhandari on 22/08/2023.
//

import SwiftUI

struct RequestsView: View {
	@EnvironmentObject private var authState: AuthViewModel
	@EnvironmentObject private var vm: FriendCircleViewModel

	var body: some View {
		ZStack {
			Color.theme.blueBG
				.ignoresSafeArea()
			VStack(alignment: .leading) {
				Text("Requests")
					.font(.custom("Poppins", size: 16))
					.foregroundColor(Color.theme.tfBlueLight)
					.padding(.leading)

				ForEach(vm.getFriendRequests, id: \.self) { requests in
					UserDetailsRow(
						name: requests.from.name,
						username: requests.from.username,
						url: requests.from.picture,
						token: authState.token,
						isSuggestionOrSendReq: false,
						wasReqSent: false,
						isRequestView: true,
						isFriendsView: false
					)
				}

				Spacer()
			}
			.padding(.top)
			.background(Color.theme.blueBG)
			.ignoresSafeArea()
		}
		.onAppear(perform: {
			vm.getFriendRequest(token: authState.token)
		})
	}
}
