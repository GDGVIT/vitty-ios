//
//  CommunityView.swift
//  VITTY
//
//  Created by Chandram Dutta on 04/01/24.
//

import SwiftUI

struct CommunityPage: View {
    var body: some View {
		Group {
			ZStack {
				VStack (alignment: .leading){
					CommunityPageHeader()
						.padding()
					Spacer()
					EmptyView()
				}
			}
			.padding(.top)
			.background(
				Image(
					"HomeBG"
				)
				.resizable().scaledToFill().edgesIgnoringSafeArea(.all)
			)
		}
    }
}

#Preview {
	CommunityPage()
}
