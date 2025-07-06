import CoreImage.CIFilterBuiltins
import SwiftUI

struct QRCodeModalView: View {
    let groupCode: String
    let circleName: String
    let existingJoinCode: String
    let onDismiss: () -> Void
    
    @State private var showingShareSheet = false
    @State private var isGeneratingCode = false
    @State private var joinCode: String = ""
    @State private var showError = false
    @State private var errorMessage = ""
    
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(CommunityPageViewModel.self) private var communityPageViewModel
    
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 20) {
                HStack {
                    Text("Circle QR Code")
                        .font(.custom("Poppins-SemiBold", size: 20))
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .font(.system(size: 18))
                    }
                }
                
                VStack(spacing: 8) {
                    Text(circleName)
                        .font(.custom("Poppins-SemiBold", size: 18))
                        .foregroundColor(.white)
                }
                
               
                if isGeneratingCode {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 200, height: 200)
                        .cornerRadius(12)
                        .overlay(
                            VStack(spacing: 8) {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: Color("Accent")))
                                Text("Generating QR Code...")
                                    .font(.custom("Poppins-Regular", size: 12))
                                    .foregroundColor(.white)
                            }
                        )
                } else if !joinCode.isEmpty {
                    if let qrImage = generateQRCode(from: createDeepLink()) {
                        Image(uiImage: qrImage)
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .background(Color.white)
                            .cornerRadius(12)
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 200, height: 200)
                            .cornerRadius(12)
                            .overlay(
                                VStack(spacing: 8) {
                                    Image(systemName: "exclamationmark.triangle")
                                        .font(.system(size: 30))
                                        .foregroundColor(.orange)
                                    Text("QR Code\nGeneration Failed")
                                        .font(.custom("Poppins-Regular", size: 12))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                    Button("Try Again") {
                                        generateJoinCode()
                                    }
                                    .font(.custom("Poppins-Regular", size: 10))
                                    .foregroundColor(Color("Accent"))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color("Secondary"))
                                    .cornerRadius(4)
                                }
                            )
                    }
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 200, height: 200)
                        .cornerRadius(12)
                        .overlay(
                            VStack(spacing: 8) {
                                Image(systemName: "qrcode")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white)
                                Text("Tap to Generate QR Code")
                                    .font(.custom("Poppins-Regular", size: 12))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                            }
                        )
                        .onTapGesture {
                            generateJoinCode()
                        }
                }
                
               
                if !joinCode.isEmpty {
                    VStack(spacing: 4) {
                        Text("Join Code:")
                            .font(.custom("Poppins-Regular", size: 12))
                            .foregroundColor(.gray)
                        Text(joinCode)
                            .font(.custom("Poppins-SemiBold", size: 16))
                            .foregroundColor(Color("Accent"))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color("Secondary"))
                            .cornerRadius(8)
                            .onTapGesture {
                                copyJoinCode()
                            }
                    }
                }
                
                Text("Share this code for others to join your circle")
                    .font(.custom("Poppins-Regular", size: 12))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                
                HStack(spacing: 12) {
                    if joinCode.isEmpty{
                        Button(action: {
                            if joinCode.isEmpty {
                                generateJoinCode()
                            }
                        }) {
                            HStack {
                                Image(systemName:"qrcode" )
                                Text( "Generate QR Code")
                            }
                            .font(.custom("Poppins-SemiBold", size: 14))
                            .foregroundColor(Color("Background"))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color("Accent"))
                            .cornerRadius(8)
                        }
                        .disabled(isGeneratingCode)
                    }
                    
                   
                }
            }
            .frame(maxWidth: 300)
            .padding(24)
            .background(Color("Background"))
            .cornerRadius(16)
            .padding(.horizontal, 30)
            .transition(.scale.combined(with: .opacity))
            Spacer()
        }
        .background(Color.black.opacity(0.5).edgesIgnoringSafeArea(.all))
        
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
         
            if !existingJoinCode.isEmpty {
                joinCode = existingJoinCode
            } else {
              
                generateJoinCode()
            }
        }
        .onChange(of: existingJoinCode) { oldValue, newValue in
            if !newValue.isEmpty && newValue != joinCode {
                joinCode = newValue
            }
        }
    }
    
    private func generateJoinCode() {
        guard let token = authViewModel.loggedInBackendUser?.token else {
            errorMessage = "Authentication required"
            showError = true
            return
        }
        
        isGeneratingCode = true
        
        communityPageViewModel.generateJoinCode(circleId: groupCode, token: token) { result in
            DispatchQueue.main.async {
                isGeneratingCode = false
                
                switch result {
                case .success(let code):
                    joinCode = code
                    
                case .failure(let error):
                    errorMessage = "Failed to generate join code: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
    
    private func copyJoinCode() {
        UIPasteboard.general.string = joinCode
       
        print("Join code copied to clipboard")
    }
    
 
    private func createDeepLink() -> String {
        guard let encodedCircleName = circleName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return "vitty://join?code=\(joinCode)"
        }
       //vitty://join?code=Ow2tWaHExs&circleName=newircircle
        return "vitty://join?code=\(joinCode)&circleName=\(encodedCircleName)"
    }
    
    private func generateQRCode(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        filter.message = Data(string.utf8)
        
        if let outputImage = filter.outputImage {
            let scaleX = 200 / outputImage.extent.size.width
            let scaleY = 200 / outputImage.extent.size.height
            let transformedImage = outputImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
            
            if let cgImage = context.createCGImage(transformedImage, from: transformedImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        return nil
    }
}

