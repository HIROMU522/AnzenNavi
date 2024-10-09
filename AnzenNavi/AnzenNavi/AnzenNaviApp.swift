//
//  AnzenNaviApp.swift
//  AnzenNavi
//
//  Created by 田中大夢 on 2024/09/21.
//
//


import SwiftUI
import Firebase

@main
struct AnzenNaviApp: App {
    // AppDelegate を SwiftUI アプリに統合
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            SplashView() // 初めに必ず SplashView を表示
        }
    }
}



