//
//  StatusRowView.swift
//  VITTY
//
//  Created by Prashanna Rajbhandari on 03/06/2023.
//

import SwiftUI

struct StatusRowView: View {
    var imageName: String
    var statusName: String
    var time: String
    var body: some View {

            HStack{
                Image(imageName)
                
                Text(statusName)
                    .font(.custom("Poppins-Medium", size: 16))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Rectangle()
                    .frame(width: 15,height: 0.5)
                    .foregroundColor(Color.theme.gray)
                Text(time)
                    .font(.custom("Poppins-Medium", size: 16))
                    .foregroundColor(Color.theme.tfBlueLight)
                
                Spacer()
            }
            .padding(.leading)
            .padding(.top)
        
    }
}

struct StatusRowView_Previews: PreviewProvider {
    static var previews: some View {
        StatusRowView(imageName: "calendar", statusName: "In a meeting", time: "1 hour")
    }
}
