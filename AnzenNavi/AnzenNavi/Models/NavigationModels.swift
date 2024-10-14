//
//  NavigationModels.swift
//  AnzenNavi
//
//  Created by 田中大夢 on 2024/10/14.
//

import Foundation

enum SignInDestination: Hashable {
    case phoneNumberLogin
    case verification(VerificationInfo)
}

struct VerificationInfo: Hashable {
    let verificationID: String
    let phoneNumber: String
}

