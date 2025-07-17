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
				BackgroundView()
				VStack(alignment: .leading) {
					VStack(alignment: .leading) {
						Text("Account Details")
							.font(Font.custom("Poppins-SemiBold", size: 20))
							.foregroundColor(Color.white)
							.padding(.vertical, 5)
						Text(
							"Name: \(authViewModel.loggedInFirebaseUser?.displayName ?? "-")"
						)
						Text(
							"Signed in with: \(authViewModel.loggedInFirebaseUser?.providerID ?? "-")"
						)
						Text(
							"Email: \(authViewModel.loggedInFirebaseUser?.email ?? "-")"
						)
					}
					.padding()
					.frame(maxWidth: .infinity, alignment: .topLeading)
					.font(Font.custom("Poppins-Regular", size: 16))
					.background{
						RoundedRectangle(cornerRadius: 12, style: .circular)
							.fill(Color("Secondary"))
							.overlay(
								RoundedRectangle(cornerRadius: 12)
									.stroke(Color("Accent"), lineWidth: 1.2)
							)
					}
					VStack(alignment: .leading) {
						Text("Setup Instructions")
							.font(Font.custom("Poppins-SemiBold", size: 20))
							.padding(.vertical, 5)
						VStack(alignment: .leading) {
							Text("1. Upload the timetable on")
							Link(
								destination: URL(string: "https://dscv.it/vittyconnect")!,
								label: {
									Text(StringConstants.websiteURL)
										.underline()
								}
							)
							Text("2. Log in with the same Apple/Google Account as shown above")
							Text("3. Upload a screenshot of your timetable")
							Text("4. Review it")
							Text("5. When done, click on Upload")
							Text("BRAVO! That's it. You did it!")
								.padding(.vertical)
						}
					}
					.padding()
					.frame(maxWidth: .infinity, alignment: .topLeading)
					.font(Font.custom("Poppins-Regular", size: 16))
					.background{
						RoundedRectangle(cornerRadius: 12, style: .circular)
							.fill(Color("Secondary"))
							.overlay(
								RoundedRectangle(cornerRadius: 12)
									.stroke(Color("Accent"), lineWidth: 1.2)
							)
					}
					Spacer()
					NavigationLink(destination: {
						if authViewModel.loggedInBackendUser == nil {
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
					.background(Color("Secondary"))
					.cornerRadius(18)
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


