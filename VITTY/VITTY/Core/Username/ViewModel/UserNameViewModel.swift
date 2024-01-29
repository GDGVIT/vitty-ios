//
//  UserNameViewModel.swift
//  VITTY
//
//  Created by Prashanna Rajbhandari on 20/05/2023.
//

import Foundation

class UserNameViewModel: ObservableObject {
	@Published var isFirstLogin: Bool = false
	@Published var usernameTF: String = ""
	@Published var regNoTF: String = ""

	@Published var isRegNoInvalid: Bool = false

	func isRegistrationNumberValid() -> Bool {
		let regex = try! NSRegularExpression(pattern: #"^\d{2}[A-Za-z]{3}\d{4}$"#)
		let range = NSRange(location: 0, length: regNoTF.utf16.count)
		return regex.firstMatch(in: regNoTF, options: [], range: range) != nil
	}

	func isUsernameValid(completion: @escaping (Bool) -> Void) {
		let parameters = "{\n    \"username\": \"\(usernameTF)\"\n}\n\n\n\n"
		let postData = parameters.data(using: .utf8)

		var request = URLRequest(
			url: URL(string: "\(APIConstants.base_url)/api/v2/auth/check-username")!,
			timeoutInterval: Double.infinity
		)
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")

		request.httpMethod = "POST"
		request.httpBody = postData

		let task = URLSession.shared.dataTask(with: request) { data, response, error in
			guard let data = data else {
				print(String(describing: error))
				completion(false)
				return
			}

			do {
				if let json = try JSONSerialization.jsonObject(with: data, options: [])
					as? [String: Any]
				{
					if let detail = json["detail"] as? String, detail == "Username is valid" {
						print("Username is valid")
						completion(true)
					}
					else {
						print("Username is not valid")
						completion(false)
					}
				}
			}
			catch let error {
				print("Error parsing JSON: \(error)")
				completion(false)
			}
		}

		task.resume()
	}

}
