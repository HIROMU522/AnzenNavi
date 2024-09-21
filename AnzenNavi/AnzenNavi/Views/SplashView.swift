//
//  SplashView.swift
//  AnzenNavi
//
//  Created by 田中大夢 on 2024/09/21.
//

import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5

    var body: some View {
        if isActive {
            // メイン画面に遷移する
            MainView()  // メイン画面に切り替えるView
        } else {
            // スプラッシュ画面
            VStack {
                Image("logo")  // Assets.xcassetsに追加したロゴを表示
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)  // ロゴのサイズを調整
                    .padding()
            }
            .scaleEffect(size)
            .opacity(opacity)
            .onAppear {
                // アニメーション
                withAnimation(.easeIn(duration: 1.2)) {
                    self.size = 1.0
                    self.opacity = 1.0
                }
                // 2秒後にメイン画面に遷移
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.isActive = true
                }
            }
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}

