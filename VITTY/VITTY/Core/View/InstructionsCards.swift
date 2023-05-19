//
//  InstructionsCards.swift
//  VITTY
//
//  Created by Ananya George on 12/24/21.
//

import SwiftUI

struct InstructionsCards: View {
    @EnvironmentObject var authState: AuthService
    var body: some View {
        VStack {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 12, style: .circular)
                    .fill(Color.darkbg)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.vprimary, lineWidth: 1.2)
                    )
                VStack(alignment: .leading) {
                    Text(StringConstants.instructionsHeaders[0])
                        .font(Font.custom("Poppins-SemiBold",size: 20))
                        .foregroundColor(Color.white)
                        .padding(.vertical,5)
                    Text(StringConstants.accData[0] + (UserDefaults.standard.string(forKey: "userName") ?? "Anon"))
                        .foregroundColor(Color.vprimary)
                    Text(StringConstants.accData[1] + (UserDefaults.standard.string(forKey: "providerId") ?? ""))
                        .foregroundColor(Color.vprimary)
                    Text(StringConstants.accData[2] + (UserDefaults.standard.string(forKey: "userEmail") ?? ""))
                        .foregroundColor(Color.vprimary)
//                    ForEach(StringConstants.accDetails, id: \.self) { point in
//                        Text(point)
//                            .foregroundColor(Color.vprimary)
//                    }
                }
                .padding()
                .font(Font.custom("Poppins-Regular",size:16))
            }
            .frame(height: 100)
            .padding(.vertical)
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 12, style: .circular)
                    .fill(Color.darkbg)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.vprimary, lineWidth: 1.2)
                    )
                VStack(alignment: .leading) {
                    Text(StringConstants.instructionsHeaders[1])
                        .font(Font.custom("Poppins-SemiBold",size: 20))
                        .foregroundColor(Color.white)
                        .padding(.vertical,5)
//                    ScrollView {
                        VStack(alignment:.leading) {
                            
                            ForEach(0 ..< StringConstants.setupInstructions.count) { point in
                                Text(StringConstants.setupInstructions[point])
                                    .foregroundColor(Color.vprimary)
                                if point == 0 {
                                    Link(destination: URL(string: StringConstants.websiteURL) ?? URL(string: "https://dscvit.com/")!, label: {
                                        Text(StringConstants.websiteURL)
                                            .underline()
                                            .foregroundColor(Color.vprimary)
                                            
                                    })
                                }
                            }
                            Text(StringConstants.setupFinalText)
                                .foregroundColor(Color.white)
                                .padding(.vertical)
                        }
//                    }
                    
                }
                .padding()
                .font(Font.custom("Poppins-Regular",size:16))
            }
//            .frame(height: 300)
            .padding(.vertical)
        }
    }
}

struct InstructionsCards_Previews: PreviewProvider {
    static var previews: some View {
        InstructionsCards()
    }
}
