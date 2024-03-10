//
//  MainView.swift
//  AnzenNavi
//
//  Created by 田中大夢 on 2024/03/10.
//

import SwiftUI
import Firebase
import AuthenticationServices

struct SignInWithAppleButton: UIViewRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var isAuthenticated: Bool

    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        let button = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        button.addTarget(context.coordinator, action: #selector(Coordinator.handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        return button
    }

    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, isAuthenticated: $isAuthenticated)
    }
    
    class Coordinator: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
        var parent: SignInWithAppleButton
        @Binding var isAuthenticated: Bool

        init(_ parent: SignInWithAppleButton, isAuthenticated: Binding<Bool>) {
            self.parent = parent
            self._isAuthenticated = isAuthenticated
        }

        @objc func handleAuthorizationAppleIDButtonPress() {
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        }

        func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let appleIDToken = appleIDCredential.identityToken,
                  let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                return
            }

            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nil)

            Auth.auth().signIn(with: credential) { [weak self] (_, error) in
                if error == nil {
                    DispatchQueue.main.async {
                        self?.isAuthenticated = true
                    }
                }
            }
        }

        func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) else {
                fatalError("アクティブなWindowSceneが見つかりません。")
            }
            return keyWindow
        }

    }
}

struct MainView: View {
    @Binding var isAuthenticated: Bool

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.96, green: 0.86, blue: 0.52).edgesIgnoringSafeArea(.all)
                VStack {
                    Image("AppName").resizable().aspectRatio(contentMode: .fill).frame(width: 100, height: 100)
                    Image("logo").resizable().aspectRatio(contentMode: .fill).frame(width: 300, height: 300)
                    SignInWithAppleButton(isAuthenticated: $isAuthenticated)
                        .frame(width: 280, height: 45)
                        .padding()
                }
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(isAuthenticated: .constant(false))
    }
}
