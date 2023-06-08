//
//  SetStatusView.swift
//  VITTY
//
//  Created by Prashanna Rajbhandari on 02/06/2023.
//

import SwiftUI

struct SetStatusView: View {
    @StateObject private var vm = SetStatusViewModel()

    var body: some View {
        ZStack {
            // background
            Color.theme.blueBG
                .ignoresSafeArea()

            // foreground
            VStack {
                statusHeader()

                selectStatus()
                
                autoUpdateSection()
                

                Spacer()
            }

        }.toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Text("Set a status")
                    .font(.custom("Poppins-Medium", size: 22))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Image(systemName: "xmark")
                    .foregroundColor(.white)
                    .padding(.trailing)
            }
        }
    }
}

struct SetStatusView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                SetStatusView()
            }
        } else {
            // Fallback on earlier versions
            NavigationView {
                SetStatusView()
            }
        }
    }
}

extension SetStatusView {
    private func Divider() -> some View {
        Rectangle()
            .frame(maxWidth: .infinity)
            .frame(height: 0.5)
            .foregroundColor(Color.theme.tfBlueLight)
    }

    private func statusHeader() -> some View {
        VStack {
            Divider()
                .padding(.top, 40)
            HStack {
                Image("SmileFace")
                    .padding(.trailing, 30)
                Text("What's Your Status")
                    .font(.custom("Poppins-Medium", size: 16))
                    .foregroundColor(Color.theme.tfBlueLight)
                Spacer()
            }.padding()

            Divider()
        }
    }
    
    private func selectStatus() -> some View{
        VStack{
            ForEach(vm.stausArray) { id in
                StatusRowView(imageName: id.imageName, statusName: id.statusName, time: id.time)
            }
            
            Divider().padding(.top)
        }
    }
    
    private func autoUpdateSection() -> some View{
        VStack(alignment: .leading){
            Text("Automatically updates")
                .font(.custom("Poppins-Medium", size: 13))
                .fontWeight(.semibold)
                .foregroundColor(Color.theme.gray)
            HStack{
                Image("gcalendar")
                
                Text("In a class")
                    .font(.custom("Poppins-Medium", size: 16))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Rectangle()
                    .frame(width: 15,height: 0.5)
                    .foregroundColor(Color.theme.gray)
                Text("Based on your Class ")
                    .font(.custom("Poppins-Medium", size: 16))
                    .foregroundColor(Color.theme.gray)
                
                Spacer()
            }
            
        }.padding(.leading)
    }
}
