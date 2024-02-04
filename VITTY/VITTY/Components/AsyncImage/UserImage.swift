//
//  UserImage.swift
//  VITTY
//
//  Created by Prashanna Rajbhandari on 08/10/2023.
//

import SwiftUI

struct UserImage: View {
	let url: String
	let height: CGFloat
	let width: CGFloat

	var body: some View {
		AsyncImage(url: URL(string: url)) { phase in
			switch phase {
				case .success(let image):
					image
						.resizable()
						.scaledToFit()
						.frame(width: width, height: height)
						.clipShape(Circle())
				case .empty, .failure:
					Image(systemName: "person.circle.fill")
						.resizable()
						.scaledToFit()
						.frame(width: width, height: height)
						.clipShape(Circle())
						.foregroundColor(.white)
				@unknown default:
					fatalError()
			}
		}
	}
}

#Preview {
	UserImage(url: "", height: 40, width: 40)
}
