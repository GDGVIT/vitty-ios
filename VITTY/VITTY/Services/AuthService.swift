//
//  AuthService.swift
//  VITTY
//
//  Created by Ananya George on 1/3/22.
//

import AuthenticationServices
import Combine
import CryptoKit
import Firebase
import FirebaseAuth
import GoogleSignIn
import SwiftUI

enum LoginOption {
    case googleSignin
    case appleSignin
}

class AuthService: NSObject, ObservableObject {
    @Published var loggedInUser: User?
    @Published var isAuthenticating: Bool = false
    @Published var error: NSError?
    @Published var onboardingComplete: Bool = false

    @Published var myUser: AuthResponse?

//    static let shared = AuthService()

    let auth = Auth.auth()
    fileprivate var currentNonce: String?

    // MARK: UserDefault keys

    static let providerIdKey = "providerId"
    static let usernameKey = "userName"
    static let useremailKey = "userEmail"
    static let instructionsCompleteKey = "instructionsComplete"
    static let notifsSetupKey = "notifsSetupKey"

    override init() {
        do {
            // try Auth.auth().useUserAccessGroup(AppConstants.VITTYappgroup)
            try Auth.auth().useUserAccessGroup("122580500.com.gdscvit.vittyios")

        } catch let error as NSError {
            print("Error changing user access group: %@", error.localizedDescription)
        }
        loggedInUser = auth.currentUser
        super.init()

        auth.addStateDidChangeListener(authStateChanged)
    }

    private func authStateChanged(with auth: Auth, user: User?) {
        guard user != loggedInUser else { return }
        loggedInUser = user
    }

    func login(with loginOption: LoginOption) {
        isAuthenticating = true
        error = nil

        switch loginOption {
        case .googleSignin:
            signInWithGoogle()
        case .appleSignin:
            // signInWithApple()
            print("apple")
        }
    }

    // MARK: Google Sign in

    private func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)

        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        guard let window = screen.windows.first?.rootViewController else { return }
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(with: config, presenting: window) { [unowned self] user, error in

            if let error = error {
                print("Error: Couldn't authenticate with Google - \(error.localizedDescription)")
                return
            }

            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
            else {
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: authentication.accessToken)

            //MARK: temp api impl
            API.shared.signInUser(with: AuthReqBody(uuid: "x1ggyeMYVQaG0oOmz8jmTRuiuhw1", reg_no: "21TES3760", username: "PrashannaTest")) { [weak self] result in
                switch result {
                case let .success(response):
                    // print(respose)
                    DispatchQueue.main.async {
                        self?.myUser = response
                        print("token from the server")
                        print(self?.myUser?.token ?? "no token")
                        let mUser = self?.myUser
                        API.shared.getUser(token: mUser?.token ?? "", username: mUser?.username ?? "")
                        API.shared.getFriends(token: mUser?.token ?? "", username: mUser?.username ?? "")
                        
                    }
                case let .failure(error):
                    print(error)
                }
            }
            API.shared.checkUsername(with: "PrashannaTest")

            print("Google credential created. Proceeding to sign in with Firebase")
            Auth.auth().signIn(with: credential, completion: authResultCompletionHandler)
        }
    }

    private func authResultCompletionHandler(auth: AuthDataResult?, error: Error?) {
        DispatchQueue.main.async {
            self.isAuthenticating = false
            if let user = auth?.user {
                self.loggedInUser = user
                UserDefaults.standard.set(user.providerData[0].providerID, forKey: AuthService.providerIdKey)
                UserDefaults.standard.set(user.displayName, forKey: AuthService.usernameKey)
                UserDefaults.standard.set(user.email, forKey: AuthService.useremailKey)
                UserDefaults.standard.set(false, forKey: AuthService.instructionsCompleteKey)
                UserDefaults.standard.set(false, forKey: AuthService.notifsSetupKey)
                print("signed in!")
                print("uid: ", user.uid)
                print("Name: \(UserDefaults.standard.string(forKey: AuthService.usernameKey) ?? "uname")")
                print("ProviderId: \(UserDefaults.standard.string(forKey: AuthService.providerIdKey) ?? "provider")")
                print("Email: \(UserDefaults.standard.string(forKey: AuthService.useremailKey) ?? "email")")

            } else if let error = error {
                self.error = error as NSError
            }
        }
    }

    func signOut() {
        do {
            try auth.signOut()
            // TODO: create method to reset all UserDefaults
            UserDefaults.resetDefaults()
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError)")
        }
    }
}

// MARK: Apple Sign in

extension AuthService: ASAuthorizationControllerDelegate {
    private func signInWithApple() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.email, .fullName]
        request.nonce = sha256(nonce)

        let authController = ASAuthorizationController(authorizationRequests: [request])
        authController.delegate = self
        authController.performRequests()
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Error signing in with Apple: \(error.localizedDescription)")
        isAuthenticating = false
        self.error = error as NSError
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        print("Apple Sign in")

        if let appleIdCred = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received but no login request was sent")
            }
            guard let appleIdToken = appleIdCred.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIdToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIdToken.debugDescription)")
                return
            }
            guard let authCode = appleIdCred.authorizationCode else {
                print("Unable to getch Authorization Code")
                return
            }
            guard let authCodeString = String(data: authCode, encoding: .utf8) else {
                print("Unable to serialize Authorization Code")
                return
            }

            print(authCodeString)

            // Initializing Firebase credential
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)

            // Sign in with Firebase
            Auth.auth().signIn(with: credential, completion: authResultCompletionHandler)
        } else {
            print("Error during authorization")
        }
    }

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
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

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        return hashString
    }
}

extension UserDefaults {
    static func resetDefaults() {
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
    }
}
