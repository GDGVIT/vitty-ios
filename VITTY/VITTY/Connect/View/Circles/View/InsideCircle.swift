//
//  InsideCircle.swift
//  VITTY
//
//  Created by Rujin Devkota on 3/26/25.


import SwiftUI

struct LeaveCircleAlert: View {
    let circleName: String
    let onCancel: () -> Void
    let onLeave: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 12) {
                Text("Leave circle?")
                    .font(.custom("Poppins-SemiBold", size: 18))
                    .foregroundColor(.white)
                
                Text("Are you sure you want to leave \(circleName)?")
                    .font(.custom("Poppins-Regular", size: 14))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 10) {
                    Button(action: onCancel) {
                        Text("Cancel")
                            .font(.custom("Poppins-Regular", size: 14))
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    Button(action: onLeave) {
                        Text("Leave")
                            .font(.custom("Poppins-Regular", size: 14))
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
            .frame(height: 150)
            .padding(20)
            .background(Color("Background"))
            .cornerRadius(16)
            .padding(.horizontal, 30)
            .transition(.scale.combined(with: .opacity))
            Spacer()
        }
        .background(Color.black.opacity(0.5).edgesIgnoringSafeArea(.all))
    }
}

struct InsideCircle: View {
    var circleName : String
    var groupCode: String
    @State var searchText: String = ""
    @State var showLeaveAlert: Bool = false
    @Environment(CommunityPageViewModel.self) private var communityPageViewModel
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                }
                Spacer()
                Text("Circle")
                    .font(.custom("Poppins-SemiBold", size: 22))
                    .foregroundColor(.white)
                Spacer()
                Button(action: {
                    showLeaveAlert = true
                }) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .foregroundColor(.white)
                }
            }
            .padding()
            
            SearchBar(searchText: $searchText)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 10) {
                Spacer().frame(height: 8)
                HStack {
                    Text("\(circleName)")
                        .font(.custom("Poppins-SemiBold", size: 20))
                        .foregroundColor(.white)
                    Spacer()
                    Text(groupCode)
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundColor(Color("Accent"))
                }
                Spacer().frame(height: 5)
                HStack {
                    HStack {
                        Image("inclass").resizable().frame(width: 18, height: 18)
                        Text("3 busy")
                            .foregroundStyle(Color("Accent"))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color("Secondary"))
                    .cornerRadius(12)
                    Spacer().frame(width: 10)
                    HStack {
                        Image("available").resizable().frame(width: 18, height: 18)
                        Text("2 available")
                            .foregroundStyle(Color("Accent"))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color("Secondary"))
                    .cornerRadius(12)
                }
            }
            .padding()
            
            if communityPageViewModel.loadingCircleMembers {
                ProgressView("Loading...")
                    .padding()
            } else if communityPageViewModel.errorCircleMembers {
                Text("Failed to load members.")
                    .foregroundColor(.red)
            } else {
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(communityPageViewModel.circleMembers, id: \ .username) { member in
                            InsideCircleRow(
                                picture: member.picture,
                                name: member.name,
                                status: "free",
                                venue: "318"
                            )
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top)
                }
            }
            Spacer()
        }
        .background(Color("Background").edgesIgnoringSafeArea(.all))
        .onAppear {
            communityPageViewModel.fetchCircleMemberData(
                from: "\(APIConstants.base_url)circles/\(groupCode)",
                token: authViewModel.loggedInBackendUser?.token ?? "",
                loading: true
            )
        }
        .overlay(
            Group {
                if showLeaveAlert {
                    LeaveCircleAlert(circleName: "\(circleName)", onCancel: {
                        showLeaveAlert = false
                    }, onLeave: {
                        let url = "\(APIConstants.base_url)circles/\(groupCode)/leave"
                        let token = authViewModel.loggedInBackendUser?.token ?? ""

                        communityPageViewModel.leaveCircle(from: url, token: token)
                        
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showLeaveAlert = false
                            presentationMode.wrappedValue.dismiss()
                        }
                    })
                }
            }
        )

        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
}
