//
//  InsideCircleCards.swift
//  VITTY
//
//  Created by Rujin Devkota on 3/26/25.
//

import SwiftUI

struct InsideCircleRow: View {
    let picture : String
    let name : String
    let status : String
    let venue : String?
    
    var body: some View {
        HStack {
            UserImage(url:picture, height: 48, width: 48)
            Spacer().frame(width: 20)
            VStack(alignment: .leading) {
                
                Text(name)
                    .font(Font.custom("Poppins-SemiBold", size: 18))
                    .foregroundColor(Color.white)
                
                if status == "free" {
                    HStack {
                        Image("available").resizable().frame(width: 20, height: 20)
                        Text("Available").foregroundStyle(Color("Accent"))
                    }
                } else {
                    HStack {
                        Image("inclass")
                        Text(venue ?? "")
                            .font(Font.custom("Poppins-Regular", size: 14))
                            .foregroundColor(Color("Accent"))
                    }
                }
            }
            Spacer()
        }
        .padding().frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color("Secondary"))
        )
    }
}
