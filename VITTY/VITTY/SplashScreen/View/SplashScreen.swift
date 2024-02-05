//
//  SplashScreen.swift
//  VITTY
//
//  Created by Ananya George on 12/22/21.
//

import SwiftUI

struct SplashScreen: View {
	@State var selectedTab: Int = 0
	@State var onboardingComplete: Bool = false
	@Environment(AuthViewModel.self) private var authViewModel

	var body: some View {
		VStack {
			TabView(selection: $selectedTab) {
				ForEach(0..<3) { _ in
					SplashScreenIllustration(selectedTab: $selectedTab)
				}
			}
			.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
			SplashScreenTabIndicator(selectedTab: $selectedTab)
			Spacer(minLength: 50)
			if selectedTab < 2 {
				CustomButton(buttonText: "Next") {
					selectedTab += 1
				}
				.padding(.vertical)

			}
			else {
				CustomButton(buttonText: "Sign in with Apple", imageString: "logo_apple") {
					authViewModel.login(with: .appleSignIn)
				}
				SignupOR()

				CustomButton(buttonText: "Sign in with Google", imageString: "logo_google") {
					authViewModel.login(with: .googleSignIn)
				}
			}
			Spacer(minLength: 50)

			if authViewModel.loggedInFirebaseUser != nil {
				NavigationLink(destination: InstructionsView()) {
					EmptyView()
				}
			}
		}
		.padding()
		.background(
			Image((selectedTab % 2 == 0) ? "SplashScreen13BG" : "SplashScreen2BG").resizable()
				.scaledToFill().edgesIgnoringSafeArea(.all)
		)
	}
}

struct SplashScreen_Previews: PreviewProvider {
	static var previews: some View {
		SplashScreen()
			.environment(AuthViewModel())
	}
}

extension AnyTransition {
	static var customTransition: AnyTransition {
		let transition = AnyTransition.scale(scale: 0.3, anchor: .topTrailing)
			.combined(with: .opacity)
		return transition
	}
}
