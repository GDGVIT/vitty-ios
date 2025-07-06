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
    @State private var isScanning = false
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
            VStack(spacing: 20) {
                Capsule()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 50, height: 5)
                    .padding(.top, 10)
                
                Spacer().frame(height: 7)
                Text("Join Circle")
                    .font(.system(size: 21, weight: .bold))
                    .foregroundColor(.white)

                Spacer().frame(width: 20)

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

                HStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.5))
                        .frame(height: 1)
                    Text("OR")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                    Rectangle()
                        .fill(Color.gray.opacity(0.5))
                        .frame(height: 1)
                }
                .padding(.horizontal, 20)

                HStack {
                    Text("Scan QR Code")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color("Accent"))
                        .padding(.leading, 20)
                    Spacer()
                }

                Button(action: {
                    isScanning = true
                }) {
                    VStack {
                        if isScanning {
                            QRScannerView(scannedCode: $scannedCode, isScanning: $isScanning)
                                .frame(width: screenWidth * 0.8, height: screenHeight * 0.25)
                        } else {
                            Image(systemName: "qrcode.viewfinder")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .foregroundColor(Color.white)

                            Text("Tap to scan QR code")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(width: screenWidth * 0.8, height: screenHeight * 0.25)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )
                }
                .disabled(isJoining)

                Spacer()
                
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
            .presentationDetents([.height(screenHeight * 0.65)])
            .background(Color("Secondary"))
            .onChange(of: scannedCode) { oldValue, newValue in
                if !newValue.isEmpty {
                    handleScannedCode(newValue)
                }
            }

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

    // MARK: - Handle Scanned Code
    private func handleScannedCode(_ code: String) {
        print("Scanned code: \(code)")
        
        
        if code.contains("vitty.app/join") {
            if let url = URL(string: code) {
                handleDeepLink(url)
            }
        } else {
          
            localGroupCode = code
            groupCode = code
            
          
            joinCircle()
        }
        
        isScanning = false
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

// MARK: - QR Scanner Components
struct QRScannerView: UIViewControllerRepresentable {
    @Binding var scannedCode: String
    @Binding var isScanning: Bool
    
    func makeUIViewController(context: Context) -> QRScannerViewController {
        let controller = QRScannerViewController()
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: QRScannerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, QRScannerDelegate {
        let parent: QRScannerView
        
        init(_ parent: QRScannerView) {
            self.parent = parent
        }
        
        func didScanCode(_ code: String) {
            parent.scannedCode = code
            parent.isScanning = false
        }
        
        func didFailWithError(_ error: Error) {
            parent.isScanning = false
        }
    }
}

protocol QRScannerDelegate: AnyObject {
    func didScanCode(_ code: String)
    func didFailWithError(_ error: Error)
}

class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    weak var delegate: QRScannerDelegate?
    
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if captureSession?.isRunning == false {
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if captureSession?.isRunning == true {
            captureSession.stopRunning()
        }
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            delegate?.didFailWithError(NSError(domain: "QRScanner", code: -1, userInfo: [NSLocalizedDescriptionKey: "Camera not available"]))
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            delegate?.didFailWithError(error)
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            delegate?.didFailWithError(NSError(domain: "QRScanner", code: -2, userInfo: [NSLocalizedDescriptionKey: "Could not add video input"]))
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            delegate?.didFailWithError(NSError(domain: "QRScanner", code: -3, userInfo: [NSLocalizedDescriptionKey: "Could not add metadata output"]))
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            delegate?.didScanCode(stringValue)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
