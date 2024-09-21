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
 
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
 
    var body: some Scene {
        WindowGroup {
            SplashView()
        }
    }
 
    class AppDelegate:NSObject,UIApplicationDelegate{
 
        func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
            FirebaseApp.configure()
            return true
        }
    }
}
 
