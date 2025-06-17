//
//  Academics.swift
//  VITTY
//
//  Created by Rujin Devkota on 2/27/25.

import SwiftUI

struct Academics: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack {
                HStack {
                    AcademicsTabButton(title: "Courses", isActive: selectedTab == 0) {
                        selectedTab = 0
                    }
                    AcademicsTabButton(title: "Reminders", isActive: selectedTab == 1) {
                        selectedTab = 1
                    }
                }
                .padding(.top, 20)
                
                TabView(selection: $selectedTab) {
                    CoursesView()
                        .tag(0)
                    RemindersView()
                        .tag(1)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
        }
    }
}

struct AcademicsTabButton: View {
    var title: String
    var isActive: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Text(title)
                    .font(.system(size: 16, weight: isActive ? .bold : .regular))
                    .foregroundColor(isActive ? .white : Color("Accent"))
                if isActive {
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                } else {
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(Color.clear)
                        .padding(.horizontal, 10)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}
