//
//  UserAPIResult.swift
//  SLPProject
//
//  Created by 노건호 on 2022/01/26.
//

import Foundation

enum UserAPIResult {
    case noRegister
    case alreadyRegister
    case invalidToken
    case failDecode
    case unknownError
    case success
}
