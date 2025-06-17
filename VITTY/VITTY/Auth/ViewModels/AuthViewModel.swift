//
//  AuthViewModel.swift
//  VITTY
//
//  Created by Chandram Dutta on 04/02/24.
//
//

import AuthenticationServices
import OSLog
import GoogleSignIn
import CryptoKit
import FirebaseAuth


enum LoginOptions {
    case googleSignIn
    case appleSignIn
}

@Observable
class AuthViewModel: NSObject, ASAuthorizationControllerDelegate {
    var loggedInFirebaseUser: User?
    var loggedInBackendUser: AppUser?
    var isLoading: Bool = false
    var isLoadingApple: Bool = false
    let firebaseAuth = Auth.auth()
    fileprivate var currentNonce: String?
    var  isLoadingGoogle: Bool = false
    
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!, category: String(describing: AuthViewModel.self)
    )
    
    override init() {
        logger.info("Initialising Auth")
        
        do {
            try firebaseAuth.useUserAccessGroup(nil)
        } catch {
            logger.error("Accessing user group keychain failed: \(error)")
        }
        
        super.init()
        
        loggedInFirebaseUser = firebaseAuth.currentUser
        firebaseAuth.addStateDidChangeListener(firebaseUserAuthUpdate)
        
        if UserDefaults.standard.string(forKey: UserDefaultKeys.tokenKey) != nil {
            logger.info("Local User Exists")
            self.loggedInBackendUser = AppUser(
                name: UserDefaults.standard.string(forKey: UserDefaultKeys.usernameKey)!,
                picture: UserDefaults.standard.string(forKey: UserDefaultKeys.pictureKey)!,
                role:  UserDefaults.standard.string(forKey: UserDefaultKeys.roleKey)!,
                token: UserDefaults.standard.string(forKey: UserDefaultKeys.tokenKey)!,
                username: UserDefaults.standard.string(forKey: UserDefaultKeys.usernameKey)!)
        }
        
        logger.info("Auth Initialisation Complete")
    }
    
    
   func signInServer(username: String, regNo: String) async {
        logger.info("Signing into server...")
        do {
            self.loggedInBackendUser = try await AuthAPIService.shared
                .signInUser(
                    with: AuthRequestBody(
                        uuid: loggedInFirebaseUser?.uid ?? "",
                        reg_no: regNo,
                        username: username
                    )
                )
        }
        catch {
            logger.error("Signing into server error: \(error)")
        }
        logger.info("Signed into server")
    }
    
    private func firebaseUserAuthUpdate(with auth: Auth, user: User?) {
        logger.info("Firebase User Auth State Updated")
        DispatchQueue.main.async {
            guard user != self.loggedInFirebaseUser else { return }
            self.loggedInFirebaseUser = user
        }
    }
    
    func login(with loginOptions: LoginOptions) async {
        logger.info("Loging In...")
        
        logger.info("Logging into Firebase...")
        do {
            switch loginOptions {
            case .googleSignIn:
                try await signInWithGoogle()
            case .appleSignIn:
                signInWithApple()
            }
        } catch {
            logger.error("Error in logging in: \(error)")
            return
        }
        logger.info("Logged Into Firebase")
        
        if (self.loggedInFirebaseUser == nil) {
            return
        }
        
        logger.info("Logging into Backend...")
        
        do {
            if (try await AuthAPIService.shared.checkUserExists(with: self.loggedInFirebaseUser!.uid)) {
                self.loggedInBackendUser = try await AuthAPIService.shared.signInUser(
                    with: AuthRequestBody(
                        uuid: self.loggedInFirebaseUser!.uid, reg_no: "", username: "")
                    )
                
                UserDefaults.standard.set(
                    loggedInBackendUser!.token,
                    forKey: UserDefaultKeys.tokenKey
                )
                UserDefaults.standard.set(
                    loggedInBackendUser!.username,
                    forKey: UserDefaultKeys.usernameKey
                )
                UserDefaults.standard.set(
                    loggedInBackendUser!.name,
                    forKey: UserDefaultKeys.nameKey
                )
                UserDefaults.standard.set(
                    loggedInBackendUser!.picture,
                    forKey: UserDefaultKeys.pictureKey
                )
                UserDefaults.standard.set(
                    loggedInBackendUser!.role,
                    forKey: UserDefaultKeys.roleKey
                )
                
                logger.debug("\(UserDefaults.standard.string(forKey: UserDefaultKeys.usernameKey)!)")
            } else {
                self.loggedInBackendUser = nil // tbh no need for this, but just to make sure
            }
        } catch {
            logger.error("Error in logging in: \(error)")
            return
        }
        
    }
    
    private func signInWithGoogle() async throws {
        logger.info("Signing in with Google...")
        
        let screen = UIApplication.shared.connectedScenes.first as! UIWindowScene
        let window = screen.windows.first!.rootViewController!
        
        let signInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: window)
        let credential = GoogleAuthProvider.credential(
            withIDToken: signInResult.user.idToken!.tokenString,
            accessToken: signInResult.user.accessToken.tokenString
        )
        
        let authDataResult = try await firebaseAuth.signIn(with: credential)
        self.loggedInFirebaseUser = authDataResult.user
        
        logger.info("Signed in with Google")
    }
    
    private func signInWithApple() {
        logger.info("Signing in with Apple...")
        
        let nonce = AppleSignInUtilties.randomNonceString()
        currentNonce = nonce
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.email, .fullName]
        request.nonce = AppleSignInUtilties.sha256(nonce)
        let authController = ASAuthorizationController(authorizationRequests: [request])
        
        authController.delegate = self
        authController.performRequests()
    }
    
    internal func authorizationController (
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        logger.error("Error signing in with Apple: \(error.localizedDescription)")
    }
    
    internal func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                logger.error("Invalid state: A login callback was received, but no login request was sent.")
                return
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                logger.error("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                logger.error("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            
            let credential = OAuthProvider.appleCredential(
                withIDToken: idTokenString,
                rawNonce: nonce,
                fullName: appleIDCredential.fullName
            )
            
            firebaseAuth.signIn(with: credential) { (authResult, error) in
                if (error != nil) {
                    self.logger.error("Error signing in with Apple to Firebase: \(error)")
                    return
                }
                self.loggedInFirebaseUser = authResult!.user
            }
        }
    }
    
    func signOut() {
        do {
            try firebaseAuth.signOut()
            UserDefaults.resetDefaults()
        }
        catch {
            logger.error("Error Signing Out: \(error)")
        }
    }
}

extension UserDefaults {
    static func resetDefaults() {
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
    }
}


private class AppleSignInUtilties {
    static func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16)
                .map { _ in
                    var random: UInt8 = 0
                    let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                    if errorCode != errSecSuccess {
                        fatalError(
                            "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                        )
                    }
                    return random
                }
            
            randoms.forEach { random in
                if length == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    static func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString =
        hashedData.compactMap {
            String(format: "%02x", $0)
        }
        .joined()
        return hashString
    }
}
