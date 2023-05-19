//
//  CustomButton.swift
//  VITTY
//
//  Created by Ananya George on 12/22/21.
//

import SwiftUI

struct CustomButton: View {
    @State var buttonText: String = "Continue"
    var fontSize: CGFloat = 18.0
    var bgroundColor: Color = Color.sec
    var borderColor: Color = Color.sec
    var borderWidth: CGFloat = 0.0
    var fgroundColor: Color = Color.white
    var cornerRad: CGFloat = 10.0
    var minLength: CGFloat = 20
    var imageString: String? = nil
    var action: () -> Void = {}
    var body: some View {
        HStack(spacing:0) {
            Button(action: action) {
                HStack {
                    Spacer()
                    if let imageString = imageString {
                        Image(imageString)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 25)
                    }
                    Text(buttonText)
                        .font(Font.custom("Poppins-SemiBold",size:fontSize))
                        .lineLimit(1)
                        .minimumScaleFactor(0.3)
                        .padding(.vertical,12)
                    Spacer()
                }
                .foregroundColor(fgroundColor)
                .background(bgroundColor)
                .cornerRadius(cornerRad)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRad)
                        .stroke(borderColor, lineWidth: borderWidth)
            )
            }
        }
    }
}

struct CustomButton_Previews: PreviewProvider {
    static var previews: some View {
        CustomButton()
    }
}
