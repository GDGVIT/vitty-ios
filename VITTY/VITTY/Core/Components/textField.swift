//
//  textField.swift
//  VITTY
//
//  Created by Prashanna Rajbhandari on 30/05/2023.
//

import SwiftUI

struct textField: View {
    @Binding var text: String
    var tfString : String
    var height : CGFloat
    
    var body: some View {
        /*VStack {
            if #available(iOS 15.0, *) {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(Color.theme.tfBlue)
                    .frame(maxWidth: .infinity)
                    .frame(height: height)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.theme.tfBlueLight, lineWidth: 1)
                            .frame(maxWidth: .infinity)
                            .frame(height: height)
                            .padding()
                            .overlay(alignment: .leading) {
                                TextField(text: $text) {
                                    Text(tfString)
                                        .foregroundColor(Color.theme.tfBlueLight)
                                }
                                .padding(.horizontal, 42)
                                .foregroundColor(.white)
                                .foregroundColor(Color.theme.tfBlue)
                            }
                    )

            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundColor(Color.blue)
                        .frame(maxWidth: .infinity)
                        .frame(height: height)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gray, lineWidth: 1)
                                .frame(maxWidth: .infinity)
                                .frame(height: height)
                                .padding()
                        )

                    HStack {
                        TextField(tfString, text: $text)
                            .padding(.horizontal, 42)
                            .foregroundColor(.white)
                            .foregroundColor(Color.blue)
                    }
                    
                }
            }
        }*/
        VStack{
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(Color.theme.tfBlue)
                .frame(maxWidth: .infinity)
                .frame(height: height)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.theme.tfBlueLight, lineWidth: 1)
                        .frame(maxWidth: .infinity)
                        .frame(height: height)
                        .padding()
                        .overlay(alignment: .leading) {
                            TextField(text: $text) {
                                Text(tfString)
                                    .foregroundColor(Color.theme.tfBlueLight)
                            }
                            .padding(.horizontal, 42)
                            .foregroundColor(.white)
                            .foregroundColor(Color.theme.tfBlue)
                        }
                )

        }
    }
}

struct textField_Previews: PreviewProvider {
    static var previews: some View {
        textField(text: .constant("A random test text"), tfString: "sample text", height: 75)
    }
}
