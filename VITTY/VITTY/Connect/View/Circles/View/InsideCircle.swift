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

struct DeleteCircleAlert: View {
    let circleName: String
    let onCancel: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 12) {
                Text("Delete circle?")
                    .font(.custom("Poppins-SemiBold", size: 18))
                    .foregroundColor(.white)
                
                Text("Are you sure you want to delete \(circleName)? This action cannot be undone and will remove all members from the circle.")
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
                    
                    Button(action: onDelete) {
                        Text("Delete")
                            .font(.custom("Poppins-Regular", size: 14))
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
            .frame(height: 180)
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

struct GenerateJoinCodeModal: View {
    let circleName: String
    let joinCode: String
    let isLoading: Bool
    let onGenerate: () -> Void
    let onDismiss: () -> Void
    let onCopyCode: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 20) {
                Text("Join Code")
                    .font(.custom("Poppins-SemiBold", size: 20))
                    .foregroundColor(.white)
                
                Text("Share this code with friends to join \(circleName)")
                    .font(.custom("Poppins-Regular", size: 14))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color("Accent")))
                        .padding()
                } else if !joinCode.isEmpty {
                    VStack(spacing: 12) {
                        Text(joinCode)
                            .font(.custom("Poppins-SemiBold", size: 24))
                            .foregroundColor(Color("Accent"))
                            .padding()
                            .background(Color("Secondary"))
                            .cornerRadius(12)
                        
                        Button(action: onCopyCode) {
                            HStack {
                                Image(systemName: "doc.on.doc")
                                Text("Copy Code")
                            }
                            .font(.custom("Poppins-Regular", size: 14))
                            .foregroundColor(Color("Accent"))
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(Color("Secondary"))
                            .cornerRadius(8)
                        }
                    }
                }
                
                HStack(spacing: 10) {
                    Button(action: onDismiss) {
                        Text("Close")
                            .font(.custom("Poppins-Regular", size: 14))
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    if joinCode.isEmpty && !isLoading {
                        Button(action: onGenerate) {
                            Text("Generate Code")
                                .font(.custom("Poppins-Regular", size: 14))
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity)
                            
                                .background(Color("Accent"))
                                .foregroundColor(.black)
                                .cornerRadius(8)
                        }
                    }
                }
            }
            .frame(minHeight: 200)
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

struct CircleMenuView: View {
    let circleName: String
    let onLeaveGroup: () -> Void
    let onDeleteGroup: () -> Void
    let onGroupRequests: () -> Void
    let onGenerateJoinCode: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 0) {
                Button(action: {
                    onCancel()
                    onLeaveGroup()
                }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red)
                        Text("Leave Group")
                            .font(.custom("Poppins-Regular", size: 16))
                            .foregroundColor(.red)
                        Spacer()
                    }
                    .padding()
                    .background(Color("Background"))
                }
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                
                Button(action: {
                    onCancel()
                    onDeleteGroup()
                }) {
                    HStack {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                        Text("Delete Circle")
                            .font(.custom("Poppins-Regular", size: 16))
                            .foregroundColor(.red)
                        Spacer()
                    }
                    .padding()
                    .background(Color("Background"))
                }
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                
                Button(action: onCancel) {
                    Text("Cancel")
                        .font(.custom("Poppins-Regular", size: 16))
                        .foregroundColor(.gray)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color("Background"))
                }
            }
            .background(Color("Background"))
            .cornerRadius(16)
            .padding(.horizontal, 30)
            .transition(.scale.combined(with: .opacity))
            Spacer()
        }
        .background(Color.black.opacity(0.5).edgesIgnoringSafeArea(.all))
    }
}


struct DualIconMenu: View {
    let onQRCode: () -> Void
    let onGenerateCode: () -> Void
    
    var body: some View {
        HStack(spacing: 6) {
          
            Button(action: onQRCode) {
                Image(systemName: "qrcode")
                    .foregroundColor(Color("Accent"))
                    .font(.system(size: 16, weight: .medium))
                    .frame(width: 32, height: 32)
                    .background(Color("Secondary"))
                    .cornerRadius(8)
            }
            
               Button(action: onGenerateCode) {
                Image(systemName: "link")
                    .foregroundColor(Color("Accent"))
                    .font(.system(size: 16, weight: .medium))
                    .frame(width: 32, height: 32)
                    .background(Color("Secondary"))
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color("Secondary").opacity(0.3))
        .cornerRadius(12)
    }
}

struct InsideCircle: View {
    var circleName : String
    var groupCode: String
    @State var searchText: String = ""
    @State var showLeaveAlert: Bool = false
    @State var showDeleteAlert: Bool = false
    @State var showCircleMenu: Bool = false
    @State var showGroupRequests : Bool = false
    @State var showGenerateJoinCode: Bool = false
    @State var generatedJoinCode: String = ""
    @State var isGeneratingCode: Bool = false
    @Environment(CommunityPageViewModel.self) private var communityPageViewModel
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(\.presentationMode) var presentationMode
    @State var showQRCode: Bool = false
    
 
    private func isUserBusy(_ member: CircleUserTemp) -> Bool {
        let status = member.status
       
        return status != "free" && !status.isEmpty
    }
    
    private func isUserAvailable(_ member: CircleUserTemp) -> Bool {
        let status = member.status
        
        return status == "free" || status.isEmpty || member.currentStatus == nil
    }
    
    private var busyCount: Int {
        communityPageViewModel.circleMembers.filter { isUserBusy($0) }.count
    }
    
    private var availableCount: Int {
        communityPageViewModel.circleMembers.filter { isUserAvailable($0) }.count
    }
    
    // MARK: - Filtered members for search
    private var filteredMembers: [CircleUserTemp] {
        if searchText.isEmpty {
            return communityPageViewModel.circleMembers
        } else {
            return communityPageViewModel.circleMembers.filter { member in
                member.name.localizedCaseInsensitiveContains(searchText) ||
                member.username.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    // MARK: - Generate Join Code Function
    private func generateJoinCode() {
        isGeneratingCode = true
        
        let token = authViewModel.loggedInBackendUser?.token ?? ""
        
        communityPageViewModel.generateJoinCode(circleId: groupCode, token: token) { result in
            DispatchQueue.main.async {
                self.isGeneratingCode = false
                
                switch result {
                case .success(let joinCode):
                    self.generatedJoinCode = joinCode
                case .failure(let error):
                    print("Error generating join code: \(error)")
                    
                }
            }
        }
    }
    
    // MARK: - Copy Join Code Function
    private func copyJoinCode() {
        UIPasteboard.general.string = generatedJoinCode
        // You might want to show a toast or feedback that the code was copied
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white).font(.title2)
                }
                Spacer()
                Text("Circle")
                    .font(.custom("Poppins-SemiBold", size: 22))
                    .foregroundColor(.white)
                Spacer()
                Button(action: {
                    showCircleMenu = true
                }) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.white)
                        .font(.system(size: 18))
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
                    
                }
                Spacer().frame(height: 5)
                HStack {
                   
                    if busyCount > 0 {
                        HStack {
                            Image("inclass").resizable().frame(width: 18, height: 18)
                            Text("\(busyCount) busy")
                                .foregroundStyle(Color("Accent"))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color("Secondary"))
                        .cornerRadius(12)
                        
                        Spacer().frame(width: 10)
                    }
                    
                  
                    if availableCount > 0 {
                        HStack {
                            Image("available").resizable().frame(width: 18, height: 18)
                            Text("\(availableCount) available")
                                .foregroundStyle(Color("Accent"))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color("Secondary"))
                        .cornerRadius(12)
                    }
                    
                    Spacer()
                    
                    
                    DualIconMenu(
                        onQRCode: {
                            showQRCode = true
                            print("QR Code tapped")
                        },
                        onGenerateCode: {
                            showGenerateJoinCode = true
                            print("Generate Code tapped")
                        }
                    )
                }
            }
            .padding()
            
            if communityPageViewModel.loadingCircleMembers {
                ProgressView("Loading...")
                    .padding()
                    .foregroundColor(.white)
            } else if communityPageViewModel.errorCircleMembers {
                Text("Failed to load members.")
                    .foregroundColor(.red)
                    .padding()
            } else {
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(filteredMembers, id: \.username) { member in
                            InsideCircleRow(
                                picture: member.picture,
                                name: member.name,
                                status: getDisplayStatus(for: member),
                                venue: getDisplayVenue(for: member)
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
        .sheet(isPresented: $showGroupRequests, content: {
            CircleRequestsView()
        })
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
                
                if showDeleteAlert {
                    DeleteCircleAlert(circleName: "\(circleName)", onCancel: {
                        showDeleteAlert = false
                    }, onDelete: {
                        let url = "\(APIConstants.base_url)circles/\(groupCode)"
                        let token = authViewModel.loggedInBackendUser?.token ?? ""

                        communityPageViewModel.deleteCircle(from: url, token: token)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showDeleteAlert = false
                            presentationMode.wrappedValue.dismiss()
                        }
                    })
                }
                
                if showGenerateJoinCode {
                    GenerateJoinCodeModal(
                        circleName: circleName,
                        joinCode: generatedJoinCode,
                        isLoading: isGeneratingCode,
                        onGenerate: {
                            generateJoinCode()
                        },
                        onDismiss: {
                            showGenerateJoinCode = false
                            generatedJoinCode = ""
                        },
                        onCopyCode: {
                            copyJoinCode()
                        }
                    )
                }
                
                if showCircleMenu {
                    CircleMenuView(
                        circleName: circleName,
                        onLeaveGroup: {
                            showLeaveAlert = true
                        },
                        onDeleteGroup: {
                            showDeleteAlert = true
                        },
                        onGroupRequests: {
                            showGroupRequests = true
                            print("Navigate to Circle Requests")
                        },
                        onGenerateJoinCode: {
                            showGenerateJoinCode = true
                        },
                        onCancel: {
                            showCircleMenu = false
                        }
                    )
                }
                
                if showQRCode {
                    QRCodeModalView(
                        groupCode: groupCode,
                        circleName: circleName,
                        onDismiss: {
                            showQRCode = false
                        }
                    )
                }
            }
        )
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
    
    // MARK: - Helper functions for display
    private func getDisplayStatus(for member: CircleUserTemp) -> String {
        let status = member.status
        
       
        if let currentStatus = member.currentStatus {
            switch currentStatus.status {
            case "class":
                return "In Class"
            case "free":
                return "Free"
            default:
                return currentStatus.status.capitalized
            }
        }
        
     
        return "Free"
    }
    
    private func getDisplayVenue(for member: CircleUserTemp) -> String {
      
        if let venue = member.venue, !venue.isEmpty {
            return venue
        }
        
      
        if let className = member.className, !className.isEmpty {
            return className
        }
        
    
        return "Available"
    }
}
