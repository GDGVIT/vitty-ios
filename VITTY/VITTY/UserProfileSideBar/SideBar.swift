import SwiftUI
import SwiftData
import OSLog
import UIKit

struct UserProfileSidebar: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Binding var isPresented: Bool
    @Binding var showLogoutAlert: Bool 

    @Environment(\.modelContext) private var modelContext
    @State private var isLoggingOut: Bool = false
    @State private var showSupportDialog: Bool = false
    
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.vitty.app",
        category: "UserProfileSidebar"
    )
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button {
                isPresented = false
            } label: {
                Image(systemName: "xmark")
                    .foregroundColor(.white)
                    .padding()
            }
            
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    UserImage(
                        url: authViewModel.loggedInBackendUser?.picture ?? "",
                        height: 60,
                        width: 60
                    )
                    Text(authViewModel.loggedInBackendUser?.name ?? "User")
                        .font(Font.custom("Poppins-Bold", size: 18))
                        .foregroundColor(.white)
                    Text("@\(authViewModel.loggedInBackendUser?.username ?? "")")
                        .font(Font.custom("Poppins-Regular", size: 14))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.top, 40)
                
                Divider().background(Color.clear)
                
                if(authViewModel.loggedInBackendUser?.campus == "vellore"){
                    NavigationLink {
                        EmptyClassRoom()
                    } label: {
                        HStack(spacing: 16) {
                            Image("emptyclassroom")
                                .foregroundColor(.white)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 8) {
                                    Text("Find Empty Classroom")
                                        .font(Font.custom("Poppins-Medium", size: 16))
                                        .foregroundColor(.white)
                                    
                                    Text("BETA")
                                        .font(.custom("Poppins-Bold", size: 9))
                                        .foregroundColor(.black)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(
                                            Capsule()
                                                .fill(Color("Accent"))
                                        )
                                        .overlay(
                                            Capsule()
                                                .stroke(Color("Accent").opacity(0.3), lineWidth: 1)
                                        )
                                }
                                
                                    .font(.custom("Poppins-Regular", size: 12))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            
                            Spacer()
                        }
                    }
                }
                
                NavigationLink {
                    SettingsView()
                } label: {
                    MenuOption(icon: "settings", title: "Settings")
                }
                
                Divider().background(Color.clear)

                MenuOption(icon: "support", title: "Support").onTapGesture {
                    logger.info("📞 Support dialog requested")
                    showSupportDialog = true
                }
                
                Divider().background(Color.clear)
                
                Spacer()
                
               
                Button {
                    showLogoutAlert = true
                } label: {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red)
                        Text("log out")
                            .font(Font.custom("Poppins-Medium", size: 16))
                            .foregroundColor(.red)
                    }
                }
                .padding(.bottom, 32)
            }
            .padding(.horizontal, 24)
            .frame(width: UIScreen.main.bounds.width * 0.75, alignment: .leading)
            .frame(maxHeight: .infinity)
            .background(Color("Background"))
            .transition(.move(edge: .trailing).combined(with: .opacity))
        }
        .sheet(isPresented: $showSupportDialog) {
            SupportDialog()
        }
    }
}

struct MenuOption: View {
    let icon: String
    let title: String
    
    
    var body: some View {
        HStack(spacing: 16) {
            Image(icon)
                .foregroundColor(.white)
                .frame(width: 24)
            Text(title)
                .font(Font.custom("Poppins-Medium", size: 16))
                .foregroundColor(.white)
        }
    }
}

struct SupportDialog: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var showSimulatorAlert = false
    @State private var simulatorEmailContent = ""
    
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.vitty.app",
        category: "SupportDialog"
    )
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("Background")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                   
                    HStack {
                        Text("Get Support")
                            .font(.custom("Poppins-Bold", size: 24))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .medium))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                    
                    VStack(spacing: 32) {
                        Image(systemName: "headphones")
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.8))
                        
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Troubleshooting Steps:")
                                .font(.custom("Poppins-SemiBold", size: 18))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                troubleshootingStep(number: 1, text: "Update the app from App Store")
                                troubleshootingStep(number: 2, text: "Log out and log back in")
                                troubleshootingStep(number: 3, text: "Clear app cache (Settings > General > iPhone Storage > VITTY > Offload App)")
                            }
                        }
                        .padding(.horizontal, 20)
        
                        VStack(spacing: 20) {
                            Text("Still need help?")
                                .font(.custom("Poppins-SemiBold", size: 18))
                                .foregroundColor(.white)
                            
                            VStack(spacing: 16) {
                                Button(action: {
                                    sendSupportEmail()
                                }) {
                                    Text("Email Support")
                                        .font(.custom("Poppins-SemiBold", size: 16))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(.white.opacity(0.3), lineWidth: 1)
                                        )
                                }
                                
                                Button(action: {
                                    openGitHubIssues()
                                }) {
                                    Text("GitHub Issues")
                                        .font(.custom("Poppins-SemiBold", size: 16))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(.white.opacity(0.3), lineWidth: 1)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer()
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Close")
                                .font(.custom("Poppins-SemiBold", size: 16))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color("Accent"))
                                )
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showSimulatorAlert) {
            SimulatorEmailAlert(
                emailContent: simulatorEmailContent,
                onDismiss: {
                    showSimulatorAlert = false
                    simulatorEmailContent = ""
                }
            )
        }
    }
    
    private func troubleshootingStep(number: Int, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number).")
                .font(.custom("Poppins-Medium", size: 16))
                .foregroundColor(.white.opacity(0.8))
                .frame(width: 20, alignment: .leading)
            
            Text(text)
                .font(.custom("Poppins-Regular", size: 16))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
    }
    
    private func sendSupportEmail() {
        logger.info("📧 Sending support email")
        
        #if targetEnvironment(simulator)
        simulatorEmailContent = generateEmailContent()
        showSimulatorAlert = true
        return
        #endif
        
        let emailSubject = "VITTY iOS App - Bug Report"
        let emailBody = generateEmailContent()
        
        let encodedSubject = emailSubject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = emailBody.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        let mailtoURL = "mailto:dscvit.vitty@gmail.com?subject=\(encodedSubject)&body=\(encodedBody)"
        
        if let url = URL(string: mailtoURL) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                logger.info("SUPPORT EMAIL: Mail app opened successfully")
            } else {
                logger.error("SUPPORT EMAIL: Mail app not available")
            }
        } else {
            logger.error("SUPPORT EMAIL: Failed to create mailto URL")
        }
    }
    
    private func openGitHubIssues() {
        let githubURL = URL(string: "https://github.com/GDGVIT/vitty-ios/issues/new?template=bug_report.md")
        if let url = githubURL {
            UIApplication.shared.open(url)
        }
    }
    
    private func generateEmailContent() -> String {
        let userInfo = getUserInfo()
        let deviceInfo = getDeviceInfo()
        let appInfo = getAppInfo()
        
        return """
        Hello VITTY Support Team,

        I'm reporting a bug in the VITTY iOS app. Please find the details below:

        **User Information:**
        - Username: \(userInfo.username)
        - Full Name: \(userInfo.fullName)
        - Email: \(userInfo.email)
        - Campus: \(userInfo.campus)

        **Device Information:**
        - Device Model: \(deviceInfo.deviceModel)
        - iOS Version: \(deviceInfo.iosVersion)
        - App Version: \(appInfo.version)
        - Build Number: \(appInfo.buildNumber)
        - Device Language: \(deviceInfo.language)
        - Time Zone: \(deviceInfo.timeZone)

        **Bug Report:**

        **Describe the bug**
        A clear and concise description of what the bug is.

        **To Reproduce**
        Steps to reproduce the behavior:
        1. Go to '...'
        2. Click on '....'
        3. Scroll down to '....'
        4. See error

        **Expected behavior**
        A clear and concise description of what you expected to happen.

        **Screenshots**
        If applicable, add screenshots to help explain your problem.

        **Smartphone (please complete the following information):**
         - Device: \(deviceInfo.deviceModel)
         - OS: \(deviceInfo.iosVersion)

        **Additional context**
        Add any other context about the problem here.

        ---
        This email was generated automatically from the VITTY iOS app.
        Report submitted on: \(getCurrentDateTime())
        """
    }
    
    private func getUserInfo() -> (username: String, fullName: String, email: String, campus: String) {
        let username = authViewModel.loggedInBackendUser?.username ?? "N/A"
        let fullName = authViewModel.loggedInBackendUser?.name ?? "N/A"
        let email = authViewModel.loggedInFirebaseUser?.email ?? "N/A"
        let campus = authViewModel.loggedInBackendUser?.campus?.capitalized ?? "N/A"
        
        return (username, fullName, email, campus)
    }
    
    private func getDeviceInfo() -> (deviceModel: String, iosVersion: String, language: String, timeZone: String) {
        let device = UIDevice.current
        let deviceModel = getDeviceModel()
        let iosVersion = "\(device.systemName) \(device.systemVersion)"
        let language = Locale.current.language.languageCode?.identifier ?? "Unknown"
        let timeZone = TimeZone.current.identifier
        
        return (deviceModel, iosVersion, language, timeZone)
    }
    
    private func getDeviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        return getReadableDeviceName(from: identifier)
    }
    
    private func getReadableDeviceName(from identifier: String) -> String {
        switch identifier {
        case "iPhone8,1": return "iPhone 6s"
        case "iPhone8,2": return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3": return "iPhone 7"
        case "iPhone9,2", "iPhone9,4": return "iPhone 7 Plus"
        case "iPhone10,1", "iPhone10,4": return "iPhone 8"
        case "iPhone10,2", "iPhone10,5": return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6": return "iPhone X"
        case "iPhone11,2": return "iPhone XS"
        case "iPhone11,4", "iPhone11,6": return "iPhone XS Max"
        case "iPhone11,8": return "iPhone XR"
        case "iPhone12,1": return "iPhone 11"
        case "iPhone12,3": return "iPhone 11 Pro"
        case "iPhone12,5": return "iPhone 11 Pro Max"
        case "iPhone13,1": return "iPhone 12 mini"
        case "iPhone13,2": return "iPhone 12"
        case "iPhone13,3": return "iPhone 12 Pro"
        case "iPhone13,4": return "iPhone 12 Pro Max"
        case "iPhone14,4": return "iPhone 13 mini"
        case "iPhone14,5": return "iPhone 13"
        case "iPhone14,2": return "iPhone 13 Pro"
        case "iPhone14,3": return "iPhone 13 Pro Max"
        case "iPhone14,7": return "iPhone 14"
        case "iPhone14,8": return "iPhone 14 Plus"
        case "iPhone15,2": return "iPhone 14 Pro"
        case "iPhone15,3": return "iPhone 14 Pro Max"
        case "iPhone15,4": return "iPhone 15"
        case "iPhone15,5": return "iPhone 15 Plus"
        case "iPhone16,1": return "iPhone 15 Pro"
        case "iPhone16,2": return "iPhone 15 Pro Max"
        case "i386", "x86_64", "arm64": return "Simulator"
        default: return identifier
        }
    }
    
    private func getAppInfo() -> (version: String, buildNumber: String) {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        
        return (version, buildNumber)
    }
    
    private func getCurrentDateTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: Date())
    }
}


struct SimulatorEmailAlert: View {
    let emailContent: String
    let onDismiss: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 20) {
                HStack {
                    Image(systemName: "envelope.badge")
                        .font(.title2)
                        .foregroundColor(Color("Accent"))
                    
                    Text("Email Content (Simulator)")
                        .font(.custom("Poppins-SemiBold", size: 18))
                        .foregroundColor(Color("Text"))
                    
                    Spacer()
                    
                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(Color("Secondary"))
                    }
                }
                
                ScrollView {
                    Text(emailContent)
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundColor(Color("Text"))
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color("Secondary").opacity(0.1))
                        )
                }
                .frame(maxHeight: 300)
                
                Text("Running in simulator - Email would open in Mail app on device")
                    .font(.custom("Poppins-Regular", size: 12))
                    .foregroundColor(Color("Secondary"))
                    .multilineTextAlignment(.center)
                
                Button(action: onDismiss) {
                    Text("Got it")
                        .font(.custom("Poppins-SemiBold", size: 16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color("Accent"))
                        )
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color("Background"))
                    .stroke(Color("Accent").opacity(0.3), lineWidth: 1)
            )
            .padding(.horizontal, 30)
            .transition(.scale.combined(with: .opacity))
            
            Spacer()
        }
        .background(
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }
        )
    }
}
struct LogoutConfirmationAlert: View {
    let onCancel: () -> Void
    let onLogout: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 16) {
              
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 30))
                    .foregroundColor(.orange)
                    .padding(.top, 8)
                
                
                Text("Log Out?")
                    .font(.custom("Poppins-SemiBold", size: 18))
                    .foregroundColor(.white)
                
               
                VStack(spacing: 8) {
                    Text("Logging out will delete:")
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: "bell.slash")
                                .font(.system(size: 12))
                                .foregroundColor(.red)
                            Text("All your reminders")
                                .font(.custom("Poppins-Regular", size: 13))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        HStack {
                            Image(systemName: "doc")
                                .font(.system(size: 12))
                                .foregroundColor(.red)
                            Text("All uploaded files")
                                .font(.custom("Poppins-Regular", size: 13))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        HStack {
                            Image(systemName: "note.text")
                                .font(.system(size: 12))
                                .foregroundColor(.red)
                            Text("All your notes")
                                .font(.custom("Poppins-Regular", size: 13))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                      
                    }
                    .padding(.horizontal, 8)
                }
                
                Text("This action cannot be undone.")
                    .font(.custom("Poppins-Regular", size: 12))
                    .foregroundColor(.red)
                    .padding(.top, 4)
                
               
                HStack(spacing: 12) {
                    Button(action: onCancel) {
                        Text("Cancel")
                            .font(.custom("Poppins-Medium", size: 14))
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    Button(action: onLogout) {
                        Text("Log Out")
                            .font(.custom("Poppins-Medium", size: 14))
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding(.top, 8)
            }
            .padding(24)
            .background(Color("Background"))
            .cornerRadius(16)
            .padding(.horizontal, 30)
            .transition(.scale.combined(with: .opacity))
            Spacer()
        }
        .background(Color.black.opacity(0.5).edgesIgnoringSafeArea(.all))
    }
}
