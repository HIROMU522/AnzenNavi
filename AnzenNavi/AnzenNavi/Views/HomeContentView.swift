//
//  HomeContentView.swift
//  AnzenNavi
//
//  Created by 田中大夢 on 2024/09/22.
//

import SwiftUI
import FirebaseAuth

struct HomeContentView: View {
    @AppStorage("log_Status") private var logStatus: Bool = true // ログイン状態を管理

    var body: some View {
        VStack {
            Text("ホーム画面のコンテンツ")
                .font(.largeTitle)
                .padding()

            // ログアウトボタン
            Button(action: {
                logOut()
            }) {
                Text("Log Out")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
            }
            .padding(.top, 20)
        }
        .edgesIgnoringSafeArea(.all)
    }

    /// ログアウト処理
    private func logOut() {
        do {
            try Auth.auth().signOut() // Firebaseからサインアウト
            logStatus = false // ログイン状態を更新し、ログイン画面に遷移
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}

struct HomeContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeContentView()
    }
}

