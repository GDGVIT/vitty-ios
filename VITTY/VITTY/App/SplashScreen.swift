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
    @EnvironmentObject var authState: AuthService
    var body: some View {
        VStack {
            TabView(selection: $selectedTab){
                ForEach(0..<3) { _ in
                    SplashScreenIllustration(selectedTab: $selectedTab)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            SplashScreenTabIndicator(selectedTab: $selectedTab)
            Spacer(minLength: 50)
            if selectedTab < 2 {
                CustomButton(buttonText:"Next") {
                    selectedTab += 1
                }
                .padding(.vertical)
                
            } else {
//                NavigationLink(destination: InstructionsView().navigationBarHidden(true), isActive: authState.loggedInUser != nil) {
                    CustomButton(buttonText: "Sign in with Google", imageString: "logo_google"){
                        authState.login(with: .googleSignin)
                    }
//                }
                SignupOR()
                NavigationLink(destination: InstructionsView(), isActive: $onboardingComplete) {
                    CustomButton(buttonText:"Sign in with Apple",imageString: "logo_apple"){
                        
                    }
                }
            }
            Spacer(minLength: 50)
            
            if authState.loggedInUser != nil {
                NavigationLink(destination: InstructionsView()) {
                    EmptyView()
                }
            }
            
        }
        .animation(.linear(duration: 0.25))
        .padding()
        .background(Image((selectedTab % 2 == 0) ? "SplashScreen13BG" : "SplashScreen2BG").resizable().scaledToFill().edgesIgnoringSafeArea(.all))
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
    }
}
