//
//  AnzenNaviApp.swift
//  AnzenNavi
//
//  Created by 田中大夢 on 2024/09/21.
//

import SwiftUI
import Firebase

@main
struct AnzenNaviApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @AppStorage("log_Status") private var logStatus: Bool = false

    var body: some Scene {
        WindowGroup {
            if logStatus {
                MainView()
            } else {
                SignInView()  
            }
        }
    }
}



