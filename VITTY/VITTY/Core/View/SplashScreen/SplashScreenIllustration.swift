//
//  SplashScreenIllustration.swift
//  VITTY
//
//  Created by Ananya George on 12/22/21.
//

import SwiftUI

struct SplashScreenIllustration: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        ZStack {
            VStack {
                if (selectedTab == 2) {
                    Spacer()
                }
                Image("SS-Illustration-\(selectedTab + 1)")
                    .resizable()
                    .scaledToFit()
                if (selectedTab == 2) {
                    Text(StringConstants.splashScreenHeader[selectedTab])
                        .font(Font.custom("Poppins-Bold", size: 22))
                        .foregroundColor(Color.white)
                        .multilineTextAlignment(.center)
                    Text(StringConstants.splashScreenDescription[selectedTab])
                        .font(Font.custom("Poppins-Medium", size: 18))
                        .foregroundColor(Color.vprimary)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    Spacer(minLength: 100)
                }
            }
            VStack {
                Spacer(minLength: 100)
                if selectedTab != 2 {
                    Text(StringConstants.splashScreenHeader[selectedTab])
                        .font(Font.custom("Poppins-Bold", size: 22))
                        .foregroundColor(Color.white)
                        .multilineTextAlignment(.center)
                    Text(StringConstants.splashScreenDescription[selectedTab])
                        .font(Font.custom("Poppins-Medium", size: 18))
                        .foregroundColor(Color.vprimary)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
        }
//        .background(Color.darkbg)
    }
}

struct SplashScreenIllustration_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenIllustration(selectedTab: .constant(2))
    }
}
