//
//  AppDelegate.swift
//  AnzenNavi
//
//  Created by 田中大夢 on 2024/10/10.
//

import UIKit
import Firebase
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Firebase の初期設定
        FirebaseApp.configure()
        // プッシュ通知の登録
        application.registerForRemoteNotifications()
        return true
    }

    // APNs トークンが取得できた場合に Firebase にセットする
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Auth.auth().setAPNSToken(deviceToken, type: .prod)
    }

    // リモート通知を受信した際に Firebase が処理するためのハンドル
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if Auth.auth().canHandleNotification(userInfo) {
            completionHandler(.noData)
            return
        }
        // 通知の内容をデバッグ用にログとして出力
        print("Received remote notification: \(userInfo)")
        completionHandler(.newData)
    }
}

