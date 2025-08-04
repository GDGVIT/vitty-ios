//
//  InstructionView.swift
//  VITTY
//
//  Created by Chandram Dutta on 05/02/24.
//

import SwiftUI

struct InstructionView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var serverStatusManager = ServerStatusManager()
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()
                
                if serverStatusManager.isServerDown {
                   
                    VStack(spacing: 30) {
                        Spacer()
                        
                        
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 100, height: 100)
                            .overlay(
                                Image(systemName: "wrench.and.screwdriver")
                                    .foregroundColor(.white)
                                    .font(.system(size: 40))
                            )
                        
                      
                        Text("Server Under Maintenance")
                            .font(.custom("Poppins-SemiBold", size: 28))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                           
                        
                        
                        Text("We're currently performing server maintenance to improve your experience.")
                            .font(.custom("Poppins-Regular", size: 16))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Text("Please check back in a few minutes. We'll be back online soon!")
                            .font(.custom("Poppins-Regular", size: 14))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                       
                        Button(action: {
                            serverStatusManager.retryServerCheck { isUp in
                                
                            }
                        }) {
                            HStack {
                                if serverStatusManager.isCheckingServer {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                        .scaleEffect(0.8)
                                } else {
                                    Text("Try Again")
                                        .font(.custom("Poppins-Medium", size: 16))
                                }
                            }
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                        .disabled(serverStatusManager.isCheckingServer)
                        .padding(.horizontal, 40)
                        
                      
                        Button(action: {
                            exit(0)
                        }) {
                            Text("Exit App")
                                .font(.custom("Poppins-Regular", size: 16))
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 10)
                        
                        Spacer()
                        
                       
                        Text("Thank you for your patience")
                            .font(.custom("Poppins-Regular", size: 14))
                            .foregroundColor(.gray)
                            .padding(.bottom, 30)
                    }
                } else {
                    
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading) {
                            Text("Account Details")
                                .font(Font.custom("Poppins-SemiBold", size: 20))
                                .foregroundColor(Color.white)
                                .padding(.vertical, 5)
                            Text(
                                "Name: \(authViewModel.loggedInFirebaseUser?.displayName ?? "-")"
                            )
                            Text(
                                "Signed in with: \(authViewModel.loggedInFirebaseUser?.providerID ?? "-")"
                            )
                            Text(
                                "Email: \(authViewModel.loggedInFirebaseUser?.email ?? "-")"
                            )
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .font(Font.custom("Poppins-Regular", size: 16))
                        .background{
                            RoundedRectangle(cornerRadius: 12, style: .circular)
                                .fill(Color("Secondary"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color("Accent"), lineWidth: 1.2)
                                )
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Setup Instructions")
                                .font(Font.custom("Poppins-SemiBold", size: 20))
                                .padding(.vertical, 5)
                            VStack(alignment: .leading) {
                                Text("1. Upload the timetable on")
                                Link(
                                    destination: URL(string: "https://dscv.it/vittyconnect")!,
                                    label: {
                                        Text(StringConstants.websiteURL)
                                            .underline()
                                    }
                                )
                                Text("2. Log in with the same Apple/Google Account as shown above")
                                Text("3. Upload a screenshot of your timetable")
                                Text("4. Review it")
                                Text("5. When done, click on Upload")
                                Text("BRAVO! That's it. You did it!")
                                    .padding(.vertical)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .font(Font.custom("Poppins-Regular", size: 16))
                        .background{
                            RoundedRectangle(cornerRadius: 12, style: .circular)
                                .fill(Color("Secondary"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color("Accent"), lineWidth: 1.2)
                                )
                        }
                        
                        Spacer()
                        
                        NavigationLink(destination: {
                            if authViewModel.loggedInBackendUser == nil {
                                UsernameView()
                            }
                            else {
                                HomeView()
                            }
                        }) {
                            Spacer()
                            Text("Done")
                                .fontWeight(.bold)
                                .foregroundColor(Color.white)
                                .padding(.vertical, 16)
                            Spacer()
                        }
                        .background(Color("Secondary"))
                        .cornerRadius(18)
                    }
                    .padding()
                }
            }
            .toolbar {
                Button(action: {
                    authViewModel.signOut()
                }) {
                    Image(systemName: "arrow.right.square")
                }
                .foregroundStyle(.white)
            }
            .navigationTitle(serverStatusManager.isServerDown ? "" : "Sync Timetable")
            .onAppear {
                
                serverStatusManager.checkServerStatus { isUp in
                    
                }
            }
        }
    }
}
