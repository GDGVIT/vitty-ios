//
//  SplashScreenTabIndicator.swift
//  VITTY
//
//  Created by Ananya George on 12/22/21.
//

import SwiftUI

struct SplashScreenTabIndicator: View {
    @Binding var selectedTab: Int
    var body: some View {
        HStack {
            ForEach(0..<3) { index in
                Image(systemName: "circle").font(Font.system(size: 12).bold())
                    .foregroundColor(selectedTab == index ? Color("Secondary") : Color.vprimary)
            }
        }
    }
}

struct SplashScreenTabIndicator_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenTabIndicator(selectedTab: .constant(1))
            .previewLayout(.sizeThatFits)
    }
}
