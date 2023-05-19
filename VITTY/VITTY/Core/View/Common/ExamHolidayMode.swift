//
//  ExamHolidayMode.swift
//  VITTY
//
//  Created by Ananya George on 12/24/21.
//

import SwiftUI

struct ExamHolidayMode: View {
    var body: some View {
        HStack {
            Spacer()
            Image(systemName: "bell.slash")
            Text("Exam/Holiday Mode ON")
            Spacer()
        }
        .padding()
        .font(Font.custom("Poppins-Regular", size: 14))
        .foregroundColor(Color.vprimary)
        .background(Color.darkbg)
    }
}

struct ExamHolidayMode_Previews: PreviewProvider {
    static var previews: some View {
        ExamHolidayMode()
    }
}
