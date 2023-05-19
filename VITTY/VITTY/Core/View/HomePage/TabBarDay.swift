//
//  TabBarDay.swift
//  VITTY
//
//  Created by Ananya George on 1/8/22.
//

import SwiftUI

struct TabBarDay: View {
    @Binding var tabSelected: Int
    var i: Int
    var body: some View {
        ZStack {
            if tabSelected == i {
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient.secGrad)
            }
            HStack {
                Spacer()
                Button(action: {
                    tabSelected = i
                }, label: {
                    Text(StringConstants.daysOfTheWeek[i])
                        .font(Font.custom("Poppins-Medium", size: 16))
                        .foregroundColor(tabSelected==i ? Color.white : Color.vprimary)
                })
                Spacer()
            }
            .padding()
        }
    }
}

struct TabBarDay_Previews: PreviewProvider {
    static var previews: some View {
        TabBarDay(tabSelected: .constant(1), i: 0)
    }
}
