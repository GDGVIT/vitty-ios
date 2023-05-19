//
//  HomeTabBarView.swift
//  VITTY
//
//  Created by Ananya George on 12/23/21.
//

import SwiftUI

struct HomeTabBarView: View {
    @Binding var tabSelected: Int
    var body: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                ScrollViewReader { scrollView in
                    HStack(spacing:0) {
                        ForEach(0..<StringConstants.daysOfTheWeek.count) { i in
                            TabBarDay(tabSelected: $tabSelected, i: i)
                                .id(i)
                        }
                    }
                    .onAppear {
                        scrollView.scrollTo(tabSelected)
                    }
                    .onChange(of: tabSelected) { newTab in
                        scrollView.scrollTo(newTab)
                    }
                }
            }
            .padding(.horizontal,5)
            .frame(height: 50)
        .background(Color.darkbg)
        }
    }
}

struct HomeTabBarView_Previews: PreviewProvider {
    static var previews: some View {
        HomeTabBarView(tabSelected: .constant(1))
    }
}
