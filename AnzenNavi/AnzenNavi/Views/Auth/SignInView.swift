//
//  SignInView.swift
//  AnzenNavi
//
//  Created by 田中大夢 on 2024/10/09.
//

import SwiftUI
import AuthenticationServices
import Firebase
import FirebaseAuth
import CryptoKit

struct SignInView: View {
    @State private var errorMessage: String = ""
    @State private var showAlert: Bool = false
    @State private var isLoading: Bool = false
    @State private var nonce: String?
    @Environment(\.colorScheme) private var scheme
    @AppStorage("log_Status") private var logStatus: Bool = false
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack(alignment: .bottom) {
                backgroundImage
                    .mask(maskGradient)
                    .ignoresSafeArea()
                
                VStack(alignment: .leading) {
                    Spacer()
                    headerText
                    appleSignInButton
                    phoneNumberSignInButton // 既存の VStack 内に保持
                }
                .padding(20)
            }
            .alert(errorMessage, isPresented: $showAlert) { }
            .overlay {
                if isLoading {
                    LoadingScreen()
                }
            }
            .navigationDestination(for: SignInDestination.self) { destination in
                switch destination {
                case .phoneNumberLogin:
                    PhoneNumberLoginView(navigationPath: $navigationPath)
                case .verification(let info):
                    VerificationCodeView(verificationID: info.verificationID, phoneNumber: info.phoneNumber)
                }
            }
        }
    }
    
    // MARK: - View Components
    
    private var backgroundImage: some View {
        GeometryReader { geometry in
            Image("BG") // 画像名が "BG" であることを確認
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
    
    private var maskGradient: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        .white,
                        .white,
                        .white,
                        .white,
                        .white.opacity(0.9),
                        .white.opacity(0.6),
                        .white.opacity(0.2),
                        .clear,
                        .clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
    }
    
    private var headerText: some View {
        Text("Sign in to start  \npreparing for evacuations")
            .font(.title.bold())
    }
    
    private var appleSignInButton: some View {
        SignInWithAppleButton(.signIn, onRequest: handleAppleSignInRequest, onCompletion: handleAppleSignInCompletion)
            .overlay(
                AppleButtonOverlay(scheme: scheme)
            )
            .frame(height: 45)
            .clipShape(Capsule())
            .padding(.top, 10)
    }
    
    private var phoneNumberSignInButton: some View {
        Button(action: {
            navigationPath.append(SignInDestination.phoneNumberLogin)
        }) {
            Text("Sign in with Phone Number")
                .foregroundStyle(Color.primary)
                .frame(height: 40)
                .frame(maxWidth: .infinity)
                .contentShape(Capsule())
                .background {
                    Capsule()
                        .stroke(Color.primary, lineWidth: 0.5)
                }
        }
        .padding(.top, 10)
    }
    
    // MARK: - Helper Views
    
    @ViewBuilder
    private func LoadingScreen() -> some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
            
            ProgressView()
                .frame(width: 45, height: 45)
                .background(.background, in: RoundedRectangle(cornerRadius: 5))
        }
    }
    
    // MARK: - Helper Methods
    
    private func handleAppleSignInRequest(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = randomNonceString()
        self.nonce = nonce
        request.requestedScopes = [.email, .fullName]
        request.nonce = sha256(nonce)
    }
    
    private func handleAppleSignInCompletion(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            loginWithFirebase(authorization)
        case .failure(let error):
            showError(error.localizedDescription)
        }
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        showAlert.toggle()
        isLoading = false
    }
    
    private func loginWithFirebase(_ authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            showError("Invalid credentials")
            return
        }
        
        guard let nonce = self.nonce else {
            showError("Missing nonce")
            return
        }
        
        guard let appleIDToken = appleIDCredential.identityToken else {
            showError("Missing identity token")
            return
        }
        
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            showError("Invalid identity token")
            return
        }
        
        isLoading = true
        
        let credential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: nonce,
            fullName: appleIDCredential.fullName
        )
        
        Auth.auth().signIn(with: credential) { authResult, error in
            DispatchQueue.main.async {
                if let error = error {
                    showError(error.localizedDescription)
                } else {
                    logStatus = true
                    isLoading = false
                }
            }
        }
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }
        return String(nonce)
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - AppleButtonOverlay

struct AppleButtonOverlay: View {
    let scheme: ColorScheme
    
    var body: some View {
        ZStack {
            Capsule()
            HStack {
                Image(systemName: "applelogo")
                Text("Sign in with Apple")
            }
            .foregroundStyle(scheme == .dark ? .black : .white)
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Previews

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}

