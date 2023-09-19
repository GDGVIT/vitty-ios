//
//  AuthReqBody.swift
//  VITTY
//
//  Created by Prashanna Rajbhandari on 19/09/2023.
//

import Foundation

struct AuthReqBody: Codable {
    let uuid: String
    let reg_no: String
    let username: String
}
