//
//  CreateGroup.swift
//  VITTY
//
//  Created by Rujin Devkota on 2/27/25.

import SwiftUI
import Alamofire

struct CreateGroup: View {
    let screenHeight = UIScreen.main.bounds.height
    let screenWidth = UIScreen.main.bounds.width
    
    @Binding var groupCode: String
    @State private var groupName: String = ""
    @State private var selectedImage: UIImage? = nil
    @State private var showImagePicker = false
    @State private var selectedFriends: [Friend] = []
    @State private var showFriendSelector = false
    @State private var isCreatingGroup = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var circle_ID = ""
    
    @Environment(CommunityPageViewModel.self) private var viewModel
    let token: String
    let username: String
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            
            Capsule()
                .fill(Color("Accent"))
                .frame(width: 80, height: 5)
                .padding(.top, 10)
            
            Text("Create Circle")
                .font(.system(size: 23, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer().frame(height: 20)
            
            
            Button(action: {
                showImagePicker = true
            }) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 75, height: 75)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "camera.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.white)
                    }
                }
            }
            .sheet(isPresented: $showImagePicker) {
                // ImagePicker implementation would go here
            }
            
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Enter circle name")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color("Accent"))
                
                TextField("Circle Name", text: $groupName)
                    .padding()
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(8)
                    .foregroundColor(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )
                    .onChange(of: groupName) { oldValue, newValue in
                      
                        let filtered = newValue.replacingOccurrences(of: " ", with: "")
                        if filtered != newValue {
                            groupName = filtered
                        }
                        
                   
                        if groupName.count > 50 {
                            groupName = String(groupName.prefix(20))
                        }
                    }
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                
              
                Text("No spaces allowed • Max 50 characters")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .padding(.leading, 5)
            }
            .padding(.horizontal, 20)

            
            
            HStack {
                Text("Add Friends")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color("Accent"))
                    .padding(.leading, 20)
                
                Spacer()
                
                Button(action: {
                    showFriendSelector = true
                }) {
                    Image(systemName: "person.badge.plus")
                        .foregroundColor(.white)
                        .font(.system(size: 20, weight: .bold))
                }
                .padding(.trailing, 20)
            }
            
            
            if selectedFriends.isEmpty {
                
                VStack {
                    Image(systemName: "person.2")
                        .font(.system(size: 30))
                        .foregroundColor(.gray)
                    Text("No friends selected")
                        .foregroundColor(.gray)
                        .font(.system(size: 14))
                }
                .frame(width: screenWidth * 0.9, height: 80)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color("Accent"), lineWidth: 2)
                )
                .background(Color.black.opacity(0.3))
                .cornerRadius(12)
                .padding(.horizontal, 20)
            } else {
                
                HStack {
                    if selectedFriends.count <= 3 {
                        
                        Spacer()
                        HStack(spacing: -15) {
                            ForEach(Array(selectedFriends.enumerated()), id: \.element.username) { index, friend in
                                AsyncImage(url: URL(string: friend.picture)) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    Circle()
                                        .fill(Color.green.opacity(0.8))
                                        .overlay(
                                            Text(String(friend.name.prefix(1)).uppercased())
                                                .foregroundColor(.white)
                                                .font(.system(size: 16, weight: .bold))
                                        )
                                }
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                            }
                        }
                        Spacer()
                    } else {
                        
                        Spacer().frame(width: 30)
                        HStack(spacing: -15) {
                            ForEach(Array(selectedFriends.prefix(3).enumerated()), id: \.element.username) { index, friend in
                                AsyncImage(url: URL(string: friend.picture)) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    Circle()
                                        .fill(Color.green.opacity(0.8))
                                        .overlay(
                                            Text(String(friend.name.prefix(1)).uppercased())
                                                .foregroundColor(.white)
                                                .font(.system(size: 16, weight: .bold))
                                        )
                                }
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                            }
                        }
                        Spacer()
                        Text("+ \(selectedFriends.count - 3) more")
                            .foregroundColor(.gray)
                            .font(.system(size: 14))
                        Spacer().frame(width: 20)
                    }
                }
                .frame(width: screenWidth * 0.9, height: 80)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color("Accent"), lineWidth: 2)
                )
                .background(Color.black.opacity(0.3))
                .cornerRadius(12)
                .padding(.horizontal, 20)
                .contentShape(Rectangle())
                .onTapGesture {
                    showFriendSelector = true
                }
            }
            
            Spacer()
            
            
            HStack {
                Spacer()
                Button(action: {
                    createGroup()
                }) {
                    HStack {
                        if isCreatingGroup {
                            ProgressView()
                                .scaleEffect(0.8)
                                .progressViewStyle(CircularProgressViewStyle(tint: .black))
                        }
                        Text(isCreatingGroup ? "Creating..." : "Create")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                    }
                    .frame(width: 100, height: 35)
                    .background(groupName.isEmpty ? Color.gray : Color("Accent"))
                    .cornerRadius(10)
                }
                .disabled(groupName.isEmpty || isCreatingGroup)
                .padding(.trailing, 20)
            }
            .padding(.bottom, 20)
            
        }
        .presentationDetents([.height(screenHeight * 0.65)])
        .background(Color("Secondary"))
        .sheet(isPresented: $showFriendSelector) {
            FriendSelectorView(
                friends: viewModel.friends,
                selectedFriends: $selectedFriends,
                loadingFriends: viewModel.loadingFreinds
            )
        }
        .alert("Group Creation", isPresented: $showAlert) {
            Button("OK") {
                if alertMessage.contains("successfully") {
                    dismiss()
                }
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    // MARK: - Group Creation using ViewModel (Fixed Version)

    private func createGroup() {
        guard !groupName.isEmpty else { return }
        
        isCreatingGroup = true
        
        viewModel.createCircle(name: groupName, token: token) { result in
            switch result {
            case .success(let circleId):
                print("Successfully created circle with ID: \(circleId)")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if let circle = self.viewModel.circles.first(where: { $0.circleName == self.groupName }) {
                        
                        print("Found circle ID: \(circle.circleID) for name: \(self.groupName)")
                        
                        self.circle_ID = circle.circleID
                        
                      
                        if self.selectedFriends.isEmpty {
                            self.isCreatingGroup = false
                            self.alertMessage = "Group created successfully!"
                            self.showAlert = true
                        } else {
                           
                            self.sendInvitationsUsingViewModel(circleId: circle.circleID)
                        }
                        
                    } else {
                        let error = NSError(domain: "CreateCircleError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Could not find created circle in local data"])
                        
                       
                        self.isCreatingGroup = false
                        self.alertMessage = "Failed to find created group in local data"
                        self.showAlert = true
                    }
                }
                
            case .failure(let error):
                self.isCreatingGroup = false
                self.alertMessage = "Failed to create group: \(error.localizedDescription)"
                self.showAlert = true
            }
        }
    }

    private func sendInvitationsUsingViewModel(circleId: String) {
        guard !selectedFriends.isEmpty else {
            self.isCreatingGroup = false
            self.alertMessage = "Group created successfully!"
            self.showAlert = true
            return
        }
        
        // Extract usernames from selected friends
        let usernames = selectedFriends.map { $0.username }
        
        print("Sending invitations for circle ID: \(circleId)")
        print("Usernames: \(usernames)")
        
        // Use the view model's sendMultipleInvitations function with correct circle ID
        viewModel.sendMultipleInvitations(circleId: circleId, usernames: usernames, token: token) { results in
            self.isCreatingGroup = false
            
            let successCount = results.values.filter { $0 }.count
            let totalCount = self.selectedFriends.count
            
            if successCount == totalCount {
                self.alertMessage = "Group created successfully! All invitations sent."
            } else if successCount > 0 {
                self.alertMessage = "Group created successfully! \(successCount) out of \(totalCount) invitations sent."
            } else {
                self.alertMessage = "Group created successfully, but failed to send invitations."
            }
            
            self.showAlert = true
        }
    }
    
    struct FriendSelectorView: View {
        let friends: [Friend]
        @Binding var selectedFriends: [Friend]
        let loadingFriends: Bool
        
        @Environment(\.dismiss) private var dismiss
        
        var body: some View {
            NavigationView {
                VStack {
                    if loadingFriends {
                        ProgressView("Loading friends...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .foregroundColor(.white)
                    } else if friends.isEmpty {
                        VStack {
                            Image(systemName: "person.2.slash")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            Text("No friends found")
                                .font(.title2)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(friends, id: \.username) { friend in
                                    FriendRowView(
                                        friend: friend,
                                        isSelected: selectedFriends.contains { $0.username == friend.username }
                                    ) { isSelected in
                                        if isSelected {
                                            selectedFriends.append(friend)
                                        } else {
                                            selectedFriends.removeAll { $0.username == friend.username }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                        }
                    }
                }
                .background(Color("Background"))
                .navigationTitle("Select Friends")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(
                    leading: Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                    },
                    trailing: Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                    }
                )
            }
            .background(Color("Background"))
        }
    }
    
    struct FriendRowView: View {
        let friend: Friend
        let isSelected: Bool
        let onToggle: (Bool) -> Void
        
        var body: some View {
            HStack {
                
                AsyncImage(url: URL(string: friend.picture)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Circle()
                        .fill(Color.blue.opacity(0.3))
                        .overlay(
                            Text(String(friend.name.prefix(1)).uppercased())
                                .foregroundColor(.white)
                                .font(Font.custom("Poppins-SemiBold", size: 16))
                        )
                }
                .frame(width: 48, height: 48)
                .clipShape(Circle())
                
                Spacer().frame(width: 20)
                
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(friend.name)
                        .font(Font.custom("Poppins-SemiBold", size: 18))
                        .foregroundColor(Color.white)
                    
                    if friend.currentStatus.status == "free" {
                        HStack {
                            Image("available")
                                .resizable()
                                .frame(width: 20, height: 20)
                            Text("Available")
                                .font(Font.custom("Poppins-Regular", size: 14))
                                .foregroundStyle(Color("Accent"))
                        }
                    } else {
                        HStack {
                            Image("inclass")
                                .resizable()
                                .frame(width: 20, height: 20)
                            Text(friend.currentStatus.venue ?? "In Class")
                                .font(Font.custom("Poppins-Regular", size: 14))
                                .foregroundColor(Color("Accent"))
                        }
                    }
                }
                
                Spacer()
                
                
                Button(action: {
                    onToggle(!isSelected)
                }) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ? Color("Accent") : .gray)
                        .font(.system(size: 24))
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color("Secondary"))
            )
            .contentShape(Rectangle())
            .onTapGesture {
                onToggle(!isSelected)
            }
        }
    }
}

// MARK: - Response Models (if not already defined elsewhere)

struct CreateCircleResponse: Decodable {
    let circleId: String
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case circleId = "circle_id"
        case message
    }
}
