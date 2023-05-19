//
//  SignupOR.swift
//  VITTY
//
//  Created by Ananya George on 12/22/21.
//

import SwiftUI

struct SignupOR: View {
    var body: some View {
        HStack {
            Spacer()
            Rectangle()
                .frame(height: 1)
            Text("OR")
                .font(Font.custom("Poppins-Regular", size: 14))
            Rectangle()
                .frame(height: 1)
            Spacer()
        }
        .foregroundColor(Color.white)
        .padding()
    }
}

struct SignupOR_Previews: PreviewProvider {
    static var previews: some View {
        SignupOR()
    }
}
