//
//  CustomTextField.swift
//  VITTY
//
//  Created by Ananya George on 12/22/21.
//

import SwiftUI

struct CustomTextField: View {
    @Binding var textFieldText: String
    var tfString: String
    var imageName: String
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius:5)
                .frame(height: 60)
                .foregroundColor(Color.darkbg)
            
            HStack {
                Image(imageName).font(Font.system(size: 18).bold())
                    .foregroundColor(Color.white)
                    TextField("", text: $textFieldText)
                    .placeholder(when: textFieldText.isEmpty) {
                        Text(tfString).foregroundColor(Color.vprimary)
                }
                        .font(Font.custom("Poppins-Medium", size: 16))
                        .foregroundColor(Color.vprimary)
                .padding()
            }
            .padding()
        }
        .padding(.horizontal)
    }
}
struct CustomTextField_Previews: PreviewProvider {
    static var previews: some View {
        CustomTextField(textFieldText: .constant(""),tfString: "Hi",imageName: "unlock")
            .previewLayout(.sizeThatFits)
    }
}

struct CustomSecureField: View {
    @Binding var secureFieldText: String
    var sfString: String
    var imageName: String
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius:5)
                .frame(height: 60)
                .foregroundColor(Color.darkbg)
            
            HStack {
                Image(imageName).font(Font.system(size: 18).bold())
                    .foregroundColor(Color.white)
                SecureField("", text: $secureFieldText)
                    .placeholder(when: secureFieldText.isEmpty) {
                        Text(sfString).foregroundColor(Color.vprimary)
                }
                        .font(Font.custom("Poppins-Medium", size: 16))
                        .foregroundColor(Color.vprimary)
                .padding()
            }
            .padding()
        }
        .padding(.horizontal)
    }
}

// EXTENSION OF VIEW TO MODIFY PLACEHOLDER TEXT
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
            ZStack(alignment: alignment) {
                placeholder().opacity(shouldShow ? 1 : 0)
                self
            }
        }
}
