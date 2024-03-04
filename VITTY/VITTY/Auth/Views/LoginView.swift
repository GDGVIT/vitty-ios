//
//  LoginView.swift
//  VITTY
//
//  Created by Chandram Dutta on 04/02/24.
//

import SwiftUI

struct LoginView: View {

	@Environment(AuthViewModel.self) private var authViewModel

	private let carouselItems = [
		LoginViewCarouselItem(
			image: "LoginViewIllustration 2",
			heading: "Never miss a class",
			subtitle: "Notifications to remind you about your upcoming classes"
		),
		LoginViewCarouselItem(
			image: "LoginViewIllustration 1",
			heading: "Get a sneak peek",
			subtitle: "View your upcoming classes and timetable via the widget"
		),
		LoginViewCarouselItem(
			image: "LoginViewIllustration 3",
			heading: "Upload Once, view everywhere",
			subtitle: "Instant Sync across all of your devices via the app"
		),
	]

	@State private var animationProgress = 0.0

	var body: some View {
		ZStack {
			Image("SplashScreen13BG")
				.resizable()
				.ignoresSafeArea()
			ScrollViewReader { value in
				VStack(alignment: .center) {
					ScrollView(.horizontal) {
						LazyHStack {
							ForEach(0..<3, id: \.self) { index in
								VStack {
									if index == 2 {
										Spacer()
									}
									Image(carouselItems[index].image)
										.resizable()
										.scaledToFit()
										.padding(.horizontal, 64)
										.frame(height: 400)
									Text(carouselItems[index].heading)
										.font(.title2)
										.fontWeight(.bold)
										.foregroundColor(Color.white)
									Text(carouselItems[index].subtitle)
										.font(.footnote)
										.foregroundColor(Color("tfBlueLight"))
										.multilineTextAlignment(.center)
										.frame(width: 400)
										.padding(.top, 1)
									if index == 2 {
										Spacer()

										Button(action: {
											Task {
												try await authViewModel.login(with: .appleSignIn)
											}
										}) {
											Spacer()
											if authViewModel.isLoading {
												ProgressView()
													.tint(.white)
													.padding(.vertical, 16)
											}
											else {

												Image("logo_apple")
													.resizable()
													.scaledToFit()
													.frame(height: 24)
												Text("Sign In With Apple")
													.fontWeight(.bold)
													.foregroundColor(Color.white)
													.padding(.vertical, 16)
											}
											Spacer()
										}
										.background(Color("brightBlue"))
										.cornerRadius(18)
										.padding([.top, .leading, .trailing])
										Button(action: {
											Task {
												try await authViewModel.login(with: .googleSignIn)
											}
										}) {
											Spacer()
											if authViewModel.isLoading {
												ProgressView()
													.tint(.white)
													.padding(.vertical, 16)
											}
											else {
												Image("logo_google")
													.resizable()
													.scaledToFit()
													.frame(height: 24)
												Text("Sign In With Google")
													.fontWeight(.bold)
													.foregroundColor(Color.white)
													.padding(.vertical, 16)
											}
											Spacer()
										}
										.background(Color("brightBlue"))
										.cornerRadius(18)
										.padding()
									}
								}
								.containerRelativeFrame(.horizontal)
								.scrollTransition(.animated, axis: .horizontal) { content, phase in
									content
										.opacity(phase.isIdentity ? 1.0 : 0.8)
										.scaleEffect(phase.isIdentity ? 1.0 : 0.8)
								}
							}

						}
						.scrollTargetLayout()
					}
					.scrollIndicators(.hidden)
					.scrollTargetBehavior(.viewAligned)
					.offset(x: -animationProgress * 75)
					.animation(.spring(), value: animationProgress)
					.onAppear {  // Start animation on appear
						DispatchQueue.main.asyncAfter(deadline: .now() + 1) {  // Delay animation start
							withAnimation(.linear(duration: 1.0)) {
								animationProgress = 1.0
							}
							DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
								withAnimation(.linear(duration: 2.0)) {
									animationProgress = 0.0
								}
							}
						}
					}
				}
			}
		}
	}

}

#Preview {
	LoginView()
		.environment(AuthViewModel())
}

struct LoginViewCarouselItem {
	let image: String
	let heading: String
	let subtitle: String
}

extension Comparable {
	func clamped(to range: Range<Self>) -> Self {
		return min(max(self, range.lowerBound), range.upperBound)
	}
}
