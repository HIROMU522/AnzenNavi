//
//  NavigationModels.swift
//  AnzenNavi
//
//  Created by 田中大夢 on 2024/10/14.
//

import Foundation

// ナビゲーション先を管理する列挙型
enum SignInDestination: Hashable {
    case phoneNumberLogin
    case verification(VerificationInfo)
}

// 検証コード入力画面に必要な情報を保持する構造体
struct VerificationInfo: Hashable {
    let verificationID: String
    let phoneNumber: String
}

