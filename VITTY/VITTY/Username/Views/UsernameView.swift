//
//  UsernameView.swift
//  VITTY
//
//  Created by Chandram Dutta on 05/02/24.
//

import SwiftUI

struct UsernameView: View {
    @State private var username = ""
    @State private var regNo = ""
    @State private var selectedCampus = "vellore"
    @State private var userNameErrorString = ""
    @State private var regNoErrorString = ""
    @State private var usernameError = true
    @State private var regNoError = true
    @State private var isLoading = false
    @State private var isCheckingExistingUser = true
    @State private var userExists = false
    
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""

    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(\.dismiss) private var dismiss
    

    private let campusOptions = [
         ("VIT Vellore", "vellore"),
        ("VIT Chennai", "chennai"),
        ("VIT Bhopal", "bhopal")
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()
                
                if isCheckingExistingUser {
                  
                    
                    VStack(spacing: 20) {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(1.1)
                        
                        Text("Checking your account...")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    }
                } else if userExists {
                  
                    VStack(spacing: 24) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.green)
                        
                        VStack(spacing: 12) {
                            Text("Welcome back!")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Your account has been found and you're ready to go.")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                        
                        NavigationLink(destination: HomeView()) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white)
                                    .frame(height: 54)
                                
                                Text("Continue to Home")
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                                    .font(.system(size: 18))
                            }
                        }
                        .padding(.top, 20)
                    }
                    .padding(.horizontal, 20)
                } else {
                   
                    VStack(alignment: .leading, spacing: 20) {
                        headerView
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Enter username, registration number, and select your campus below.")
                                .font(.footnote)
                                .foregroundColor(.white.opacity(0.8))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .onChange(of: username) { _, _ in
                                    checkUserExists { result in
                                        switch result {
                                        case .success(let exists):
                                            if exists {
                                                usernameError = true
                                            } else {
                                                usernameError = false
                                            }
                                        case .failure(_):
                                            userNameErrorString = "An error occurred. Please try again."
                                            usernameError = true
                                        }
                                    }
                                }
                            
                            Text("Your username will help your friends find you!")
                                .font(.footnote)
                                .foregroundColor(.white.opacity(0.7))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .onChange(of: regNo) { _, _ in
                                    let regex = #"^\d{2}[A-Za-z]{3}\d{4}$"#
                                    let regNoTest = NSPredicate(format: "SELF MATCHES %@", regex)
                                    if regNoTest.evaluate(with: regNo) {
                                        regNoErrorString = ""
                                        regNoError = false
                                    } else {
                                        regNoErrorString = "Please enter a valid registration number."
                                        regNoError = true
                                    }
                                }
                        }
                        
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Username")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.1))
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    .frame(height: 50)
                                
                                TextField("Enter your username", text: $username)
                                    .padding(.horizontal, 16)
                                    .foregroundColor(.white)
                                    .font(.system(size: 16))
                            }
                            
                            if !userNameErrorString.isEmpty {
                                Text(userNameErrorString)
                                    .font(.caption)
                                    .foregroundStyle(.red)
                            }
                        }
                        
                      
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Registration Number")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.1))
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    .frame(height: 50)
                                
                                TextField("e.g., 21BCE1234", text: $regNo)
                                    .padding(.horizontal, 16)
                                    .foregroundColor(.white)
                                    .font(.system(size: 16))
                            }
                            
                            if !regNoErrorString.isEmpty {
                                Text(regNoErrorString)
                                    .font(.caption)
                                    .foregroundStyle(.red)
                            }
                        }
                        
                       
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Campus")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.1))
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    .frame(height: 50)
                                
                                HStack {
                                    Menu {
                                        ForEach(campusOptions, id: \.1) { campus in
                                            Button(action: {
                                                selectedCampus = campus.1
                                            }) {
                                                HStack {
                                                    Text(campus.0)
                                                        .foregroundColor(.primary)
                                                    if selectedCampus == campus.1 {
                                                        Spacer()
                                                        Image(systemName: "checkmark")
                                                            .foregroundColor(.blue)
                                                    }
                                                }
                                            }
                                        }
                                    } label: {
                                        HStack {
                                            Text(campusOptions.first(where: { $0.1 == selectedCampus })?.0 ?? "Select Campus")
                                                .foregroundColor(.white)
                                                .font(.system(size: 16))
                                            Spacer()
                                            Image(systemName: "chevron.down")
                                                .foregroundColor(.white.opacity(0.7))
                                                .font(.system(size: 14))
                                        }
                                        .padding(.horizontal, 16)
                                    }
                                }
                            }
                        }
                        
                        Spacer()
                        
                      
                        Button(action: {
                            print("is this button being pressed")
                            Task {
                                isLoading = true
                                
                                do {
                                    try await authViewModel.signInServer(username: username, regNo: regNo, campus: selectedCampus)
                                } catch {
                                    alertTitle = "Sign In Error"
                                    alertMessage = "Unable to sign in. Please contact VITTY support for assistance."
                                    showAlert = true
                                    print("Sign in error: \(error)")
                                }
                                
                                isLoading = false
                            }
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        (usernameError || regNoError || isLoading || username.isEmpty || regNo.isEmpty) ?
                                        Color.white.opacity(0.3) :
                                        Color.white
                                    )
                                    .frame(height: 54)
                                
                                if isLoading {
                                    ProgressView()
                                        .tint(Color.black)
                                } else {
                                    Text("Done")
                                        .fontWeight(.bold)
                                        .foregroundColor(
                                            (usernameError || regNoError || isLoading || username.isEmpty || regNo.isEmpty) ?
                                            Color.white.opacity(0.7) :
                                            Color.black
                                        )
                                        .font(.system(size: 18))
                                }
                            }
                        }
                        .disabled(usernameError || regNoError || isLoading || username.isEmpty || regNo.isEmpty)
                        .padding(.bottom, 20)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationBarBackButtonHidden(true)
            .alert(alertTitle, isPresented: $showAlert) {
                Button("OK") {
                    showAlert = false
                }
            } message: {
                Text(alertMessage)
            }
            .onAppear {
                checkExistingUser()
            }
        }
        .accentColor(.white)
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .font(.title3)
                        .fontWeight(.medium)
                        .frame(width: 40, height: 40)
                }
                Spacer()
            }
            
            HStack {
                Text("Let's Sign you in")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
            }
        }
        .padding(.top, 10)
    }
    
    private func checkExistingUser() {
        guard let firebaseUUID = authViewModel.loggedInFirebaseUser?.uid else {
            isCheckingExistingUser = false
            return
        }
        
        Task {
            do {
       
                let backendUser = try await authenticateWithFirebase(uuid: firebaseUUID)
                
              
                DispatchQueue.main.async {
                    self.authViewModel.loggedInBackendUser = AppUser(
                        name: backendUser.name,
                        picture: backendUser.picture,
                        role: backendUser.role,
                        token: backendUser.token,
                        username: backendUser.username,
                        campus: backendUser.campus
                    )
                    
                   
                    UserDefaults.standard.set(backendUser.token, forKey: UserDefaultKeys.tokenKey)
                    UserDefaults.standard.set(backendUser.username, forKey: UserDefaultKeys.usernameKey)
                    UserDefaults.standard.set(backendUser.name, forKey: UserDefaultKeys.nameKey)
                    UserDefaults.standard.set(backendUser.picture, forKey: UserDefaultKeys.pictureKey)
                    UserDefaults.standard.set(backendUser.role, forKey: UserDefaultKeys.roleKey)
                    
                    if let campus = backendUser.campus {
                        UserDefaults.standard.set(campus, forKey: UserDefaultKeys.campusKey)
                    } else {
                        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.campusKey)
                    }
                    
                    self.userExists = true
                    self.isCheckingExistingUser = false
                }
            } catch {
               
                DispatchQueue.main.async {
                    self.userExists = false
                    self.isCheckingExistingUser = false
                }
            }
        }
    }
    
    private func authenticateWithFirebase(uuid: String) async throws -> FirebaseAuthResponse {
        guard let url = URL(string: "\(Constants.url)auth/firebase") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = FirebaseAuthRequest(uuid: uuid)
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if httpResponse.statusCode == 200 {
            return try JSONDecoder().decode(FirebaseAuthResponse.self, from: data)
        } else {
            throw URLError(.badServerResponse)
        }
    }
    
    func checkUserExists(completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let url = URL(string: "\(Constants.url)auth/check-username") else {
            completion(.failure(AuthAPIServiceError.invalidUrl))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(["username": username])
        } catch {
            completion(.failure(error))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                completion(.failure(AuthAPIServiceError.invalidUrl))
                return
            }
            
            guard let response = response as? HTTPURLResponse else { return }
            
            if response.statusCode == 200 {
                DispatchQueue.main.async {
                    userNameErrorString = ""
                }
                completion(.success(false))
            } else {
                do {
                    let res = try JSONDecoder().decode([String: String].self, from: data)
                    DispatchQueue.main.async {
                        userNameErrorString = res["detail"] ?? "Username already exists"
                    }
                } catch {
                    DispatchQueue.main.async {
                        userNameErrorString = "Username already exists"
                    }
                }
                completion(.success(true))
            }
        }
        task.resume()
    }
}
