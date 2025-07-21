//
//  CircleRequests.swift
//  VITTY
//
//  Created by Rujin Devkota on 6/24/25.
//



import SwiftUI

struct CircleRequestRow: View {
    let request: CircleRequest
    let onAccept: () -> Void
    let onDecline: () -> Void
    @Environment(CommunityPageViewModel.self) private var communityPageViewModel
    
    var body: some View {
        HStack {
            UserImage(url: "https://picsum.photos/200/300", height: 48, width: 48)
            
            Spacer().frame(width: 16)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("@\(request.from_username)")
                    .font(.custom("Poppins-SemiBold", size: 16))
                    .foregroundColor(.white)
                
                Text("wants you to  join \(request.circle_name)")
                    .font(.custom("Poppins-Regular", size: 14))
                    .foregroundColor(Color("Accent"))
                    .lineLimit(2)
            }
            
            Spacer()
            
            if communityPageViewModel.loadingRequestAction {
                ProgressView()
                    .scaleEffect(0.8)
                    .padding(.trailing)
            } else {
                HStack(spacing: 8) {
                    Button(action: onDecline) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Color.red.opacity(0.8))
                            .cornerRadius(18)
                    }
                    
                    Button(action: onAccept) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Color.green.opacity(0.8))
                            .cornerRadius(18)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color("Secondary"))
        )
        .animation(.easeInOut(duration: 0.2), value: communityPageViewModel.loadingRequestAction)
    }
}

struct CircleRequestsView: View {
    @Environment(CommunityPageViewModel.self) private var communityPageViewModel
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showSuccessAlert = false
    @State private var alertMessage = ""
    @State private var searchText = ""
    
    private var filteredRequests: [CircleRequest] {
        if searchText.isEmpty {
            return communityPageViewModel.circleRequests
        } else {
            return communityPageViewModel.circleRequests.filter { request in
                request.from_username.localizedCaseInsensitiveContains(searchText) ||
                request.circle_name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
         
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .font(.title2)
                }
                
                Spacer()
                
                Text("Circle Requests")
                    .font(.custom("Poppins-SemiBold", size: 20))
                    .foregroundColor(.white)
                
                Spacer()
                
              
                Button(action: {
                    refreshRequests()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                }
            }
            .padding()
            
   
            SearchBar(searchText: $searchText)
                .padding(.horizontal)
            
            Spacer().frame(height: 16)
            
          
            if communityPageViewModel.loadingCircleRequests {
                Spacer()
                VStack(spacing: 12) {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("Loading requests...")
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundColor(Color("Accent"))
                }
                Spacer()
                
            } else if communityPageViewModel.errorCircleRequests {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 32))
                        .foregroundColor(.red)
                    
                    Text("Failed to load requests")
                        .font(.custom("Poppins-SemiBold", size: 16))
                        .foregroundColor(.white)
                    
                    Text("Please try again")
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundColor(Color("Accent"))
                    
                    Button(action: refreshRequests) {
                        Text("Retry")
                            .font(.custom("Poppins-Regular", size: 14))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color("Accent"))
                            .cornerRadius(20)
                    }
                    .padding(.top, 8)
                }
                Spacer()
                
            } else if filteredRequests.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: searchText.isEmpty ? "person.2" : "magnifyingglass")
                        .font(.system(size: 32))
                        .foregroundColor(Color("Accent"))
                    
                    Text(searchText.isEmpty ? "No pending requests" : "No matching requests")
                        .font(.custom("Poppins-SemiBold", size: 16))
                        .foregroundColor(.white)
                    
                    Text(searchText.isEmpty ?
                         "You're all caught up! No one is waiting to join your circles." :
                         "Try adjusting your search terms")
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundColor(Color("Accent"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                Spacer()
                
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(filteredRequests, id: \.id) { request in
                            CircleRequestRow(
                                request: request,
                                onAccept: {
                                    acceptRequest(request)
                                },
                                onDecline: {
                                    declineRequest(request)
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 100)
                }
            }
            
            Spacer()
        }
        .background(Color("Background").edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            refreshRequests()
        }
        .refreshable {
            refreshRequests()
        }
        .alert("Request Processed", isPresented: $showSuccessAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func refreshRequests() {
        guard let token = authViewModel.loggedInBackendUser?.token else { return }
        communityPageViewModel.fetchCircleRequests(token: token)
    }
    
    private func acceptRequest(_ request: CircleRequest) {
        guard let token = authViewModel.loggedInBackendUser?.token else { return }
        
        communityPageViewModel.acceptCircleRequest(circleId: request.circle_id, token: token) { success in
            if success {
                alertMessage = "you have been added to \(request.circle_name)"
                showSuccessAlert = true
                
              
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    communityPageViewModel.fetchCircleData(
                        from: "\(APIConstants.base_url)circles",
                        token: token,
                        loading: false
                    )
                }
            } else {
                alertMessage = "Failed to accept the request. Please try again."
                showSuccessAlert = true
            }
        }
    }
    
    private func declineRequest(_ request: CircleRequest) {
        guard let token = authViewModel.loggedInBackendUser?.token else { return }
        
        communityPageViewModel.declineCircleRequest(circleId: request.circle_id, token: token) { success in
            if success {
                alertMessage = "Request from @\(request.from_username) has been declined"
                showSuccessAlert = true
            } else {
                alertMessage = "Failed to decline the request. Please try again."
                showSuccessAlert = true
            }
        }
    }
}
