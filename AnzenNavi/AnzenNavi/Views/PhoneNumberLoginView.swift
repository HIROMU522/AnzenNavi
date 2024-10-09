//
//  PhoneNumberLoginView.swift
//  AnzenNavi
//
//  Created by 田中大夢 on 2024/10/09.
//

import SwiftUI
import FirebaseAuth

struct PhoneNumberLoginView: View {
    @State private var phoneNumber: String = ""
    @State private var verificationCode: String = ""
    @State private var verificationID: String?
    @State private var showVerificationCodeField: Bool = false
    @State private var errorMessage: String = ""
    @State private var showAlert: Bool = false
    @AppStorage("log_Status") private var logStatus: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            Text("電話番号でログイン")
                .font(.title)

            TextField("+81XXXXXXXXXX", text: $phoneNumber)
                .keyboardType(.phonePad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            if showVerificationCodeField {
                TextField("確認コードを入力してください", text: $verificationCode)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button("ログイン") {
                    verifyCode()
                }
                .padding()
            } else {
                Button("確認コードを送信") {
                    sendVerificationCode()
                }
                .padding()
            }
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(title: Text("エラー"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
    }

    // 確認コードを送信するメソッド
    func sendVerificationCode() {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
            if let error = error {
                errorMessage = error.localizedDescription
                showAlert = true
                return
            }
            self.verificationID = verificationID
            self.showVerificationCodeField = true
        }
    }

    // 確認コードを使ってログインするメソッド
    func verifyCode() {
        guard let verificationID = verificationID else {
            errorMessage = "確認IDが見つかりません"
            showAlert = true
            return
        }
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: verificationCode)

        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                errorMessage = error.localizedDescription
                showAlert = true
                return
            }
            // ログイン成功
            logStatus = true
        }
    }
}
