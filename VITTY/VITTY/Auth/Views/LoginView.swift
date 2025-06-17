//
//  LoginView.swift
//  VITTY
//
//  Created by Chandram Dutta on 04/02/24.
//

import OSLog
import SwiftUI

struct LoginView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var animationProgress = 0.0
    
    private let carouselItems = [
        LoginViewCarouselItem(image: "LoginViewIllustration 2", heading: "Never miss a class", subtitle: "Notifications to remind you about your upcoming classes"),
        LoginViewCarouselItem(image: "LoginViewIllustration 1", heading: "Get a sneak peek", subtitle: "View your upcoming classes and timetable via the widget"),
        LoginViewCarouselItem(image: "LoginViewIllustration 3", heading: "Upload Once, view everywhere", subtitle: "Instant Sync across all of your devices via the app")
    ]

    var body: some View {
        ZStack {
            BackgroundView()
            ScrollViewReader { value in
                VStack(alignment: .center) {
                    ScrollView(.horizontal) {
                        LazyHStack {
                            ForEach(carouselItems.indices, id: \.self) { index in
                                CarouselItemView(item: carouselItems[index], index: index, lastIndex: carouselItems.count - 1)
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollIndicators(.hidden)
                    .scrollTargetBehavior(.viewAligned)
                    .offset(x: -animationProgress * 75)
                    .animation(.spring(), value: animationProgress)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
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
                .safeAreaPadding()
            }
        }
    }
}

struct SignInButtonsView: View {
    @Environment(AuthViewModel.self) private var authViewModel

    var body: some View {
        VStack {
            Button(action: {
                Task {
                    authViewModel.isLoadingApple = true
                    await authViewModel.login(with: .appleSignIn)
                    authViewModel.isLoadingApple = false
                }
            }) {
                HStack {
                    if authViewModel.isLoadingApple {
                        ProgressView()
                            .tint(.white)
                            .padding(.vertical, 16)
                    } else {
                        Image("logo_apple")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 24)
                        Text("Sign In With Apple")
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                            .padding(.vertical, 16)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .background(Color("Secondary"))
            .cornerRadius(18)
            .padding([.top, .leading, .trailing])

            Button(action: {
                Task {
                    authViewModel.isLoadingGoogle = true
                    await authViewModel.login(with: .googleSignIn)
                    authViewModel.isLoadingGoogle = false
                }
            }) {
                HStack {
                    if authViewModel.isLoadingGoogle {
                        ProgressView()
                            .tint(.white)
                            .padding(.vertical, 16)
                    } else {
                        Image("logo_google")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 24)
                        Text("Sign In With Google")
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                            .padding(.vertical, 16)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .background(Color("Secondary"))
            .cornerRadius(18)
            .padding()
        }
    }
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
struct CarouselItemView: View {
    let item: LoginViewCarouselItem
    let index: Int
    let lastIndex: Int
    @Environment(AuthViewModel.self) private var authViewModel

    var body: some View {
        VStack {
            if index == lastIndex {
                Spacer()
            }
            Image(item.image)
                .resizable()
                .scaledToFit()
                .padding(.horizontal, 64)
                .frame(height: 400)
            Text(item.heading)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color.white)
            Text(item.subtitle)
                .font(.footnote)
                .foregroundColor(Color("tfBlueLight"))
                .multilineTextAlignment(.center)
                .frame(width: 400)
                .padding(.top, 1)
            if index == lastIndex {
                Spacer()
                SignInButtonsView()
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
