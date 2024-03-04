//
//  Usernameview.swift
//  VITTY
//
//  Created by Chandram Dutta on 05/02/24.
//

import SwiftUI

struct UsernameView: View {
	@State private var username = ""
	@State private var regNo = ""
	@State private var userNameErrorString = ""
	@State private var regNoErrorString = ""
	@State private var usernameError = true
	@State private var regNoError = true

	@State private var isLoading = false

	@Environment(AuthViewModel.self) private var authViewModel

	var body: some View {
		NavigationStack {
			ZStack {
				Image("HomeBG")
					.resizable()
					.ignoresSafeArea()
				VStack(alignment: .leading) {
					Text("Enter username and your registration number below.")
						.foregroundColor(Color.vprimary)
						.font(.footnote)
						.frame(maxWidth: .infinity, alignment: .leading)
						.onChange(of: username) { _, _ in
							checkUserExists { result in
								switch result {
									case .success(let exists):

										if exists {
											usernameError = true
										}
										else {
											usernameError = false
										}
									case .failure(_):
										userNameErrorString = "An error occurred. Please try again."
										usernameError = true
								}
							}
						}
					Text("Your username will help your friends find you!")
						.foregroundColor(Color.vprimary)
						.font(.footnote)
						.frame(maxWidth: .infinity, alignment: .leading)
						.onChange(of: regNo) { _, _ in
							let regex = #"^\d{2}[A-Za-z]{3}\d{4}$"#
							let regNoTest = NSPredicate(format: "SELF MATCHES %@", regex)
							if regNoTest.evaluate(with: regNo) {
								regNoErrorString = ""
								regNoError = false
							}
							else {
								regNoErrorString = "Please enter a valid registration number."
								regNoError = true
							}
						}
					ZStack {
						TextField("Username", text: $username)
							.padding()
					}
					.background(Color("tfBlue"))
					.cornerRadius(18)
					.padding(.top)
					Text(userNameErrorString)
						.font(.footnote)
						.foregroundStyle(.red)
					ZStack {
						TextField("Registration No.", text: $regNo)
							.padding()
					}
					.background(Color("tfBlue"))
					.cornerRadius(18)
					.padding(.top)
					Text(regNoErrorString)
						.font(.footnote)
						.foregroundStyle(.red)
					Spacer()
					Button(action: {
						Task {
							
							isLoading = true
							await authViewModel.signInServer(username: username, regNo: regNo)
							isLoading = false
						}
					}) {
						if isLoading {
							ProgressView()
								.padding(.vertical, 16)
						}
						else {
							Spacer()
							Text("Done")
								.fontWeight(.bold)
								.foregroundColor(Color.white)
								.padding(.vertical, 16)
							Spacer()
						}
					}
					.disabled(regNoError || usernameError)
					.background(Color("brightBlue"))
					.cornerRadius(18)
				}
				.padding(.horizontal)

			}
			.navigationTitle("Let's Sign You In")
		}
		.accentColor(.white)
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
		}
		catch {
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
				userNameErrorString = ""
				completion(.success(false))
			}
			else {
				do {
					let res = try JSONDecoder().decode([String: String].self, from: data)
					userNameErrorString = res["detail"]!
				}
				catch {
					completion(.success(true))
				}
				completion(.success(true))
			}
		}
		task.resume()
	}
}

#Preview {
	UsernameView()
		.preferredColorScheme(.dark)
}
