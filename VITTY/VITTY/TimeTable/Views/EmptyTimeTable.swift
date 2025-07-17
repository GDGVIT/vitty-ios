//
//  EmptyTimeTable.swift
//  VITTY
//
//  Created by Rujin Devkota on 7/17/25.
//

import SwiftUI

struct EmptyTimetableView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var showingInstructionView = false
    
   
    let onReload: () -> Void
    let isRefreshing: Bool
    
    
    init(onReload: @escaping () -> Void = {}, isRefreshing: Bool = false) {
        self.onReload = onReload
        self.isRefreshing = isRefreshing
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(Color("Accent"))
                .padding(.bottom, 8)
            
            Text("No Timetable Found")
                .font(Font.custom("Poppins-Bold", size: 24))
                .foregroundColor(.primary)
            
            Text("It looks like you haven't uploaded your timetable yet. Upload it on our website to get started!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            VStack(spacing: 12) {
                Button(action: {
                    if let url = URL(string: "https://dscv.it/vittyconnect") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack {
                        Image(systemName: "safari")
                        Text("Upload Timetable")
                    }
                    .foregroundColor(.black)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color("Accent"))
                    .cornerRadius(12)
                }
                
                // Add reload button
                Button(action: {
                    onReload()
                }) {
                    HStack {
                        if isRefreshing {
                            ProgressView()
                                .scaleEffect(0.8)
                                .foregroundColor(Color("Accent"))
                        } else {
                            Image(systemName: "arrow.clockwise")
                        }
                        Text(isRefreshing ? "Checking..." : "Check Again")
                    }
                    .foregroundColor(Color("Accent"))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color("Secondary"))
                    .cornerRadius(12)
                }
                .disabled(isRefreshing)
                
                Button(action: {
                    showingInstructionView = true
                }) {
                    HStack {
                        Image(systemName: "info.circle")
                        Text("View Instructions")
                    }
                    .foregroundColor(Color("Accent"))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color("Secondary"))
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal, 32)
            .padding(.top, 16)
            
            Spacer()
        }
        .sheet(isPresented: $showingInstructionView) {
            InstructionView()
        }
    }
}
