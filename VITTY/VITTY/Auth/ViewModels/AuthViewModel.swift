//
//  AuthViewModel.swift
//  VITTY
//
//  Created by Chandram Dutta on 04/02/24.
//

import AuthenticationServices
import CryptoKit
import Firebase
import FirebaseAuth
import Foundation
import GoogleSignIn

enum LoginOption {
	case googleSignIn
	case appleSignIn
}

@Observable
class AuthViewModel: NSObject, ASAuthorizationControllerDelegate {
	var loggedInFirebaseUser: User?
	var appUser: AppUser?
	var isLoading: Bool = false
	var error: NSError?
	let firebaseAuth = Auth.auth()
	fileprivate var currentNonce: String?

	override init() {
		do {
			try firebaseAuth.useUserAccessGroup(nil)
		}
		catch {
			print("Error: AuthViewModel(useUserAccessGroup)")
		}
		
		loggedInFirebaseUser = firebaseAuth.currentUser
		super.init()
		firebaseAuth.addStateDidChangeListener(authViewModelChanged)
		do {
			if UserDefaults.standard.string(forKey: UserDefaultKeys.userKey) != nil {
				signInServer(username: UserDefaults.standard.string(forKey: UserDefaultKeys.userKey) ?? "", regNo: "")
			}
		}
	}

	private func authViewModelChanged(with auth: Auth, user: User?) {
		DispatchQueue.main.async {
			guard user != self.loggedInFirebaseUser else { return }
			self.loggedInFirebaseUser = user
		}
	}

	func login(with loginOption: LoginOption) {
		isLoading = true
		error = nil

		switch loginOption {
			case .googleSignIn:
				signInWithGoogle()
			case .appleSignIn:
				signInWithApple()
		}
	}

	private func signInWithGoogle() {
		guard let clientID = FirebaseApp.app()?.options.clientID else { return }
		let config = GIDConfiguration(clientID: clientID)

		guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
			return
		}
		guard let window = screen.windows.first?.rootViewController else { return }
		GIDSignIn.sharedInstance.signIn(with: config, presenting: window) {
			[unowned self] user, error in

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

			let credential = GoogleAuthProvider.credential(
				withIDToken: idToken,
				accessToken: authentication.accessToken
			)

			firebaseAuth.signIn(with: credential, completion: authResultCompletionHandler)
		}
	}

	private func signInWithApple() {
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

	internal func authorizationController(
		controller: ASAuthorizationController,
		didCompleteWithError error: Error
	) {
		print("Error signing in with Apple: \(error.localizedDescription)")
		isLoading = false
		self.error = error as NSError
	}

	internal func authorizationController(
		controller: ASAuthorizationController,
		didCompleteWithAuthorization authorization: ASAuthorization
	) {
		if let appleIdCred = authorization.credential as? ASAuthorizationAppleIDCredential {
			guard let nonce = currentNonce else {
				fatalError(
					"Invalid state: A login callback was received but no login request was sent"
				)
			}
			guard let appleIdToken = appleIdCred.identityToken else {
				print("Unable to fetch identity token")
				return
			}
			guard let idTokenString = String(data: appleIdToken, encoding: .utf8) else {
				print(
					"Unable to serialize token string from data: \(appleIdToken.debugDescription)"
				)
				return
			}
			guard let authCode = appleIdCred.authorizationCode else {
				print("Unable to getch Authorization Code")
				return
			}
			guard String(data: authCode, encoding: .utf8) != nil else {
				print("Unable to serialize Authorization Code")
				return
			}

			let credential = OAuthProvider.credential(
				withProviderID: "apple.com",
				idToken: idTokenString,
				rawNonce: nonce
			)

			firebaseAuth.signIn(with: credential, completion: authResultCompletionHandler)
		}
		else {
			print("Error during authorization")
		}
	}

	func signOut() {
		do {
			try firebaseAuth.signOut()
			// TODO: create method to reset all UserDefaults
			UserDefaults.resetDefaults()
		}
		catch let signOutError as NSError {
			print("Error Signing Out: \(signOutError)")
		}
	}

	func signInServer(username: String, regNo: String) {
		AuthAPIService.shared.signInUser(
			with: AuthRequestBody(
				uuid: loggedInFirebaseUser?.uid ?? "",
				reg_no: regNo,
				username: username
			)
		) {
			[weak self] result in
			switch result {
				case let .success(response):
					self?.appUser = response
				case let .failure(error):
					print(error)
			}
		}
	}

	private func authResultCompletionHandler(auth: AuthDataResult?, error: Error?) {
		DispatchQueue.main.async {
			self.isLoading = false
			if let user = auth?.user {
				self.loggedInFirebaseUser = user
				let userDefaultsStandard = UserDefaults.standard
				userDefaultsStandard.set(
					user.providerID,
					forKey: UserDefaultKeys.providerIdKey
				)
				userDefaultsStandard.set(user.displayName, forKey: UserDefaultKeys.usernameKey)
				userDefaultsStandard.set(false, forKey: UserDefaultKeys.instructionsCompleteKey)
				AuthAPIService.shared.checkUserExists(with: user.uid) {
					[weak self] result in
					switch result {
						case let .success(response):
							if response {
								AuthAPIService.shared.signInUser(
									with: AuthRequestBody(uuid: user.uid, reg_no: "", username: "")
								) {
									[weak self] result in
									switch result {
										case let .success(response):
											DispatchQueue.main.async {
												self?.appUser = response
												UserDefaults.standard.set(
													self?.appUser?.token,
													forKey: UserDefaultKeys.tokenKey
												)
												UserDefaults.standard.set(
													self?.appUser?.username,
													forKey: UserDefaultKeys.userKey
												)
												UserDefaults.standard.set(
													self?.appUser?.name,
													forKey: UserDefaultKeys.nameKey
												)
												UserDefaults.standard.set(
													self?.appUser?.picture,
													forKey: UserDefaultKeys.imageKey
												)
											}
										case let .failure(error):
											print(error)
									}
								}
							}
						case let .failure(error):
							print(error)
					}
				}

			}
			else if let error = error {
				self.error = error as NSError
			}
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

extension UserDefaults {
	static func resetDefaults() {
		if let bundleID = Bundle.main.bundleIdentifier {
			UserDefaults.standard.removePersistentDomain(forName: bundleID)
		}
	}
}
