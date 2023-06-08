//
//  HomePageHeader.swift
//  VITTY
//
//  Created by Ananya George on 12/23/21.
//

import SwiftUI

struct HomePageHeader: View {
    @Binding var goToSettings: Bool
    @Binding var showLogout: Bool
    var body: some View {
        HStack {
            Text("Schedule")
            Spacer()
            Menu {
                Button(action: {
                    goToSettings = true
                }, label: {
                    HStack {
                        Image(systemName: "gear")
                        Text("Settings")
                    }
                })
                Button(action: shareSheet, label: {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share")
                    }
                })
                Button(action: {
                    showLogout = true
                }, label: {
                    HStack {
                        Image(systemName: "arrow.right.square")
                        Text("Logout")
                    }
                })
            } label: {
                Image(systemName: "ellipsis")
            }
        }
        .font(Font.custom("Poppins-Bold", size: 22))
        .foregroundColor(Color.white)
    }
    // share sheet
    func shareSheet() {
//    guard let data = URL(string: "https://vitty.dscvit.com/") else {return} // add appstore link
        let data = StringConstants.shareSheetContent
        let av = UIActivityViewController(activityItems: [data], applicationActivities: nil)
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        window?.rootViewController?.present(av, animated: true, completion: nil)
    }
}

struct HomePageHeader_Previews: PreviewProvider {
    static var previews: some View {
        HomePageHeader(goToSettings: .constant(false), showLogout: .constant(false))
            .previewLayout(.sizeThatFits)
    }
}

