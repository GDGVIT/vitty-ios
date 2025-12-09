//  JoinGroup.swift
//  VITTY
//
//  Created by Rujin Devkota on 2/28/25.
//

import SwiftUI
import AVFoundation
import UIKit

struct JoinGroup: View {
    let screenHeight = UIScreen.main.bounds.height
    let screenWidth = UIScreen.main.bounds.width

    @Binding var groupCode: String
    @State private var scannedCode: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isJoining = false
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var circleName = ""
    @State private var localGroupCode = ""

    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(CommunityPageViewModel.self) private var communityPageViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Drag indicator
                Capsule()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 50, height: 5)
                    .padding(.top, 8)
                
                // Title
                Text("Join Circle")
                    .font(.system(size: 21, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 20)
                    .padding(.bottom, 24)

                // Input section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Enter circle code")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color("Accent"))

                    TextField("Enter circle code", text: $localGroupCode)
                        .padding()
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                        .onChange(of: localGroupCode) { oldValue, newValue in
                            let filtered = newValue.filter { $0.isLetter || $0.isNumber }
                            localGroupCode = filtered
                            groupCode = filtered
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                }
                .padding(.horizontal, 20)

                Spacer()
                
                // Join button
                HStack {
                    Spacer()
                    Button(action: {
                        joinCircle()
                    }) {
                        HStack {
                            if isJoining {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                            }
                            Text(isJoining ? "JOINING..." : "JOIN")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                        }
                        .frame(width: 100, height: 35)
                        .background(localGroupCode.isEmpty ? Color.gray : Color("Accent"))
                        .cornerRadius(10)
                    }
                    .disabled(isJoining || localGroupCode.isEmpty)
                    .padding(.trailing, 20)
                }
                .padding(.bottom, 20)
            }
            .presentationDetents([.height(screenHeight * 0.35)])
            .background(Color("Secondary"))

            if showToast {
                VStack {
                    Spacer()
                    ToastView(message: toastMessage, isShowing: $showToast)
                        .padding(.bottom, 50)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("JoinCircleFromDeepLink"))) { notification in
            if let userInfo = notification.userInfo,
               let code = userInfo["code"] as? String {
                
                localGroupCode = code
                groupCode = code
                
                joinCircle()
            }
        }
        .alert("Join Circle", isPresented: $showingAlert) {
            Button("OK") {
                if alertMessage.contains("successfully") || alertMessage.contains("requested") {
                    dismiss()
                }
            }
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            localGroupCode = groupCode
        }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }

    // MARK: - Handle Deep Link
    
    private func handleDeepLink(_ url: URL) {
        print("Deep link received in JoinGroup: \(url.absoluteString)")
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            print("Failed to parse URL components")
            return
        }
        
        // Handle the URL format: https://vitty.app/join?code=ABC123
        
        if let code = components.queryItems?.first(where: { $0.name == "code" })?.value {
            localGroupCode = code
            groupCode = code
            
            joinCircle()
        }
    }

    // MARK: - Join Circle
    private func joinCircle() {
        guard !localGroupCode.isEmpty,
              let username = authViewModel.loggedInBackendUser?.username,
              let token = authViewModel.loggedInBackendUser?.token else {
            showToast(message: "Error: Unable to get user information", isError: true)
            return
        }

        if localGroupCode.count < 3 {
            showToast(message: "Error: Circle code must be at least 3 characters", isError: true)
            return
        }

        isJoining = true
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)

        let urlString = "\(APIConstants.base_url)circles/join?code=\(localGroupCode)"
        guard let url = URL(string: urlString) else {
            showToast(message: "Error: Invalid URL", isError: true)
            isJoining = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")

        print("Joining circle with code: \(localGroupCode)")
        print("Request URL: \(urlString)")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isJoining = false

                if let error = error {
                    print("Network error: \(error.localizedDescription)")
                    showToast(message: "Network error: \(error.localizedDescription)", isError: true)
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    showToast(message: "Error: Invalid response", isError: true)
                    return
                }

                print("Response status code: \(httpResponse.statusCode)")

                if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                    showToast(message: "Successfully joined the circle! 🎉", isError: false)

                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()

                    communityPageViewModel.fetchCircleData(
                        from: "\(APIConstants.base_url)circles",
                        token: token,
                        loading: false
                    )

                    localGroupCode = ""
                    groupCode = ""

                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        dismiss()
                    }
                } else {
                    if let data = data {
                        print("Error response data: \(String(data: data, encoding: .utf8) ?? "No data")")
                        
                        if let errorResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let message = errorResponse["message"] as? String {
                            showToast(message: "Error: \(message)", isError: true)
                        } else {
                            handleHTTPError(statusCode: httpResponse.statusCode)
                        }
                    } else {
                        handleHTTPError(statusCode: httpResponse.statusCode)
                    }
                }
            }
        }.resume()
    }
    
    // MARK: - Handle HTTP Errors
    private func handleHTTPError(statusCode: Int) {
        switch statusCode {
        case 400:
            showToast(message: "Error: Invalid circle code", isError: true)
        case 404:
            showToast(message: "Error: Circle not found", isError: true)
        case 409:
            showToast(message: "Error: Already a member of this circle", isError: true)
        case 403:
            showToast(message: "Error: Not authorized to join this circle", isError: true)
        default:
            showToast(message: "Error: Failed to join circle (Code: \(statusCode))", isError: true)
        }
    }

    // MARK: - Show Toast
    private func showToast(message: String, isError: Bool) {
        toastMessage = message
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            showToast = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showToast = false
            }
        }
    }
}

// MARK: - Toast View
struct ToastView: View {
    let message: String
    @Binding var isShowing: Bool
    
    var body: some View {
        if isShowing {
            HStack {
                Text(message)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.black.opacity(0.8))
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
            )
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .onTapGesture {
                withAnimation {
                    isShowing = false
                }
            }
        }
    }
}
