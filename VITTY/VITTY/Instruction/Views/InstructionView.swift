//
//  InstructionView.swift
//  VITTY
//
//  Created by Chandram Dutta on 05/02/24.
//

import SwiftUI

struct InstructionView: View {
	@Environment(AuthViewModel.self) private var authViewModel
	var body: some View {
		NavigationStack {
			ZStack {
				Image("SplashScreen13BG")
					.resizable()
					.ignoresSafeArea()
				VStack {
					ZStack(alignment: .leading) {
						RoundedRectangle(cornerRadius: 12, style: .circular)
							.fill(Color.darkbg)
							.overlay(
								RoundedRectangle(cornerRadius: 12)
									.stroke(Color.vprimary, lineWidth: 1.2)
							)
						VStack(alignment: .leading) {
							Text("Account Details")
								.font(Font.custom("Poppins-SemiBold", size: 20))
								.foregroundColor(Color.white)
								.padding(.vertical, 5)
							Text(
								"Name: \(authViewModel.loggedInFirebaseUser?.displayName ?? "-")"
							)
							.foregroundColor(Color.vprimary)
							Text(
								"Signed in with: \(authViewModel.loggedInFirebaseUser?.providerID ?? "-")"
							)
							.foregroundColor(Color.vprimary)
							Text(
								"Email: \(authViewModel.loggedInFirebaseUser?.email ?? "-")"
							)
							.foregroundColor(Color.vprimary)
						}
						.padding()
						.font(Font.custom("Poppins-Regular", size: 16))
					}
					.frame(height: 100)
					.padding(.vertical)
					ZStack(alignment: .leading) {
						RoundedRectangle(cornerRadius: 12, style: .circular)
							.fill(Color.darkbg)
							.overlay(
								RoundedRectangle(cornerRadius: 12)
									.stroke(Color.vprimary, lineWidth: 1.2)
							)
						VStack(alignment: .leading) {
							Text("Setup Instructions")
								.font(Font.custom("Poppins-SemiBold", size: 20))
								.foregroundColor(Color.white)
								.padding(.vertical, 5)
							//                    ScrollView {
							VStack(alignment: .leading) {
								Text("1. Upload the timetable on")
								Link(
									destination: URL(string: "https://dscvit.com/vitty")!,
									label: {
										Text(StringConstants.websiteURL)
											.underline()
											.foregroundColor(Color.vprimary)

									}
								)
								Text("2. Log in with the same Apple/Google Account as shown above")
								Text("3. Upload a screenshot of your timetable")
								Text("4. Review it")
								Text("5. When done, click on Upload")
								Text("BRAVO! That's it. You did it!")
									.foregroundColor(Color.white)
									.padding(.vertical)
							}
							.foregroundColor(Color.vprimary)
						}
						.padding()
						.font(Font.custom("Poppins-Regular", size: 16))
					}
					.padding(.vertical)
					NavigationLink(destination: {
						if authViewModel.appUser == nil {
							UsernameView()
						}
						else {
							HomeView()
						}
					}) {
						Spacer()
						Text("Done")
							.fontWeight(.bold)
							.foregroundColor(Color.white)
							.padding(.vertical, 16)

						Spacer()
					}
					.background(Color("brightBlue"))
					.cornerRadius(18)
					Spacer()
				}
				.padding()

			}
			.toolbar {
				Button(action: {
					authViewModel.signOut()
				}) {
					Image(systemName: "arrow.right.square")
				}
				.foregroundStyle(.white)
			}
			.navigationTitle("Sync Timetable")
		}
	}
}

#Preview {
	InstructionView()
		.environment(AuthViewModel())
		.preferredColorScheme(.dark)
}
