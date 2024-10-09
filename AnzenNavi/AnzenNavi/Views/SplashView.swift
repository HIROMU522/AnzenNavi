//
//  SplashView.swift
//  AnzenNavi
//
//  Created by 田中大夢 on 2024/09/21.
//

import SwiftUI
import FirebaseAuth

struct SplashView: View {
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    @AppStorage("log_Status") private var logStatus: Bool = false

    var body: some View {
        if isActive {
            if logStatus {
                MainView() // ログインしている場合は MainView へ
            } else {
                LoginView() // ログインしていない場合は LoginView へ
            }
        } else {
            VStack {
                Image("logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                    .padding()
            }
            .scaleEffect(size)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: 1.2)) {
                    self.size = 1.0
                    self.opacity = 1.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.isActive = true // 2秒後にログイン状態をチェックして遷移
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

