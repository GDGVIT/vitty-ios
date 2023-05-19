//
//  WidgetHeader.swift
//  VITTY
//
//  Created by Prashanna Rajbhandari on 13/05/2023.
//

import SwiftUI

struct WidgetHeader: View {
    var body: some View {
        HStack {
            Text("Today's Schedule")
                .font(Font.custom("Poppins-Regular", size: 14))
                .foregroundColor(Color.vprimary)
                .padding(.leading, 15)
                .padding(.top, 10)
            .padding(.bottom, 5)
            Spacer()
            Text("VITTY")
                .font(Font.custom("Poppins-Regular", size: 14))
                .foregroundColor(Color.vprimary)
                .padding(.top, 10)
                .padding(.trailing,15)
            .padding(.bottom, 5)
        }
    }
}

struct WidgetHeader_Previews: PreviewProvider {
    static var previews: some View {
        WidgetHeader()
    }
}
