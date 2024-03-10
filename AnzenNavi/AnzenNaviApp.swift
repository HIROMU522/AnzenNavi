//
//  AnzenNaviApp.swift
//  AnzenNavi
//
//  Created by 田中大夢 on 2024/03/10.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

enum AppState {
    case loading
    case authenticated
    case notAuthenticated
}

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

class AuthenticationViewModel: ObservableObject {
    @Published var appState = AppState.loading
    
    init() {
        self.authenticate()
    }
    
    private func authenticate() {
        // Firebase Authenticationの状態を監視
        Auth.auth().addStateDidChangeListener { [weak self] (_, user) in
            // 最低1秒間はロード画面
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self?.appState = user != nil ? .authenticated : .notAuthenticated
            }
        }
    }
}

@main
struct AnzenNaviApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var viewModel = AuthenticationViewModel()

    var body: some Scene {
        WindowGroup {
            switch viewModel.appState {
            case .loading:
                LoadView()
            case .authenticated:
                ContentView()
            case .notAuthenticated:
                MainView(isAuthenticated: .constant(false))
            }
        }
    }
}
